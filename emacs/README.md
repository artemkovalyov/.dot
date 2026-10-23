# Emacs — patched pgtk build

Local patches to Emacs source for the pgtk (Wayland) build, plus a script to
clone, patch, build, and install from scratch.

## Quick start

```bash
# First-time build
~/.dot/emacs/build-emacs.sh

# After an upstream update
~/.dot/emacs/build-emacs.sh --rebuild
```

The script handles dependencies, cloning, patching, configure, make, and
`sudo make install`. See `build-emacs.sh --help` for options.

## Patches

### `0001` — pgtk: split GDK_MOD1_MASK and GDK_META_MASK modifier handling

Fixes `pgtkterm.c` so Alt (Mod1) and Meta (Mod2) are distinct Emacs modifiers
on pgtk/Wayland, enabling `A-` bindings separate from `M-`.

**Problem:** pgtk mapped both `GDK_MOD1_MASK` (Alt_L) and `GDK_META_MASK` to
`mod_meta`, making it impossible to use Alt as a distinct modifier. Custom XKB
layouts that place Meta_L (LWin) on Mod2 were also broken.

**Fix:** `GDK_MOD1_MASK` → `mod_alt`, `GDK_META_MASK` + `GDK_MOD2_MASK` →
`mod_meta`.

### `0002` — pgtk: map GDK_MOD3_MASK to hyper modifier

Fixes CapsLock-based Hyper bindings (`H-`) on Wayland.

**Problem:** CapsLock is mapped to `Hyper_L` on Mod3 in the XKB config.
On pgtk, `GDK_MOD3_MASK` was not handled — the Hyper modifier was silently
dropped, so `H-` bindings received just the bare key. `GDK_HYPER_MASK` is only
set when GDK itself recognises the keysym as Hyper, which doesn't happen
reliably on all Wayland compositors.

**Fix:** `GDK_MOD3_MASK` → `mod_hyper`.

## Applying patches manually

```bash
cd ~/dev/emacs
~/.dot/emacs/apply-patches.sh
```

Use `-f` to reset and reapply after an upstream pull:

```bash
cd ~/dev/emacs && git pull
~/.dot/emacs/apply-patches.sh -f
```

## XKB layout

The patches pair with `~/.dot/xkb/` which maps:

| Physical key | Keysym    | Mod  | Emacs |
|---|---|---|---|
| Left Alt     | `Alt_L`   | Mod1 | `A-`  |
| Left Win     | `Meta_L`  | Mod2 | `M-`  |
| CapsLock     | `Hyper_L` | Mod3 | `H-`  |
| Right Alt    | `Super_R` | Mod4 | `s-`  |
