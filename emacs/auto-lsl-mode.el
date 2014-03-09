;; // This program is free software: you can redistribute it and/or
;; // modify it under the terms of the GNU General Public License as
;; // published by the Free Software Foundation, either version 3 of the
;; // License, or (at your option) any later version.
;; //
;; // This program is distributed in the hope that it will be useful, but
;; // WITHOUT ANY WARRANTY; without even the implied warranty of
;; // MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; // General Public License for more details.
;; //
;; // You should have received a copy of the GNU General Public License
;; // along with this program.  If not, see
;; // <http://www.gnu.org/licenses/>.


;; load lsl-mode
;;
(load "~/emacs/lsl-mode")

;; enable it automatically for files named like *.lsl
;;
(lsl-mode-auto-enable)

  

(defun my-reload-lsl ()
  "Reload lsl-mode --- reloads the mode, enables it for all
relevant buffers and adds an entry to auto-mode-alist when
needed."
  (interactive)
  (unload-feature 'lsl-mode)
  (load "~/emacs/lsl-mode")
  (lsl-modeset-all-buffers)
  (lsl-mode-auto-enable)
  (message "lsl-mode reloaded"))


;; yasnippet /w autocomplete
;;
(add-to-list 'load-path "~/emacs/yasnippet")
(require 'yasnippet)
(yas-global-mode 1)
(add-to-list 'yas-snippet-dirs "~/emacs/yasnippet/snippets/lsl-mode")

(add-to-list 'load-path "~/emacs/auto-complete")
(require 'auto-complete-config)
(ac-config-default)
;; (add-to-list 'ac-dictionary-directories "~/emacs/ac-dictionaries")
(setq ac-menu-height 20)

;; (defun my-ac-lsl ()
;;   "set sources for yasnippet with lsl-mode"
;;   (setq ac-sources 'ac-source-yasnippet))

;; (add-hook 'lsl-mode 'my-ac-lsl)

;; (global-hi-lock-mode 1)
