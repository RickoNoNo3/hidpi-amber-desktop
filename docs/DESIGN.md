# Design and modification notes

## Goals

The bundle follows a small set of rules:

1. Dark gray surfaces instead of blue-tinted or glossy surfaces.
2. Amber (`#E5A50A`) for selection and attention.
3. Dark foreground (`#1C1C1C`) whenever amber is a background.
4. Square Xfwm4 decorations with generous HiDPI resize targets.
5. No gradients in the Xfwm4 frame or Xfce task buttons.
6. Toolkit boundaries are respected instead of pretending one theme engine
   controls GTK 3, GTK 4, Qt, and Fcitx.

## GTK 2/3: Adwaita-dark-amber

The GTK theme began as Ubuntu's packaged Adwaita Dark resources. Blue accent
uses were changed to amber. Selection foregrounds were changed to dark text
where amber is used as a full background.

The theme directory contains GTK 2 and GTK 3 only. A previous GTK 4 experiment
caused transparent or otherwise broken libadwaita windows and was removed from
the supported bundle. Modern libadwaita applications should use their native
Adwaita Dark styling.

## User GTK 3 CSS

`config/gtk-3.0/hidpi-amber.css` is intentionally separate from the base GTK
theme. The installer imports it from `~/.config/gtk-3.0/gtk.css`, allowing the
fixes to be installed and removed independently.

### Xfce tasklist

The Window Buttons plugin uses GTK buttons and adds `.tasklist`; grouped
buttons also carry `.group-button`. “Show flat buttons” changes GTK relief, but
does not prevent the GTK theme from drawing hover, checked, or grouped-button
backgrounds. The override therefore addresses all relevant button classes and
states explicitly:

- normal: transparent
- hover: solid `#454545`
- current (`:checked`): black with light text
- attention (`.suggested-action`): amber with dark text

Borders, corner radii, shadows, gradients, and transitions are removed only
inside the tasklist.

### Selection state combinations

GTK selectors such as `selected`, `focus`, `hover`, and `backdrop` can combine.
An application may briefly show the expected foreground during focus changes,
then settle on a more specific theme rule. Explicit selected-state selectors
keep the foreground dark on amber in Xfce settings panels, Remmina, and other
GTK 3 tree/list views.

### Nested menus

When a submenu is open, its parent item remains hovered. Without an explicit
foreground on each submenu item, the parent's dark hover foreground can be
inherited by the entire submenu. The user CSS assigns light text to ordinary
menu items, dark text to hovered items, and gray text to disabled items.

## Xfwm4: Minimal-hdpi

The decoration is built entirely from XPM files to avoid seams caused by
mixing PNG and XPM assets.

- square corners
- solid gray active and inactive title bars
- 6 px frame with a 1 px dark outer edge
- 24×24 px bottom-corner resize handles
- standard minimize, maximize, and close glyphs
- no title or control gradients

The control geometry is based on Xfce's `Default-hdpi`, while the frame and
styling are custom.

## Fcitx 5

The Classic UI candidate panel and embedded application preedit are different
rendering paths.

- The **candidate panel** is controlled by
  `fcitx5/themes/minimal-amber/theme.conf`.
- **Embedded preedit** is drawn by each client toolkit and can vary between
  GTK, Qt, Chromium/Electron, terminals, and XIM clients.

For consistent appearance, `apply.sh` sets
`PreeditEnabledByDefault=False`, causing preedit to be shown in the Fcitx
panel. This can still be toggled at runtime with the configured Fcitx shortcut
(commonly `Ctrl+Alt+P`).

`UseAccentColor=False` is also important. If enabled, Fcitx's
`AccentColorField` mappings may replace manually configured candidate and
highlight backgrounds with the system accent.

## Why GTK 4 and Qt are not included

GTK 4/libadwaita uses its own CSS, CSD windows, cards, boxed lists, and large
radius variables. Qt applications use `QStyle` or application QSS. Anki's
“Native Style,” for example, can resolve to Qt Fusion rather than a GTK style.
Changing either reliably requires a separate, application-aware project.
