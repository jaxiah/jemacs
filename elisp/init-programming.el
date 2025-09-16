;; toggle comment
(global-set-key (kbd "M-;") 'comment-line)

;; 在 c/c++ mode 中切换头/源文件
(add-hook 'c-mode-hook   (lambda () (local-set-key (kbd "M-o") 'ff-find-other-file)))
(add-hook 'c++-mode-hook (lambda () (local-set-key (kbd "M-o") 'ff-find-other-file)))

;; --------------------------------------------------------------------------------
;; indent 相关设置
;; --------------------------------------------------------------------------------
(setq-default indent-tabs-mode nil tab-width 8)
;; c/c++
(add-hook 'c-mode-hook (lambda () (setq c-basic-offset 2)))
(add-hook 'c++-mode-hook (lambda () (setq c-basic-offset 2)))
;; ocaml (tuareg-mode)
(add-hook 'tuareg-mode-hook (lambda () (setq tuareg-indent-level 2)))
;; js/ts
(add-hook 'js-mode-hook (lambda () (setq js-indent-level 2)))
(add-hook 'js2-mode-hook (lambda () (setq js2-basic-offset 2)))
(add-hook 'typescript-mode-hook (lambda () (setq typescript-indent-level 2)))
;; python
(add-hook 'python-mode-hook (lambda () (setq python-indent-offset 4)))

(use-package dtrt-indent
  :ensure t
  :config
  (dtrt-indent-mode 1)
  (setq dtrt-indent-verbosity 0)
  (setq dtrt-indent-run-after-smie t))
;; --------------------------------------------------------------------------------

(use-package markdown-mode
  :ensure t
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown")
  :bind (:map markdown-mode-map
              ("C-c C-e" . markdown-do))
  :custom-face
  (markdown-code-face ((t (:inherit default)))))

(use-package tuareg
  :ensure t
  :mode (("\\.ml[iylp]?" . tuareg-mode)
         ("\\.mli?" . tuareg-mode)
         ("\\.ocamlinit" . tuareg-mode)))

(use-package ocaml-eglot
  :ensure t
  :after tuareg
  :hook
  (tuareg-mode . ocaml-eglot)
  (ocaml-eglot . eglot-ensure))

(use-package eglot
  :ensure t
  :hook ((c-mode          . eglot-ensure)
         (c++-mode        . eglot-ensure)
         (python-mode     . eglot-ensure)
         (tuareg-mode     . eglot-ensure)
         (markdown-mode   . eglot-ensure))
  :config
  (add-to-list 'eglot-server-programs '((c-mode c++-mode) . ("clangd" "--background-index=1" "--j=1")))
  (add-to-list 'eglot-server-programs '(markdown-mode . ("marksman")))
  (add-to-list 'eglot-server-programs '(python-mode . ("pyright-langserver" "--stdio")))
  (add-to-list 'eglot-server-programs '((tuareg-mode) . ("ocamllsp")))
  (add-hook 'eglot-managed-mode-hook (lambda () (eglot-inlay-hints-mode -1))))


(use-package consult-eglot
  :ensure t)

(use-package consult-eglot-embark
  :ensure t
  :after (embark consult-eglot)
  :config
  (consult-eglot-embark-mode))

(use-package copilot
  :vc (:url "https://github.com/copilot-emacs/copilot.el"
            :rev :newest
            :branch "main")              
  :hook (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word)
              ("C-n" . 'copilot-next-completion)
              ("C-p" . 'copilot-previous-completion))
  :config
  (add-to-list 'copilot-indentation-alist '(prog-mode 2))
  (add-to-list 'copilot-indentation-alist '(org-mode 2))
  (add-to-list 'copilot-indentation-alist '(text-mode 2))
  (add-to-list 'copilot-indentation-alist '(closure-mode 2))
  (add-to-list 'copilot-indentation-alist '(emacs-lisp-mode 2)))

;; (setq copilot-disable-max-char-warning t)
(setq copilot-max-char -1)

(use-package dape
  :ensure t
  :preface
  ;; By default dape shares the same keybinding prefix as `gud'
  ;; If you do not want to use any prefix, set it to nil.
  ;; (setq dape-key-prefix "\C-x\C-a")

  :hook
  ;; Save breakpoints on quit
  (kill-emacs . dape-breakpoint-save)
  ;; Load breakpoints on startup
  (after-init . dape-breakpoint-load)

  :config
  ;; Turn on global bindings for setting breakpoints with mouse
  (dape-breakpoint-global-mode)

  ;; Info buffers to the right
  (setq dape-buffer-window-arrangement 'right)

  ;; Info buffers like gud (gdb-mi)
  ;; (setq dape-buffer-window-arrangement 'gud)
  ;; (setq dape-info-hide-mode-line nil)

  ;; Pulse source line (performance hit)
  (add-hook 'dape-display-source-hook 'pulse-momentary-highlight-one-line)

  ;; Showing inlay hints
  (setq dape-inlay-hints t)

  ;; Save buffers on startup, useful for interpreted languages
  (add-hook 'dape-start-hook (lambda () (save-some-buffers t t)))

  ;; Kill compile buffer on build success
  (add-hook 'dape-compile-hook 'kill-buffer)

  ;; Projectile users
  (setq dape-cwd-function 'projectile-project-root))

(custom-theme-set-faces
 'user
 ;; '(dape-inlay-hint-face ((t (:inherit :default :weight bold :height 1.0))))
 '(dape-inlay-hint-face ((t (:inherit shadow :height 1.0))))
 '(dape-inlay-hint-highlight-face ((t (:inherit (bold highlight) :height 1.0))))
 )

(with-eval-after-load 'dape
  (add-to-list 'dape-configs
               '(dbgpy
                 modes (python-mode python-ts-mode)
                 ensure (lambda (config)
                          (dape-ensure-command config)
                          (let ((python (dape-config-get config 'command)))
                            (unless (zerop (call-process python nil nil nil "-c" "import debugpy.adapter"))
                              (user-error "%s module debugpy is not installed" python))))
                 command (lambda ()
                           (or python-shell-interpreter
                               "python"))
                 command-args ("-m" "debugpy.adapter" "--host" "127.0.0.1" "--port" "20258")
                 port 20258
                 :request "launch"
                 :type "python"
                 :cwd dape-cwd
                 :program dape-buffer-default
                 :args []
                 :justMyCode nil
                 :console "integratedTerminal"
                 :showReturnValue t
                 :stopOnEntry nil)))

(use-package repeat
  :config
  (repeat-mode))


(use-package pyvenv
  :ensure t
  :config
  (pyvenv-mode 1))

;; (add-to-list 'auto-mode-alist '("\\.cu\\'" . c++-mode))
;; (add-to-list 'auto-mode-alist '("\\.cl\\'" . c++-mode))
;; cuda-mode and opencl-c-mode derives from c++-mode
(use-package cuda-mode :ensure t)
(use-package opencl-c-mode :ensure t)

(use-package format-all
  :commands format-all-mode
  :hook (prog-mode . format-all-mode)
  :config
  (setq-default format-all-formatters
                '(("Python" (black "-l" "1024")))))

(provide 'init-programming)
