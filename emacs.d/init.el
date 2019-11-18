;; Added by Package.el.  This must copme before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)
(add-to-list 'package-archives
	     '("melpa-stable" . "https://stable.melpa.org/packages/") t)
;; (package-refresh-contents)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(show-paren-mode t)

;; 行番号
(global-display-line-numbers-mode)

(when window-system
  (set-frame-size (selected-frame) 120 48)
  (set-frame-parameter nil 'alpha 92))

(setq inhibit-startup-screen t)
(setq ring-bell-function 'ignore)
(fset 'yes-or-no-p 'y-or-n-p)

;; フォント設定
(when (member "Ricty Diminished" (font-family-list))
  (add-to-list 'default-frame-alist '(font . "Ricty Diminished 14")))

;; packages
(use-package zenburn-theme
  :ensure t
  :config
  (load-theme 'zenburn t))

(use-package markdown-mode
  :ensure t)

(use-package cider
  :ensure t)
