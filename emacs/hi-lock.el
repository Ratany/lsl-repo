;;; hi-lock.el --- minor mode for interactive automatic highlighting  -*- lexical-binding: t -*-

;; Copyright (C) 2000-2014 Free Software Foundation, Inc.

;; Author: David M. Koppelman <koppel@ece.lsu.edu>
;; Keywords: faces, minor-mode, matching, display

;; This file is part of GNU Emacs.

;; GNU Emacs is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;;
;;  With the hi-lock commands text matching interactively entered
;;  regexp's can be highlighted.  For example, `M-x highlight-regexp
;;  RET clearly RET RET' will highlight all occurrences of `clearly'
;;  using a yellow background face.  New occurrences of `clearly' will
;;  be highlighted as they are typed.  `M-x unhighlight-regexp RET'
;;  will remove the highlighting.  Any existing face can be used for
;;  highlighting and a set of appropriate faces is provided.  The
;;  regexps can be written into the current buffer in a form that will
;;  be recognized the next time the corresponding file is read (when
;;  file patterns is turned on).
;;
;;  Applications:
;;
;;    In program source code highlight a variable to quickly see all
;;    places it is modified or referenced:
;;    M-x highlight-regexp RET ground_contact_switches_closed RET RET
;;
;;    In a shell or other buffer that is showing lots of program
;;    output, highlight the parts of the output you're interested in:
;;    M-x highlight-regexp RET Total execution time [0-9]+ RET hi-blue-b RET
;;
;;    In buffers displaying tables, highlight the lines you're interested in:
;;    M-x highlight-lines-matching-regexp RET January 2000 RET hi-black-b RET
;;
;;    When writing text, highlight personal cliches.  This can be
;;    amusing.
;;    M-x highlight-phrase RET as can be seen RET RET
;;
;;  Setup:
;;
;;    Put the following code in your init file.  This turns on
;;    hi-lock mode and adds a "Regexp Highlighting" entry
;;    to the edit menu.
;;
;;    (global-hi-lock-mode 1)
;;
;;    To enable the use of patterns found in files (presumably placed
;;    there by hi-lock) include the following in your init file:
;;
;;    (setq hi-lock-file-patterns-policy 'ask)
;;
;;    If you get tired of being asked each time a file is loaded replace
;;    `ask' with a function that returns t if patterns should be read.
;;
;;    You might also want to bind the hi-lock commands to more
;;    finger-friendly sequences:

;;    (define-key hi-lock-map "\C-z\C-h" 'highlight-lines-matching-regexp)
;;    (define-key hi-lock-map "\C-zi" 'hi-lock-find-patterns)
;;    (define-key hi-lock-map "\C-zh" 'highlight-regexp)
;;    (define-key hi-lock-map "\C-zp" 'highlight-phrase)
;;    (define-key hi-lock-map "\C-zr" 'unhighlight-regexp)
;;    (define-key hi-lock-map "\C-zb" 'hi-lock-write-interactive-patterns))

;;    See the documentation for hi-lock-mode `C-h f hi-lock-mode' for
;;    additional instructions.

;; Sample file patterns:

; Hi-lock: (("^;;; .*" (0 (quote hi-black-hb) t)))
; Hi-lock: ( ("make-variable-buffer-\\(local\\)" (0 font-lock-keyword-face)(1 'italic append)))))
; Hi-lock: end

;;; Code:

(require 'font-lock)

(defgroup hi-lock nil
  "Interactively add and remove font-lock patterns for highlighting text."
  :link '(custom-manual "(emacs)Highlight Interactively")
  :group 'font-lock)

(defcustom hi-lock-file-patterns-range 10000
  "Limit of search in a buffer for hi-lock patterns.
When a file is visited and hi-lock mode is on, patterns starting
up to this limit are added to font-lock's patterns.  See documentation
of functions `hi-lock-mode' and `hi-lock-find-patterns'."
  :type 'integer
  :group 'hi-lock)

(defcustom hi-lock-highlight-range 200000
  "Size of area highlighted by hi-lock when font-lock not active.
Font-lock is not active in buffers that do their own highlighting,
such as the buffer created by `list-colors-display'.  In those buffers
hi-lock patterns will only be applied over a range of
`hi-lock-highlight-range' characters.  If font-lock is active then
highlighting will be applied throughout the buffer."
  :type 'integer
  :group 'hi-lock)

(defcustom hi-lock-exclude-modes
  '(rmail-mode mime/viewer-mode gnus-article-mode)
  "List of major modes in which hi-lock will not run.
For security reasons since font lock patterns can specify function
calls."
  :type '(repeat symbol)
  :group 'hi-lock)

(defcustom hi-lock-file-patterns-policy 'ask
  "Specify when hi-lock should use patterns found in file.
If `ask', prompt when patterns found in buffer; if bound to a function,
use patterns when function returns t (function is called with patterns
as first argument); if nil or `never' or anything else, don't use file
patterns."
  :type '(choice (const :tag "Do not use file patterns" never)
                 (const :tag "Ask about file patterns" ask)
                 (function :tag "Function to check file patterns"))
  :group 'hi-lock
  :version "22.1")

;; It can have a function value.
(put 'hi-lock-file-patterns-policy 'risky-local-variable t)

(defcustom hi-lock-auto-select-face nil
  "Non-nil means highlighting commands do not prompt for the face to use.
Instead, each hi-lock command will cycle through the faces in
`hi-lock-face-defaults'."
  :type 'boolean
  :version "24.4")

(defcustom hi-lock-file-name-specifier "\\(-\\*- \\)hi-lock-patterns-file"
  "Expression used to find the name of a file to read hi-lock
highlighting-patterns from.

The default is set such that a line specifying the file variable
`hi-lock-patterns-file' can be found.

Please see `hi-lock-get-patterns-file-name' for how this
expression is used."
  :type '(string)
  :group 'hi-lock)
(put 'hi-lock-patterns-file 'safe-local-variable #'stringp)

(defcustom hi-lock-patterns-end-marker "hi-lock-patterns-end"
  "Expression used to mark the end of hi-lock highlighting-patterns in
a buffer dedicated to holding such patterns.  This can be a regular
expression.

The expression that will be searched for is the return value of
`hi-lock-make-reasonable-end-marker'.  It is appended to the buffer,
in a new line, by `hi-lock-write-patterns-file'.

`hi-lock-get-patterns-from-file' uses it to figure out when to stop
reading the buffer."
  :type '(string)
  :group 'hi-lock)

(defgroup hi-lock-faces nil
  "Faces for hi-lock."
  :group 'hi-lock
  :group 'faces)

(defface hi-yellow
  '((((min-colors 88) (background dark))
     (:background "yellow1" :foreground "black"))
    (((background dark)) (:background "yellow" :foreground "black"))
    (((min-colors 88)) (:background "yellow1"))
    (t (:background "yellow")))
  "Default face for hi-lock mode."
  :group 'hi-lock-faces)

(defface hi-pink
  '((((background dark)) (:background "pink" :foreground "black"))
    (t (:background "pink")))
  "Face for hi-lock mode."
  :group 'hi-lock-faces)

(defface hi-green
  '((((min-colors 88) (background dark))
     (:background "light green" :foreground "black"))
    (((background dark)) (:background "green" :foreground "black"))
    (((min-colors 88)) (:background "light green"))
    (t (:background "green")))
  "Face for hi-lock mode."
  :group 'hi-lock-faces)

(defface hi-blue
  '((((background dark)) (:background "light blue" :foreground "black"))
    (t (:background "light blue")))
  "Face for hi-lock mode."
  :group 'hi-lock-faces)

(defface hi-black-b
  '((t (:weight bold)))
  "Face for hi-lock mode."
  :group 'hi-lock-faces)

(defface hi-blue-b
  '((((min-colors 88)) (:weight bold :foreground "blue1"))
    (t (:weight bold :foreground "blue")))
  "Face for hi-lock mode."
  :group 'hi-lock-faces)

(defface hi-green-b
  '((((min-colors 88)) (:weight bold :foreground "green1"))
    (t (:weight bold :foreground "green")))
  "Face for hi-lock mode."
  :group 'hi-lock-faces)

(defface hi-red-b
  '((((min-colors 88)) (:weight bold :foreground "red1"))
    (t (:weight bold :foreground "red")))
  "Face for hi-lock mode."
  :group 'hi-lock-faces)

(defface hi-black-hb
  '((t (:weight bold :height 1.67 :inherit variable-pitch)))
  "Face for hi-lock mode."
  :group 'hi-lock-faces)

(defface hi-global-variable
  '((t (:foreground "Magenta")))
  "Face to highlight global variables."
  :group 'hi-lock-faces)

(defface hi-functionlike
  '((t (:foreground "LightGreen")))
  "Face to highlight something that is like a function."
  :group 'hi-lock-faces)

(defface hi-constant
  '((t (:foreground "brown4")))
  "Face to highlight something that is a constant."
  :group 'hi-faces)

(defvar-local hi-lock-file-patterns nil
  "Patterns found in file for hi-lock.  Should not be changed.")
(put 'hi-lock-file-patterns 'permanent-local t)

(defvar-local hi-lock-patterns-file nil
  "Remember the name of the file to read hi-lock highlighting-patterns
  for this buffer from.

Use this as buffer or dir local variable.")
(put 'hi-lock-patterns-file 'permanent-local t)

(defvar-local hi-lock-interactive-patterns nil
  "Patterns provided to hi-lock by user.  Should not be changed.")
(put 'hi-lock-interactive-patterns 'permanent-local t)

(define-obsolete-variable-alias 'hi-lock-face-history
                                'hi-lock-face-defaults "23.1")
(defvar hi-lock-face-defaults
  '("hi-yellow" "hi-pink" "hi-green" "hi-blue" "hi-black-b"
    "hi-blue-b" "hi-red-b" "hi-green-b" "hi-black-hb")
  "Default faces for hi-lock interactive functions.")

(define-obsolete-variable-alias 'hi-lock-regexp-history
                                'regexp-history
                                "23.1")

(defvar hi-lock-file-patterns-prefix "Hi-lock"
  "Search target for finding hi-lock patterns at top of file.")

(defvar hi-lock-archaic-interface-message-used nil
  "True if user alerted that `global-hi-lock-mode' is now the global switch.
Earlier versions of hi-lock used `hi-lock-mode' as the global switch;
the message is issued if it appears that `hi-lock-mode' is used assuming
that older functionality.  This variable avoids multiple reminders.")

(defvar hi-lock-archaic-interface-deduce nil
  "If non-nil, sometimes assume that `hi-lock-mode' means `global-hi-lock-mode'.
Assumption is made if `hi-lock-mode' used in the *scratch* buffer while
a library is being loaded.")

(defvar hi-lock-menu
  (let ((map (make-sparse-keymap "Hi Lock")))
    (define-key-after map [highlight-regexp]
      '(menu-item "Highlight Regexp..." highlight-regexp
		  :help "Highlight text matching PATTERN (a regexp)."))

    (define-key-after map [highlight-phrase]
      '(menu-item "Highlight Phrase..." highlight-phrase
		  :help "Highlight text matching PATTERN (a regexp processed to match phrases)."))

    (define-key-after map [highlight-lines-matching-regexp]
      '(menu-item "Highlight Lines..." highlight-lines-matching-regexp
		  :help "Highlight lines containing match of PATTERN (a regexp)."))

    (define-key-after map [highlight-symbol-at-point]
      '(menu-item "Highlight Symbol at Point" highlight-symbol-at-point
		  :help "Highlight symbol found near point without prompting."))

    (define-key-after map [unhighlight-regexp]
      '(menu-item "Remove Highlighting..." unhighlight-regexp
		  :help "Remove previously entered highlighting pattern."
		  :enable hi-lock-interactive-patterns))

    (define-key-after map [hi-lock-write-interactive-patterns]
      '(menu-item "Patterns to Buffer" hi-lock-write-interactive-patterns
		  :help "Insert interactively added REGEXPs into buffer at point."
		  :enable hi-lock-interactive-patterns))

    (define-key-after map [hi-lock-find-patterns]
      '(menu-item "Patterns from Buffer" hi-lock-find-patterns
		  :help "Use patterns (if any) near top of buffer."))

    (define-key-after map [hi-lock-constant]
      '(menu-item "Highlight constant" hi-lock-constant
		  :help "Highlight something at point that is a constant."))

    (define-key-after map [hi-lock-functionlike]
      '(menu-item "Highlight functionlike" hi-lock-functionlike
		  :help "Highlight something at point that is like a function."))

    (define-key-after map [hi-lock-global-variable]
      '(menu-item "Highlight global variable" hi-lock-global-variable
		  :help "Highlight something at point that is a global variable."))

    (define-key-after map [hi-lock-revert-patterns-from-file]
      '(menu-item "Revert patterns from buffer" hi-lock-revert-patterns-from-file
		  :help "Revert all highlighting patters to the patterns in the dedicated buffer."
		  :enable hi-lock-patterns-file))

    (define-key-after map [hi-lock-revert-patterns-file-name]
      '(menu-item "Revert name of patterns-file" hi-lock-revert-patterns-file-name
		  :help "Revert the name of the file storing the highlighting patterns."))
    map)
  "Menu for hi-lock mode.")

(defvar hi-lock-map
  (let ((map (make-sparse-keymap "Hi Lock")))
    (define-key map "\C-xwi" 'hi-lock-find-patterns)
    (define-key map "\C-xwl" 'highlight-lines-matching-regexp)
    (define-key map "\C-xwp" 'highlight-phrase)
    (define-key map "\C-xwh" 'highlight-regexp)
    (define-key map "\C-xw." 'highlight-symbol-at-point)
    (define-key map "\C-xwr" 'unhighlight-regexp)
    (define-key map "\C-xwb" 'hi-lock-write-interactive-patterns)
    (define-key map "\C-xwc" 'hi-lock-constant)
    (define-key map "\C-xwf" 'hi-lock-functionlike)
    (define-key map "\C-xwg" 'hi-lock-global-variable)
    (define-key map "\C-xw!" 'hi-lock-revert-patterns-from-file)
    (define-key map "\C-xwn" 'hi-lock-revert-patterns-file-name)
    map)
  "Key map for hi-lock.")

;; Visible Functions

;;;###autoload
(define-minor-mode hi-lock-mode
  "Toggle selective highlighting of patterns (Hi Lock mode).
With a prefix argument ARG, enable Hi Lock mode if ARG is
positive, and disable it otherwise.  If called from Lisp, enable
the mode if ARG is omitted or nil.

Hi Lock mode is automatically enabled when you invoke any of the
highlighting commands listed below, such as \\[highlight-regexp].
To enable Hi Lock mode in all buffers, use `global-hi-lock-mode'
or add (global-hi-lock-mode 1) to your init file.

In buffers where Font Lock mode is enabled, patterns are
highlighted using font lock.  In buffers where Font Lock mode is
disabled, patterns are applied using overlays; in this case, the
highlighting will not be updated as you type.

When Hi Lock mode is enabled, a \"Regexp Highlighting\" submenu
is added to the \"Edit\" menu.  The commands in the submenu,
which can be called interactively, are:

\\[highlight-regexp] REGEXP FACE
  Highlight matches of pattern REGEXP in current buffer with FACE.

\\[highlight-phrase] PHRASE FACE
  Highlight matches of phrase PHRASE in current buffer with FACE.
  (PHRASE can be any REGEXP, but spaces will be replaced by matches
  to whitespace and initial lower-case letters will become case insensitive.)

\\[highlight-lines-matching-regexp] REGEXP FACE
  Highlight lines containing matches of REGEXP in current buffer with FACE.

\\[highlight-symbol-at-point]
  Highlight the symbol found near point without prompting, using the next
  available face automatically.

\\[unhighlight-regexp] REGEXP
  Remove highlighting on matches of REGEXP in current buffer.

\\[hi-lock-write-interactive-patterns]
  Write active REGEXPs into buffer as comments (if possible).  They may
  be read the next time file is loaded or when the \\[hi-lock-find-patterns] command
  is issued.  The inserted regexps are in the form of font lock keywords.
  (See `font-lock-keywords'.)  They may be edited and re-loaded with \\[hi-lock-find-patterns],
  any valid `font-lock-keywords' form is acceptable.  When a file is
  loaded the patterns are read if `hi-lock-file-patterns-policy' is
  'ask and the user responds y to the prompt, or if
  `hi-lock-file-patterns-policy' is bound to a function and that
  function returns t.

\\[hi-lock-find-patterns]
  Re-read patterns stored in buffer (in the format produced by \\[hi-lock-write-interactive-patterns]).

When hi-lock is started and if the mode is not excluded or patterns
rejected, the beginning of the buffer is searched for lines of the
form:
  Hi-lock: FOO

where FOO is a list of patterns.  The patterns must start before
position \(number of characters into buffer)
`hi-lock-file-patterns-range'.  Patterns will be read until
Hi-lock: end is found.  A mode is excluded if it's in the list
`hi-lock-exclude-modes'.

\\[hi-lock-revert-patterns-file-name]
  Search the current buffer for the variable
  `hi-lock-patterns-file' and set it (to a potentially new value)
  even when this variable is already set.

This variable is used to specify a file in which to store
highlighting-patterns.  This allows you to keep the patterns in a
separate file which can be shared among multiple files.  This is
particularly useful when editing source code because you can use
a single file with highlighting-patterns which is shared by
multiple files of the same project.

When using a separate file, highlighting-patterns can still be
written to the current buffer with
\\[hi-lock-write-interactive-patterns].  Both the patterns from
the current buffer and from the separate file apply.

The file with the highlighting-patterns is transparently
maintained in a dedicated buffer.  The dedicated buffer is
automatically saved to `hi-lock-patterns-file' when the current
buffer is saved.

You can specify `hi-lock-patterns-file' as a buffer-local
variable.  Please note that the value of this variable (the file
name) must be given in double-quotes.

Please see also `hi-lock-file-name-specifier'.

\\[hi-lock-constant]
  Highlight the thing at point with the `hi-constant' face.

\\[hi-lock-functionlike]
  Highlight the thing at point with the `hi-functionlike' face.

\\[hi-lock-global-variable]
  Highlight the thing at point with the `hi-global' face.

\\[hi-lock-revert-patterns-from-file]
  Revert the currently used highlighting-patterns to the patterns
  in `hi-lock-patterns-file'.

\\[hi-lock-revert-patterns-file-name]
  Once `hi-lock-patterns-file' has been set, the current buffer
  is not searched again for a line specifying this variable.  You
  can revert to the value specified in the current buffer with
  \\[hi-lock-revert-patterns-file-name].  This is for instances
  when you modified the value of the variable and want the new
  value take effect."
  :group 'hi-lock
  :lighter (:eval (if (or hi-lock-interactive-patterns
			  hi-lock-file-patterns)
		      " Hi" ""))
  :global nil
  :keymap hi-lock-map
  (when (and (equal (buffer-name) "*scratch*")
             load-in-progress
             (not (called-interactively-p 'interactive))
             (not hi-lock-archaic-interface-message-used))
    (setq hi-lock-archaic-interface-message-used t)
    (if hi-lock-archaic-interface-deduce
        (global-hi-lock-mode hi-lock-mode)
      (warn
       "Possible archaic use of (hi-lock-mode).
Use (global-hi-lock-mode 1) in .emacs to enable hi-lock for all buffers,
use (hi-lock-mode 1) for individual buffers.  For compatibility with Emacs
versions before 22 use the following in your init file:

        (if (functionp 'global-hi-lock-mode)
            (global-hi-lock-mode 1)
          (hi-lock-mode 1))
")))
  (if hi-lock-mode
      ;; Turned on.
      (progn
	(define-key-after menu-bar-edit-menu [hi-lock]
	  (cons "Regexp Highlighting" hi-lock-menu))
	;; order does matter, see `hi-lock-apply-patterns-from-file'
	(hi-lock-find-patterns)
	(hi-lock-apply-patterns-from-file)
	(add-hook 'after-save-hook 'hi-lock-write-patterns-file t t)
        (add-hook 'font-lock-mode-hook 'hi-lock-font-lock-hook nil t)
        ;; Remove regexps from font-lock-keywords (bug#13891).
	(add-hook 'change-major-mode-hook (lambda () (hi-lock-mode -1)) nil t))
    ;; Turned off.
    (when (or hi-lock-interactive-patterns
	      hi-lock-file-patterns)
      (when hi-lock-interactive-patterns
	(font-lock-remove-keywords nil hi-lock-interactive-patterns)
	(setq hi-lock-interactive-patterns nil))
      (when hi-lock-file-patterns
	(font-lock-remove-keywords nil hi-lock-file-patterns)
	(setq hi-lock-file-patterns nil))
      (remove-overlays nil nil 'hi-lock-overlay t)
      (when font-lock-fontified (font-lock-fontify-buffer)))
    (define-key-after menu-bar-edit-menu [hi-lock] nil)
    (remove-hook 'font-lock-mode-hook 'hi-lock-font-lock-hook t)
    (remove-hook 'after-save-hook 'hi-lock-write-patterns-file t)))

;;;###autoload
(define-globalized-minor-mode global-hi-lock-mode
  hi-lock-mode turn-on-hi-lock-if-enabled
  :group 'hi-lock)

(defun turn-on-hi-lock-if-enabled ()
  (setq hi-lock-archaic-interface-message-used t)
  (unless (memq major-mode hi-lock-exclude-modes)
    (hi-lock-mode 1)))

;;;###autoload
(defalias 'highlight-lines-matching-regexp 'hi-lock-line-face-buffer)
;;;###autoload
(defun hi-lock-line-face-buffer (regexp &optional face)
  "Set face of all lines containing a match of REGEXP to FACE.
Interactively, prompt for REGEXP using `read-regexp', then FACE.
Use the global history list for FACE.

Use Font lock mode, if enabled, to highlight REGEXP.  Otherwise,
use overlays for highlighting.  If overlays are used, the
highlighting will not update as you type."
  (interactive
   (list
    (hi-lock-regexp-okay
     (read-regexp "Regexp to highlight line" 'regexp-history-last))
    (hi-lock-read-face-name)))
  (or (facep face) (setq face 'hi-yellow))
  (unless hi-lock-mode (hi-lock-mode 1))
  (hi-lock-set-pattern
   ;; The \\(?:...\\) grouping construct ensures that a leading ^, +, * or ?
   ;; or a trailing $ in REGEXP will be interpreted correctly.
   (concat "^.*\\(?:" regexp "\\).*$") face))


;;;###autoload
(defalias 'highlight-regexp 'hi-lock-face-buffer)
;;;###autoload
(defun hi-lock-face-buffer (regexp &optional face)
  "Set face of each match of REGEXP to FACE.
Interactively, prompt for REGEXP using `read-regexp', then FACE.
Use the global history list for FACE.

Use Font lock mode, if enabled, to highlight REGEXP.  Otherwise,
use overlays for highlighting.  If overlays are used, the
highlighting will not update as you type."
  (interactive
   (list
    (hi-lock-regexp-okay
     (read-regexp "Regexp to highlight" 'regexp-history-last))
    (hi-lock-read-face-name)))
  (or (facep face) (setq face 'hi-yellow))
  (unless hi-lock-mode (hi-lock-mode 1))
  (hi-lock-set-pattern regexp face))

;;;###autoload
(defalias 'highlight-phrase 'hi-lock-face-phrase-buffer)
;;;###autoload
(defun hi-lock-face-phrase-buffer (regexp &optional face)
  "Set face of each match of phrase REGEXP to FACE.
Interactively, prompt for REGEXP using `read-regexp', then FACE.
Use the global history list for FACE.

When called interactively, replace whitespace in user-provided
regexp with arbitrary whitespace, and make initial lower-case
letters case-insensitive, before highlighting with `hi-lock-set-pattern'.

Use Font lock mode, if enabled, to highlight REGEXP.  Otherwise,
use overlays for highlighting.  If overlays are used, the
highlighting will not update as you type."
  (interactive
   (list
    (hi-lock-regexp-okay
     (hi-lock-process-phrase
      (read-regexp "Phrase to highlight" 'regexp-history-last)))
    (hi-lock-read-face-name)))
  (or (facep face) (setq face 'hi-yellow))
  (unless hi-lock-mode (hi-lock-mode 1))
  (hi-lock-set-pattern regexp face))

;;;###autoload
(defalias 'highlight-symbol-at-point 'hi-lock-face-symbol-at-point)
;;;###autoload
(defun hi-lock-face-symbol-at-point ()
  "Highlight each instance of the symbol at point.
Uses the next face from `hi-lock-face-defaults' without prompting,
unless you use a prefix argument.
Uses `find-tag-default-as-symbol-regexp' to retrieve the symbol at point.

This uses Font lock mode if it is enabled; otherwise it uses overlays,
in which case the highlighting will not update as you type."
  (interactive)
  (let* ((regexp (hi-lock-regexp-okay
		  (find-tag-default-as-symbol-regexp)))
	 (hi-lock-auto-select-face t)
	 (face (hi-lock-read-face-name)))
    (or (facep face) (setq face 'hi-yellow))
    (unless hi-lock-mode (hi-lock-mode 1))
    (hi-lock-set-pattern regexp face)))

(defun hi-lock-keyword->face (keyword)
  (cadr (cadr (cadr keyword))))    ; Keyword looks like (REGEXP (0 'FACE) ...).

(declare-function x-popup-menu "menu.c" (position menu))

(defun hi-lock--regexps-at-point ()
  (let ((regexps '()))
    ;; When using overlays, there is no ambiguity on the best
    ;; choice of regexp.
    (let ((regexp (get-char-property (point) 'hi-lock-overlay-regexp)))
      (when regexp (push regexp regexps)))
    ;; With font-locking on, check if the cursor is on a highlighted text.
    (let ((face-after (get-text-property (point) 'face))
          (face-before
           (unless (bobp) (get-text-property (1- (point)) 'face)))
          (faces (mapcar #'hi-lock-keyword->face
                         hi-lock-interactive-patterns)))
      (unless (memq face-before faces) (setq face-before nil))
      (unless (memq face-after faces) (setq face-after nil))
      (when (and face-before face-after (not (eq face-before face-after)))
        (setq face-before nil))
      (when (or face-after face-before)
        (let* ((hi-text
                (buffer-substring-no-properties
                 (if face-before
                     (or (previous-single-property-change (point) 'face)
                         (point-min))
                   (point))
                 (if face-after
                     (or (next-single-property-change (point) 'face)
                         (point-max))
                   (point)))))
          ;; Compute hi-lock patterns that match the
          ;; highlighted text at point.  Use this later in
          ;; during completing-read.
          (dolist (hi-lock-pattern hi-lock-interactive-patterns)
            (let ((regexp (car hi-lock-pattern)))
              (if (string-match regexp hi-text)
                  (push regexp regexps)))))))
    regexps))

(defvar-local hi-lock--unused-faces nil
  "List of faces that is not used and is available for highlighting new text.
Face names from this list come from `hi-lock-face-defaults'.")

;;;###autoload
(defalias 'unhighlight-regexp 'hi-lock-unface-buffer)
;;;###autoload
(defun hi-lock-unface-buffer (regexp)
  "Remove highlighting of each match to REGEXP set by hi-lock.
Interactively, prompt for REGEXP, accepting only regexps
previously inserted by hi-lock interactive functions.
If REGEXP is t (or if \\[universal-argument] was specified interactively),
then remove all hi-lock highlighting."
  (interactive
   (cond
    (current-prefix-arg (list t))
    ((and (display-popup-menus-p)
          (listp last-nonmenu-event)
          use-dialog-box)
     (catch 'snafu
       (or
        (x-popup-menu
         t
         (cons
          `keymap
          (cons "Select Pattern to Unhighlight"
                (mapcar (lambda (pattern)
                          (list (car pattern)
                                (format
                                 "%s (%s)" (car pattern)
                                 (hi-lock-keyword->face pattern))
                                (cons nil nil)
                                (car pattern)))
                        hi-lock-interactive-patterns))))
        ;; If the user clicks outside the menu, meaning that they
        ;; change their mind, x-popup-menu returns nil, and
        ;; interactive signals a wrong number of arguments error.
        ;; To prevent that, we return an empty string, which will
        ;; effectively disable the rest of the function.
        (throw 'snafu '("")))))
    (t
     ;; Un-highlighting triggered via keyboard action.
     (unless hi-lock-interactive-patterns
       (error "No highlighting to remove"))
     ;; Infer the regexp to un-highlight based on cursor position.
     (let* ((defaults (or (hi-lock--regexps-at-point)
                          (mapcar #'car hi-lock-interactive-patterns))))
       (list
        (completing-read (if (null defaults)
                             "Regexp to unhighlight: "
                           (format "Regexp to unhighlight (default %s): "
                                   (car defaults)))
                         hi-lock-interactive-patterns
			 nil t nil nil defaults))))))
  (dolist (keyword (if (eq regexp t) hi-lock-interactive-patterns
                     (list (assoc regexp hi-lock-interactive-patterns))))
    (when keyword
      (let ((face (hi-lock-keyword->face keyword)))
        ;; Make `face' the next one to use by default.
        (when (symbolp face)          ;Don't add it if it's a list (bug#13297).
          (add-to-list 'hi-lock--unused-faces (face-name face))))
      (font-lock-remove-keywords nil (list keyword))
      (setq hi-lock-interactive-patterns
            (delq keyword hi-lock-interactive-patterns))
      (remove-overlays
       nil nil 'hi-lock-overlay-regexp (hi-lock--hashcons (car keyword)))
      (when font-lock-fontified (font-lock-fontify-buffer)))))

;;;###autoload
(defun hi-lock-write-interactive-patterns ()
  "Write interactively added patterns, if any, into buffer at point.

Interactively added patterns are those normally specified using
`highlight-regexp' and `highlight-lines-matching-regexp'; they can
be found in variable `hi-lock-interactive-patterns'."
  (interactive)
  (if (null hi-lock-interactive-patterns)
      (error "There are no interactive patterns"))
  (let ((beg (point)))
    (mapc
     (lambda (pattern)
       (insert (format "%s: (%s)\n"
		       hi-lock-file-patterns-prefix
		       (prin1-to-string pattern))))
     hi-lock-interactive-patterns)
    (comment-region beg (point)))
  (when (> (point) hi-lock-file-patterns-range)
    (warn "Inserted keywords not close enough to top of file")))

(defsubst hi-lock-comment-start-protected ()
  "Since `comment-start' can sometimes be nil, return a default
for such instances, otherwise return `comment-start'."
  (or comment-start "# "))

(defun hi-lock-get-patterns-file-name (&optional force)
  "When `hi-lock-patterns-file' is not nil, attempt to set it from
`hi-lock-file-name-specifier' by searching the current buffer, unless
the variable is already set.

When the optional argument FOCE is not nil, attempt to set the
variable regardless whether it is already set or not.

The search is limited to between `point-min' and (+ (point-min) 1024)."
  (interactive)
  (unless (or
	   (not force)
	   hi-lock-patterns-file)
    (save-excursion
      (save-restriction
	(widen)
	(goto-char (point-min))
	(let ((file-name-specifier
	       (concat "^" (hi-lock-comment-start-protected) "[:space:]*" hi-lock-file-name-specifier ": ")))
	  (when (re-search-forward file-name-specifier (+ (point) 1024) t)
	    (when (looking-at "\\\"") (forward-char)
		  (setq hi-lock-patterns-file (thing-at-point 'filename t)))))))))

(defun hi-lock-revert-patterns-file-name ()
  "Use `hi-lock-get-patterns-file-name' to revert
`hi-lock-patterns-file' even when `hi-lock-patterns-file' is
already set."
  (interactive)
  (hi-lock-get-patterns-file-name t)
  (message "use highlighting-patterns from %s"
	   hi-lock-patterns-file))

(defsubst hi-lock-make-reasonable-end-marker (for-writing)
  "Return a regex which is a reasonable end-marker to indicate where
 hi-lock highlighting-patterns inserted into a dedicated buffer
 end. Reasonable particularly means that the marker shall be usable
 even when `comment-start' is nil.

When the argument 'for-writing' is nil, return a regex which matches
the end-marker used in the patterns´ buffer.

Otherwise, the returned marker is suited to be appended to a buffer."
  (if for-writing
      (concat (hi-lock-comment-start-protected) hi-lock-patterns-end-marker)
    (concat "^" (hi-lock-comment-start-protected) "\\_<" hi-lock-patterns-end-marker "\\_>")))

(defun hi-lock-quick-add (whichface)
  "Highlight something at point with a face given in whichface."
  (let* ((regexp (hi-lock-regexp-okay (find-tag-default-as-symbol-regexp))))
    (hi-lock-set-pattern regexp whichface))
  ;; set modified to get the dedicated patterns buffer updated
  (if hi-lock-patterns-file
      (set-buffer-modified-p t)
    (message "The variable `hi-lock-patterns-file' needs to be set to specify a dedicated buffer to store patterns." )))

(defun hi-lock-constant ()
  "Add a pattern to highlight something at point that is a
constant."
  (interactive)
  (hi-lock-quick-add 'hi-constant))

(defun hi-lock-functionlike ()
  "Add a pattern to highlight something at point that is like a
function."
  (interactive)
  (hi-lock-quick-add 'hi-functionlike))

(defun hi-lock-global-variable ()
  "Add a pattern to highlight something at point that is a
global variable."
  (interactive)
  (hi-lock-quick-add 'hi-global-variable))

;; Implementation Functions

(defun hi-lock-process-phrase (phrase)
  "Convert regexp PHRASE to a regexp that matches phrases.

Blanks in PHRASE replaced by regexp that matches arbitrary whitespace
and initial lower-case letters made case insensitive."
  (let ((mod-phrase nil))
    ;; FIXME fragile; better to just bind case-fold-search?  (Bug#7161)
    (setq mod-phrase
          (replace-regexp-in-string
           "\\(^\\|\\s-\\)\\([a-z]\\)"
           (lambda (m) (format "%s[%s%s]"
                               (match-string 1 m)
                               (upcase (match-string 2 m))
                               (match-string 2 m))) phrase))
    ;; FIXME fragile; better to use search-spaces-regexp?
    (setq mod-phrase
          (replace-regexp-in-string
           "\\s-+" "[ \t\n]+" mod-phrase nil t))))

(defun hi-lock-regexp-okay (regexp)
  "Return REGEXP if it appears suitable for a font-lock pattern.

Otherwise signal an error.  A pattern that matches the null string is
not suitable."
  (cond
   ((null regexp)
    (error "Regexp cannot match nil"))
   ((string-match regexp "")
    (error "Regexp cannot match an empty string"))
   (t regexp)))

(defun hi-lock-read-face-name ()
  "Return face for interactive highlighting.
When `hi-lock-auto-select-face' is non-nil, just return the next face.
Otherwise, or with a prefix argument, read a face from the minibuffer
with completion and history."
  (unless hi-lock-interactive-patterns
    (setq hi-lock--unused-faces hi-lock-face-defaults))
  (let* ((last-used-face
	  (when hi-lock-interactive-patterns
	    (face-name (hi-lock-keyword->face
                        (car hi-lock-interactive-patterns)))))
	 (defaults (append hi-lock--unused-faces
			   (cdr (member last-used-face hi-lock-face-defaults))
			   hi-lock-face-defaults))
	 face)
          (if (and hi-lock-auto-select-face (not current-prefix-arg))
	(setq face (or (pop hi-lock--unused-faces) (car defaults)))
      (setq face (completing-read
		  (format "Highlight using face (default %s): "
			  (car defaults))
		  obarray 'facep t nil 'face-name-history defaults))
      ;; Update list of un-used faces.
      (setq hi-lock--unused-faces (remove face hi-lock--unused-faces))
      ;; Grow the list of defaults.
      (add-to-list 'hi-lock-face-defaults face t))
    (intern face)))

(defun hi-lock-set-pattern (regexp face)
  "Highlight REGEXP with face FACE."
  ;; Hashcons the regexp, so it can be passed to remove-overlays later.
  (setq regexp (hi-lock--hashcons regexp))
  (let ((pattern (list regexp (list 0 (list 'quote face) 'prepend))))
    ;; Refuse to highlight a text that is already highlighted.
    (unless (assoc regexp hi-lock-interactive-patterns)
      (push pattern hi-lock-interactive-patterns)
      (if (and font-lock-mode (font-lock-specified-p major-mode))
	  (progn
	    (font-lock-add-keywords nil (list pattern) t)
	    (font-lock-fontify-buffer))
        (let* ((range-min (- (point) (/ hi-lock-highlight-range 2)))
               (range-max (+ (point) (/ hi-lock-highlight-range 2)))
               (search-start
                (max (point-min)
                     (- range-min (max 0 (- range-max (point-max))))))
               (search-end
                (min (point-max)
                     (+ range-max (max 0 (- (point-min) range-min))))))
          (save-excursion
            (goto-char search-start)
            (while (re-search-forward regexp search-end t)
              (let ((overlay (make-overlay (match-beginning 0) (match-end 0))))
                (overlay-put overlay 'hi-lock-overlay t)
                (overlay-put overlay 'hi-lock-overlay-regexp regexp)
                (overlay-put overlay 'face face))
              (goto-char (match-end 0)))))))))

(defun hi-lock-set-file-patterns (patterns)
  "Replace file patterns list with PATTERNS and refontify."
  (when (or hi-lock-file-patterns patterns)
    (font-lock-remove-keywords nil hi-lock-file-patterns)
    (setq hi-lock-file-patterns patterns)
    (font-lock-add-keywords nil hi-lock-file-patterns t)
    (font-lock-fontify-buffer)))

(defun hi-lock-find-patterns ()
  "Find patterns in current buffer for hi-lock."
  (interactive)
  (unless (memq major-mode hi-lock-exclude-modes)
    (let ((all-patterns nil)
          (target-regexp (concat "\\<" hi-lock-file-patterns-prefix ":")))
      (save-excursion
	(save-restriction
	  (widen)
	  (goto-char (point-min))
	  (re-search-forward target-regexp
			     (+ (point) hi-lock-file-patterns-range) t)
	  (beginning-of-line)
	  (while (and (re-search-forward target-regexp (+ (point) 100) t)
		      (not (looking-at "\\s-*end")))
            (condition-case nil
                (setq all-patterns (append (read (current-buffer)) all-patterns))
              (error (message "Invalid pattern list expression at %d"
                              (line-number-at-pos)))))))
      (when (and all-patterns
                 hi-lock-mode
                 (cond
                  ((eq this-command 'hi-lock-find-patterns) t)
                  ((functionp hi-lock-file-patterns-policy)
                   (funcall hi-lock-file-patterns-policy all-patterns))
                  ((eq hi-lock-file-patterns-policy 'ask)
                   (y-or-n-p "Add patterns from this buffer to hi-lock? "))
                  (t nil)))
        (hi-lock-set-file-patterns all-patterns)
        (if (called-interactively-p 'interactive)
            (message "Hi-lock added %d patterns." (length all-patterns)))))))

(defun hi-lock-get-patterns-from-file (file)
  "Read hi-lock-mode highlighting-patterns from a file and return
the patterns read."
  (with-current-buffer
      (find-file-noselect file)
    (goto-char (point-min))
    (let ((marker-pos
	   (re-search-forward (hi-lock-make-reasonable-end-marker nil) (point-max) t)))
      (when marker-pos
	(goto-char marker-pos)
	(forward-line -1)
	(end-of-line)
	(setq marker-pos (point))
	(goto-char (point-min))
	(message "reading hi-lock highlighting-patterns from %s (characters %d..%d)"
		 (buffer-name)
		 (point-min) marker-pos)
	(let ((patterns nil))
	  (while (< (point) marker-pos)
	    (setq patterns (append (read (current-buffer)) patterns)))
	  patterns)))))

(defun hi-lock-apply-patterns-from-file ()
  "Use hi-lock-mode highlighting-patterns from another file with this file.

Which file to read the patterns from is specified through
`hi-lock-file-name-specifier'.  To specify a file, put a line
like


// hi-lock-filename: ../some-file.fontify


into the buffer you want to use the file with.  The file will be
visited in another buffer, and additional patterns are written to
the other buffer and saved to the file when this file is saved."
  (hi-lock-get-patterns-file-name)
  (when hi-lock-patterns-file
    (let ((patterns (hi-lock-get-patterns-from-file hi-lock-patterns-file)))
      ;; add the patterns specified within the current buffer because
      ;; `hi-lock-set-file-patterns' unsets them
      (setq patterns (append hi-lock-file-patterns patterns))
      (if (not patterns)
	  (message "found no patterns to apply to %s in %s"
		   (buffer-name)
		   hi-lock-patterns-file)
	(hi-lock-set-file-patterns patterns)
	(message "%d patterns applied from file %s to buffer %s"
		 (length patterns)
		 hi-lock-patterns-file
		 (buffer-name))))))

(defun hi-lock-write-patterns-file ()
  "When `hi-lock-patterns-file' is not nil, update the dedicated
buffer holding the hi-lock highlighting-patterns and save the
buffer to `hi-lock-patterns-file'."
  (interactive)
  (hi-lock-get-patterns-file-name)
  (when hi-lock-patterns-file
    (let ((all-patterns
	   (delete-dups (append
			 ;; put most recently added into first line of buffer
			 hi-lock-interactive-patterns
			 (hi-lock-get-patterns-from-file hi-lock-patterns-file)))))
      (with-current-buffer
	  (find-file-noselect hi-lock-patterns-file)
	(erase-buffer)
	(mapc
	 (lambda (this)
	   (insert (format "(%s)\n" (prin1-to-string this))))
	 all-patterns)
	(insert (hi-lock-make-reasonable-end-marker t) "\n")
	(save-buffer)))))

(defun hi-lock-revert-patterns-from-file ()
  "Unset all hi-lock highlighting-patterns for the current buffer
and apply patterns from the buffers` patterns file.  Do nothing
when no file for storing the patterns is specified for the
current buffer."
  (interactive)
  (hi-lock-get-patterns-file-name)
  (if (not hi-lock-patterns-file)
      (error "No buffer with patterns to revert to has been set")
    (when hi-lock-interactive-patterns
      (mapc
       (lambda (this)
	 (hi-lock-unface-buffer (car this)))
       hi-lock-interactive-patterns)
      (setq hi-lock-interactive-patterns nil))
    (hi-lock-apply-patterns-from-file)))

(defun hi-lock-font-lock-hook ()
  "Add hi-lock patterns to font-lock's."
  (when font-lock-fontified
    (font-lock-add-keywords nil hi-lock-file-patterns t)
    (font-lock-add-keywords nil hi-lock-interactive-patterns t)))

(defvar hi-lock--hashcons-hash
  (make-hash-table :test 'equal :weakness t)
  "Hash table used to hash cons regexps.")

(defun hi-lock--hashcons (string)
  "Return unique object equal to STRING."
  (or (gethash string hi-lock--hashcons-hash)
      (puthash string string hi-lock--hashcons-hash)))

(defun hi-lock-unload-function ()
  "Unload the Hi-Lock library."
  (global-hi-lock-mode -1)
  ;; continue standard unloading
  nil)

(provide 'hi-lock)

;;; hi-lock.el ends here
