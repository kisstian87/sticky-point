;;; sticky-point.el --- Preserve point position while scrolling -*- lexical-binding: t; -*-
;; Author: KISStian <kisstian87@gmail.com>
;; Version: 0.9.0
;; Package-Requires: ((emacs "28.1"))
;; Keywords: convenience, faces
;; URL: https://github.com/kisstian87/sticky-point

;;; Commentary:
;`sticky-point.el' is a minor mode for Emacs that provides
;;additional features similar to modern editors.	It includes
;;features such as preserving the cursor position when scrolling,
;;highlighting symbols and corresponding parentheses, and
;;indentation guides.	 It also offers options for customizing the
;;behavior:
;; - Preserves the logical position of the cursor when scrolling
;; - Highlights the symbol under the cursor (limited to the visible window)
;; - Highlights corresponding parentheses
;; - Highlights corresponding HTML tags
;; - Indentation guides

;; This file is not part of GNU Emacs.
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the
;; GNU General Public License for more details.
;; You should have received a copy of the GNU General Public License
;; along with this program.	 If not, see <https://www.gnu.org/licenses/>.

;;; Code:
(defgroup sticky-point nil
	"Preservation of cursor position and current buffer highlights."
	:group 'convenience
	:prefix "sticky-point-")
(defgroup sticky-point-faces nil
	"Sticky-cursor faces."
	:group 'sticky-point)

;;; Customs
;;;###autoload
(defcustom global-sticky-point-mode nil
	"Preserves the cursor position when scrolling and optionally highlights.
Maintains the logical cursor position even if it disappears from the visible
window while scrolling, as in modern editors.	 It also offers three optional
highlighting options:
	`sticky-point-highlight-symbol-mode'
	`sticky-point-show-parens-mode'
	`sticky-point-indent-guides-mode'.
This is the global version."
	:type 'boolean
	:local nil
	:group 'sticky-point)
