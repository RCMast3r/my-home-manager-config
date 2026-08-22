#!/usr/bin/env bash
# Apply this repo's configuration to this machine, in one command.
#
#   ./update.sh                  activate the configuration as it is on disk
#   ./update.sh --update-inputs  bump flake.lock first, then activate
#
# Two independent generations get activated:
#   home-manager    user packages, dotfiles, shell aliases   (no root)
#   system-manager  /run/opengl-driver graphics drivers      (needs root)

set -euo pipefail

# Operate on the flake beside this script, whatever the caller's cwd is.
cd "$(dirname "$(readlink -f "$0")")"

HM_USER="ben"
SYSTEM="x86_64-linux"   # must match `system` in flake.nix

if [[ "${1:-}" == "--update-inputs" ]]; then
    echo "==> Updating flake inputs"
    nix flake update
elif [[ -n "${1:-}" ]]; then
    echo "unknown argument: $1" >&2
    echo "usage: $0 [--update-inputs]" >&2
    exit 64
fi

# This is a working repo that gets rebuilt from a dirty tree constantly, so the
# "Git tree ... is dirty" warning is noise rather than news. --no-warn-dirty
# covers our own nix calls; system-manager makes its own, hence --nix-option.
NIX_FLAGS=(--no-warn-dirty)
SM_FLAGS=(--nix-option warn-dirty false)

# Build everything before activating anything, so an evaluation error fails
# the run outright instead of leaving the machine half-updated.
echo "==> Building home-manager generation"
nix build ".#homeConfigurations.${HM_USER}.activationPackage" --out-link result "${NIX_FLAGS[@]}"

echo "==> Building system graphics configuration"
nix build ".#systemConfigs.${SYSTEM}.default" --no-link "${NIX_FLAGS[@]}"
system_manager="$(nix build '.#system-manager' --no-link --print-out-paths "${NIX_FLAGS[@]}")"

echo "==> Activating home-manager generation"
./result/activate

# Populates /run/opengl-driver so Nix-built GUI apps find the Mesa DRI drivers
# instead of falling back to the SwiftShader CPU rasterizer. Prompts for the
# sudo password; use --ask-sudo-password instead of --sudo if that prompt ever
# gets swallowed when running non-interactively.
#
# Name the attribute explicitly. Given a bare '.', system-manager probes
# systemConfigs.<system>.<hostname>, .<hostname> and .<system>.default in turn,
# spending a nix eval on each and logging the misses before it lands on
# .default.
echo "==> Activating system graphics (requires root)"
"${system_manager}/bin/system-manager" switch --flake '.#default' --sudo "${SM_FLAGS[@]}"

# This script used to mirror ~/.nix-profile/share into ~/.local/share by hand.
# targets.genericLinux now puts the profile on XDG_DATA_DIRS instead, so GNOME
# reads desktop entries and icons straight out of the profile. Sweep up the
# leftovers: the old loop only ever created links, so every package dropped
# from packages.nix left a dead launcher behind in the app grid.
#
# Deliberately narrow: only symlinks, only ones resolving into the Nix profile.
# Real files and links to anything else (RPM, Flatpak, hand-made) are untouched.
echo "==> Removing leftover desktop/icon symlinks into the Nix profile"
removed=0
for dir in "${HOME}/.local/share/applications" "${HOME}/.local/share/icons"; do
    [ -d "$dir" ] || continue
    while IFS= read -r link; do
        echo "    $(basename "$link")"
        rm -f "$link"
        removed=$((removed + 1))
    done < <(find "$dir" -maxdepth 1 -type l -lname '*nix-profile*')
done
if [ "$removed" -eq 0 ]; then
    echo "    none left to remove"
fi

echo "==> Done."
echo
echo "Note: XDG_DATA_DIRS is applied at session start, so log out and back in"
echo "for GNOME to pick up desktop entries directly from the Nix profile."
