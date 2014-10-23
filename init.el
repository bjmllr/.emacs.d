(add-to-list 'load-path "~/.emacs.d/lisp")
(byte-recompile-directory (expand-file-name "~/.emacs.d/lisp") 0)

(require 'cask "~/.cask/cask.el")
(cask-initialize)

;; packages configured by Custom
(require 'whitespace)
(require 'auto-complete)

(setenv "PATH" (concat (getenv "PATH") ":/usr/local/bin"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;; custom-set-variables was added by Custom.
(global-auto-revert-mode nil)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ac-auto-start t)
 '(column-number-mode t)
 '(custom-enabled-themes (quote (smart-mode-line-dark)))
 '(custom-safe-themes
   (quote
    ("6a37be365d1d95fad2f4d185e51928c789ef7a4ccf17e7ca13ad63a8bf5b922f" "8aebf25556399b58091e533e455dd50a6a9cba958cc4ebb0aab175863c25b9a4" "756597b162f1be60a12dbd52bab71d40d6a2845a3e3c2584c6573ee9c332a66e" default)))
 '(desktop-save t)
 '(desktop-save-mode t)
 '(electric-indent-mode t)
 '(electric-layout-mode t)
 '(electric-pair-mode t)
 '(global-whitespace-mode nil)
 '(ido-cannot-complete-command (quote ido-next-match))
 '(ido-everywhere t)
 '(indent-tabs-mode nil)
 '(js2-basic-offset 2)
 '(magit-use-overlays nil)
 '(save-place t nil (saveplace))
 '(show-paren-mode t)
 '(tab-stop-list (quote (4 8 12 16 20 24 28 32 36 40 44 48 52 56 60)))
 '(tramp-default-method "scpx")
 '(uniquify-buffer-name-style (quote reverse) nil (uniquify))
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
 '(whitespace-space ((t nil)))
 '(whitespace-tab ((t (:background "#202b40"))))
 '(widget-field ((t (:background "Black")))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; custom-set-variables was added by Custom.

;;;;; Server
(server-start)

;;;;; UI
(defalias 'yes-or-no-p 'y-or-n-p)
(tool-bar-mode -1)
(define-key global-map (kbd "C-c C-SPC") 'ace-jump-mode)
(define-key global-map (kbd "M-j") (lambda ()
                                     (interactive)
                                     (newline-and-indent)
                                     (previous-line)
                                     (funcall indent-line-function)))
(require 'ido) (ido-mode t)
(set-face-attribute 'default nil :height 100)

(desktop-save-mode)

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

;;; Terminals
(defun is-empty (s) (= (length s) 0))
(defun term-with-title (title cmd)
  "Start a shell in term-mode, optionally giving it an explicit title"
  (interactive "sTitle of terminal session: \nsCommand to run: ")
  (if (is-empty cmd) (term "/bin/bash") (term cmd))
  (if (is-empty title) () (rename-buffer title)))
(global-set-key (kbd "C-c T") 'term-with-title)

(defadvice term-handle-exit
    (after term-kill-buffer-on-exit activate)
  (kill-buffer))

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
(global-set-key (kbd "C-x f") 'recentf-open-files)
(setq recentf-auto-cleanup 'never)

;;; Backup/Autosave/Lockfiles
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))
(setq create-lockfiles nil)

;;;;; Programming
(setq-default tab-width 4)
(require 'flycheck)

;;; (ma)git
(require 'magit)
(global-set-key (kbd "C-c v s") 'magit-status)
(global-set-key (kbd "C-c v w") 'server-edit)

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

;;;;; YAML
(defun disable-electric-indent ()
  (set (make-local-variable 'electric-indent-functions)
       (list (lambda (arg) 'no-indent))))
(add-hook 'yaml-mode-hook   'disable-electric-indent)
(add-hook 'yaml-mode-hook 'whitespace-mode)

(add-to-list 'auto-mode-alist '("\\.sls\\'"    . yaml-mode))

;;;;; ELisp
(add-hook 'emacs-lisp-mode (lambda () (setq indent-tabs-mode nil)))
(add-hook 'emacs-lisp-mode 'whitespace-mode)

;;;;; HTML
(add-hook 'html-mode-hook (lambda () (setq indent-tabs-mode nil)))
(add-hook 'html-mode-hook 'whitespace-mode)
(defun my-html-greaterthan ()
  "Insert >, close the tag, place the cursor inside it, and indent"
  (interactive)
  (if (char-equal ?> (char-after)) (right-char) (insert ">"))
  (save-excursion (sgml-close-tag) (funcall indent-line-function)))
(eval-after-load 'sgml-mode
  '(define-key html-mode-map (kbd ">") 'my-html-greaterthan))
(defun my-html-newline ()
  "Indents the current line, inserts a line, which it also indents; inserts an additional newline if point is between two tags"
  (interactive)
  (if (and (char-equal ?> (char-before)) (char-equal ?< (char-after)))
	  (progn
	   (funcall indent-line-function)
	   (newline-and-indent)
	   (save-excursion (newline-and-indent))
	   (funcall indent-line-function))
	(progn
	  (funcall indent-line-function)
	  (newline-and-indent))))
(eval-after-load 'sgml-mode
  '(define-key html-mode-map (kbd "RET") 'my-html-newline))

;;;;; JavaScript
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(add-hook 'js2-mode-hook (lambda () (setq indent-tabs-mode nil)))
(add-hook 'js2-mode-hook (lambda () (setq electric-pair-mode nil)))
(add-hook 'js2-mode-hook 'disable-electric-indent)
(add-hook 'js2-mode-hook (lambda () (autopair-mode)))
(add-hook 'js2-mode-hook 'whitespace-mode)
(defun my-js2-newline ()
  "Indents the current line, inserts a line, which it also indents"
  (interactive)
  (funcall indent-line-function)
  (newline-and-indent))
(eval-after-load 'js2-mode
  '(define-key js2-mode-map (kbd "C-j") 'my-js2-newline))
(defun my-js2-curly-bracket ()
  "Indents, inserts {"
  (interactive)
  (funcall indent-line-function)
  (insert "{"))
(eval-after-load 'js2-mode
  '(define-key js2-mode-map (kbd "{")   'my-js2-curly-bracket))
(defun my-js2-semicolon ()
  "Indents, inserts ;, indents again"
  (interactive)
  (funcall indent-line-function)
  (insert ";"))
(eval-after-load 'js2-mode
  '(define-key js2-mode-map (kbd ";")   'my-js2-semicolon))

;;;;;  CoffeeScript
(add-to-list 'auto-mode-alist '("\\.coffee.js\\'" . coffee-mode))
;;(add-hook 'coffee-mode-hook (lambda () (setq indent-tabs-mode nil)))
(add-hook 'coffee-mode-hook 'disable-electric-indent)
(add-hook 'coffee-mode-hook 'whitespace-mode)
;;(define-key coffee-mode-map [(super r)] 'coffee-compile-buffer)

;;;;; Ruby
(require 'rspec-mode)
(require 'rbenv)
(global-rbenv-mode)
(setq rspec-use-rake-when-possible nil)
(require 'ruby-tools)
(require 'rcodetools)
(define-key ruby-mode-map (kbd "C-c C-c") 'xmp)
(setenv "PAGER" (executable-find "cat"))
(require 'robe)
(push 'ac-source-robe ac-sources)

(add-hook 'ruby-mode-hook 'ruby-tools-mode)
(add-hook 'ruby-mode-hook 'flycheck-mode)
(add-hook 'ruby-mode-hook 'rspec-mode)
(add-hook 'ruby-mode-hook 'ruby-end-mode)
(add-hook 'ruby-mode-hook 'whitespace-mode)

(add-to-list 'auto-mode-alist '("Capfile"    . ruby-mode))
(add-to-list 'auto-mode-alist '("Gemfile\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("Guardfile"  . ruby-mode))
(add-to-list 'auto-mode-alist '("Rakefile"   . ruby-mode))
(add-to-list 'auto-mode-alist '(".pryrc"     . ruby-mode))

;;; can't figure out how to get this to work well with bundler
;; (add-hook 'ruby-mode-hook 'robe-mode)
;; (add-hook 'robe-mode-hook 'robe-start)

;;;;; PHP
(defun bmiller/php-mode-init ()
   "Set some buffer-local variables."
   (setq indent-tabs-mode t)
   (message "php-mode customizations activated"))
(add-hook 'php-mode-hook 'bmiller/php-mode-init)
(add-hook 'php-mode-hook 'whitespace-mode)

;;;;; Haskell
(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
(add-hook 'haskell-mode-hook 'whitespace-mode)

;;;;; Scala
(setq sbt:program-name (concat (getenv "HOME") "/.scala/sbt/bin/sbt"))

;;;;; Misc Key Bindings / Utility functions
(global-unset-key (kbd "C-z")) ;; suspend-frame is also bound to C-x C-z
(global-set-key (kbd "C-c i") 'insert-char)

(defun backward-kill-word-or-space-or-newline ()
  (interactive)
  (if (char-equal ?\n (char-before))
         (backward-delete-char-untabify 1)
       (if (or (char-equal ?\s (char-before))
                       (char-equal ?\t (char-before)))
               (progn
                 (while (or (char-equal ?\s (char-before))
                                        (char-equal ?\t (char-before)))
                       (backward-delete-char-untabify 1)))
         (backward-kill-word 1))))
(global-set-key (kbd "C-<backspace>") 'backward-kill-word-or-space-or-newline)

;;; Mac key
(setq mac-command-modifier 'super)
;; cut, copy, paste
(global-set-key (kbd "s-x") 'kill-region)
(global-set-key (kbd "s-c") 'kill-ring-save)
(global-set-key (kbd "s-v") 'yank)
(global-set-key (kbd "s-V") 'yank-pop)
;; navigate windows
(global-set-key (kbd "s-P") 'windmove-up)
(global-set-key (kbd "s-N") 'windmove-down)
(global-set-key (kbd "s-F") 'windmove-right)
(global-set-key (kbd "s-B") 'windmove-left)
;; navigate frames
(global-set-key (kbd "s-O") 'other-frame)

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

;;; smart mode line

(defun powerline-my-theme ()
  "Setup a personal mode-line with major and minor modes centered."
  (interactive)
  (setq-default
   mode-line-format
   '("%e"
     (:eval
      (let* ((active (powerline-selected-window-active))
             (mode-line (if active 'mode-line 'mode-line-inactive))
             (face1 (if active 'powerline-active1 'powerline-inactive1))
             (face2 (if active 'powerline-active2 'powerline-inactive2))
             (separator-left
              (intern (format "powerline-%s-%s"
                              powerline-default-separator
                              (car powerline-default-separator-dir))))
             (separator-right
              (intern (format "powerline-%s-%s"
                              powerline-default-separator
                              (cdr powerline-default-separator-dir))))
             (lhs (list (powerline-raw "%*" nil 'l)
                        (powerline-buffer-id nil 'l)
                        (powerline-raw " ")
                        (funcall separator-left mode-line face1)
                        (powerline-narrow face1 'l)
                        (powerline-vc face1)))
             (rhs (list (powerline-raw "%4l" face1 'r)
                        (powerline-raw ":" face1)
                        (powerline-raw "%3c" face1 'r)
                        (powerline-raw global-mode-string face1 'r)
                        (funcall separator-right face1 mode-line)
                        (powerline-raw " ")
                        (powerline-raw "%6p" nil 'r)
                        (powerline-buffer-size nil 'l)
                        (powerline-hud face2 face1)))
             (center (list (powerline-raw " " face1)
                           (funcall separator-left face1 face2)
                           (when (boundp 'erc-modified-channels-object)
                             (powerline-raw erc-modified-channels-object face2 'l))
                           (powerline-major-mode face2 'l)
                           (powerline-process face2)
                           (powerline-raw ":" face2)
                           (powerline-minor-modes face2 'l)
                           (powerline-raw " " face2)
                           (funcall separator-right face2 face1))))
        (concat (powerline-render lhs)
                (powerline-fill-center face1 (/ (powerline-width center) 2.0))
                (powerline-render center)
                (powerline-fill face1 (powerline-width rhs))
                (powerline-render rhs)))))))
(sml/setup)
(powerline-my-theme)
(load-theme 'solarized-dark t)
(run-at-time 0 nil 'powerline-reset)

(diminish 'flycheck-mode "c")
(diminish 'auto-complete-mode "a")
(diminish 'global-whitespace-mode "w")
(diminish 'magit-auto-revert-mode "r")
(diminish 'rspec-mode "s")
(diminish 'ruby-tools-mode "t")
