;; -*- lexical-binding: t -*-

;; ------------------------------------------------------------------------------------------------------------------------
;; 一些路径设置
;; ------------------------------------------------------------------------------------------------------------------------
(setq user-home-directory (expand-file-name "~/"))
(add-to-list 'load-path (expand-file-name "elisp" user-emacs-directory))
(add-to-list 'native-comp-eln-load-path (expand-file-name "eln-cache" user-home-directory))
(setq package-user-dir (expand-file-name "emacs-package" user-home-directory)
      custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'no-error 'no-message)

;; ------------------------------------------------------------------------------------------------------------------------
;; elpa 设置
;; ------------------------------------------------------------------------------------------------------------------------
(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives
      `(("melpa" . ,(concat user-home-directory ".elpa-mirror/melpa/"))
        ("org"   . ,(concat user-home-directory ".elpa-mirror/org/"))
        ("gnu"   . ,(concat user-home-directory ".elpa-mirror/gnu/"))))

(unless (bound-and-true-p package--initialized) (package-initialize))
(unless package-archive-contents (package-refresh-contents))


(require 'init-builtin)
(require 'init-keybinding)

;; ----------------------------------------------------------------------------------------------------
;; bootstrap straight.el
;; ----------------------------------------------------------------------------------------------------
;; (defvar bootstrap-version)
;; (let ((bootstrap-file
;;        (expand-file-name
;;         "straight/repos/straight.el/bootstrap.el"
;;         (or (bound-and-true-p straight-base-dir)
;;             user-emacs-directory)))
;;       (bootstrap-version 7))
;;   (unless (file-exists-p bootstrap-file)
;;     (with-current-buffer
;;         (url-retrieve-synchronously
;;          "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
;;          'silent 'inhibit-cookies)
;;       (goto-char (point-max))
;;       (eval-print-last-sexp)))
;;   (load bootstrap-file nil 'nomessage))


(use-package which-key
  :ensure t
  :config
  (which-key-mode))


(use-package beacon
  :ensure t
  :config
  (beacon-mode 1))


;; (use-package company
;;   :ensure t
;;   :init
;;   (global-company-mode t)
;;   :config
;;   (setq company-minimum-prefix-length 3)
;;   (setq company-idle-delay 0.3)
;;   (setq company-global-modes '(not eshell-mode shell-mode powershell-mode)))


(use-package powershell
  :ensure t)


(use-package expand-region
  :ensure t
  :config
  (global-set-key (kbd "C-= =") 'er/expand-region)
  (global-set-key (kbd "C-= w") 'er/mark-word)
  (global-set-key (kbd "C-= s") 'er/mark-symbol)
  (global-set-key (kbd "C-= p") 'er/mark-symbol-with-prefix)
  (global-set-key (kbd "C-= n") 'er/mark-next-accessor)
  (global-set-key (kbd "C-= m") 'er/mark-method-call)
  (global-set-key (kbd "C-= i q") 'er/mark-inside-quotes)
  (global-set-key (kbd "C-= a q") 'er/mark-outside-quotes)
  (global-set-key (kbd "C-= i (") 'er/mark-inside-pairs)
  (global-set-key (kbd "C-= a (") 'er/mark-outside-pairs)
  (global-set-key (kbd "C-= c") 'er/mark-comment)
  (global-set-key (kbd "C-= u") 'er/mark-url)
  (global-set-key (kbd "C-= e") 'er/mark-email)
  (global-set-key (kbd "C-= d") 'er/mark-defun))


(require 'init-consult)
(require 'init-programming)


;; ------------------------------------------------------------------------------------------------------------------------
;; vertico, orderless, marginalia, embark
;; ------------------------------------------------------------------------------------------------------------------------

;; minibuffer 的补全
(use-package vertico
  :ensure t
  :init
  (vertico-mode t))


;; minibuffer 的无序模糊搜索
(use-package orderless
  :ensure t
  :config
  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides '((file (styles basic partial-completion)))))


;; In-buffer completion UI consistent with Vertico: Corfu
(use-package corfu
  :ensure t
  :init
  (global-corfu-mode)
  :custom
  (corfu-auto t)
  (corfu-auto-delay 0.3)
  (corfu-auto-prefix 3)
  (corfu-quit-no-match 'separator)
  (corfu-preselect 'prompt)
  :config
  ;; Disable auto popup in shell-mode; manual completion still available
  (add-hook 'shell-mode-hook (lambda () (setq-local corfu-auto nil)))
  (add-hook 'eshell-mode-hook (lambda () (setq-local corfu-auto nil)))
  (add-hook 'powershell-mode-hook (lambda () (setq-local corfu-auto nil))))

;; Extra completion sources: Cape
(use-package cape
  :ensure t
  :init
  (add-hook 'prog-mode-hook
            (lambda ()
              (setq-local tab-always-indent 'complete)
              (add-to-list 'completion-at-point-functions #'cape-file)
              (add-to-list 'completion-at-point-functions #'cape-dabbrev)
              (add-to-list 'completion-at-point-functions #'cape-keyword)
              (add-to-list 'completion-at-point-functions #'cape-symbol))))


;; minibuffer 搜索候选加 annotation
(use-package marginalia
  :ensure t
  :init
  (marginalia-mode t))


;; embark 上下文菜单
(use-package embark
  :ensure t
  :config
  :bind
  (("C-." . embark-act)
   ("C-h B" . embark-bindings)))


(use-package embark-consult
  :ensure t
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))


(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("C-c p" . projectile-command-map)))


(use-package ace-window
  :ensure t
  :init
  (global-set-key [remap other-window] 'ace-window)
  :config
  ;; Customize ace-window face
  (custom-theme-set-faces 'user
   '(aw-leading-char-face ((t (:inherit ace-jump-face-foreground :height 3.0))))))


(use-package avy
  :ensure t
  :bind (("M-g c" . avy-goto-char)
         ("M-g w" . avy-goto-word-1)
         ("M-g l" . avy-goto-line)))


(use-package dired-sidebar
  :bind (("C-x C-n" . dired-sidebar-toggle-sidebar))
  :ensure t
  :commands (dired-sidebar-toggle-sidebar)
  :init
  (add-hook 'dired-sidebar-mode-hook
            (lambda ()
              (unless (file-remote-p default-directory)
                (auto-revert-mode))))
  :config
  (push 'toggle-window-split dired-sidebar-toggle-hidden-commands)
  (push 'rotate-windows dired-sidebar-toggle-hidden-commands)
  (setq dired-sidebar-subtree-line-prefix "__")
  (setq dired-sidebar-use-term-integration t))


(use-package evil
  :ensure t
  :init
  (setq evil-mode nil)
  :config
  (defun my-evil-bindings ()
    (define-key evil-insert-state-map (kbd "C-f") 'forward-char)
    (define-key evil-insert-state-map (kbd "C-b") 'backward-char)
    (define-key evil-insert-state-map (kbd "C-n") 'next-line)
    (define-key evil-insert-state-map (kbd "C-p") 'previous-line)
    (define-key evil-insert-state-map (kbd "C-a") 'beginning-of-line)
    (define-key evil-insert-state-map (kbd "C-e") 'end-of-line)
    (define-key evil-insert-state-map (kbd "C-d") 'delete-char)
    (define-key evil-insert-state-map (kbd "C-k") 'kill-line))

  (defun toggle-global-evil-mode ()
    (interactive)
    (if evil-mode
        (evil-mode -1)
      (evil-mode 1))
    (message "Evil mode %s" (if evil-mode "enabled" "disabled")))

  (global-set-key (kbd "M-z") 'toggle-global-evil-mode)

  ;; Use hook to set up bindings when evil-mode is enabled
  (add-hook 'evil-mode-hook #'my-evil-bindings))

;; (use-package centaur-tabs
;;   :ensure t
;;   :demand
;;   :config
;;   (centaur-tabs-mode t)
;;   (centaur-tabs-headline-match)
;;   ;; (setq centaur-tabs-height 32
;;   (setq centaur-tabs-style "bar"
;;         centaur-tabs-set-modified-marker t
;;         centaur-tabs-modified-marker "**")
;;   ;; (centaur-tabs-change-fonts (face-attribute 'default :font) 110)
;;   :bind
;;   ("<C-prior>" . centaur-tabs-backward)
;;   ("<C-next>" . centaur-tabs-forward))

(require 'init-jxh-codes)


(load-theme 'wombat)

