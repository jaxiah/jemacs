;; -*- lexical-binding: t; -*-

;;; my-core.el --- Windows-safe paths and built-in Emacs behavior

(defconst my-config-directory
  (file-name-as-directory (expand-file-name user-emacs-directory))
  "Root directory of this configuration.")

(defconst my-data-directory
  (expand-file-name "data/" my-config-directory)
  "Persistent data belonging to this configuration.")

(defconst my-cache-directory
  (expand-file-name "cache/" my-config-directory)
  "Cache data belonging to this configuration.")

(defconst my-eln-directory
  (expand-file-name "cache/eln/" my-config-directory)
  "Native compilation cache belonging to this configuration.")

(defgroup my-emacs nil
  "Personal settings for the isolated Windows configuration."
  :group 'environment)

(dolist (directory (list my-data-directory
                         my-cache-directory
                         my-eln-directory
                         (expand-file-name "backups/" my-data-directory)
                         (expand-file-name "auto-save/" my-data-directory)
                         (expand-file-name "server/" my-data-directory)))
  (make-directory directory t))

(when (boundp 'native-comp-eln-load-path)
  (add-to-list 'native-comp-eln-load-path my-eln-directory))

;; Keep every state file inside the selected init directory.  This is the key
;; property that makes `--init-directory' useful on Windows.
(setq custom-file (expand-file-name "custom.el" my-config-directory)
      recentf-save-file (expand-file-name "recentf" my-data-directory)
      savehist-file (expand-file-name "savehist" my-data-directory)
      save-place-file (expand-file-name "places" my-data-directory)
      bookmark-default-file (expand-file-name "bookmarks" my-data-directory)
      project-list-file (expand-file-name "projects" my-data-directory)
      url-history-file (expand-file-name "url-history" my-data-directory)
      transient-history-file (expand-file-name "transient-history" my-data-directory)
      tramp-persistency-file-name (expand-file-name "tramp" my-data-directory)
      auto-save-list-file-prefix (expand-file-name "auto-save-list/.saves-"
                                                   my-data-directory)
      backup-directory-alist `(("." . ,(expand-file-name "backups/" my-data-directory)))
      auto-save-file-name-transforms
      `((".*" ,(file-name-as-directory
                 (expand-file-name "auto-save/" my-data-directory)) t))
      server-auth-dir (expand-file-name "server/" my-data-directory)
      server-name "jemacs")

(load custom-file 'noerror 'nomessage)

;; General behavior.
(setq inhibit-startup-message t
      inhibit-startup-screen t
      initial-scratch-message nil
      ring-bell-function #'ignore
      use-dialog-box nil
      frame-title-format '("%b — Emacs")
      column-number-mode t
      truncate-lines t
      scroll-conservatively 100
      scroll-margin 3
      mouse-wheel-scroll-amount '(5 ((shift) . 1) ((control) . nil))
      mouse-wheel-progressive-speed nil
      history-length 200
      save-interprogram-paste-before-kill t
      select-enable-clipboard t
      select-enable-primary nil)

(setq-default tab-width 8
              indent-tabs-mode nil)

(when (eq system-type 'windows-nt)
  ;; Chocolatey Emacs normally inherits PATH correctly.  Select a usable shell
  ;; without hard-coding a user-specific installation directory.
  (let ((pwsh (or (executable-find "pwsh.exe")
                  (executable-find "pwsh")))
        (cmd (or (executable-find "cmd.exe")
                 (executable-find "cmd"))))
    (cond
     (pwsh
      (setq shell-file-name pwsh
            explicit-shell-file-name pwsh
            shell-command-switch "-Command"))
     (cmd
      (setq shell-file-name cmd
            explicit-shell-file-name cmd
            shell-command-switch "/c")))))

;; If the preferred font is absent, Emacs simply keeps its normal Windows
;; default.  The font selection is applied per frame in my-ui.el.
(defconst my-font-candidates
  '("Maple Mono NL NF CN" "Cascadia Mono" "Consolas" "Segoe UI Mono")
  "Font families tried in order on graphical frames.")

(defcustom my-enable-copilot nil
  "Whether to install and enable Copilot at startup.

The default is nil because Copilot is a separately authenticated service and
requires a GitHub checkout.  Use `M-x my/enable-copilot' when it is wanted."
  :type 'boolean
  :group 'my-emacs)

;; ---------------------------------------------------------------------------
;; Personal commands

(defun my/open-config ()
  "Open this configuration's init file."
  (interactive)
  (find-file (expand-file-name "init.el" my-config-directory)))

(defun my/find-file (arg)
  "Open a file normally, or literally when ARG is supplied.

This keeps `C-u C-x C-f' useful for large files that should not trigger
normal decoding, font-locking, or mode initialization."
  (interactive "P")
  (if arg
      (call-interactively #'find-file-literally)
    (call-interactively #'find-file)))

(defun my/isearch-forward ()
  "Start isearch with the active region as its initial query."
  (interactive)
  (if (use-region-p)
      (let ((search-text (buffer-substring-no-properties
                          (region-beginning) (region-end))))
        (deactivate-mark)
        (isearch-mode t nil nil nil)
        (isearch-yank-string search-text))
    (isearch-forward)))

(defun my/generate-dir-locals-for-python-venv (venv-path)
  "Write a Windows-safe `.dir-locals.el' for VENV-PATH.

The generated strings are printed with `prin1', so backslashes in a Windows
path cannot accidentally become escape sequences in the Lisp file."
  (interactive
   (list (read-directory-name "Select Python virtualenv directory: "
                              nil nil t)))
  (let* ((venv-path (directory-file-name (expand-file-name venv-path)))
         (venv-bin (if (eq system-type 'windows-nt)
                       "Scripts/python.exe"
                     "bin/python"))
         (python-exe (expand-file-name venv-bin venv-path))
         (dir-locals-file (expand-file-name ".dir-locals.el" default-directory))
         (dir-locals
          `((python-mode
             (pyvenv-activate . ,venv-path)
             (python-shell-interpreter . ,python-exe)
             (eglot-workspace-configuration
              . ((:python . ((:pythonPath . ,python-exe)))))))))
    (unless (file-exists-p python-exe)
      (user-error "Python executable not found: %s" python-exe))
    (when (or (not (file-exists-p dir-locals-file))
              (y-or-n-p "Overwrite existing .dir-locals.el? "))
      (with-temp-file dir-locals-file
        (insert ";; Generated by my/generate-dir-locals-for-python-venv\n")
        (prin1 dir-locals (current-buffer))
        (insert "\n"))
      (message "Wrote %s for Python venv %s" dir-locals-file venv-path))))

(provide 'my-core)
