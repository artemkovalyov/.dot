# XKB keyboard config

Custom modifier layout for KDE Wayland.

## Layout (`symbols/art-mods`)

| Key | Action |
|-----|--------|
| CapsLock | Hyper (Mod3) |
| Shift+CapsLock | Switch input group (language) |
| LWin | Meta (Mod2) |
| LAlt | Alt (Mod1) |
| RAlt | Super |
| RCtrl | Multi_key / ISO Level3 Shift |

## Install

```bash
./xkb-config.sh        # install (skips existing files)
./xkb-config.sh -f     # overwrite existing files
```

Installs to:
- `~/.config/xkb/` — XKB symbols and rules (picked up by libxkbcommon)
- `~/.config/kxkbrc` — KDE keyboard settings (`Options=art-mods`, layouts: us/ru/ua)

Log out and back in to apply.
