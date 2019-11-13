;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-refresh-contents)

(unless (package-installed-p 'monokai-theme)
  (package-install 'monokai-theme))
(unless (package-installed-p 'markdown-mode)
  (package-install 'markdown-mode))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(show-paren-mode t)

(when window-system
  (set-frame-size (selected-frame) 120 48)
  (set-frame-parameter nil 'alpha 90))

(load-theme 'monokai t)

(setq ring-bell-function 'ignore)

(setq inhibit-startup-screen t)

;; フォント設定
(when (member "Ricty Diminished" (font-family-list))
  (add-to-list 'default-frame-alist '(font . "Ricty Diminished-14")))
