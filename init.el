;; -*- lexical-binding: t; -*-

;;; init.el --- isolated Windows configuration

(when (version< emacs-version "29.1")
  (error "jemacs requires Emacs 29.1 or newer"))

(add-to-list 'load-path (expand-file-name "lisp/" user-emacs-directory))

(require 'my-core)
(require 'my-package)
(require 'my-builtins)
(require 'my-ui)
(require 'my-completion)
(require 'my-navigation)
(require 'my-programming)
(require 'my-org)
(require 'my-startup)

;; Return to a normal GC budget after the expensive first load.
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 64 1024 1024)
                  gc-cons-percentage 0.1)))

;; Keep an emacsclient endpoint scoped to this configuration.  Starting it is
;; harmless when one is already running, and the error is intentionally only a
;; message so a normal GUI startup never becomes unusable.
(unless noninteractive
  (require 'server)
  (unless (server-running-p)
    (condition-case err
        (server-start)
      (error (message "Could not start jemacs server: %s"
                     (error-message-string err))))))

(provide 'init)
;;; init.el ends here
