;; testing a patch to ruby-mode.el that fixes ruby-{end,beginning}-of-block

(defun ruby-move-to-block (n)
  "Move to the beginning (N < 0) or the end (N > 0) of the
current block, a sibling block, or an outer block.  Do that (abs N) times."
  (back-to-indentation)
  (let ((signum (if (> n 0) 1 -1))
        (backward (< n 0))
        (depth (or (nth 2 (ruby-parse-region (point) (line-end-position))) 0))
        case-fold-search
        down done)
    (when (looking-at ruby-block-mid-re)
      (setq depth (+ depth signum)))
    (when (< (* depth signum) 0)
      ;; Moving end -> end or beginning -> beginning.
      (setq depth 0))
    (dotimes (_ (abs n))
      (setq done nil)
      (setq down (save-excursion
                   (back-to-indentation)
                   ;; There is a block start or block end keyword on this
                   ;; line, don't need to look for another block.
                   (and (re-search-forward
                         (if backward ruby-block-end-re
                           (concat "\\_<\\(" ruby-block-beg-re "\\)\\_>"))
                         (line-end-position) t)
                        (not (nth 8 (syntax-ppss))))))
      (while (and (not done) (not (if backward (bobp) (eobp))))
        (forward-line signum)
        (cond
         ;; Skip empty and commented out lines.
         ((looking-at "^\\s *$"))
         ((looking-at "^\\s *#"))
         ;; Skip block comments;
         ((and (not backward) (looking-at "^=begin\\>"))
          (re-search-forward "^=end\\>"))
         ((and backward (looking-at "^=end\\>"))
          (re-search-backward "^=begin\\>"))
         ;; Jump over a multiline literal.
         ((ruby-in-ppss-context-p 'string)
          (goto-char (nth 8 (syntax-ppss)))
          (unless backward
            (forward-sexp)
            (when (bolp) (forward-char -1)))) ; After a heredoc.
         (t
          (let ((state (ruby-parse-region (point) (line-end-position))))
            (unless (car state) ; Line ends with unfinished string.
              (if (nth 2 state) (setq depth (+ (nth 2 state) depth)))))
          (cond
           ;; Increased depth, we found a block.
           ((> (* signum depth) 0)
            (setq down t))
           ;; We're at the same depth as when we started, and we've
           ;; encountered a block before.  Stop.
           ((and down (zerop depth))
            (setq done t))
           ;; Lower depth, means outer block, can stop now.
           ((< (* signum depth) 0)
            (setq done t)))))))
    (back-to-indentation)))
