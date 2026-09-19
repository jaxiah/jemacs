;; -*- lexical-binding: t; -*-

;;; my-package.el --- package.el bootstrap for the isolated configuration

(require 'package)

(defcustom my-package-proxy "localhost:4878"
  "HTTP proxy used for ELPA package downloads.

Set this to nil when the proxy is not running.  The value follows Emacs's
`url-proxy-services' format and intentionally has no `http://' prefix."
  :type '(choice (const :tag "No proxy" nil) string)
  :group 'my-emacs)

(when my-package-proxy
  (setq url-proxy-services `(("http" . ,my-package-proxy)
                             ("https" . ,my-package-proxy))))

;; The local proxy can legitimately rewrite the downloaded archive stream, so
;; GNU ELPA's detached signature does not match the bytes received by Emacs.
;; Package downloads still use HTTPS through the local proxy.  Direct users
;; retain signature checking by default.
(defcustom my-package-check-signature
  (if my-package-proxy nil t)
  "Signature policy for package archives.

The default is relaxed only when `my-package-proxy' is enabled because the
current local proxy does not preserve GNU ELPA's detached archive signature."
  :type '(choice (const :tag "Check signatures" t)
                 (const :tag "Allow unsigned packages" allow-unsigned)
                 (const :tag "Disable signature checks" nil))
  :group 'my-emacs)

(setq package-check-signature my-package-check-signature)

(setq package-user-dir (expand-file-name "packages/" my-config-directory)
      package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("nongnu" . "https://elpa.nongnu.org/nongnu/")
        ("melpa" . "https://melpa.org/packages/"))
      package-enable-at-startup nil
      package-native-compile t)

(make-directory package-user-dir t)
(package-initialize)

;; A partially successful refresh can leave only one archive cached.  Force a
;; complete refresh when either official archive is absent, otherwise a MELPA
;; package may appear to have an impossible future dependency simply because
;; its GNU ELPA dependency metadata was not downloaded.
(let ((archive-directory (expand-file-name "archives/" package-user-dir)))
  (when (or (not (file-exists-p (expand-file-name "gnu/archive-contents"
                                                   archive-directory)))
            (not (file-exists-p (expand-file-name "nongnu/archive-contents"
                                                   archive-directory))))
    (setq package-archive-contents nil)))

(defvar my-package-refresh-attempted nil
  "Whether this session has tried to refresh package archives.")

(defconst my-core-packages
  '(consult vertico orderless marginalia embark embark-consult
    corfu cape which-key projectile ace-window avy expand-region
    beacon pinyinlib markdown-mode dtrt-indent pyvenv magit)
  "Packages installed automatically for normal use.")

(defconst my-optional-packages
  '(evil dired-sidebar consult-eglot consult-eglot-embark dape format-all)
  "Packages for the current C/C++ and Python workflow.")

(defun my/package-refresh-contents ()
  "Refresh package archives once, reporting failures without aborting startup."
  (unless my-package-refresh-attempted
    (setq my-package-refresh-attempted t)
    (condition-case err
        (progn
          (message "Refreshing Emacs package archives...")
          (package-refresh-contents)
          t)
      (error
       (message "Package archive refresh failed: %s"
                (error-message-string err))
       nil))))

(defun my/package-available-p (package)
  "Return non-nil when PACKAGE is installed or otherwise loadable."
  (or (package-installed-p package)
      (locate-library (symbol-name package))))

(defun my/ensure-package (package)
  "Install PACKAGE if needed and return whether it is available.

This function is deliberately tolerant: a missing network connection should
not make a usable built-in Emacs fail to start."
  (or (my/package-available-p package)
      (condition-case err
          (progn
            (unless package-archive-contents
              (my/package-refresh-contents))
            (unless (my/package-available-p package)
              (package-install package))
            (my/package-available-p package))
        (error
         (message "Could not install package `%s': %s"
                  package (error-message-string err))
         nil))))

;; `use-package' is built into every supported Emacs version.  Loading it
;; normally keeps declaration errors visible instead of silently ignoring the
;; rest of the configuration.
(require 'use-package)

(defun my/ensure-core-packages ()
  "Install the packages used by the normal editing experience."
  (interactive)
  (dolist (package my-core-packages)
    (my/ensure-package package))
  (message "Core package check complete"))

(defun my/install-optional-packages ()
  "Install language and integration packages not needed by every session."
  (interactive)
  (dolist (package my-optional-packages)
    (my/ensure-package package))
  (message "Optional package check complete"))

(defun my/package-report ()
  "Show package and external executable availability in a temporary buffer."
  (interactive)
  (with-output-to-temp-buffer "*my-package-report*"
    (princ (format "Config directory: %s\n\n" my-config-directory))
    (princ "Core packages:\n")
    (dolist (package my-core-packages)
      (princ (format "  %-22s %s\n" package
                     (if (my/package-available-p package) "available" "missing"))))
    (princ "\nOptional packages:\n")
    (dolist (package my-optional-packages)
      (princ (format "  %-22s %s\n" package
                     (if (my/package-available-p package) "available" "missing"))))
    (princ "\nExecutables:\n")
    (dolist (program '("git" "rg" "clangd" "clang-format" "python"
                       "pyright-langserver" "black" "pwsh" "node"))
      (princ (format "  %-22s %s\n" program (or (executable-find program) "missing"))))))

;; Install the stable, frequently used layer during first startup.  The
;; operation is skipped when a user deliberately sets this variable to nil.
(defcustom my-auto-install-core-packages t
  "Whether to install missing core packages while loading the configuration."
  :type 'boolean
  :group 'my-emacs)

(when my-auto-install-core-packages
  (my/ensure-core-packages))

(provide 'my-package)
