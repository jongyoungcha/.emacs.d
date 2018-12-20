;;; Avdded by Package.el.  This must come before configurations of
;;; installed packages.  Don't delete this line.  If you don't want it,
;;; just comment it out by adding a semicolon to the start of the line.
;;; You may delete these explanatory comments.

(gnutls-available-p)

(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/")
             '("marmalade" . "https://marmalade-repo.org/packages/"))

(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))

(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))


(defun my-show-eshell ()
  (interactive)
  (let (cmd)
    (setq cmd (format "%s %s" "cd" default-directory))
    (message cmd)
    (with-current-buffer "*eshell*"
      (eshell-return-to-prompt)
      (insert cmd)
      (eshell-send-input)
      (pop-to-buffer-same-window "*eshell*"))
    ))

(defun jo-open-line-above ()
  "Insert a newline above the current line and put point at beginning."
  (interactive)
  (unless (bolp)
    (beginning-of-line))
  (newline)
  (forward-line -1)
  (indent-according-to-mode))

(defun jo-open-line-below ()
  "Insert a newline below the current line and put point at beginning."
  (interactive)
  (unless (eolp)
    (end-of-line))
  (newline-and-indent))

(defun my-get-selection-length ()
  "Get length of selection."
  (interactive)
  (if (use-region-p)
      (let (pos1 pos2)
        (setq pos1 (region-beginning) pos2 (region-end))
        (- pos2 pos1))
    -1
    )
  )


(defun my-show-selection-length ()
  "Show length of selection."
  (interactive)
  (let (length)
    (setq length (my-get-selection-length))
    (if (equal length -1)
        (message "regions is not activated...")
      (message "length : %d" length)
      )
    )
  )


(defun my-cut-line-or-region ()
  "Cut current line, or text selection
When `universal-argument' is called first, cut whole buffer (respects `narrow-to-region').

URL `http://ergoemacs.org/emacs/emacs_copy_cut_current_line.html'
Version 2015-06-10"
  (interactive)
  (if current-prefix-arg
      (progn ; not using kill-region because we don't want to include previous kill
        (kill-new (buffer-string))
        (delete-region (point-min) (point-max)))
    (progn (if (use-region-p)
               (kill-region (region-beginning) (region-end) t)
             (kill-region (line-beginning-position) (line-beginning-position 2))))))


(defun my-copy-line-or-region ()
  "Copy current line, or text selection.
When called repeatedly, append copy subsequent lines.
When `universal-argument' is called first, copy whole buffer (respects `narrow-to-region').

