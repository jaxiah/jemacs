;; -*- lexical-binding: t; -*-

;; Keep startup and package compilation isolated from the default Emacs
;; installation.  This file is intentionally small: user-facing settings live
;; in lisp/my-*.el.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.8
      package-enable-at-startup nil
      load-prefer-newer noninteractive
      native-comp-jit-compilation nil
      native-comp-async-report-warnings-errors (if init-file-debug 'async 'silent))

(when (boundp 'native-comp-deferred-compilation)
  (setq native-comp-deferred-compilation nil))

;; Large language-server and formatter output benefits from a larger read
;; buffer.  This is especially noticeable on Windows pipes.
(setq read-process-output-max (* 4 1024 1024)
      process-adaptive-read-buffering nil)

(when (eq system-type 'windows-nt)
  ;; Avoid an expensive stat call for every file and use larger Emacs IPC
  ;; buffers.  These are the same class of Windows-specific optimizations used
  ;; by mature configurations such as Doom and Centaur.
  (setq w32-get-true-file-attributes nil
        w32-pipe-read-delay 0
        w32-pipe-buffer-size (* 64 1024)))

;; Make file names, buffers and subprocess communication predictable on a
;; Chinese Windows installation.
(set-language-environment "UTF-8")
(prefer-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-file-name-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8-unix)
(setenv "PYTHONIOENCODING" "UTF-8")

;; Avoid resizing the initial frame several times during startup.
(setq frame-inhibit-implied-resize t)

;; Keep the initial GUI frame predictable on Windows.  Set both alists because
;; the initial frame and frames created later do not necessarily consult the
;; same one during startup.
(dolist (frame-alist-variable '(default-frame-alist initial-frame-alist))
  (dolist (frame-parameter '((fullscreen . nil)
                             (width . 160)
                             (height . 48)))
    (set frame-alist-variable
         (cons frame-parameter
               (assq-delete-all (car frame-parameter)
                                (symbol-value frame-alist-variable))))))

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)

;; File-name handlers are consulted very frequently while packages load.  No
;; compressed or remote file is needed during early init; restore the values as
;; soon as startup is complete.
(let ((saved-file-name-handler-alist file-name-handler-alist)
      (saved-load-suffixes load-suffixes)
      (saved-load-file-rep-suffixes load-file-rep-suffixes))
  (setq file-name-handler-alist nil
        load-suffixes '(".elc" ".el")
        load-file-rep-suffixes '(""))
  (add-hook 'emacs-startup-hook
            (lambda ()
              (setq file-name-handler-alist saved-file-name-handler-alist
                    load-suffixes saved-load-suffixes
                    load-file-rep-suffixes saved-load-file-rep-suffixes))
            101))

(setq use-package-enable-imenu-support t)

;; Startup profiling is opt-in because sampling itself adds a small amount of
;; overhead.  `profile-startup.ps1' sets this environment variable for one
;; diagnostic launch only.
(when (getenv "MY_EMACS_PROFILE_STARTUP")
  (require 'profiler)
  (when (fboundp 'profiler-cpu-start)
    (profiler-start 'cpu)))
