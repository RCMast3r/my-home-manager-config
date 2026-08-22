#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/Downloads"
DOWNLOAD_URL="https://get.foxglove.dev/desktop/latest/foxglove-studio-latest-linux-amd64.deb"
FORCE="${FORCE:-0}"

# Read the version out of the .deb control file (works on a truncated download too,
# since control.tar.* always precedes data.tar.* in the ar archive).
deb_version() {
    local deb="$1" member
    member=$(ar t "${deb}" 2>/dev/null | grep '^control\.tar' | head -1)
    [[ -n "${member}" ]] || return 1
    # tar can't sniff compression on a non-seekable pipe, so pick it by extension
    local taropt
    case "${member}" in
        *.gz)  taropt=-z ;;
        *.xz)  taropt=-J ;;
        *.zst) taropt=--zstd ;;
        *)     taropt= ;;
    esac
    ar p "${deb}" "${member}" 2>/dev/null | tar ${taropt} -xO ./control 2>/dev/null \
        | awk '/^Version:/{print $2; exit}'
}

mkdir -p "${WORKDIR}"

# Peek at the first chunk of the remote .deb to learn the latest version without
# pulling down the whole ~100MB payload.
echo "Checking latest Foxglove Studio version..."
PEEK_FILE="${WORKDIR}/.foxglove-peek.deb"
curl -sfL --range 0-262143 -o "${PEEK_FILE}" "${DOWNLOAD_URL}"
VERSION=$(deb_version "${PEEK_FILE}" || true)
rm -f "${PEEK_FILE}"
if [[ -z "${VERSION}" ]]; then
    echo "ERROR: Could not determine latest version from ${DOWNLOAD_URL}" >&2
    exit 1
fi
echo "Latest version: ${VERSION}"

INSTALLED=$(rpm -q --qf '%{VERSION}' foxglove-studio 2>/dev/null || true)
if [[ "${INSTALLED}" == "${VERSION}" && "${FORCE}" != "1" ]]; then
    echo "foxglove-studio ${VERSION} is already installed. Set FORCE=1 to rebuild."
    exit 0
fi
if [[ -n "${INSTALLED}" ]]; then
    echo "Installed version: ${INSTALLED}"
fi

DEB_FILE="${WORKDIR}/foxglove-studio-${VERSION}-linux-amd64.deb"

# Download latest .deb
echo "Downloading Foxglove Studio ${VERSION} .deb..."
wget -q --show-progress -O "${DEB_FILE}" "${DOWNLOAD_URL}"

# Sanity check that we got the version we peeked at
GOT_VERSION=$(deb_version "${DEB_FILE}" || true)
if [[ "${GOT_VERSION}" != "${VERSION}" ]]; then
    echo "ERROR: downloaded .deb is version '${GOT_VERSION}', expected '${VERSION}'" >&2
    exit 1
fi

# Clean up every previous build tree and RPM, so the lookups below can only ever
# find what this run produces
for stale in "${WORKDIR}"/foxglove-studio-*/ "${WORKDIR}"/foxglove-studio-*.orig; do
    if [[ -d "${stale}" ]]; then
        echo "Removing old build directory: ${stale}"
        rm -rf "${stale}"
    fi
done
rm -f "${WORKDIR}"/foxglove-studio-*.rpm

# Generate RPM build tree from .deb (fakeroot so files end up owned by root)
echo "Generating RPM spec from .deb..."
cd "${WORKDIR}"
fakeroot alien -r -g "${DEB_FILE}" 2>&1

SPEC_DIR="${WORKDIR}/foxglove-studio-${VERSION}"
SPEC_FILE=$(echo "${SPEC_DIR}"/foxglove-studio-${VERSION}-*.spec)
if [[ ! -f "${SPEC_FILE}" ]]; then
    echo "ERROR: Could not find generated .spec file for ${VERSION}" >&2
    exit 1
fi
echo "Found spec: ${SPEC_FILE}"

# Fix empty Summary tag
sed -i 's/^Summary: *$/Summary: Foxglove Studio/' "${SPEC_FILE}"

# chrome-sandbox needs to stay setuid root for the Electron sandbox
sed -i 's|^"/opt/Foxglove/chrome-sandbox"$|%attr(4755,root,root) "/opt/Foxglove/chrome-sandbox"|' "${SPEC_FILE}"

# alien drops the .deb maintainer scripts. Most of what they do is apt repo and
# AppArmor setup that is meaningless here; the parts worth keeping are the
# /usr/bin symlink and the mime/desktop database refresh.
awk '
/^%files$/ && !inserted {
    print "%post"
    print "ln -sf /opt/Foxglove/foxglove-studio /usr/bin/foxglove-studio"
    print "update-mime-database /usr/share/mime >/dev/null 2>&1 || :"
    print "update-desktop-database /usr/share/applications >/dev/null 2>&1 || :"
    print ""
    print "%postun"
    print "if [ \"$1\" -eq 0 ]; then"
    print "    rm -f /usr/bin/foxglove-studio"
    print "    update-mime-database /usr/share/mime >/dev/null 2>&1 || :"
    print "    update-desktop-database /usr/share/applications >/dev/null 2>&1 || :"
    print "fi"
    print ""
    inserted = 1
}
{ print }
' "${SPEC_FILE}" > "${SPEC_FILE}.new" && mv "${SPEC_FILE}.new" "${SPEC_FILE}"

# Build the RPM
echo "Building RPM..."
cd "${SPEC_DIR}"
rpmbuild --buildroot="$(pwd)" -bb --target x86_64 "${SPEC_FILE}" 2>&1

RPM_FILE=$(echo "${WORKDIR}"/foxglove-studio-${VERSION}-*.x86_64.rpm)
if [[ ! -f "${RPM_FILE}" ]]; then
    echo "ERROR: RPM file not found after build" >&2
    exit 1
fi
echo "Built: ${RPM_FILE}"

# Install, replacing whatever version is currently there in one transaction.
# -U installs when nothing is present and upgrades otherwise; --replacefiles
# covers the files alien lists as owned by "/" and other shared directories.
echo "Installing ${RPM_FILE}..."
sudo rpm -Uvh --replacefiles "${RPM_FILE}"

echo "Done. Installed foxglove-studio $(rpm -q --qf '%{VERSION}' foxglove-studio). Run: foxglove-studio"
