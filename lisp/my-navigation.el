;; -*- lexical-binding: t; -*-

;;; my-navigation.el --- buffers, windows, and modal editing

(when (my/package-available-p 'which-key)
  (use-package which-key
    :ensure nil
    :hook (after-init . which-key-mode)
    :custom (which-key-idle-delay 0.5)))

(when (my/package-available-p 'beacon)
  (use-package beacon
    :ensure nil
    :hook (after-init . beacon-mode)))

(when (my/package-available-p 'expand-region)
  (use-package expand-region
    :ensure nil
    :bind (("C-= =" . er/expand-region)
           ("C-= w" . er/mark-word)
           ("C-= s" . er/mark-symbol)
           ("C-= p" . er/mark-symbol-with-prefix)
           ("C-= n" . er/mark-next-accessor)
           ("C-= m" . er/mark-method-call)
           ("C-= i q" . er/mark-inside-quotes)
           ("C-= a q" . er/mark-outside-quotes)
           ("C-= i (" . er/mark-inside-pairs)
           ("C-= a (" . er/mark-outside-pairs)
           ("C-= c" . er/mark-comment)
           ("C-= u" . er/mark-url)
           ("C-= e" . er/mark-email)
           ("C-= d" . er/mark-defun))))

(when (my/package-available-p 'ace-window)
  (use-package ace-window
    :ensure nil
    :bind ([remap other-window] . ace-window)
    :custom-face
    (aw-leading-char-face ((t (:inherit font-lock-keyword-face
                                        :height 3.0 :weight bold))))))

(when (my/package-available-p 'avy)
  (use-package avy
    :ensure nil
    :bind (("M-g c" . avy-goto-char)
           ("M-g w" . avy-goto-word-1)
           ("M-g l" . avy-goto-line))))

(when (my/package-available-p 'projectile)
  (use-package projectile
    :ensure nil
    :init
    ;; Set these before `projectile-mode' loads the package, so it never reads
    ;; the old root-level files left by an earlier configuration.
    (setq projectile-known-projects-file
          (expand-file-name "projectile-bookmarks.eld" my-data-directory)
          projectile-frecency-file
          (expand-file-name "projectile-frecency.eld" my-data-directory))
    (projectile-mode 1)
    :bind-keymap ("C-c p" . projectile-command-map)
    :custom (projectile-completion-system 'default)
    :config
    ;; Keep Python projects discoverable even when they have no VCS metadata.
    (add-to-list 'projectile-project-root-files "pyproject.toml")))

(when (my/package-available-p 'magit)
  (use-package magit
    :ensure nil
    :commands magit-status
    :bind ("C-x g" . magit-status)))

(when (my/package-available-p 'dired-sidebar)
  (use-package dired-sidebar
    :ensure nil
    :commands dired-sidebar-toggle-sidebar
    :bind ("C-x C-n" . dired-sidebar-toggle-sidebar)
    :config
    (add-hook 'dired-sidebar-mode-hook
              (lambda ()
                (unless (file-remote-p default-directory)
                  (auto-revert-mode 1))))))

(defun my/toggle-evil-mode ()
  "Toggle global Evil mode while leaving Emacs state as the default."
  (interactive)
  (unless (fboundp 'evil-mode)
    (unless (my/ensure-package 'evil)
      (user-error "Could not install Evil; run M-x my/install-optional-packages"))
    (require 'evil))
  (evil-mode (if (bound-and-true-p evil-mode) -1 1))
  (message "Evil mode %s" (if (bound-and-true-p evil-mode) "enabled" "disabled")))

(global-set-key (kbd "M-z") #'my/toggle-evil-mode)

;; Evil is deliberately absent from the normal startup path.  If the user
;; invokes M-z, load it and preserve the familiar Emacs cursor keys in insert
;; state.
(setq evil-want-C-u-scroll t)

(defun my/evil-emacs-like-insert-bindings ()
  "Keep familiar Emacs cursor keys available in Evil insert state."
  (define-key evil-insert-state-map (kbd "C-f") #'forward-char)
  (define-key evil-insert-state-map (kbd "C-b") #'backward-char)
  (define-key evil-insert-state-map (kbd "C-n") #'next-line)
  (define-key evil-insert-state-map (kbd "C-p") #'previous-line)
  (define-key evil-insert-state-map (kbd "C-a") #'beginning-of-line)
  (define-key evil-insert-state-map (kbd "C-e") #'end-of-line)
  (define-key evil-insert-state-map (kbd "C-d") #'delete-char)
  (define-key evil-insert-state-map (kbd "C-k") #'kill-line))

(with-eval-after-load 'evil
  (add-hook 'evil-mode-hook #'my/evil-emacs-like-insert-bindings))

(provide 'my-navigation)