;;;###autoload
(defcustom sticky-point-mode nil
	"Preserves the cursor position when scrolling and optionally highlights.
Maintains the logical cursor position even if it disappears from the visible
window while scrolling, as in modern editors.	 It also offers three optional
highlighting options:
	`sticky-point-highlight-symbol-mode'
	`sticky-point-show-parens-mode'
	`sticky-point-indent-guides-mode'."
	:type 'boolean
	:local t)
;;;###autoload
(defcustom sticky-point-highlight-symbol-mode nil
	"Highlight all occurrences of the symbol under the cursor.
The highlighting is limited to the visible region of the window."
	:type 'boolean
	:require 'sticky-point
	:group 'sticky-point)
;;;###autoload
(defcustom global-sticky-point-highlight-symbol-mode nil
	"Highlight all occurrences of the symbol under the cursor.
The highlighting is limited to the visible region of the window."
	:type 'boolean
	:local nil
	:require 'sticky-point
	:group 'sticky-point)
;;;###autoload
(defcustom sticky-point-show-parens-mode nil
	"Highlight the parentheses that surround the cursor.
The highlighting is limited to the visible region of the window."
	:type 'boolean
	:require 'sticky-point
	:group 'sticky-point)
;;;###autoload
(defcustom global-sticky-point-show-parens-mode nil
	"Highlight the parentheses that surround the cursor.
The highlighting is limited to the visible region of the window."
	:type 'boolean
	:local nil
	:require 'sticky-point
	:group 'sticky-point)
;;;###autoload
(defcustom sticky-point-indent-guides-mode nil
	"Draw vertical indentation guides within the block.
The highlighting is limited to the visible region of the window."
	:type 'boolean
	:require 'sticky-point
	:group 'sticky-point)
;;;###autoload
(defcustom global-sticky-point-indent-guides-mode nil
	"Draw vertical indentation guides within the block.
The highlighting is limited to the visible region of the window."
	:type 'boolean
	:local nil
	:require 'sticky-point
	:group 'sticky-point)
;;;###autoload
(defcustom sticky-point-scroll-commands
	'(mwheel-scroll scroll-up scroll-down scroll-left scroll-right scroll-up-command scroll-down-command scroll-other-window scroll-other-window-down scroll-bar-scroll-up scroll-bar-scroll-down scroll-bar-drag scroll-bar-movement scroll-bar-toolkit-scroll scroll-bar-toolkit-horizontal-scroll ignore-preserving-kill-region treemacs-leftclick-action company-abort corfu-quit save-buffer pixel-scroll-precision handle-select-window handle-switch-frame lsp-ui-doc--handle-mouse-movement pixel-scroll-start-momentum pixel-scroll-interpolate-down pixel-scroll-interpolate-up scroll-up-line scroll-down-line pixel-scroll-precision-scroll-down pixel-scroll-precision-scroll-up-page)
	"Commands treated as scrolling operations.
When `this-command' is in this list, the logical cursor is
not updated and the saved position is preserved even if it
disappears from the visible window."
	:type '(repeat symbol)
	:local nil
	:require 'sticky-point
	:group 'sticky-point)
;;;###autoload
(defcustom sticky-point-delay-symbol 0.1
	"Seconds of inactivity before highlighting the symbol."
	:type 'number
	:local nil
	:require 'sticky-point
	:group 'sticky-point)
;;;###autoload
(defcustom sticky-point-delay-indent 0.1
	"Seconds of inactivity before drawing the indentation guides."
	:type 'number
	:local nil
	:require 'sticky-point
	:group 'sticky-point)
;;;###autoload
(defcustom sticky-point-delay-parentheses 0.1
	"Seconds of inactivity before highlighting the parentheses."
	:type 'number
	:local nil
	:require 'sticky-point
	:group 'sticky-point)
;;;###autoload
(defcustom sticky-point-case-sensitive nil
	"If it is non-nil, match symbols case-insensitively."
	:type 'boolean
	:local nil
	:require 'sticky-point
	:group 'sticky-point)
;;;###autoload
(defcustom sticky-point-indent-guide-character "│"
	"Character used to draw the indentation guides."
	:type 'string
	:local nil
	:require 'sticky-point
	:group 'sticky-point)

;;; Faces
(defface sticky-point-nested-level '((t (:foreground "#6ae4b9"))) "Nested level." :group 'sticky-point-faces)
(defface sticky-point-highlight-parens '((t (:background "#2f9f2f" :foreground "#ffffff"))) "Highlight parentheses." :group 'sticky-point-faces)
(defface sticky-point-highlight-nested-parens '((t (:background "#40da40" :foreground "#ffffff"))) "Highlight parentheses." :group 'sticky-point-faces)
(defface sticky-point-highlight-paren-error '((t (:background "#550000" :foreground "#ffffff"))) "Parentheses error." :group 'sticky-point-faces)
(defface sticky-point-highlight-symbol '((t (:background "#2f447f" :foreground "#ffffff"))) "Highlight symbol." :group 'sticky-point-faces)
(defface sticky-point-highlight-tag '((t (:background "#444400" :foreground "#ffffff"))) "Highlight html tag." :group 'sticky-point-faces)
(defface sticky-point-highlight-tag-error '((t (:background "#550000" :foreground "#ffffff"))) "Highlight html tag error." :group 'sticky-point-faces)

;;; Variables
(defvar-local sticky-point--cursor-type-original cursor-type "Original cursor type.")
(defvar-local sticky-point--selection-mark nil "Selection mark.")
(defvar-local sticky-point--current-position nil "Variable to save the cursor's position.")
(defvar-local sticky-point--highlight-symbol-timer nil "Highlight symbol timer.")
(defvar-local sticky-point--search-parentheses-timer nil "Search parentheses timer.")
(defvar-local sticky-point--indent-overlay-timer nil "Indent overlay timer.")

;;; Highlight symbol
(defun sticky-point--highlight-symbol-timer-func (position)
	"Timer to highlight symbol at its POSITION."
	(when sticky-point--highlight-symbol-timer (cancel-timer sticky-point--highlight-symbol-timer))
	(let ((buffer (current-buffer))) (setq sticky-point--highlight-symbol-timer (run-with-idle-timer sticky-point-delay-symbol nil (lambda () (while-no-input (when (buffer-live-p buffer) (with-current-buffer (window-buffer) (sticky-point--highlight-symbol position)))))))))
(defun sticky-point--highlight-symbol (position)
	"Highlighting function for the symbol at its POSITION."
	(interactive "d")
	(let* ((start (max (window-start) (point-min)))
					(end (min (or (window-end nil t) (point-max)) (point-max)))
					(case-fold-search (not sticky-point-case-sensitive))
					(symbol (unless (region-active-p) (save-excursion (goto-char position) (thing-at-point 'symbol)))))
		(when (< start end)
			(save-excursion
				(remove-overlays start end 'face 'sticky-point-highlight-symbol)
				(remove-overlays start end 'face 'hl-line)
				(goto-char position)
				(unless (region-active-p) (overlay-put (make-overlay (line-beginning-position) (save-excursion (goto-char (line-end-position)) (forward-line 1) (point))) 'face 'hl-line))
				(when (and symbol (not (string= symbol "")))
					(goto-char start)
					(while (re-search-forward (concat "\\_<" (regexp-quote symbol) "\\_>") end t)
						(overlay-put (make-overlay (match-beginning 0) (match-end 0)) 'face 'sticky-point-highlight-symbol)))))))

;;; Indent overlay
(declare-function python-nav-up-list "Python up-list.")
(declare-function python-nav-backward-up-list "Python backward-up-list.")
(defun sticky-point--indent-overlay-timer-func (position)
	"Timer for highlighting nesting level at the POSITION."
	(when sticky-point--indent-overlay-timer (cancel-timer sticky-point--indent-overlay-timer))
	(let ((buffer (current-buffer))) (setq sticky-point--indent-overlay-timer (run-with-idle-timer sticky-point-delay-indent nil (lambda () (while-no-input (when (buffer-live-p buffer) (with-current-buffer (window-buffer) (sticky-point--indent-overlay position)))))))))
(defun sticky-point--indent-overlay (position)
	"Highlights the nesting level at POSITION, limited to the visible."
	(interactive "d")
	(with-current-buffer (window-buffer)
		(let* ((start (max (window-start) (point-min)))
					 (end (min (or (window-end nil t) (point-max)) (point-max)))
					 (array '(("(" ")") ("[" "]") ("{" "}"))))
			(when (< start end)
				(remove-overlays start end 'face 'sticky-point-highlight-nested-parens)
				(remove-overlays start end 'face 'sticky-point-nested-level)
				(save-excursion
					(goto-char position)
					(when (and (char-before)
									(member (char-to-string (char-before)) (mapcar #'cadr arreglo)))
						(backward-char 1))
					(when (and (char-after)
									(member (char-to-string (char-after)) (mapcar #'car arreglo)))
						(forward-char 1))
					(when (member (char-to-string (char-before)) (mapcar #'cadr array))
						(backward-char 1))
					(when (member (char-to-string (char-after)) (mapcar #'car array))
						(forward-char 1))
					(when (ignore-errors (if (memq major-mode '(python-mode python-ts-mode)) (python-nav-backward-up-list 1) (backward-up-list 1)) t)
						(let* ((start2 (+ 1 (point)))
									 (indent (current-indentation))
									 (end2	 (save-excursion (goto-char start2) (when (ignore-errors (if (memq major-mode '(python-mode python-ts-mode)) (python-nav-up-list 1) (up-list 1)) t) (point)))))
							(when (and start2 end2 (< start2 end2))
								(dolist (p (list (1- start2) (1- end2)))
									(when (and (>= p start) (< p end) (not (eq (char-syntax (char-after p)) ?w)))
										(let ((ov (make-overlay p (1+ p))))
											(overlay-put ov 'face 'sticky-point-highlight-nested-parens))))
								(goto-char (max start2 start))
								(while (< (point) (min end2 end))
									(let ((line-start (point)))
										(when (>= line-start start)
											(let ((pos (save-excursion (move-to-column indent) (when (eq (current-column) indent) (point)))))
												(when (and pos
																	 (<	 pos (line-end-position))
																	 (>= pos (max start2 start))
																	 (<	 pos (min end2 end))
																	 (memq (char-after pos) '(?\s ?\t)))
													(let* ( (start2-col (save-excursion (goto-char pos) (current-column)))
																	(end2-col (save-excursion (goto-char pos) (forward-char 1) (current-column)))
																	(columns (- end2-col start2-col))
																	(display (concat sticky-point-indent-guide-character (make-string (1- columns) ?\s)))
																	(ov (make-overlay pos (1+ pos))))
														(overlay-put ov 'display display)
														(overlay-put ov 'face 'sticky-point-nested-level))))))
									(forward-line 1))))))))))

;;; Search parentheses
(defun sticky-point--search-parentheses-timer-func (position)
	"Timer para resaltar parentheses en la POSITION."
	(when sticky-point--search-parentheses-timer (cancel-timer sticky-point--search-parentheses-timer))
	(let ((buffer (current-buffer))) (setq sticky-point--search-parentheses-timer (run-with-idle-timer sticky-point-delay-parentheses nil (lambda () (while-no-input (when (buffer-live-p buffer) (with-current-buffer (window-buffer) (sticky-point--search-parentheses position)))))))))
(defun sticky-point--search-parentheses (position)
	"Function to find pairs at POSITION."
	(interactive "d")
	(with-current-buffer (window-buffer)
		(let* ((start (max (window-start) (point-min)))
						(end (min (or (window-end nil t) (point-max)) (point-max)))
						(case-fold-search (not sticky-point-case-sensitive))
						(symbol (if (region-active-p) (buffer-substring-no-properties (region-beginning) (region-end)) (save-excursion (goto-char position) (thing-at-point 'symbol)))))
			(when (< start end)
				(remove-overlays start end 'face 'sticky-point-highlight-paren-error)
				(remove-overlays start end 'face 'sticky-point-highlight-parens)
				(remove-overlays start end 'face 'sticky-point-highlight-tag)
				(remove-overlays start end 'face 'sticky-point-highlight-tag-error)
				(save-excursion
					(let ((pair nil)
								 (position_aux position)
								 (array '(("(" ")") ("[" "]") ("{" "}")))
								 (character1 (save-excursion (goto-char position) (thing-at-point 'char)))
								 (character2 (save-excursion (goto-char (- position 1)) (thing-at-point 'char))))
						(dotimes (i (length array))
							(unless pair
								(let ( (parentheses1 (nth 0 (nth i array)))
											 (parentheses2 (nth 1 (nth i array)))
											 (comment nil)
											 (string nil)
											 (counter 0))
									(when (or (string= character1 parentheses1) (string= character2 parentheses1) (string= character1 parentheses2) (string= character2 parentheses2))
										(when (or (string= symbol character1) (string= symbol character2)) (remove-overlays start end 'face 'sticky-point-highlight-symbol))
										(when (or (string= character2 parentheses2)
														(and (string= character2 parentheses1)
															(not (string= character1 parentheses1))))
											(setq position_aux (- position_aux 1)))
										(goto-char position_aux)
										(setq string (nth 3 (syntax-ppss position_aux)))
										(setq comment (nth 4 (syntax-ppss position_aux)))
										(overlay-put (make-overlay position_aux (1+ position_aux)) 'face 'sticky-point-highlight-parens)
										
										(if (and (< (1+ position_aux) (point-max)) (string= (char-to-string (char-after (1+ position_aux))) parentheses2))
											(progn
												(overlay-put (make-overlay (1+ position_aux) (+ 2 position_aux)) 'face 'sticky-point-highlight-paren1)
												(setq pair t)
												(setq counter -50))
											(when (or (string= character1 parentheses2) (string= character2 parentheses2))
												(goto-char (+ position_aux 1))))
										
										(while (and (not (eq (abs counter) 50)) (if (or (string= character1 parentheses1) (string= character2 parentheses1)) (re-search-forward (if (string= parentheses1 "[") "[][]" (concat "[" parentheses1 parentheses2 "]")) (point-max) t) (re-search-backward (if (string= parentheses1 "[") "[][]" (concat "[" parentheses1 parentheses2 "]")) (point-min) t)))
											(when (and
															(eq string (nth 3 (syntax-ppss (point))))
															(eq comment (nth 4 (syntax-ppss (point)))))
												(if (or (string= (match-string 0) character1) (string= (match-string 0) character2))
													(setq counter (+ counter 1))
													(progn
														(setq counter (- counter 1))
														(when (eq counter 0)
															(setq pair t)
															(setq counter -50)
															(overlay-put (make-overlay (match-beginning 0) (match-end 0)) 'face 'sticky-point-highlight-parens))))))
											(unless pair (overlay-put (make-overlay position_aux (1+ position_aux)) 'face 'sticky-point-highlight-paren-error)))))))
					(when
						(memq major-mode '(web-mode php-ts-mode html-ts-mode html-mode sgml-mode xml-mode nxml-mode))
						(let ((position_aux position)
									(pair nil)
									(counter 1)
									(array '("area" "base" "br" "col" "embed" "hr" "img" "input" "keygen" "link" "meta" "param" "source" "track" "wbr")))
							(let* ((tag1 (save-excursion (goto-char position_aux) (search-backward "<" (point-min) t) (match-beginning 0)))
										 (tag2 (save-excursion (goto-char tag1) (search-forward ">" (point-max) t) (match-beginning 0)))
										 (tag (when (eq (line-number-at-pos tag1) (line-number-at-pos tag2)) (save-excursion (goto-char tag1) (re-search-forward "[a-zA-Z/]+" tag2 t) (if (eq (match-beginning 0) (+ 1 tag1)) (buffer-substring-no-properties (match-beginning 0) (match-end 0)) nil)))))
								(when (and tag (> (length tag) 0) (<= tag1 position_aux) (>= tag2 position_aux))
									(overlay-put (make-overlay tag1 (+ tag2 1)) 'face 'sticky-point-highlight-tag)
									(unless (or (string= (buffer-substring-no-properties (- tag2 1) tag2) "/") (member (replace-regexp-in-string "/" "" tag) array))
										(if (not (string= (substring tag 0 1) "/"))
											(progn	; APERTURA
												(goto-char tag2)
												(while (and (not pair) (re-search-forward (concat "<\\(/?\\)" (regexp-quote tag) "[^>]*>") (point-max) t))
													(unless (nth 4 (syntax-ppss (point)))
														(if (not(string= (substring (buffer-substring-no-properties (match-beginning 0) (match-end 0)) 0 2) "</"))
															(setq counter (+ counter 1))
															(progn
																(setq counter (- counter 1))
																(when (eq counter 0)
																	(overlay-put (make-overlay (match-beginning 0) (match-end 0)) 'face 'sticky-point-highlight-tag)
																	(setq pair t)))))))
											(progn	; CIERRE
												(goto-char tag1)
												(while (and (not pair) (re-search-backward (concat "<\\(/?\\)" (regexp-quote (substring tag 1 (length tag))) "[^>]*>") (point-min) t))
													(unless (nth 4 (syntax-ppss (point)))
														(if (string= (substring (buffer-substring-no-properties (match-beginning 0) (match-end 0)) 0 2) "</")
															(setq counter (+ counter 1))
															(progn
																(setq counter (- counter 1))
																(when (eq counter 0)
																	(overlay-put (make-overlay (match-beginning 0) (match-end 0)) 'face 'sticky-point-highlight-tag)
																	(setq pair t))))))))
										(unless pair (overlay-put (make-overlay tag1 (+ tag2 1)) 'face 'sticky-point-highlight-tag-error))))))))))))

(defun sticky-point--save-position ()
	"Stores the original position in a variable to be able to return later."
	(with-current-buffer (window-buffer)
		(unless sticky-point--current-position (setq sticky-point--current-position (point)))
		(if
			(memq this-command sticky-point-scroll-commands)
			(if (pos-visible-in-window-p sticky-point--current-position)
				(unless cursor-type
					(goto-char sticky-point--current-position)
					(setq cursor-type sticky-point--cursor-type-original)
					(setq face-remapping-alist (assq-delete-all 'line-number-current-line face-remapping-alist)))
				(when cursor-type
					(setq cursor-type nil)
					(push '(line-number-current-line line-number) face-remapping-alist)))
			(progn (setq sticky-point--current-position (point))))
		(when (or buffer-file-name (derived-mode-p 'prog-mode 'text-mode))
			(when sticky-point-highlight-symbol-mode (sticky-point--highlight-symbol-timer-func sticky-point--current-position))
			(when sticky-point-show-parens-mode (sticky-point--search-parentheses-timer-func sticky-point--current-position))
			(when sticky-point-indent-guides-mode (sticky-point--indent-overlay-timer-func sticky-point--current-position)))))

(defun sticky-point--load-position ()
	"Loads the saved position to return when no longer visible."
	(with-current-buffer (window-buffer)
		(unless sticky-point--current-position (setq sticky-point--current-position (point)))
		(unless (eq sticky-point--current-position (point))
			(unless
				(memq this-command sticky-point-scroll-commands)
				(unless cursor-type
					(goto-char sticky-point--current-position)
					(let ((sticky-point-position-return (point)))
						(when sticky-point--selection-mark
							(when (and (use-region-p) (or (and (< sticky-point-position-return sticky-point--current-position) (< sticky-point--selection-mark sticky-point--current-position)) (and (> sticky-point-position-return sticky-point--current-position) (> sticky-point--selection-mark sticky-point--current-position))))
								(setq sticky-point--selection-mark sticky-point--current-position))
							(push-mark sticky-point--selection-mark nil t)
							(goto-char sticky-point-position-return)))
					(setq cursor-type sticky-point--cursor-type-original)
					(setq face-remapping-alist(assq-delete-all 'line-number-current-line face-remapping-alist)))))))

;;;###autoload
(define-minor-mode sticky-point-mode
	"Preserves the cursor position when scrolling and optionally highlights.
Maintains the logical cursor position even if it disappears from the visible
window while scrolling, as in modern editors.	 It also offers three optional
highlighting options:
	`sticky-point-highlight-symbol-mode'
	`sticky-point-show-parens-mode'
	`sticky-point-indent-guides-mode'."
	:lighter " SC"
	:group 'sticky-point
	(if sticky-point-mode
		(progn
			(setq sticky-point--cursor-type-original cursor-type)
			(add-hook 'post-command-hook #'sticky-point--save-position)
			(add-hook 'pre-command-hook #'sticky-point--load-position))
	(progn
		(remove-overlays nil nil 'face 'sticky-point-highlight-symbol)
		(remove-overlays nil nil 'face 'sticky-point-highlight-parens)
		(remove-overlays nil nil 'face 'sticky-point-highlight-parens)
		(remove-overlays nil nil 'face 'sticky-point-highlight-paren-error)
		(remove-overlays nil nil 'face 'sticky-point-nested-level)
		(remove-overlays nil nil 'face 'sticky-point-highlight-tag)
		(remove-overlays nil nil 'face 'sticky-point-highlight-tag-error)
		(setq sticky-point--current-position nil)
		(remove-hook 'post-command-hook #'sticky-point--save-position)
		(remove-hook 'pre-command-hook #'sticky-point--load-position)
		(when sticky-point--highlight-symbol-timer
			(cancel-timer sticky-point--highlight-symbol-timer)
			(setq sticky-point--highlight-symbol-timer nil))
		(when sticky-point--search-parentheses-timer
			(cancel-timer sticky-point--search-parentheses-timer)
			(setq sticky-point--search-parentheses-timer nil))
		(when sticky-point--indent-overlay-timer
			(cancel-timer sticky-point--indent-overlay-timer)
			(setq sticky-point--indent-overlay-timer nil)))))

;;;###autoload
(define-minor-mode sticky-point-highlight-symbol-mode
	"Highlight all occurrences of the symbol under the cursor.
The highlighting is limited to the visible region of the window."
	:lighter " SP-Sym"
	:group 'sticky-point
	(if sticky-point-highlight-symbol-mode
		(progn
			(unless sticky-point-mode (sticky-point-mode 1))
			(when buffer-file-name
				(sticky-point--highlight-symbol-timer-func (point))))
		(when sticky-point--highlight-symbol-timer
			(cancel-timer sticky-point--highlight-symbol-timer)
			(setq sticky-point--highlight-symbol-timer nil))
		(remove-overlays nil nil 'face 'sticky-point-highlight-symbol)))

;;;###autoload
(define-minor-mode sticky-point-show-parens-mode
	"Highlight the parentheses that surround the cursor.
The highlighting is limited to the visible region of the window."
	:lighter " SP-Par"
	:group 'sticky-point
	(if sticky-point-show-parens-mode
		(progn
			(unless sticky-point-mode (sticky-point-mode 1))
			(when (and sticky-point-mode buffer-file-name)
				(sticky-point--search-parentheses-timer-func (point))))
		(when sticky-point--search-parentheses-timer
			(cancel-timer sticky-point--search-parentheses-timer)
			(setq sticky-point--search-parentheses-timer nil))
		(remove-overlays nil nil 'face 'sticky-point-highlight-parens)
		(remove-overlays nil nil 'face 'sticky-point-highlight-parens)
		(remove-overlays nil nil 'face 'sticky-point-highlight-paren-error)
		(remove-overlays nil nil 'face 'sticky-point-highlight-tag)
		(remove-overlays nil nil 'face 'sticky-point-highlight-tag-error)))

;;;###autoload
(define-minor-mode sticky-point-indent-guides-mode
	"Draw vertical indentation guides within the block.
The highlighting is limited to the visible region of the window."
	:lighter " SP-Ind"
	:group 'sticky-point
	(if sticky-point-indent-guides-mode
		(progn
			(unless sticky-point-mode (sticky-point-mode 1))
			(when (and sticky-point-mode buffer-file-name)
				(sticky-point--indent-overlay-timer-func (point))))
		(progn
			(when sticky-point--indent-overlay-timer
				(cancel-timer sticky-point--indent-overlay-timer)
				(setq sticky-point--indent-overlay-timer nil))
			(remove-overlays nil nil 'face 'sticky-point-highlight-parens)
			(remove-overlays nil nil 'face 'sticky-point-nested-level))))

;;;###autoload
(define-globalized-minor-mode global-sticky-point-highlight-symbol-mode
	sticky-point-highlight-symbol-mode
	(lambda () (sticky-point-highlight-symbol-mode 1))
	:group 'sticky-point)
;;;###autoload
(define-globalized-minor-mode global-sticky-point-show-parens-mode
	sticky-point-show-parens-mode
	(lambda () (sticky-point-show-parens-mode 1))
	:group 'sticky-point)
;;;###autoload
(define-globalized-minor-mode global-sticky-point-indent-guides-mode
	sticky-point-indent-guides-mode
	(lambda () (sticky-point-indent-guides-mode 1))
	:group 'sticky-point)
;;;###autoload
(define-globalized-minor-mode global-sticky-point-mode
	sticky-point-mode
	(lambda () (sticky-point-mode 1))
	:group 'sticky-point)
(provide 'sticky-point)
;;; sticky-point.el ends here
