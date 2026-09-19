;; -*- lexical-binding: t; -*-

;;; my-ui.el --- graphical frame and display settings

(defun my/center-frame (&optional frame)
  "Center FRAME in the usable area of its current monitor."
  (setq frame (or frame (selected-frame)))
  (when (display-graphic-p frame)
    (let* ((monitor (frame-monitor-attributes frame))
           (workarea (cdr (assq 'workarea monitor))))
      (when (and workarea (= (length workarea) 4))
        (let* ((workarea-left (nth 0 workarea))
               (workarea-top (nth 1 workarea))
               (workarea-width (nth 2 workarea))
               (workarea-height (nth 3 workarea))
               (left (+ workarea-left
                        (max 0 (/ (- workarea-width (frame-pixel-width frame))
                                  2))))
               (top (+ workarea-top
                       (max 0 (/ (- workarea-height (frame-pixel-height frame))
                                 2)))))
          (set-frame-position frame left top))))))

(dolist (mode '(menu-bar-mode tool-bar-mode scroll-bar-mode))
  (when (fboundp mode)
    (funcall mode -1)))

(defun my/apply-frame-settings (&optional frame)
  "Apply Windows-friendly font settings to FRAME."
  (setq frame (or frame (selected-frame)))
  (when (display-graphic-p frame)
    (with-selected-frame frame
      (let ((font-family
             (catch 'found
               (dolist (family my-font-candidates)
                 (when (find-font (font-spec :family family))
                   (throw 'found family))))))
        (when font-family
          (set-face-attribute 'default frame
                              :family font-family
                              :height 110)))
      (my/center-frame frame))))

(add-hook 'after-make-frame-functions #'my/apply-frame-settings)

(defun my/show-initial-frame ()
  "Apply final frame settings, then reveal the initially hidden frame."
  (let ((frame (selected-frame)))
    (when (display-graphic-p frame)
      ;; The launchers pass `--iconic', so all visual adjustments happen while
      ;; the frame is hidden from the user.  The final centering must happen
      ;; after deiconifying: Windows can restore the old iconified position
      ;; when `make-frame-visible' returns.
      (my/apply-frame-settings frame)
      (make-frame-visible frame)
      (my/center-frame frame)
      (raise-frame frame))))

;; `window-setup-hook' runs after the initial frame's command-line parameters
;; have been applied, which is the reliable point for the final Windows move.
(add-hook 'window-setup-hook #'my/show-initial-frame)

(load-theme 'wombat t)

(provide 'my-ui)
