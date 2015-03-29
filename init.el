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
 '(electric-layout-mode t)
 '(electric-pair-mode t)
 '(erc-modules
   (quote
    (autojoin button completion fill irccontrols keep-place list log match menu move-to-prompt netsplit networks noncommands readonly ring scrolltobottom stamp track)))
 '(erc-track-enable-keybindings nil)
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
(require 'expand-region)
(defalias 'yes-or-no-p 'y-or-n-p)
(tool-bar-mode -1)
(define-key global-map (kbd "C-=") 'er/expand-region)
(define-key global-map (kbd "C-c =") 'align-regexp)
(define-key global-map (kbd "C-c C-SPC") 'ace-jump-mode)
(define-key global-map (kbd "M-j") (lambda ()
                                     (interactive)
                                     (newline-and-indent)
                                     (previous-line)
                                     (funcall indent-line-function)))
(require 'ido) (ido-mode t)
(set-face-attribute 'default nil :height 100)

(desktop-save-mode)

;;; scratch buffer
(defun scratch ()
  (interactive)
  (switch-to-buffer "*scratch*"))
(define-key global-map (kbd "s-s") 'scratch)

;;; window layouts
(defun arrange-windows-two-by-two ()
  (interactive)
  (delete-other-windows)
  (split-window-below)
  (split-window-right)
  (windmove-down)
  (split-window-right)
  (windmove-up))
(global-set-key (kbd "C-x 7") 'arrange-windows-two-by-two)
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
(global-set-key (kbd "C-x 6") 'arrange-windows-three-by-two)
(global-set-key (kbd "C-x 5") 'make-frame)

;;; Terminals
(defun is-empty (s) (= (length s) 0))
(defun term-with-title (title)
  "Start a shell in term-mode, optionally giving it an explicit title"
  (interactive "sTitle of terminal session: ")
  (ansi-term "/bin/bash")
  (if (is-empty title) () (rename-buffer title)))
(global-set-key (kbd "C-c T") 'term-with-title)

(defadvice term-handle-exit
    (after term-kill-buffer-on-exit activate)
  (kill-buffer))

;;; comma separated lists
(defun next-comma ()
  (interactive)
  (re-search-forward "[,\(\{]\\|do")
  (re-search-forward "[^[:space:]\n\(\{]")
  (backward-char))
(global-set-key (kbd "C-,") 'next-comma)
(defun prev-comma ()
  (interactive)
  (re-search-backward "[,\)\}]\\|end")
  (re-search-backward "[^[:space:]\n\)\},]"))
(global-set-key (kbd "C-M-,") 'prev-comma)

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
(setq recentf-auto-cleanup 'never)
(recentf-mode 1)
(global-set-key (kbd "C-x f") 'recentf-open-files)

;;; Backup/Autosave/Lockfiles
(setq backup-directory-alist
      `((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
      `((".*" ,temporary-file-directory t)))
(setq create-lockfiles nil)

;;;;; Programming
(require 'flycheck)
(require 'aggressive-indent)

(setq-default tab-width 4)
(setq delete-trailing-lines t)
(defun delete-trailing-whitespace-after ()
  (delete-trailing-whitespace (point) (point-max)))
(defun add-hook-delete-trailing-whitespace-after ()
  (add-hook 'post-command-hook 'delete-trailing-whitespace-after))

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

;;; guard (ct)

;; http://stackoverflow.com/questions/8989540/touch-current-file-in-emacs
(defun touch ()
  "updates mtime on the file for the current buffer"
  (interactive)
  (shell-command (concat "touch " (shell-quote-argument (buffer-file-name))))
  (clear-visited-file-modtime))
(global-set-key (kbd "C-.") 'touch)

;; TODO - make this not depend on magit
;;      - try magit topdir, then projectile topdir, then PWD
(defun guard ()
  "start a local Guard session"
  (interactive)
  (shell-command
   (concat "cd " (magit-get-top-dir) " && bin/guard --clear &")
   (get-buffer-create "*Guard*"))
  (set-buffer (get-buffer-create "*Guard*"))
  (compilation-shell-minor-mode))

(setq ansi-color-for-comint-mode-on t)

(defun guard-listen ()
  "start a local listen session for Guard"
  (interactive))

;;;;; YAML
(defun disable-electric-indent ()
  (set (make-local-variable 'electric-indent-functions)
       (list (lambda (arg) 'no-indent))))
(add-hook 'yaml-mode-hook   'disable-electric-indent)
(add-hook 'yaml-mode-hook 'whitespace-mode)

(add-to-list 'auto-mode-alist '("\\.sls\\'"    . yaml-mode))

;;;;; ELisp
(add-hook 'emacs-lisp-mode-hook (lambda () (setq mode-name "ELisp")))
(add-hook 'emacs-lisp-mode (lambda () (setq indent-tabs-mode nil)))
(add-hook 'emacs-lisp-mode 'whitespace-mode)
(add-hook 'emacs-lisp-mode 'aggressive-indent-mode)

;;;;; HTML
(add-hook 'html-mode-hook (lambda () (setq indent-tabs-mode nil)))
(add-hook 'html-mode-hook 'whitespace-mode)
(defun bmiller/html-greaterthan ()
  "Insert >, close the tag, place the cursor inside it, and indent"
  (interactive)
  (if (char-equal ?> (char-after)) (right-char) (insert ">"))
  (save-excursion (sgml-close-tag) (funcall indent-line-function)))
(eval-after-load 'sgml-mode
  '(define-key html-mode-map (kbd ">") 'bmiller/html-greaterthan))

(defun bmiller/html-newline ()
  "Indents the current line, inserts a line, which it also indents; inserts an additional newline if point is between two tags"
  (interactive)
  (if (= (point) (point-max))
      (insert "\n")
    (if (and (char-equal ?> (char-before)) (char-equal ?< (char-after)))
        (progn
          (funcall indent-line-function)
          (newline-and-indent)
          (save-excursion (next-line) (funcall indent-line-function))
          (funcall indent-line-function))
      (progn
        (funcall indent-line-function)
        (newline-and-indent)))))

(eval-after-load 'sgml-mode
  '(define-key html-mode-map (kbd "RET") 'bmiller/html-newline))

;;;;; JavaScript
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(add-hook 'js2-mode-hook (lambda () (setq mode-name "JS2")))
(add-hook 'js2-mode-hook (lambda () (setq indent-tabs-mode nil)))
(add-hook 'js2-mode-hook 'whitespace-mode)
(add-hook 'js2-mode-hook 'aggressive-indent-mode)

(defun bmiller/js2-funkey ()
  "Types 'function' for me"
  (interactive)
  (insert "function "))
(eval-after-load 'js2-mode
  '(define-key js2-mode-map (kbd "C-c C-f") 'bmiller/js2-funkey))

;;;;;  CoffeeScript
(add-to-list 'auto-mode-alist '("\\.coffee.js\\'" . coffee-mode))
;;(add-hook 'coffee-mode-hook (lambda () (setq indent-tabs-mode nil)))
(add-hook 'coffee-mode-hook 'disable-electric-indent)
(add-hook 'coffee-mode-hook 'whitespace-mode)
;;(define-key coffee-mode-map [(super r)] 'coffee-compile-buffer)

;;;;; Ruby
(require 'rspec-mode)
(require 'rbenv)
(require 'ruby-tools)
(require 'rcodetools)
(require 'robe)
(require 'ruby-end)

(setq rbenv-show-active-ruby-in-modeline nil)
(global-rbenv-mode)
(setq rspec-use-rake-when-possible nil)
(define-key ruby-mode-map (kbd "C-c C-c") 'xmp)
(setenv "PAGER" (executable-find "cat"))
(push 'ac-source-robe ac-sources)

(defun bmiller/ruby-before-save ()
  (interactive)
  (indent-region (point-min) (point-max))
  (save-excursion (end-of-buffer) (delete-blank-lines))
  (delete-trailing-whitespace (point-min) (point-max)))

(add-hook 'ruby-mode-hook 'ruby-tools-mode)
(add-hook 'ruby-mode-hook 'flycheck-mode)
(add-hook 'ruby-mode-hook 'rspec-mode)
(add-hook 'ruby-mode-hook 'ruby-end-mode)
(add-hook 'ruby-mode-hook 'whitespace-mode)
(add-hook 'ruby-mode-hook 'aggressive-indent-mode)
(add-hook 'ruby-mode-hook 'add-hook-delete-trailing-whitespace-after)
(add-hook 'ruby-mode-hook
          (lambda () (add-hook 'before-save-hook
                               'bmiller/ruby-before-save nil t)))

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

;;;;; C
(setq-default c-basic-offset 4)
(setq c-basic-offset 4)

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

(defface powerline-active3
  '((t (:background "grey70" :foreground "black" :inherit mode-line)))
  "Powerline face 3."
  :group 'powerline)

(defun bmiller/powerline-theme ()
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
             (face3 (if active 'powerline-active3 'powerline-inactive2))

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
                           (funcall separator-left face1 face3)
                           (powerline-major-mode face3 'l)
                           (powerline-process face3)
                           (powerline-raw ":" face3)
                           (powerline-minor-modes face3 'l)
                           (powerline-raw " " face3)
                           (funcall separator-right face3 face1))))
        (concat (powerline-render lhs)
                (powerline-fill-center face1 (/ (powerline-width center) 2.0))
                (powerline-render center)
                (powerline-fill face1 (powerline-width rhs))
                (powerline-render rhs)))))))

;; ERC channel notifications can be added like this:
;; (when (boundp 'erc-modified-channels-object)
;;   (powerline-raw erc-modified-channels-object face2 'l))
;; but ERC adds that list to some other object in the above, need to investigate

(sml/setup)
(bmiller/powerline-theme)
(load-theme 'solarized-dark t)
(add-hook 'window-configuration-change-hook 'powerline-reset)

(add-to-list 'sml/replacer-regexp-list
             '("^~/src/unipede/apps/global_api/public/ui/" ":UPui:") t)
(add-to-list 'sml/replacer-regexp-list
             '("^~/src/unipede/" ":UP:") t)

(diminish 'flycheck-mode "!")
(diminish 'auto-complete-mode "*")
(diminish 'global-whitespace-mode)
(diminish 'whitespace-mode)
(diminish 'magit-auto-revert-mode "~")
(diminish 'rspec-mode ".")
(diminish 'aggressive-indent-mode ">")
(diminish 'ruby-end-mode)
(diminish 'ruby-tools-mode)
(diminish 'compilation-shell-minor-mode ":")

;;;;; IRC (ERC)

;; http://www.emacswiki.org/emacs/ErcChannelTracking
(setq erc-log-channels-directory "~/.erc/logs/")
(setq erc-save-buffer-on-part t)
(add-hook 'erc-insert-post-hook 'erc-save-buffer-in-logs)
(setq erc-track-exclude-types '("JOIN" "PART" "QUIT" "NICK" "MODE"))
(setq erc-hide-list '("JOIN" "PART" "QUIT" "NICK" "MODE"))
(setq erc-join-buffer 'bury)
(setq erc-log-insert-log-on-open nil)

(defun reset-erc-track-mode ()
  (interactive)
  (setq erc-modified-channels-alist nil)
  (erc-modified-channels-update))
(global-set-key (kbd "C-c @") 'erc-track-switch-buffer)

(load "~/.erc/init.el")

(defun ruby-document-end ()
  (interactive)
  (ruby-end-of-block)
  (ruby-beginning-of-block)
  (move-end-of-line nil)
  (set-mark (point))
  (move-beginning-of-line nil)
  (copy-to-register 'ruby-document-end-register (point) (mark))
  (ruby-end-of-block)
  (move-beginning-of-line nil)
  (forward-word)
  (set-mark (point))
  (move-end-of-line nil)
  (delete-region (point) (mark))
  (insert " # ")
  (insert-register 'ruby-document-end-register)
  (move-beginning-of-line nil)
  (re-search-forward "#")
  (forward-char)
  (just-one-space)
  (ruby-beginning-of-block)
  (next-line)
  (indent-for-tab-command))
(global-set-key (kbd "C-c C-e") 'ruby-document-end)
