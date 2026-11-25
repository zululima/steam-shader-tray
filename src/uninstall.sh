#!/bin/sh
# SPDX-License-Identifier: AGPL-3.0-or-later
# Stops steam-shader-tray and removes what install.sh added. With --keep-state
# it keeps what the tray learned from Steam's logs, the pause list and the
# Steam setting.
set -eu
steam_dev="$HOME/.local/share/Steam/steam_dev.cfg"
pid=$(gdbus call --session --dest org.freedesktop.DBus \
  --object-path /org/freedesktop/DBus \
  --method org.freedesktop.DBus.GetConnectionUnixProcessID \
  local.SteamShaderTray 2>/dev/null | sed -n 's/^(uint32 \([0-9]*\),)$/\1/p') || true
if [ -n "$pid" ]; then
  kill "$pid"
fi
rm -f "$HOME/.local/bin/steam-shader-tray"
rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/steam-shader-tray"
rm -f "${XDG_CONFIG_HOME:-$HOME/.config}/autostart/steam-shader-tray.desktop"
if [ "${1:-}" != "--keep-state" ]; then
  rm -rf "${XDG_STATE_HOME:-$HOME/.local/state}/steam-shader-tray"
  rm -rf "${XDG_CONFIG_HOME:-$HOME/.config}/steam-shader-tray"
  if [ -e "$steam_dev" ]; then
    sed -i '/^bShaderAlwaysProcessWhenRunningGame /d' "$steam_dev"
  fi
  echo "steam-shader-tray removed"
fi
