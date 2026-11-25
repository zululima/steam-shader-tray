#!/bin/sh
# SPDX-License-Identifier: AGPL-3.0-or-later
# Installs steam-shader-tray for the current user, starts it at login and now.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
bin="$HOME/.local/bin"
data="${XDG_DATA_HOME:-$HOME/.local/share}/steam-shader-tray"
config="${XDG_CONFIG_HOME:-$HOME/.config}/steam-shader-tray"
autostart="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
steam_dev="$HOME/.local/share/Steam/steam_dev.cfg"

"$here/uninstall.sh" --keep-state
install -Dm755 "$here/steam-shader-tray" "$bin/steam-shader-tray"
install -Dm644 -t "$data/icons" "$here"/icons/*.svg
if [ ! -e "$config/pause-during" ]; then
  mkdir -p "$config"
  cat > "$config/pause-during" <<'LIST'
# Steam app IDs of the games during which steam-shader-tray pauses Steam's
# shader processing, one per line. Text after an ID is ignored.
730 Counter-Strike 2
LIST
fi
if ! grep -qs '^bShaderAlwaysProcessWhenRunningGame ' "$steam_dev"; then
  if [ -s "$steam_dev" ] && [ -n "$(tail -c 1 "$steam_dev")" ]; then
    echo >> "$steam_dev"
  fi
  echo 'bShaderAlwaysProcessWhenRunningGame 1' >> "$steam_dev"
  echo "Steam keeps processing shaders during games once it restarts"
fi
mkdir -p "$autostart"
cat > "$autostart/steam-shader-tray.desktop" <<DESKTOP
[Desktop Entry]
Type=Application
Name=Steam shader tray icon
Comment=Shows when Steam processes shaders, so Play is not pressed too early
Exec=$bin/steam-shader-tray
Icon=$data/icons/steam-shader-tray-busy.svg
Terminal=false
X-KDE-autostart-phase=2
DESKTOP
setsid -f "$bin/steam-shader-tray" >/dev/null 2>&1
echo "steam-shader-tray installed and started"
