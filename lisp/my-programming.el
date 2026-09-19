;; -*- lexical-binding: t; -*-

;;; my-programming.el --- C/C++, Python, Eglot, Dape, and formatting

(global-set-key (kbd "M-;") #'comment-line)
(global-set-key (kbd "M-g -") #'my/open-config)
(global-set-key (kbd "C-x C-f") #'my/find-file)
(global-set-key (kbd "C-s") #'my/isearch-forward)
(global-set-key (kbd "C-x C-r") #'recentf-open-files)

(add-hook 'c-mode-hook (lambda ()
                         (setq-local c-basic-offset 2)
                         (local-set-key (kbd "M-o") #'ff-find-other-file)))
(add-hook 'c++-mode-hook (lambda ()
                           (setq-local c-basic-offset 2)
                           (local-set-key (kbd "M-o") #'ff-find-other-file)))
(add-hook 'c-ts-mode-hook (lambda ()
                            (setq-local c-ts-mode-indent-offset 2)
                            (local-set-key (kbd "M-o") #'ff-find-other-file)))
(add-hook 'c++-ts-mode-hook (lambda ()
                              (setq-local c-ts-mode-indent-offset 2)
                              (local-set-key (kbd "M-o") #'ff-find-other-file)))
(dolist (hook '(c-mode-common-hook c-ts-mode-hook c++-ts-mode-hook))
  (add-hook hook (lambda () (setq-local indent-tabs-mode nil))))
(add-hook 'python-mode-hook (lambda () (setq-local python-indent-offset 4)))
(add-hook 'python-ts-mode-hook (lambda () (setq-local python-indent-offset 4)))

(when (my/package-available-p 'dtrt-indent)
  (use-package dtrt-indent
    :ensure nil
    :custom (dtrt-indent-verbosity 0)
    :config
    (setq dtrt-indent-run-after-smie t)
    (dolist (hook '(c-mode-hook c++-mode-hook c-ts-mode-hook c++-ts-mode-hook
                    python-mode-hook python-ts-mode-hook))
      (add-hook hook #'dtrt-indent-mode))))

(when (my/package-available-p 'markdown-mode)
  (use-package markdown-mode
    :ensure nil
    :mode (("README\\.md\\'" . gfm-mode)
           ("\\.md\\'" . markdown-mode)
           ("\\.markdown\\'" . markdown-mode))
    :bind (:map markdown-mode-map
                ("C-c C-e" . markdown-do))
    :custom-face
    (markdown-code-face ((t (:inherit default))))))

(require 'eglot)

(setq eglot-autoshutdown t
      eglot-send-changes-idle-time 0.5
      eglot-prefer-plaintext t
      eglot-extend-to-xref t)

;; Emacs already knows how to select C/C++ and Python language servers.  Only
;; retain the useful clangd options from the previous configuration.
(add-to-list 'eglot-server-programs
             '((c-mode c++-mode c-ts-mode c++-ts-mode
                       c-or-c++-mode c-or-c++-ts-mode)
               . ("clangd" "--background-index" "--clang-tidy")))

(dolist (hook '(c-mode-hook c++-mode-hook c-ts-mode-hook c++-ts-mode-hook
                python-mode-hook python-ts-mode-hook))
  (add-hook hook #'eglot-ensure))

;; Use the faster, more precise built-in Tree-sitter modes when grammars have
;; been installed.  This is conditional: a fresh Chocolatey installation
;; keeps working without downloading grammar DLLs.
(when (fboundp 'treesit-language-available-p)
  (dolist (mapping '((c-mode . c-ts-mode)
                     (c++-mode . c++-ts-mode)
                     (python-mode . python-ts-mode)))
    (when (condition-case nil
              (treesit-language-available-p
               (pcase (cdr mapping)
                 ('c-ts-mode 'c)
                 ('c++-ts-mode 'cpp)
                 ('python-ts-mode 'python)))
            (error nil))
      (add-to-list 'major-mode-remap-alist mapping))))

(with-eval-after-load 'project
  (when (boundp 'project-vc-extra-root-markers)
    (add-to-list 'project-vc-extra-root-markers "pyproject.toml")))

(add-hook 'eglot-managed-mode-hook
          (lambda ()
            (when (fboundp 'eglot-inlay-hints-mode)
              (eglot-inlay-hints-mode -1))))

(when (my/package-available-p 'consult-eglot)
  (use-package consult-eglot :ensure nil))

(when (my/package-available-p 'consult-eglot-embark)
  (use-package consult-eglot-embark
    :ensure nil
    :after (embark consult-eglot)
    :config (consult-eglot-embark-mode 1)))

(when (my/package-available-p 'pyvenv)
  (use-package pyvenv
    :ensure nil
    :config (pyvenv-mode 1)))

(when (my/package-available-p 'format-all)
  (use-package format-all
    :ensure nil
    :commands format-all-buffer
    :bind ("C-c f" . format-all-buffer)
    :config
    (let (formatters)
      (when (executable-find "clang-format")
        (setq formatters
              '(("C" (clang-format))
                ("C++" (clang-format)))))
      (when (executable-find "black")
        (setq formatters
              (append formatters '(("Python" (black "-l" "1024"))))))
      (when formatters
        (setq-default format-all-formatters formatters)))))

(when (my/package-available-p 'dape)
  (use-package dape
    :ensure nil
    :bind ("C-x C-a d" . dape)
    :init
    (setq dape-buffer-window-arrangement 'right
          dape-inlay-hints t
          dape-default-breakpoints-file
          (expand-file-name "dape-breakpoints" my-data-directory))
    :config
    (dape-breakpoint-global-mode 1)
    (dape-breakpoint-load)
    (add-hook 'kill-emacs-hook #'dape-breakpoint-save)
    (add-hook 'dape-display-source-hook #'pulse-momentary-highlight-one-line)
    (add-hook 'dape-start-hook (lambda () (save-some-buffers t t)))
    (with-eval-after-load 'projectile
      (setq dape-cwd-function #'projectile-project-root))
    (add-to-list 'dape-configs
                 '(dbgpy
                   modes (python-mode python-ts-mode)
                   ensure (lambda (config)
                            (dape-ensure-command config)
                            (let ((python (dape-config-get config 'command)))
                              (unless (zerop
                                       (call-process python nil nil nil
                                                     "-c"
                                                     "import debugpy.adapter"))
                                (user-error "%s module debugpy is not installed"
                                            python))))
                   command (lambda () (or python-shell-interpreter "python"))
                   command-args ("-m" "debugpy.adapter" "--host" "127.0.0.1"
                                 "--port" 20258)
                   port 20258
                   :request "launch"
                   :type "python"
                   :cwd dape-cwd
                   :program dape-buffer-default
                   :args []
                   :justMyCode nil
                   :console "integratedTerminal"
                   :showReturnValue t
                   :stopOnEntry nil))))

(defun my/enable-copilot ()
  "Install Copilot from Git and enable it in programming buffers."
  (interactive)
  (setq my-enable-copilot t)
  (condition-case err
      (progn
        (unless (my/package-available-p 'copilot)
          (require 'package-vc)
          (package-vc-install
           '(copilot :url "https://github.com/copilot-emacs/copilot.el.git"
                     :branch "main")))
        (require 'copilot)
        (add-hook 'prog-mode-hook #'copilot-mode)
        (define-key copilot-completion-map (kbd "<tab>") #'copilot-accept-completion)
        (define-key copilot-completion-map (kbd "TAB") #'copilot-accept-completion)
        (define-key copilot-completion-map (kbd "C-TAB")
                    #'copilot-accept-completion-by-word)
        (define-key copilot-completion-map (kbd "C-<tab>")
                    #'copilot-accept-completion-by-word)
        (define-key copilot-completion-map (kbd "C-n") #'copilot-next-completion)
        (define-key copilot-completion-map (kbd "C-p") #'copilot-previous-completion)
        (setq copilot-max-char -1)
        (customize-save-variable 'my-enable-copilot t)
        (message "Copilot enabled; authenticate with its normal command if needed"))
    (error
     (setq my-enable-copilot nil)
     (user-error "Could not install or load Copilot: %s"
                 (error-message-string err)))))

(when my-enable-copilot
  (my/enable-copilot))

(when (fboundp 'repeat-mode)
  (repeat-mode 1))

(provide 'my-programming)
