# sticky-point

[![MELPA](https://melpa.org/packages/sticky-point-badge.svg)](https://melpa.org/#/sticky-point)

> Preserve the logical position of the cursor while scrolling in Emacs.

`sticky-point` keeps the cursor anchored to its logical position when you
scroll it out of view, like modern editors do. It also ships three optional
sub-modes that add visual context around point:

- Highlight all occurrences of the symbol at point
- Highlight the parentheses (or HTML/XML tags) surrounding point
- Draw vertical indentation guides

All features are limited to the visible region of the window, which keeps
them fast even in large buffers.

## Why another package?

Emacs already ships `scroll-restore` in GNU ELPA, and it does a good job at
preserving point during scroll. `sticky-point` exists because there are
still cases where `scroll-restore` does not behave as expected:

- **`pixel-scroll-precision-mode`**: `sticky-point` handles sub-line
  scrolling cleanly.
- **`hl-line` integration**: the current line indicator follows the logical
  cursor, not the visual one, when you scroll back.
- **`cursor-type` management**: the visual cursor hides while the logical
  position is offscreen, and reappears with the correct shape when you
  scroll back, regardless of whether `cursor-type` is a symbol, a cons, or
  `nil`.
- **Selective activation**: enable only the features you want, per buffer
  or globally, without pulling in unrelated dependencies.

If `scroll-restore` already works for you, you probably don't need
`sticky-point`. If you want the additional highlighting features, or if
`scroll-restore` misbehaves with pixel scrolling or `hl-line`, give it a
try.

## Features

| Feature | Default | Description |
|---|---|---|
| Cursor position preservation | Always on with the base mode | Keeps point anchored when scrolled out of view |
| Symbol highlighting | Off | Highlights every occurrence of the symbol at point in the visible region |
| Paren/tag highlighting | Off | Highlights the matching `(`/`)`, `[`/`]`, `{`/`}` or HTML/XML tag pair around point |
| Indent guides | Off | Draws vertical guides at the current indentation level |

## Installation

### From Source
Clone the repository somewhere on your load-path:
git clone https://github.com/KISStian/sticky-point ~/.emacs.d/lisp/sticky-point
