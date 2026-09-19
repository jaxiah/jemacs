;; -*- lexical-binding: t; -*-

;;; my-org.el --- small, non-invasive Org defaults

(use-package org
  :ensure nil
  :hook (org-mode . visual-line-mode)
  :custom
  (org-startup-indented t)
  (org-hide-emphasis-markers t)
  (org-return-follows-link t)
  (org-src-window-setup 'current-window))

(provide 'my-org)
