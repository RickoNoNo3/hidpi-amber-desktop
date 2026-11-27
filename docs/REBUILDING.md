# Rebuilding and porting

This document records how the bundle relates to its upstream themes so it can
be updated on another distribution or after a toolkit upgrade.

## Reference environment

The first packaged release was produced and verified with:

| Component | Reference package |
| --- | --- |
| GNOME GTK 2/3 themes | `gnome-themes-extra-data 3.28-5` |
| Fcitx data | `fcitx5-data 5.1.19-1` |
| Xfwm4 | `xfwm4 4.20.0-1build1` |
| Xfce panel | `xfce4-panel 4.20.7-1` |

Distribution revisions can differ even when the upstream version is the same.
Always test a rebuilt theme in a disposable user account or temporary HOME.

## Rebuilding GTK 3 from the installed Adwaita resource

On current GTK 3 installations,
`/usr/share/themes/Adwaita-dark/gtk-3.0/gtk.css` may contain only a GResource
import. The full CSS is embedded in `libgtk-3.so.0`.

List and extract it with:

```sh
GTK3_LIB=$(ldconfig -p | awk '/libgtk-3.so.0/{print $NF; exit}')
gresource list "$GTK3_LIB" |
  grep /org/gtk/libgtk/theme/Adwaita/gtk-contained-dark.css
gresource extract "$GTK3_LIB" \
  /org/gtk/libgtk/theme/Adwaita/gtk-contained-dark.css \
  > gtk.css
```

Do not publish a blind color replacement without reviewing every state.
The original blue palette has semantic light, base, border, pressed, backdrop,
and disabled shades. The amber port uses these principal mappings:

| Adwaita role | Upstream example | Amber example |
| --- | --- | --- |
| Main accent | `#15539E` | `#E5A50A` |
| Bright attention | `#1F76E1` | `#F6D32D` |
| Accent border | `#0F3B71` | `#9F7200` |
| Dark focus edge | `#030C17` | `#4A3500` |
| Pressed accent | `#103E75` | `#926500` |
| Link/bright accent | `#3584E4` | `#F5C211` |
| Text on full accent | white | `#1C1C1C` |

The resulting CSS also includes explicit accessibility overrides at its end.
Those rules prevent child labels, selected rows, menu items, and checked
controls from reintroducing white text on an amber background.

After rebuilding, compare against the embedded source:

```sh
diff -u gtk-contained-dark.css \
  themes/Adwaita-dark-amber/gtk-3.0/gtk.css
```

Check at minimum normal, hover, active, checked, selected, disabled, focus, and
backdrop combinations. GTK state specificity is the main source of regressions.

## Rebuilding GTK 2

Start from the distribution's `Adwaita-dark/gtk-2.0` directory. Most assets are
unchanged. The essential palette changes in `gtkrc` are:

```text
selected_fg_color: #1C1C1C
selected_bg_color: #E5A50A
link_color:         #F5C211
visited_link_color: #E5A50A
```

Keep the upstream image assets and include files together; GTK 2 themes often
refer to them by relative path.

## Porting the GTK 3 user override

The tasklist selectors are tied to Xfce panel's `.tasklist`,
`.group-button`, and `.suggested-action` conventions. When updating Xfce:

1. inspect the Window Buttons plugin source for added CSS classes;
2. verify what class or state represents urgency;
3. test normal windows and grouped application buttons;
4. test current, hover, urgent, and urgent-current combinations.

Keep application selection and nested-menu fixes separate from the base theme.
That makes them easy to remove when a newer GTK theme no longer needs them.

## Rebuilding Minimal-hdpi

Xfwm4 decoration parts are XPM files. The bundle intentionally uses one image
format throughout to avoid one-pixel seams from mixed rasterization paths.

When changing dimensions:

- preserve the 6 px side and bottom frame target;
- preserve the 24×24 px bottom-corner hit areas;
- keep active/inactive title pieces the same height;
- update every active, inactive, prelight, pressed, and toggled control state;
- test maximized windows, where `maximized_offset=0` matters.

## Rebuilding the Fcitx theme

Copy the current Fcitx default dark Classic UI theme and retain all paging
assets. Then apply these functional settings:

```ini
[InputPanel]
NormalColor=#f6f5f4
HighlightColor=#1c1c1c
HighlightBackgroundColor=#e5a50a
HighlightCandidateColor=#000000

[InputPanel/Background]
Color=#1c1c1c

[InputPanel/Highlight]
Color=#e5a50a
```

The selected candidate background belongs to
`InputPanel/Highlight/Color`; it is not the top-level
`HighlightBackgroundColor`. Disable system accent substitution while testing,
otherwise manual highlight fields can appear to have no effect.

## Release checks

Before publishing an update:

```sh
for file in bin/* scripts/*.sh; do sh -n "$file"; done
grep -RInE '/home/|password=|token=|secret=' \
  --exclude-dir=.git .
```

Then run `install.sh --apply` and `uninstall.sh` with an isolated HOME and
confirm:

- a pre-existing GTK user stylesheet survives;
- same-named theme directories are restored;
- prior Xfce theme names are restored;
- prior Fcitx files are restored;
- no GTK 4 files are installed.
