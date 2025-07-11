#!/usr/bin/env bash
set -euo pipefail

# List of Hangover packages (update as needed)
PACKAGES=(
  hangover-libarm64ecfex
  hangover-libwow64fex
  hangover-wowbox64
  hangover-wine
)

# Recommended packages for better compatibility
RECOMMENDED_PACKAGES=(
  libglu1-mesa
  libglu1
  libodbc1
  libsdl2-2.0-0
)

# Helper functions
error() {
  echo -e "\033[31mERROR: $1\033[0m" >&2
  exit 1
}

info() {
  echo -e "\033[32mINFO: $1\033[0m"
}

# Extract function definitions for reuse
ERROR_FUNC=$(declare -f error)
INFO_FUNC=$(declare -f info)

# kill any running Wine processes
pkill -9 wine 2>/dev/null || true
command -v wineserver >/dev/null && wineserver -k 2>/dev/null || true

# remove the helper
info "Removing terminal commands..."
sudo rm -f /usr/local/bin/generate-hangover-prefix || error "Failed to remove generate-hangover-prefix"
info "Done"

# clear Wine mime/app entries
info "Removing mimetypes..."
# see: https://askubuntu.com/a/400430
rm -f ~/.local/share/mime/packages/x-wine*
rm -f ~/.local/share/applications/wine-extension*
rm -f ~/.local/share/icons/hicolor/*/*/application-x-wine-extension*
rm -f ~/.local/share/mime/application/x-wine-extension*
info "Done"

# purge the Hangover packages
info "Purging Hangover packages..."
for pkg in "${PACKAGES[@]}"; do
  sudo apt purge -y "${pkg}"* || true
done
info "Done"

# purge recommended packages
info "Purging recommended packages..."
for pkg in "${RECOMMENDED_PACKAGES[@]}"; do
  sudo apt purge -y "$pkg" || info "Package $pkg was not installed or failed to remove (this is usually fine)"
done
info "Done"

# remove orphaned dependencies
info "Removing orphaned dependencies..."
sudo apt autoremove --purge -y || true
info "Done"

# warn about remaining Wine prefix
if [ -d "$HOME/.wine" ]; then
  info "You just uninstalled the Hangover app, but it's not completely gone yet."
  info "To prevent data loss, your Wine configuration is still located in:"
  info "  $HOME/.wine"
  info "Feel free to delete or rename that folder to free up space or troubleshoot."
fi

true