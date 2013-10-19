(add-to-list 'load-path "~/.emacs.d/lisp")

(require 'prelude-packages)
(byte-recompile-directory (expand-file-name "~/.emacs.d/lisp") 0)

;; packages configured by Custom
(require 'whitespace)
(require 'auto-complete)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; custom-set-variables was added by Custom.
(global-auto-revert-mode nil)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ac-auto-start t)
 '(backup-directory-alist (quote (("\".*\"" . "temporary-file-directory"))))
 '(column-number-mode t)
 '(custom-enabled-themes (quote (solarized-dark)))
 '(custom-safe-themes
   (quote
	("8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" default)))
 '(desktop-save t)
 '(desktop-save-mode t)
 '(electric-indent-mode t)
 '(electric-layout-mode t)
 '(global-whitespace-mode t)
 '(ido-cannot-complete-command (quote ido-next-match))
 '(ido-everywhere t)
 '(ruby-indent-level 4)
 '(ruby-indent-tabs-mode t)
 '(save-place t nil (saveplace))
 '(show-paren-mode t)
 '(tab-stop-list (quote (4 8 12 16 20 24 28 32 36 40 44 48 52 56 60)))
 '(tramp-default-method "scpx")
 '(uniquify-buffer-name-style (quote forward) nil (uniquify))
 '(visible-bell t)
 '(whitespace-display-mappings nil)
 '(whitespace-style
   (quote
	(face spaces trailing tabs space-before-tab indentation)))
 '(x-stretch-cursor t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(whitespace-tab ((t (:background "#202b40")))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; custom-set-variables was added by Custom.

;;;;; Server
(server-start)

;;;;; UI
(tool-bar-mode -1)
(define-key global-map (kbd "C-c SPC") 'ace-jump-mode)
(require 'ido) (ido-mode t)

;;; smart mode line
(sml/setup)

;;; window layouts
(defun arrange-windows-two-by-two ()
  (interactive)
  (delete-other-windows)
  (split-window-below)
  (split-window-right)
  (windmove-down)
  (split-window-right)
  (windmove-up))
(global-set-key (kbd "s-W") 'arrange-windows-two-by-two)
(defun arrange-windows-three-by-two ()
  (interactive)
  (delete-other-windows)
  (split-window-right)
  (split-window-below)
  (windmove-right)
  (split-window-right)
  (split-window-below)
  (windmove-right)
  (split-window-below)
  (windmove-left)
  (windmove-left)
  (balance-windows))
(global-set-key (kbd "s-w") 'arrange-windows-three-by-two)

;;;;; File Management
(global-set-key (kbd "C-x C-f") 'ido-find-file)

;;; can't remember where this came from
(defun rename-file-and-buffer ()
  "Rename the current buffer and file it is visiting."
  (interactive)
  (let ((filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (message "Buffer is not visiting a file!")
      (let ((new-name (read-file-name "New name: " filename)))
        (cond
         ((vc-backend filename) (vc-rename-file filename new-name))
         (t
          (rename-file filename new-name t)
          (set-visited-file-name new-name t t)))))))
(global-set-key (kbd "C-c r") 'rename-file-and-buffer)
(defun delete-this-buffer-and-file ()
  "Removes file connected to current buffer and kills buffer."
  (interactive)
  (let ((filename (buffer-file-name))
        (buffer (current-buffer))
        (name (buffer-name)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (when (yes-or-no-p "Are you sure you want to remove this file? ")
        (delete-file filename)
        (kill-buffer buffer)
        (message "File '%s' successfully removed" filename)))))
(global-set-key (kbd "C-c k") 'delete-this-buffer-and-file)

;;; Recent Files
(recentf-mode 1)
(global-set-key "\C-x f" 'recentf-open-files)
(setq recentf-auto-cleanup 'never)

;;;;; Programming
(setq-default tab-width 4)
(smart-tabs-insinuate 'ruby)

;;; parens
(smartparens-global-mode t)
(sp-pair "("  ")"  :bind "C-(")
(sp-pair "{"  "}"  :bind "C-{")
(sp-pair "["  "]"  :bind "C-}")
(sp-pair "\"" "\"" :bind "C-\"")
(sp-pair "'"  "'"  :bind "C-'")
;;(sp-pair "|"  "|"  :bind "C-|")

;; Autocomplete
(global-auto-complete-mode t)
(add-to-list 'ac-modes 'sql-mode 'ruby-mode)
(setq ac-sources '(ac-source-filename
				   ac-source-functions
				   ac-source-variables
				   ac-source-symbols
				   ac-source-features
				   ac-source-abbrev
				   ac-source-words-in-buffer
				   ac-source-words-in-same-mode-buffers
				   ac-source-words-in-all-buffer
				   ac-source-dictionary))

(defun disable-electric-indent ()
  (set (make-local-variable 'electric-indent-functions)
       (list (lambda (arg) 'no-indent))))
(add-hook 'coffee-mode-hook 'disable-electric-indent)

;;;;; Ruby
(rvm-use-default)
(setq rspec-use-rake-when-possible nil)
(setq ruby-indent-tabs-mode t)
(smart-tabs-advice ruby-indent-line ruby-indent-level)
(add-hook 'ruby-mode-hook 'hs-minor-mode)
(require 'ruby-tools)
(add-hook 'ruby-mode-hook 'ruby-tools-mode)
(require 'ruby-end)
(add-hook 'ruby-mode-hook 'ruby-end-mode)
(require 'ruby-block)
(ruby-block-mode t)
(setq ruby-block-highlight-toggle t)
(require 'robe)

(push 'ac-source-robe ac-sources)
(add-hook 'ruby-mode-hook 'flycheck-mode)

;;; Ruby Emacs Magic
;; rcodetools/xmpfilter
(require 'rcodetools)
(define-key ruby-mode-map (kbd "C-c C-c") 'xmp)

;;; Ruby inferior process stuff that I don't yet grok
;; (add-hook 'ruby-mode-hook 'robe-mode)
;; (add-hook 'robe-mode-hook 'run-ruby)
;; (add-hook 'robe-mode-hook 'robe-start)
;; (add-to-list 'inf-ruby-implementations '("pry" . "pry"))
;; (setq inf-ruby-default-implementation "pry")
;; (setq inf-ruby-first-prompt-pattern "^\\[[0-9]+\\] pry\\((.*)\\)> *")
;; (setq inf-ruby-prompt-pattern "^\\[[0-9]+\\] pry\\((.*)\\)[>*\"'] *")

;;;;; PHP
(defun bmiller/php-mode-init ()
   "Set some buffer-local variables."
   (setq indent-tabs-mode t)
   (message "php-mode customizations activated"))
(add-hook 'php-mode-hook 'bmiller/php-mode-init)

;;;;; Misc Key Bindings / Utility functions
(global-unset-key (kbd "C-z")) ;; suspend-frame is also bound to C-x C-z
(global-set-key (kbd "C-c i") 'insert-char)

;;; Mac key
(setq mac-command-modifier 'super)
;; cut, copy, paste
(global-set-key (kbd "s-x") 'kill-region)
(global-set-key (kbd "s-c") 'kill-ring-save)
(global-set-key (kbd "s-v") 'yank)
(global-set-key (kbd "s-V") 'yank-pop)
;; navigate windows
(global-set-key (kbd "<s-up>") 'windmove-up)
(global-set-key (kbd "<s-down>") 'windmove-down)
(global-set-key (kbd "<s-right>") 'windmove-right)
(global-set-key (kbd "<s-left>") 'windmove-left)

;;; other editing
(setq kill-whole-line t)
(defun kill-line-above ()
  (interactive)
  (previous-line)
  (move-beginning-of-line 1)
  (kill-line))
(global-set-key (kbd "C-S-k") 'kill-line-above)

;;;;; Docs
;;; Dash
(global-set-key "\C-cd" 'dash-at-point)
