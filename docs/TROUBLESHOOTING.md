# Troubleshooting

## A GTK 3 application still shows old colors

GTK 3 user CSS is generally loaded when the process starts. Close every window
of the application and ensure no background process remains, then reopen it.
Remmina and Thunar are common examples.

## Grouped task buttons are rounded or have a background

Toggle **Show flat buttons** off and on once in the Window Buttons properties,
then reload the panel:

```sh
xfce4-panel -r
```

The toggle makes the plugin reapply relief to existing normal and grouped
buttons. The CSS handles their hover and checked states after that.

## A submenu has dark text on a dark background

Confirm the import exists near the beginning of
`~/.config/gtk-3.0/gtk.css`:

```css
/* hidpi-amber-desktop:start */
@import url("hidpi-amber.css");
/* hidpi-amber-desktop:end */
```

Restart the affected GTK 3 application.

## Selected text becomes white or gray after focus changes

This usually means the application was running before the user CSS was
installed, or it has an application-specific selector with greater
specificity. Restart it first. If the problem remains, inspect the widget with
GTK Inspector before adding broad global selectors.

## Fcitx candidate background ignores the configured color

Disable **Follow system accent color**. With `UseAccentColor=True`, Fcitx may
substitute fields listed by the theme's `AccentColorField` mapping.

The candidate background is controlled by:

```text
Input Panel → Highlight → Color
```

The top-level `Highlight Background Color` controls highlighted preedit text,
not the current candidate row.

## Fcitx preedit colors differ between applications

Embedded preedit is client-rendered. GTK, Qt, Chromium/Electron, terminals, and
XIM clients can all display it differently. Disable **Show preedit in
application** so Fcitx renders it in its own panel.

## GNOME Calendar or Bottles still has large rounded corners

Expected. These are GTK 4/libadwaita applications. This repository deliberately
does not override libadwaita.

## Anki remains rounded in Native Style

Expected. Anki is a Qt application, and Native Style may select Qt Fusion.
GTK CSS has no effect on Qt widget geometry.
