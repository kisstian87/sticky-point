# sticky-point

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
<!--
### From MELPA (once published)

```elisp
(require 'package)
(add-to-list 'package-archives
						 '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Then:
;; M-x package-install RET sticky-point RET
```
-->
### From source

Clone the repository somewhere on your `load-path`:

```bash
git clone https://github.com/kisstian87/sticky-point ~/.emacs.d/lisp/sticky-point
```

Then add it to your config:

```elisp
(add-to-list 'load-path (locate-user-emacs-file "lisp/sticky-point"))
(require 'sticky-point)
```

### With `quelpa`

If you use `quelpa` and `quelpa-use-package`, install directly from the
GitHub repository:

```elisp
(use-package sticky-point
	:quelpa (sticky-point
		:fetcher github
		:repo "kisstian87/sticky-point")
	:ensure nil
	:config
	(global-sticky-point-mode t)
	;; Uncomment the sub-modes you want, globally:
	;; (sticky-point-highlight-symbol-mode t)
	;; (sticky-point-highlight-paren-mode t)
	;; (sticky-point-indent-guide-mode t)
	)
```

The `(fetcher github :repo "user/repo")` form is the standard MELPA-style
recipe; `quelpa` understands it natively.

### With `straight.el`

If you use `straight.el` with `use-package`, use the `:straight` keyword
with a recipe:

```elisp
(use-package sticky-point
	:straight (sticky-point
		:type git
		:host github
		:repo "kisstian87/sticky-point")
	:ensure nil
	:config
	(global-sticky-point-mode t)
	;; Uncomment the sub-modes you want, globally:
	;; (sticky-point-highlight-symbol-mode t)
	;; (sticky-point-highlight-paren-mode t)
	;; (sticky-point-indent-guide-mode t)
	)
```

The `:type git` field is optional if `straight-default-vc` is already `git`.

### Note on `use-package-always-ensure`

If you have `(setq use-package-always-ensure t)`, add `:ensure nil` to the
`quelpa` and `straight` declarations above. Otherwise `use-package` will
try to install the package from MELPA via `package.el` and fail because
the recipe lives in one of the other fetchers.

## Usage

### Minimal setup

Enable `sticky-point-mode` globally and let the default turn-on function
handle the rest:

```elisp
(require 'sticky-point)
(global-sticky-point-mode t)
```

That's it. `sticky-point-mode` will be active in every buffer whose
major mode satisfies `(derived-mode-p 'prog-mode 'text-mode 'conf-mode)`.

### With all visual sub-modes

```elisp
(require 'sticky-point)
(global-sticky-point-mode t)
(sticky-point-highlight-symbol-mode t)
(sticky-point-highlight-paren-mode t)
(sticky-point-indent-guide-mode t)
```

### Selectively, only in programming modes

```elisp
(require 'sticky-point)

(add-hook 'prog-mode-hook #'sticky-point-mode)
```

### Disable in a specific buffer

```elisp
M-x sticky-point-mode
```

The mode is buffer-local, so disabling it in one buffer does not affect
the rest.
<!--
### With `use-package`

```elisp
(use-package sticky-point
	:ensure t
	:hook
	:config
	(global-sticky-point-mode t)
	;; Uncomment the sub-modes you want, globally:
	;; (sticky-point-highlight-symbol-mode t)
	;; (sticky-point-highlight-paren-mode t)
	;; (sticky-point-indent-guide-mode t)
	)
```-->

## Configuration

All options live in the `sticky-point` customization group. Use
`M-x customize-group RET sticky-point RET` to browse them interactively.

### Scroll detection

```elisp
(add-to-list 'sticky-point-scroll-commands 'my-scroll-up)
(add-to-list 'sticky-point-scroll-commands 'my-scroll-down)
```

Commands listed here are treated as "the user is scrolling, don't move
the logical cursor". You can add commands from third-party packages
(Evil, Treemacs, Company, Corfu, LSP-UI, etc.) as needed.

### Delays

```elisp
(setq sticky-point-delay-symbol			 0.1)		; seconds
(setq sticky-point-delay-indent			 0.1)
(setq sticky-point-delay-parentheses 0.1)
```

All three are idle timers wrapped in `while-no-input`, so typing is never
blocked.

### Symbol matching

```elisp
(setq sticky-point-case-sensitive nil)
```

When `nil`, the symbol highlighter ignores case.

### Indent guides

```elisp
(setq sticky-point-indent-guide-character "│")
```

Change the character used to draw the guides if `│` does not render well
in your font. For example:

```elisp
(setq sticky-point-indent-guide-character "┃")	; heavier bar
(setq sticky-point-indent-guide-character "¦")	; broken bar
```

## Faces

All faces are defined in the `sticky-point-faces` group and can be
customized independently:

- `sticky-point-nested-level`
- `sticky-point-highlight-paren1`
- `sticky-point-highlight-paren2`
- `sticky-point-highlight-paren-error`
- `sticky-point-highlight-symbol`
- `sticky-point-highlight-tag`
- `sticky-point-highlight-tag-error`

Example:

```elisp
(custom-set-faces
 '(sticky-point-highlight-symbol ((t (:background "#2f447f" :foreground "#ffffff"))))
 '(sticky-point-nested-level		((t (:foreground "#6ae4b9")))))
```

## Compatibility

- Emacs 28.1 or later
- Works with `pixel-scroll-precision-mode`
- Works with `show-paren-mode` (temporarily disables it while active, restores on exit)
- Works with `evil-mode` (scroll commands from Evil are in the default list)
- Python-aware: uses `python-nav-backward-up-list` / `python-nav-up-list`
	in `python-mode` and `python-ts-mode` for indent guide detection

## Performance

`sticky-point` is designed to never block typing:

- The `post-command-hook` and `pre-command-hook` only do bookkeeping.
- All expensive work (overlay creation, `re-search`, `syntax-ppss`) runs
	inside `run-with-idle-timer` wrapped in `while-no-input`.
- Highlighting is limited to `(window-start)` / `(window-end)`, so large
	buffers behave the same as small ones.

If you notice any lag, please open an issue with a minimal reproduction.

## Contributing

Bug reports, feature requests, and pull requests are welcome. Please:

1. Open an issue before sending large PRs.
2. Run `M-x checkdoc` and `M-x package-lint-current-buffer` before
	 submitting.
3. Keep docstrings in English.

## License

Distributed under the GNU General Public License, version 3 or later.
See [LICENSE](LICENSE) for the full text.
