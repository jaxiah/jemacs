;; -*- lexical-binding: t; -*-

;;; my-builtins.el --- vanilla Emacs behavior and built-in conveniences

;; These settings intentionally stay close to ordinary Emacs.  They provide
;; the useful, low-surprise parts of the larger configurations without
;; introducing a modal editing layer.

(require 'ibuffer)
(require 'ls-lisp)
(require 'recentf)
(require 'savehist)
(require 'uniquify)

;; Familiar editing behavior retained from the previous configuration.
(delete-selection-mode 1)
(global-auto-revert-mode 1)
(save-place-mode 1)
(winner-mode 1)
(show-paren-mode 1)
(electric-pair-mode 1)
(windmove-default-keybindings)

;; Display line numbers only where they help.  Other modes retain Emacs's
;; default, so they need no explicit disabling hooks.
(dolist (hook '(prog-mode-hook conf-mode-hook))
  (add-hook hook #'display-line-numbers-mode))

;; Emacs's built-in ls-lisp handles Unicode and Windows paths more reliably
;; than an external `ls'.
(setq ls-lisp-dirs-first t
      ls-lisp-use-insert-directory-program nil)

;; Persistent minibuffer and file history.
(setq recentf-max-saved-items 300
      recentf-max-menu-items 100
      recentf-auto-cleanup 'never
      savehist-additional-variables
      '(search-ring regexp-search-ring mark-ring global-mark-ring)
      savehist-save-minibuffer-history t
      savehist-autosave-interval 300
      enable-recursive-minibuffers t)
(recentf-mode 1)
(savehist-mode 1)

;; Make duplicate buffer names unambiguous without changing ordinary buffer
;; names when there is no collision.
(setq uniquify-buffer-name-style 'forward
      uniquify-separator "/"
      uniquify-after-kill-buffer-p t
      uniquify-ignore-buffers-re "^\\*")

;; Ibuffer is still a normal Emacs command, but is substantially more useful
;; than the legacy buffer-menu for a project-oriented workflow.
(global-set-key (kbd "C-x C-b") #'ibuffer)

;; Handle files with very long lines without making ordinary buffers slower.
(when (require 'so-long nil t)
  (global-so-long-mode 1))

(when (fboundp 'pixel-scroll-precision-mode)
  (pixel-scroll-precision-mode 1))

;; Keep the minibuffer prompt from becoming editable or accidentally selected.
(setq minibuffer-prompt-properties
      '(read-only t cursor-intangible t face minibuffer-prompt))
(add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

(provide 'my-builtins)
;;; my-builtins.el ends here
