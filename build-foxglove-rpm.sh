#!/bin/bash
set -euo pipefail

WORKDIR="${HOME}/Downloads"
DEB_FILE="${WORKDIR}/foxglove-studio-latest-linux-amd64.deb"
DOWNLOAD_URL="https://github.com/foxglove/studio/releases/latest/download/foxglove-studio-latest-linux-amd64.deb"

# Download latest .deb
echo "Downloading latest Foxglove Studio .deb..."
wget -q --show-progress -O "${DEB_FILE}" "${DOWNLOAD_URL}"

# Clean up any previous build directory
BUILD_DIR=$(find "${WORKDIR}" -maxdepth 1 -type d -name "foxglove-studio-*" 2>/dev/null | head -1)
if [[ -n "${BUILD_DIR}" ]]; then
    echo "Removing old build directory: ${BUILD_DIR}"
    rm -rf "${BUILD_DIR}"
fi

# Generate RPM build tree from .deb
echo "Generating RPM spec from .deb..."
cd "${WORKDIR}"
alien -r -g "${DEB_FILE}" 2>&1

# Find the generated spec file
SPEC_FILE=$(find "${WORKDIR}" -maxdepth 2 -name "*.spec" | head -1)
if [[ -z "${SPEC_FILE}" ]]; then
    echo "ERROR: Could not find generated .spec file" >&2
    exit 1
fi
echo "Found spec: ${SPEC_FILE}"

# Fix empty Summary tag
sed -i 's/^Summary: *$/Summary: Foxglove Studio/' "${SPEC_FILE}"

# Build the RPM
SPEC_DIR=$(dirname "${SPEC_FILE}")
echo "Building RPM..."
cd "${SPEC_DIR}"
rpmbuild --buildroot="$(pwd)" -bb --target x86_64 "${SPEC_FILE}" 2>&1

RPM_FILE=$(find "${WORKDIR}" -maxdepth 1 -name "foxglove-studio-*.rpm" | head -1)
if [[ -z "${RPM_FILE}" ]]; then
    echo "ERROR: RPM file not found after build" >&2
    exit 1
fi
echo "Built: ${RPM_FILE}"

# Install (remove old version first if present)
if rpm -q foxglove-studio &>/dev/null; then
    echo "Removing existing installation..."
    sudo rpm -e foxglove-studio
fi

echo "Installing ${RPM_FILE}..."
sudo rpm -i "${RPM_FILE}"

echo "Done. Run: /opt/Foxglove/foxglove-studio"
