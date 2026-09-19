;; -*- lexical-binding: t; -*-

;;; my-completion.el --- minibuffer and in-buffer completion

(when (my/package-available-p 'vertico)
  (use-package vertico
    :ensure nil
    :init (vertico-mode 1)
    :config
    ;; Directory completion behaves much more naturally on Windows when
    ;; RET/DEL can enter and back out of path components directly.
    (when (require 'vertico-directory nil t)
      (define-key vertico-map (kbd "RET") #'vertico-directory-enter)
      (define-key vertico-map (kbd "DEL") #'vertico-directory-delete-char)
      (define-key vertico-map (kbd "M-DEL") #'vertico-directory-delete-word)
      (add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy))))

(when (my/package-available-p 'orderless)
  (use-package orderless
    :ensure nil
    :custom
    (completion-styles '(orderless basic))
    (completion-category-defaults nil)
    (completion-category-overrides
     '((file (styles basic partial-completion))))))

;; Chinese project names and paths remain searchable by either their original
;; text or pinyin initials, while ordinary Orderless matching is unchanged.
(when (my/package-available-p 'pinyinlib)
  (use-package pinyinlib
    :ensure nil
    :after orderless
    :config
    (defun my/orderless-regexp-pinyin (component)
      "Turn a minibuffer COMPONENT into an Orderless pinyin regexp."
      (orderless-regexp (pinyinlib-build-regexp-string component)))
    (add-to-list 'orderless-matching-styles #'my/orderless-regexp-pinyin)))

(when (my/package-available-p 'marginalia)
  (use-package marginalia
    :ensure nil
    :init (marginalia-mode 1)))

(when (my/package-available-p 'embark)
  (use-package embark
    :ensure nil
    :bind (("C-." . embark-act)
           ("C-h B" . embark-bindings))))

(when (my/package-available-p 'embark-consult)
  (use-package embark-consult
    :ensure nil
    :hook (embark-collect-mode . consult-preview-at-point-mode)))

(when (my/package-available-p 'corfu)
  (use-package corfu
    :ensure nil
    :init (global-corfu-mode 1)
    :custom
    (corfu-auto t)
    (corfu-auto-delay 0.3)
    (corfu-auto-prefix 3)
    (corfu-quit-no-match 'separator)
    (corfu-preselect 'prompt)
    :config
    (dolist (hook '(shell-mode-hook eshell-mode-hook))
      (add-hook hook (lambda () (setq-local corfu-auto nil))))))

(when (my/package-available-p 'cape)
  (use-package cape
    :ensure nil
    :hook (prog-mode . my/cape-setup)
    :init
    (defun my/cape-setup ()
      "Add file, dabbrev, keyword and symbol completion to programming buffers."
      (setq-local tab-always-indent 'complete)
      (setq-local completion-at-point-functions
                  (append '(cape-file cape-dabbrev cape-keyword cape-symbol)
                          completion-at-point-functions)))))

(when (my/package-available-p 'consult)
  (use-package consult
    :ensure nil
    :bind (;; C-c bindings in `mode-specific-map'
           ("C-c M-x" . consult-mode-command)
           ("C-c h" . consult-history)
           ("C-c k" . consult-kmacro)
           ("C-c m" . consult-man)
           ("C-c i" . consult-info)
           ([remap Info-search] . consult-info)
           ;; C-x bindings
           ("C-x M-:" . consult-complex-command)
           ("C-x b" . consult-buffer)
           ("C-x 4 b" . consult-buffer-other-window)
           ("C-x 5 b" . consult-buffer-other-frame)
           ("C-x t b" . consult-buffer-other-tab)
           ("C-x r b" . consult-bookmark)
           ("C-x p b" . consult-project-buffer)
           ;; Registers and kill ring
           ("M-#" . consult-register-load)
           ("M-'" . consult-register-store)
           ("C-M-#" . consult-register)
           ("M-y" . consult-yank-pop)
           ;; Goto/search maps
           ("M-g e" . consult-compile-error)
           ("M-g f" . consult-flymake)
           ("M-g g" . consult-goto-line)
           ("M-g M-g" . consult-goto-line)
           ("M-g o" . consult-outline)
           ("M-g m" . consult-mark)
           ("M-g k" . consult-global-mark)
           ("M-g i" . consult-imenu)
           ("M-g I" . consult-imenu-multi)
           ("M-s d" . consult-find)
           ("M-s c" . consult-locate)
           ("M-s g" . consult-grep)
           ("M-s G" . consult-git-grep)
           ("M-s r" . consult-ripgrep)
           ("M-s l" . consult-line)
           ("M-s L" . consult-line-multi)
           ("M-s k" . consult-keep-lines)
           ("M-s u" . consult-focus-lines)
           ("M-s e" . consult-isearch-history)
           :map isearch-mode-map
           ("M-e" . consult-isearch-history)
           ("M-s e" . consult-isearch-history)
           ("M-s l" . consult-line)
           ("M-s L" . consult-line-multi)
           :map minibuffer-local-map
           ("M-s" . consult-history)
           ("M-r" . consult-history))
    :hook (completion-list-mode . consult-preview-at-point-mode)
    :init
    (advice-add #'register-preview :override #'consult-register-window)
    (setq register-preview-delay 0.5
          xref-show-xrefs-function #'consult-xref
          xref-show-definitions-function #'consult-xref)
    :config
    (consult-customize
     consult-theme consult-ripgrep consult-git-grep consult-grep
     consult-man consult-bookmark consult-recent-file consult-xref
     :preview-key '(:debounce 0.4 any))
    (setq consult-narrow-key "<")))

(provide 'my-completion)
