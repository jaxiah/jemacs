;; -*- lexical-binding: t; -*-

;;; my-startup.el --- lightweight startup timing and profiling

(defcustom my-startup-profile-file
  (expand-file-name "data/startup-profile.el" my-config-directory)
  "File used to save an opt-in Emacs CPU startup profile."
  :type 'file
  :group 'my-emacs)

(defun my/finish-startup-profile ()
  "Stop the opt-in startup profiler, save it, and display its report."
  (when (and (featurep 'profiler)
             (fboundp 'profiler-running-p)
             (profiler-running-p 'cpu))
    (profiler-stop)
    (let ((profile-file (or (getenv "MY_EMACS_PROFILE_FILE")
                            my-startup-profile-file)))
      (when (and profile-file (not (string= profile-file "")))
        (make-directory (file-name-directory (expand-file-name profile-file)) t)
        (profiler-write-profile (profiler-cpu-profile) profile-file)
        (message "Startup CPU profile written to %s" profile-file)))
    (unless noninteractive
      (profiler-report))))

(defun my/report-startup-time ()
  "Show the startup duration reported by Emacs itself."
  (message "jemacs started in %s" (emacs-init-time)))

(add-hook 'emacs-startup-hook #'my/finish-startup-profile 80)
(unless noninteractive
  (add-hook 'emacs-startup-hook #'my/report-startup-time 90))

(provide 'my-startup)
;;; my-startup.el ends here