URL `http://ergoemacs.org/emacs/emacs_copy_cut_current_line.html'
Version 2017-07-08"
  (interactive)
  (if current-prefix-arg
      (progn
        (kill-ring-save (point-min) (point-max))
        (message "All visible buffer text copied"))
    (if (use-region-p)
        (progn
          (kill-ring-save (region-beginning) (region-end))
          (message "Active region copied"))
      (if (eq last-command this-command)
          (if (eobp)
              (progn (message "empty line at end of buffer." ))
            (progn
              (kill-append "\n" nil)
              (kill-append
               (buffer-substring-no-properties (line-beginning-position) (line-end-position))
               nil)
              (message "Line copy appended")
              (progn
                (end-of-line)
                (forward-char))))
        (if (eobp)
            (if (eq (char-before) 10 )
                (progn (message "empty line at end of buffer." ))
              (progn
                (kill-ring-save (line-beginning-position) (line-end-position))
                (end-of-line)
                (message "line copied")))
          (progn
            (kill-ring-save (line-beginning-position) (line-end-position))
            (end-of-line)
            (forward-char)
            (message "line copied")))))))


;; When the loading time, the packages will be updated.
(use-package auto-package-update
  :ensure t)
(with-eval-after-load 'auto-package-update
  (lambda()
    (auto-package-update-now)))

(when (eq system-type 'darwin)
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier nil))


(setenv "LANG" "en_US.UTF-8")
(setenv "LC_ALL" "en_US.UTF-8")
(setenv "LC_CTYPE" "en_US.UTF-8")
(setenv "PTYHONIOENCODING" "utf-8")


(defun exec-shell-command-with-buffer(cmd temp-buffer-name)
  (interactive)
  (with-output-to-temp-buffer temp-buffer-name
    ;; (shell-command cmd temp-buffer-name "*Massage*")
    (async-shell-command cmd temp-buffer-name temp-buffer-name)
    (pop-to-buffer temp-buffer-name)
    ))

;; add themes
(use-package color-theme-sanityinc-tomorrow :ensure t)
(use-package solarized-theme :ensure t)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;  common configurations  ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package evil
  :ensure t)

(use-package yasnippet
  :ensure t)
(require 'yasnippet)
(yas-global-mode 1)

(use-package helm
  :ensure t)

(setq helm-split-window-in-side-p t)

(require 'helm-bookmark)

(with-eval-after-load 'helm
  (helm-mode 1)
  (setq helm-candidate-number-limit 500)
  (global-set-key (kbd "M-x") 'helm-M-x)
  (global-set-key (kbd "C-x C-f") 'helm-find-files)
  (global-set-key (kbd "C-x C-b") 'helm-buffers-list)
  (global-set-key (kbd "C-x r l") 'helm-bookmarks)
  )

(require 'helm-config)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; you need ag binary                        ;;
;; $ brew install the_silver_searcher        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package helm-ag
  :ensure t)
(with-eval-after-load 'helm-ag
  (global-set-key (kbd "C-c a g") 'helm-do-ag))

(use-package eyebrowse
  :ensure t)
(with-eval-after-load 'eyebrowse
  (setq eyebrowse-mode t))

(use-package prodigy
  :ensure t)

(use-package auto-dim-other-buffers
  :init
  (custom-set-faces
   '(auto-dim-other-buffers-face ((t (:background "#101520")))))
  (add-hook 'after-init-hook
            (lambda ()
              (when (fboundp 'auto-dim-other-buffers-mode)
                (auto-dim-other-buffers-mode t))))
  :ensure t)


(use-package hungry-delete
  :ensure t)
(global-hungry-delete-mode)

;; Add self paranthesis completion function.
;; (defun electric-pair ()
;;   "If at end of line, insert character pair without surrounding spaces.
;; Otherwise, just insert the typed character."
;;   (interactive)
;;   (if (eolp) (let (parens-require-spaces) (insert-pair)) (self-insert-command 1)))

(use-package autopair
  :ensure t)
(autopair-global-mode 1)
(setq autopair-autowrap t)

;; reuse a dired list buffer.
(require 'dired)
(define-key dired-mode-map (kbd "RET") 'dired-find-alternate-file)
(define-key dired-mode-map (kbd "^")
  (lambda () (interactive)
    (find-alternate-file "..")))

;; Remove the key esc esc esc remove other window
(defadvice keyboard-escape-quit (around my-keyboard-escape-quit activate)
  (let (orig-one-window-p)
    (fset 'orig-one-window-p (symbol-function 'one-window-p))
    (fset 'one-window-p (lambda (&optional nomini all-frames) t))
    (unwind-protect
        ad-do-it
      (fset 'one-window-p (symbol-function 'orig-one-window-p)))))

(defun indent-buffer ()
  "Indent the currently visited buffer."
  (interactive)
  (indent-region (point-min) (point-max)))


(defun indent-region-or-buffer ()
  "Indent a region if selected, otherwise the whole buffer."
  (interactive)
  (save-excursion
    (if (region-active-p)
        (progn
          (indent-region (region-beginning) (region-end))
          (message "Indented selected region."))
      (progn
        (indent-buffer)
        (message "Indented buffer.")))))

(global-set-key (kbd "C-M-\\") 'indent-region-or-buffer)


;; (defun my-prev-window ()
;;   (interactive)
;;   (other-window -1))

(setq skippable-buffers '("^\\*Messages\\*" "^\\*scratch\\*" "^\\*Help\\*" "^\\*helm buffers\\*"))

(defun jong-next-buffer ()
  "next-buffer that skips certain buffers"
  (interactive)
  (next-buffer)
  (dolist (skippable-buffer skippable-buffers)
    (when (string-match (buffer-name) skippable-buffer)
      (message "skip buffer: %s" skippable-buffer)
      (next-buffer)
      )
    ))

(defun jong-prev-buffer ()
  "next-buffer that skips certain buffers"
  (interactive)
  (previous-buffer)
  (dolist (skippable-buffer skippable-buffers)
    (when (string-match (buffer-name) skippable-buffer)
      (message "skip buffer: %s" skippable-buffer)
      (previous-buffer)
      )
    ))


(defun jo-show-buffer-other-window ()
  (interactive)
  (other-window -1)
  (helm-buffers-list)
  (other-window 1)
  )

(defun jo-show-buffer-other-window-move ()
  (interactive)
  (other-window -1)
  (helm-buffers-list)
  )

(defun jo-isearch-forward-other-window ()
  (interactive)
  (other-window -1)
  (isearch-forward)
  (other-window 1)
  )

(defun jo-isearch-backward-other-window ()
  (interactive)
  (other-window -1)
  (isearch-backward)
  (other-window 1)
  )


(defun chan-forward-word ()
  "Chan 'forward-word."
  (interactive)
  (let ((candidate-chars "[\(\)\{\}\;\:]")
        (target-string "")
        (base-pos 0)
        (fword-pos 0)
        (candindate-pos 0)
        (gap-length 0))
    (setq base-pos (point))
    (forward-word)
    (setq fword-pos (point))
    (setq target-string (buffer-substring base-pos fword-pos))
    (setq gap-length (string-match candidate-chars target-string))
    (if (not (equal gap-length nil))
        (backward-char (- (- (length target-string) gap-length) 1))))
  )


(defun chan-backward-word ()
  "Chan 'backward-word."
  (interactive)
  (let ((candidate-chars "[\(\)\;\:\{\}]")
        (target-string "")
        (base-pos 0)
        (bword-pos 0)
        (candindate-pos 0))
    (setq base-pos (point))
    (search-backward-regexp candidate-chars nil 'noerror)
    (setq candindate-pos (point))
    (goto-char base-pos)
    (backward-word)
    (setq bword-pos (point))
    (if (> candindate-pos bword-pos)
        (goto-char candindate-pos)))
  )

(defun chan-forward-delete-word ()
  "Chan 'forward-delete-word."
  (interactive)
  (let ((candidate-chars "[\(\)\;\:\{\} ]")
        (target-string "")
        (base-pos 0)
        (fword-pos 0)
        (candidate-pos 0))
    (setq base-pos (point))
    (search-forward-regexp candidate-chars nil 'noerror)
    (setq candidate-pos (point))
    (forward-word)
    (setq fword-pos (point))
    (goto-char base-pos)
    (if (> candidate-pos fword-pos)
        (delete-region base-pos fword-pos)
      (delete-region base-pos (1- candidate-pos )))
    (when (equal (point) base-pos)
      (if (equal (string (char-after (point))) " ")
          (while (equal (string (char-after (point))) " ")
            (delete-region (point) (1+ (point))))
        (delete-region (point) (1+ (point))))
      ))
  )


(defun chan-backward-delete-word ()
  "Chan 'backward-delete-word."
  (interactive)
  (let ((candidate-chars "[\(\)\;\:\{\} ]")
        (target-string "")
        (base-pos 0)
        (bword-pos 0)
        (candidate-pos 0))
    (setq base-pos (point))
    (search-backward-regexp candidate-chars nil 'noerror)
    (setq candidate-pos (point))
    (backward-word)
    (setq bword-pos (point))
    (goto-char base-pos)
    (if (> candidate-pos bword-pos)
        (ignore-errors (delete-region (1+ candidate-pos) base-pos))
      (ignore-errors (delete-region (1+ bword-pos) base-pos)))
    (when (equal (point) base-pos)
      (ignore-errors (delete-region (1- base-pos) base-pos)))
    )
  )


(defun chan-copy-current-line ()
  "Chan 'copy current line."
  (interactive)
  (let ((prev-pos (point))
        (start-line-pos (progn (beginning-of-line) (point)))
        (end-line-pos (progn (end-of-line) (point))))
    (kill-new (buffer-substring start-line-pos end-line))
    (goto-char prev-pos)))

(defun delete-word (arg)
  "Delete characters forward until encountering the end of a word.
With argument ARG, do this that many times."
  (interactive "p")
  (delete-region (point) (progn (forward-word arg) (point))))

(defun backward-delete-word (arg)
  "Delete characters backward until encountering the beginning of a word.
With argument ARG, do this that many times."
  (interactive "p")
  (delete-word (- arg)))

(global-set-key (kbd "M-<backspace>") 'backward-delete-word)
(global-set-key (kbd "M-d") 'delete-word)

(global-set-key [remap next-buffer] 'my-next-buffer)

(setq confirm-kill-emacs 'y-or-n-p)

(setq mark-ring-max 8)
(setq global-mark-ring-max 8)
(setq set-mark-command-repeat-pop t)
(global-set-key (kbd "S-SPC") 'toggle-korean-input-method)
(global-set-key (kbd "C-k") (lambda () (interactive)
                              (call-interactively 'comint-kill-whole-line)
                              (call-interactively 'indent-for-tab-command)))

(global-set-key (kbd "M-;") (lambda () (interactive)
                              (let ((base-pos 0))
                                (setq base-pos (point))
                                (beginning-of-line)
                                (call-interactively 'comment-line)
                                (goto-char base-pos)
                                (forward-line)
                                (indent-for-tab-command)
                                )))


(global-set-key (kbd "C-S-o") 'jo-open-line-above)
(global-set-key (kbd "C-o") 'jo-open-line-below)

(global-set-key (kbd "C-x C-x") 'other-window)
(global-set-key (kbd "C-x C-p") 'other-window)
(global-set-key (kbd "C-c k") (lambda() (interactive)
                                (call-interactively 'other-window)
                                (kill-buffer (buffer-name))
                                (call-interactively 'other-window)))



(global-set-key (kbd "C-S-M-;") 'windmove-left)
(global-set-key (kbd "C-S-M-'") 'windmove-right)

(global-set-key (kbd "C-S-M-[") 'windmove-up)
(global-set-key (kbd "C-<backspace>") 'hungry-delete-backward)
(global-set-key (kbd "C-<deletechar>") 'hungry-delete-forward)

(global-set-key (kbd "M-d") 'chan-forward-delete-word)
(global-set-key (kbd "M-<backspace>") 'chan-backward-delete-word)
(global-set-key (kbd "C-M-y") 'chan-copy-current-line)
(global-set-key (kbd "C-y") (lambda ()
                              (interactive)
                              (electric-newline-and-maybe-indent)
                              (call-interactively 'yank)
                              ))


(global-set-key (kbd "M-ESC ESC") 'keyboard-escape-quit)
(global-set-key (kbd "C-h SPC") 'helm-all-mark-rings)
(global-set-key (kbd "C-h C-SPC") 'helm-all-mark-rings)

(global-set-key (kbd "C-d") 'delete-forward-char)
(global-set-key (kbd "M-v") 'evil-scroll-page-up)
(global-set-key (kbd "C-v") 'evil-scroll-page-down)

(global-set-key (kbd "M-p") 'evil-jump-backward)
(global-set-key (kbd "M-n") 'evil-jump-forward)



;; Forward word with candidate characters.
(global-set-key (kbd "M-f") 'chan-forward-word)
(global-set-key (kbd "M-F") (lambda () (interactive)
                              (setq this-command-keys-shift-translated t)
                              (if (equal (region-active-p) nil)
                                  (call-interactively 'set-mark-command))
                              (chan-forward-word)))

;; Back word with candidate characters.
(global-set-key (kbd "M-b") 'chan-backward-word)
(global-set-key (kbd "M-B") (lambda () (interactive)
                              (setq this-command-keys-shift-translated t)
                              (if (not (use-region-p))
                                  (call-interactively 'set-mark-command))
                              (chan-backward-word)))


(global-set-key (kbd "C-c v y") 'my-copy-linea-or-region)
(global-set-key (kbd "C-c v x") 'my-cut-line-or-region)

(global-set-key [remap next-buffer] 'jong-next-buffer)
(global-set-key [remap previous-buffer] 'jong-prev-buffer)

(global-set-key (kbd "C-x b") 'helm-buffers-list)
(global-set-key (kbd "C-x C-b") 'helm-buffers-list)
(global-set-key (kbd "C-c b") 'jo-show-buffer-other-window)
(global-set-key (kbd "C-c C-b") 'jo-show-buffer-other-window)
(global-set-key (kbd "C-x n") 'jo-show-buffer-other-window-move)
(global-set-key (kbd "C-x C-n") 'jo-show-buffer-other-window-move)
(global-set-key (kbd "C-c C-s") 'jo-isearch-forward-other-window)
(global-set-key (kbd "C-c C-r") 'jo-isearch-backward-other-window)
(global-set-key (kbd "C-M-i") (lambda() (interactive) (scroll-other-window 15)))
(global-set-key (kbd "C-M-o") (lambda() (interactive) (scroll-other-window -15)))
(global-set-key (kbd "C-x w b") 'switch-to-buffer-other-window)

(global-set-key (kbd "C-c <") (lambda() (interactive)
                                (call-interactively 'eyebrowse-prev-window-config)
                                (message "slot : %s" (eyebrowse--get 'current-slot))))

(global-set-key (kbd "C-c >") (lambda() (interactive)
                                (call-interactively 'eyebrowse-next-window-config)
                                (message "slot : %s" (eyebrowse--get 'current-slot))))

(global-set-key (kbd "C-c w w") (lambda() (interactive)
                                  (call-interactively 'eyebrowse-switch-to-window-config-1)
                                  (call-interactively 'eyebrowse-switch-to-window-config-2)
                                  (call-interactively 'eyebrowse-switch-to-window-config-3)))


(global-set-key (kbd "<f8>") (lambda () (interactive)
			       (call-interactively 'gud-print)))
(global-set-key (kbd "<f9>") (lambda () (interactive)
			       (call-interactively 'gud-break)))
(global-set-key (kbd "<f10>") (lambda () (interactive)
				(call-interactively 'gud-nexti)))
(global-set-key (kbd "<f11>") (lambda () (interactive)
				(call-interactively 'gud-stepi)))
(global-set-key (kbd "<f12>") (lambda () (interactive)
				(if (get-buffer "*gud-debug*")
				    (with-current-buffer (get-buffer "*gud-debug*")
				      (progn (goto-char (point-max))
					     (insert "clearall")
					     (autopair-newline))
				      (with-current-buffer (get-buffer "*gud-connect*")
					(progn (goto-char (point-max))
					       (insert "clearall")
					       (autopair-newline)))))))


(defun my-reload-dir-locals-for-current-buffer ()
  "reload dir locals for the current buffer"
  (interactive)
  (let ((enable-local-variables :all))
    (hack-dir-local-variables-non-file-buffer)))

(defun my-reload-dir-locals-for-all-buffer-in-this-directory ()
  "for every buffer iwth the same `default-directory` as the current buffer's, reload dir-locals."
  (interactive)
  (let ((dir default-directory))
    (dolist (buffer (buffer-list))
      (with-current-buffer buffer
        (when (equal default-directory dir))
        (my-reload-dir-locals-for-current-buffer)))))


;; default setting.
(defun toggle-transparency ()
  "Transparency frame."
  (interactive)
  (let ((alpha (frame-parameter nil 'alpha)))
    (set-frame-parameter
     nil 'alpha
     (if (eql (cond ((numberp alpha) alpha)
                    ((numberp (cdr alpha)) (cdr alpha))
                    ;; Also handle undocumented (<active> <inactive>) form.

                    ((numberp (cadr alpha)) (cadr alpha)))
              100)
         '(85 . 50) '(100 . 100)))))

(global-set-key (kbd "C-c t") 'toggle-transparency)

(global-set-key (kbd "C-x C-0") 'delete-other-windows-vertically)

;; hide tool bar
(menu-bar-mode -1)
(tool-bar-mode -1)
(blink-cursor-mode -1)

(setq visible-bell nil)
(setq ring-bell-function 'ignore)

(defun lispy-parens ()
  "Setup parens display for lisp modes."
  (setq show-paren-delay 0)n
  (setq show-paren-style 'parenthesis)

  (show-paren-mode 1)
  (set-face-backgrount 'show-paren-math)
  (show-paren-mode 1)
  (set-face-background 'show-paren-match-face (face-background 'default))
  (if (boundp 'font-lock-comment-face)
      (set-face-foreground 'show-paren-match-face
                           (face-foreground 'font-lock-comment-face))
    (set-face-foreground 'show-paren-match-face
                         (face-foreground 'default)))
  (set-face-attribute 'show-paren-match-face nil :weight 'extra-bold))

(require 'paren)
(set-face-background 'show-paren-match (face-background 'default))
(set-face-foreground 'show-paren-match "#def")
(set-face-attribute 'show-paren-match  nil :weight 'extra-bold)

(show-paren-mode 1)

(setq show-paren-delay 0)

;; reload ~/.emacs.d/init.el file
(defun reload-user-init-file()
  "Load user init.el file"
  (interactive)
  (eval '(load-file user-init-file)))

;; open ~/.emacs.d/init.el
(defun open-init-el()
  "Open user init.el file"
  (interactive)
  (find-file-at-point user-init-file))

(global-set-key (kbd "C-c f e d") 'open-init-el)
(global-set-key (kbd "C-c l e d") 'reload-user-init-file)

(use-package auto-complete
  :ensure t)


(use-package company
  :ensure t)
(with-eval-after-load 'company
  (setq company-async-timeout 4)
  (setq company-dabbrev-downcase nil)
  (setq company-idle-delay 0.1)
  (setq company-minimum-prefix-length 3)
  (global-set-key (kbd "C-<tab>") 'company-complete)
  (add-hook 'after-init-hook 'global-company-mode))

(use-package company-quickhelp
  :ensure t)
(with-eval-after-load 'company-quickhelp
  (company-quickhelp-mode)
  (setq company-quickhelp-delay 0.1))

(use-package magit
  :ensure t
  :config
  (setq git-commit-summary-max-length 1000))

(use-package projectile
  :ensure t
  :init
  :config
  (projectile-global-mode)
  (setq projectile-indexing-method 'hybrid)
  (setq projectile-globally-ignored-directories (append '(".git") projectile-globally-ignored-directories))
  (setq projectile-globally-ignored-directories (append '(".svn") projectile-globally-ignored-directories))
  (setq projectile-enable-caching t)
  )

(use-package helm-projectile
  :ensure t)

(with-eval-after-load 'helm-projectile
  (setq helm-projectile-fuzzy-match nil))

(setq projectile-completion-system 'helm)
(helm-projectile-on)

(defun jo-set-projectile-run-command ()
  "Read user input command and set 'projectile-project-run-cmd'."
  (interactive)
  (let (user-input)
    (if (not (equal "" (setq user-input (read-string "Enter the command : "))))
        (progn
          (setq projectile-project-run-cmd user-input)
          (message "Changed projectile-project-run-cmd as %s" user-input))
      (message "The command was empty..."))
    ))

(global-set-key (kbd "C-c p p") 'projectile-switch-project)
(global-set-key (kbd "C-c p f") 'projectile-find-file-in-known-projects)
(global-set-key (kbd "C-c p c") 'projectile-compile-project)
(global-set-key (kbd "C-c p r") 'projectile-run-project)
(global-set-key (kbd "C-c p s") 'jo-set-projectile-run-command)
(global-set-key (kbd "C-c w f") 'other-frame)

(use-package exec-path-from-shell
  :ensure t)
(require 'exec-path-from-shell)
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize)
  (exec-path-from-shell-copy-envs '("PATH" "GOPATH")))

(use-package ido
  :ensure t
  :config
  :init
  (ido-mode t)
  (setq ido-enable-flex-matching t))

(use-package  flycheck
  :ensure t
  :init
  (global-flycheck-mode t))

(use-package auto-highlight-symbol
  :ensure t
  :init)
(require 'auto-highlight-symbol)
(global-auto-highlight-symbol-mode t)


(require 'files)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; elisp develope environments ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(add-hook 'emacs-lisp-mode-hook
          (lambda()
            (local-set-key (kbd "C-c g g") 'xref-find-definitions)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;  python develope environments  ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package elpy
  :ensure t)
(with-eval-after-load 'elpy
  (require 'elpy)
  (elpy-enable)
  ;; (elpy-use-ipython)
  (setq elpy-rpc-backend "jedi")
  (setq python-shell-interpreter "ipython")
  (setenv "IPY_TEST_SIMPLE_PROMPT" "1")
  (add-to-list 'python-shell-completion-native-disabled-interpreters "ipython")
  (setq jedi:complete-on-dot t)
  (setq jedi:environment-root "jedi"))

(use-package company-jedi
  :ensure t)
(add-hook 'python-mode-hook
          (lambda()
            (add-to-list 'company-backend 'company-jedi)))

(global-set-key (kbd "C-c i") 'indent-region)



(use-package anaconda-mode
  :ensure t)
(require 'anaconda-mode)
(add-hook 'python-mode-hook 'anaconda-mode)
(add-hook 'python-mode-hook 'anaconda-eldoc-mode)


(defun jyc-run-python ()
  "Use run python program"
  (interactive)
  (compile (concat "python " (buffer-name))))

(defun delete-above-below-window ()
  (interactive)
  (cond
   ((window-in-direction 'above)
    (windmove-up)
    (delete-window))
   ((window-in-direction 'below)
    (windmove-down)
    (delete-window))
   ((window-in-direction 'left)
    nil)
   ((window-in-direction 'right)
    nil))
  )

;; (defvar jo-kill-target-buffers)
(defcustom  jo-kill-target-buffers
  :type 'list)
(setq jo-kill-target-buffers (list "*RTags*" "*compilation*" "*Occur*" "*Help*"
                                   "*Warnings*" "*xref*" "*Node Shell*" "*Google Translyeate*"))
(defun kill-temporary-buffers ()
  "Kill current buffer unconditionally."
  (interactive)
  (let ((buffer-modifinnnned-p nil)
        (buffer-to-kill nil))
    (dolist (buffer-name jo-kill-target-buffers)
      (when (setq buffer-to-kill (get-buffer buffer-name))
        (kill-buffer buffer-to-kill)))
    (if (not (equal projectile-project-name nil))
        (when (get-buffer (setq buffer-to-kill (format "%s-%s" "*compilation*" projectile-project-name)))
          (kill-buffer buffer-to-kill)))
    (delete-above-below-window))
  )


(global-set-key (kbd "C-g")
                (lambda () (interactive)
                  (kill-temporary-buffers)
                  (keyboard-quit))
                )

(add-hook 'python-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c g g") 'anaconda-mode-find-definitions)
            (local-set-key (kbd "C-c c c") 'jyc-run-python)
            (local-set-key (kbd "C-g") 'kill-temporary-buffers)
            (local-set-key (kbd "C-S-g") 'close-compilation-window)
            (linum-mode t)
            ))


(defun create-tags (dir-name)
  "Create tags file."
  (interactive "DDirectory: ")
  (eshell-command 
   (format "find %s -type f -name \"*.[ch]\" | etags -" dir-name)))

  ;;;  Jonas.Jarnestrom<at>ki.ericsson.se A smarter               
  ;;;  find-tag that automagically reruns etags when it cant find a               
  ;;;  requested item and then makes a new try to locate it.                      
  ;;;  Fri Mar 15 09:52:14 2002    
(defadvice find-tag (around refresh-etags activate)
  "Rerun etags and reload tags if tag not found and redo find-tag.              
   If buffer is modified, ask about save before running etags."
  (let ((extension (file-name-extension (buffer-file-name))))
    (condition-case err
        ad-do-it
      (error (and (buffer-modified-p)
                  (not (ding))
                  (y-or-n-p "Buffer is modified, save it? ")
                  (save-buffer))
             (er-refresh-etags extension)
             ad-do-it))))

(defun er-refresh-etags (&optional extension)
  "Run etags on all peer files in current dir and reload them silently."
  (interactive)
  (shell-command (format "etags *.%s" (or extension "el")))
  (let ((tags-revert-without-query t))  ; don't query, revert silently          
    (visit-tags-table default-directory nil)))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; rust develope environments ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package rust-mode
  :ensure t)

(use-package racer
  :ensure t)

(use-package cargo
  :ensure t)

(require 'racer)
(require 'cargo)

(setq rust-format-on-save t)

(use-package org
  :ensure t)

(use-package markdown-mode
  :ensure t  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

(add-to-list 'load-path "~/.emacs.d/jongyoungcha")

(use-package google-translate
  :ensure t)
(with-eval-after-load 'google-translate
  (setq google-translate-default-source-language "en")
  (setq google-translate-default-target-language "ko")
  (global-set-key (kbd "C-c g d") 'google-translate-at-point))

(require 'chan-cursor-tracker)
(require 'jong-tramp)
(require 'jong-elisp)
(require 'jong-term)
(require 'jong-scheme)
(require 'jong-cmake)
(require 'jong-c)
(require 'jong-scala)
(require 'jong-haskell)
(require 'jong-nodejs)
;; (require 'jong-minor-eos)
(require 'jong-go)
(require 'jong-network)

;; Test logics must be located end of the script
(require 'jong-ether-test)

(load-theme 'sanityinc-tomorrow-blue t)
(set-background-color "#102033")
(set-cursor-color "#ff4444")
(global-hl-line-mode t)

(when (member "fixed" (font-family-list))
  (set-face-attribute 'default nil :font "fixed-12")
  (setq-default line-spacing 2))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; char encoding environment ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(set-default-coding-systems 'utf-8-unix)
(set-language-environment 'UTF-8)

;;;;;;;;;;;;;;;;;;;;;;;;
;; set the font style ;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; set a default font
;; (when (member "courier" (font-family-list))
;;   (set-face-attribute 'default nil :font "courier"))

;; set a default font


;; (when (member "DejaVu Sans Mono" (font-family-list))
;;   (set-face-attribute 'default nil :font "DejaVu Sans Mono-12")
;;   (setq-default line-spacing 3))


;; specify font for all unicode characters
;; (when (member "Symbola" (font-family-list))
;;   (set-fontset-font t 'unicode "Symbola" nil 'prepend))


;; specify font for chinese characters using default chinese font on linux
;; (when (member "WenQuanYi Micro Hei" (font-family-list))
;;   (set-fontset-font t '(#x4e00 . #x9fff) "WenQuanYi Micro Hei" ))

;; (when (eq system-type 'darwin)
;;   (set-face-attribute 'default nil :family "monaco"))


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (pcap-mode go-dlv go-errcheck helm-go-package go-stacktracer flymake-go go-direx go-eldoc company-go popwin direx go-guru go-mode tide indium js-comint nodejs-repl xref-js2 js2-refactor js2-mode flycheck-haskell haskell-mode ensime helm-gtags ggtags cmake-ide company-rtags rtags smart-compile cmake-mode xterm-color elisp-refs google-translate cargo racer rust-mode anaconda-mode company-jedi elpy auto-highlight-symbol flycheck exec-path-from-shell helm-projectile projectile magit company-quickhelp company auto-complete autopair hungry-delete auto-dim-other-buffers prodigy eyebrowse helm-ag helm yasnipppet evil solarized-theme color-theme-sanityinc-tomorrow auto-package-update use-package))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auto-dim-other-buffers-face ((t (:background "#101520")))))
