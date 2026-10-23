# Emacs patches

Local patches to Emacs source for the pgtk (Wayland) build.

## Patches

### `0001-pgtk-split-GDK_MOD1_MASK-and-GDK_META_MASK-modifier-.patch`

Fixes modifier handling in `pgtkterm.c` so Alt (Mod1) and Meta (Mod2)
are distinct Emacs modifiers on pgtk/Wayland.

**Problem:** pgtk mapped both `GDK_MOD1_MASK` (Alt_L) and `GDK_META_MASK`
to `mod_meta`, making it impossible to use `A-` bindings separately from
`M-`. Custom XKB layouts that place Meta_L on Mod2 (LWin) were also broken.

**Fix:** Split the two masks so `GDK_MOD1_MASK` → `mod_alt` and
`GDK_META_MASK` + `GDK_MOD2_MASK` → `mod_meta`.

Pairs with `~/.config/xkb/symbols/art-mods` (see `~/.dot/xkb/`).

## Apply

```bash
cd ~/dev/emacs
~/.dot/emacs/apply-patches.sh
```

Use `-f` to reset and reapply after an upstream pull:

```bash
cd ~/dev/emacs && git pull
~/.dot/emacs/apply-patches.sh -f
```
