;; -*- lexical-binding: t -*-

;; ----------------------------------------------------------------------------------------------------
;; 基本内置选项设置
;; ----------------------------------------------------------------------------------------------------

(setq inhibit-startup-message t)

;; shift + 方向键来切换 window
;; 跟 org-mode 的日期界面冲突
(windmove-default-keybindings)

;; 记住window配置状态，C-c left or right来切换
(winner-mode 1)

;; 显示光标列数
(setq column-number-mode t)

;; 高亮当前行
(global-hl-line-mode 0)

;; 设置 tab 标签宽度
(setq-default tab-width 8)

;; frame 标题显示 buffer 名
(setq frame-title-format "%b")

;; 关闭文件备份
(setq make-backup-files nil)

;; 选中后输入会删除
(delete-selection-mode 1)

;; 开启 narrow 功能
(put 'narrow-to-region 'disabled nil)
(put 'narrow-to-page 'disabled nil)

;; 开启全局行号
(global-display-line-numbers-mode)

;; 在某些模式下关闭行号以避免干扰
(dolist (mode '(term-mode eshell-mode vterm-mode shell-mode dired-mode org-mode))
  (add-hook (intern (format "%s-hook" mode))
            (lambda () (display-line-numbers-mode -1))))

;; 自动载入外部修改
(global-auto-revert-mode t)

;; 默认截断
(setq-default truncate-lines t)

;; 平滑滚动
(setq scroll-conservatively 100)
;; 鼠标平滑滚动
(setq mouse-wheel-scroll-amount '(5 ((shift) . 1) ((control) . nil)))
(setq mouse-wheel-progressive-speed nil)

;; 让 dired mode 中目录排在前面
(require 'ls-lisp)
(setq ls-lisp-dirs-first t)
(setq ls-lisp-use-insert-directory-program nil)

;; force line wrap to wrap at word boundaries
;; (setq-default word-wrap t)

(add-to-list 'default-frame-alist '(top . 0.5))
(add-to-list 'default-frame-alist '(left . 0.5))
(add-to-list 'default-frame-alist '(fullscreen))

;; 根据不同分辨率做不同设置
;; (let* ((resolution (shell-command-to-string (format "%s" (expand-file-name "cc/get-scr-res.exe" user-emacs-directory))))
;;        (height (string-to-number (cadr (split-string resolution "x"))))
;;        (settings (cond
;;                   ((<= height 1080) '(:font-size 10 :width 160 :height 40))
;;                   ((<= height 1440) '(:font-size 11 :width 160 :height 40))
;;                   ((<= height 2160) '(:font-size 12 :width 160 :height 40))
;;                   (t '(:font-size 10 :width 160 :height 40)))) ;; 默认设置
;;        (font-size (plist-get settings :font-size))
;;        (frame-width (plist-get settings :width))
;;        (frame-height (plist-get settings :height)))
;; 
;;   (message "Screen height detected: %d, applying settings: font-size=%d, width=%d, height=%d"
;;            height font-size frame-width frame-height)
;;   (add-to-list 'default-frame-alist `(font . ,(format "Maple Mono NL NF CN %d" font-size)))
;;   (add-to-list 'default-frame-alist `(width . ,frame-width))
;;   (add-to-list 'default-frame-alist `(height . ,frame-height)))

(let* ((font-size 11)
       (frame-width 160)
       (frame-height 40))
  (message "Applying fixed settings: font-size=%d, width=%d, height=%d" font-size frame-width frame-height)
  (add-to-list 'default-frame-alist `(font . ,(format "Maple Mono NL NF CN %d" font-size)))
  (add-to-list 'default-frame-alist `(width . ,frame-width))
  (add-to-list 'default-frame-alist `(height . ,frame-height)))

(provide 'init-builtin)
