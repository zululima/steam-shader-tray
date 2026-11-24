# steam-shader-tray

A tray icon for Linux that shows whether Steam still has Vulkan shaders to
process, so you can tell before pressing Play whether Steam will make you wait
on its "Processing Vulkan shaders" dialog.

Steam processes a game's shaders in the background after the game installs or
gets new shader data. Pressing Play before that is done stops the background
pass and runs the rest in the dialog. Starting another game from Steam stops
the background pass too, and the icon then tells you the work is still left.

| Icon | Shown when | Tooltip |
| --- | --- | --- |
| <img src="icons/steam-shader-tray-busy.svg" width="22" alt="Hourglass"> | Steam is processing shaders | Each game with Steam's progress figures |
| <img src="icons/steam-shader-tray-paused.svg" width="22" alt="Pause"> | A game has shaders left but nothing processes them | Each game with the last progress figures |
| <img src="icons/steam-shader-tray-idle.svg" width="22" alt="Check mark"> | No game has shaders left | That no game has shaders left |

KDE Plasma puts the check mark among the tray's hidden icons.

## Requirements

- Steam installed natively, in `~/.local/share/Steam`. The Flatpak is not
  supported.
- Python 3 with PyGObject, and GdkPixbuf that loads SVG. On Arch Linux these
  are the packages `python-gobject` and `gdk-pixbuf2`.
- A tray that shows StatusNotifierItem icons, such as KDE Plasma's.

Tested on KDE Plasma 6.8 on CachyOS.

## Install

The script installs the tray for your user, adds it to the programs that start
at login and starts it.

```bash
git clone https://github.com/zululima/steam-shader-tray.git && \
  steam-shader-tray/install.sh
```

## Uninstall

```bash
~/steam-shader-tray/uninstall.sh
```

## How it works

Every 5 seconds the tray looks for `fossilize_replay`, the program Steam
processes shaders with, and reads the new lines of Steam's
`logs/shader_log.txt`:

- New shader data for a game, or a pass that starts, marks the game
  unfinished.
- A pass that completes marks the game done.
- A pass Steam stops ends without a completion, so the game stays unfinished.

What it has read is kept in `~/.local/state/steam-shader-tray/state.json`,
since Steam starts a new log once the old one reaches 4 MB. On its first start
the tray knows only what Steam's current and previous logs hold.

The tray depends on the program name and the log lines above, which a Steam
update can change.

## License

The code is licensed under the GNU Affero General Public License, version 3
or later, in [LICENSE](LICENSE). The README and the icons are licensed under
CC BY-SA 4.0, in [LICENSE-PROSE](LICENSE-PROSE).
