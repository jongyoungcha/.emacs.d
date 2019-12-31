;;; Avdded by Package.el.  This must come before configurations of
;;; installed packages.  Don't delete this line.  eIf you don't want it,
;;; just comment it out by adding a semicolon to the start of the line.
;;; You may delete these explanatory comments.
(gnutls-available-p)
;; (setq gnutls-algorithm-priority "NORMAL:-VERS-TLS1.3")
;; (setq package--check-signature nil)

(setq package-check-signature nil)

(require 'package)

(setq package-archives '(("gnu" . "https://elpa.gnu.org/packages/")
												 ("marmalade" . "https://marmalade-repo.org/packages/")
												 ("melpa" . "https://melpa.org/packages/")))

(when (< emacs-major-version 24)
	;; For important compatibility libraries like cl-lib
	(add-to-list 'package-archives '("gnu" . "http://mirrors.163.com/elpa/gnu")))

(package-initialize)
(unless (package-installed-p 'use-package)
	(package-refresh-contents)
	(package-install 'use-package))

(add-to-list 'load-path "~/.emacs.d/jongyoungcha")
(use-package avy
	:ensure t
	:config
	:bind
	("C-'" . avy-goto-word-0)
	("C-;" . avy-goto-line))

(global-font-lock-mode t)
(transient-mark-mode 1)
(setq eldoc-idle-delay 0.05)

(use-package org
	:ensure t
	:config
	(add-to-list 'auto-mode-alist '("\\.org$" . org-mode)))

(use-package async
	:ensure t
	:config
	(async-bytecomp-package-mode 1))

(use-package hungry-delete
	:ensure t)

(use-package syntax-subword
	:ensure t
	:config)

(defun jong-get-selection-length ()
	"Get length of selection."
	(interactive)
	(if (use-region-p)
			(let (pos1 pos2)
				(setq pos1 (region-beginning) pos2 (region-end))
				(- pos2 pos1))
		-1))


(defun jong-show-selection-length ()
	"Show length of selection."
	(interactive)
	(let (length)
		(setq length (jong-get-selection-length))
		(if (equal length -1)
				(message "regions is not activated...")
			(message "length : %d" length))
		))


(defun jong-switch-last-two-buffers ()
	"Switch to previously open buffer.
Repeated invocations toggle between the two most recently open buffers."
	(interactive)
	(switch-to-buffer (other-buffer (current-buffer) 1)))


(defun jong-cut-line-or-region ()
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


(defun jong-copy-line-or-region ()
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
		(async-shell-command cmd temp-buffer-name temp-buffer-name)
		(pop-to-buffer temp-buffer-name)
		))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;  common configurations  ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package yasnippet
	:ensure t)

(require 'yasnippet)
(yas-global-mode 1)


(use-package helm
	:ensure t
	:init
	:config
	(setq helm-split-window-in-side-p t)
	(helm-mode 1)
	(setq helm-candidate-number-limit 500)
	(global-set-key (kbd "M-x") 'helm-M-x)
	(global-set-key (kbd "C-x C-f") 'helm-find-files)
	(global-set-key (kbd "C-x C-b") 'helm-buffers-list)
	(global-set-key (kbd "C-x r l") 'helm-bookmarks)
	(define-key helm-find-files-map (kbd "M-<right>") 'helm-execute-persistent-action)
	(define-key helm-find-files-map (kbd "M-<left>") 'helm-find-files-up-one-level)
	(define-key helm-read-file-map (kbd "M-<right>") 'helm-execute-persistent-action)
	(define-key helm-read-file-map (kbd "M-<left>") 'helm-find-files-up-one-level))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; you need to install ag binary      ;;
;; $ brew install the_silver_searcher ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package helm-ag
	:ensure t)
(with-eval-after-load 'helm-ag
	(global-set-key (kbd "C-c a g") 'helm-do-ag))

(use-package prodigy
	:ensure t)

;; (use-package autopair
;; :ensure t)

(autopair-global-mode 1)
(setq autopair-autowrap t)

(use-package undo-tree
	:ensure t
	:config
	(global-undo-tree-mode t))

;; reuse a dired list buffer.
(require 'dired)
(define-key dired-mode-map (kbd "RET") 'dired-find-alternate-file)
(define-key dired-mode-map (kbd "^")
	(lambda () (interactive)
		(find-alternate-file "..")))

;; Remove the key esc esc esc remove other window
(defadvice keyboard-escape-quit (around jong-keyboard-escape-quit activate)
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


(defun jong-forward-delete-word ()
	"Chan 'forward-delete-word."
	(interactive)
	(let ((target-string "")
				(base-pos 0)
				(fword-pos 0)
				(candidate-pos 0)
				(curr-char)
				)
		(setq curr-char (string (char-after (point))))
		(if (string-match curr-char "[ \n\t] ")
				(call-interactively #'hungry-delete-forward)
			(progn
				(setq base-pos (point))
				(search-forward-regexp candidate-chars nil 'noerror)
				(setq candidate-pos (point))
				(forward-word)
				(setq fword-pos (point))
				(goto-char base-pos)
				(if (> candidate-pos fword-pos)
						(delete-region base-pos fword-pos)
					(delete-region base-pos candidate-pos))))
		)
	)


(defun jong-backward-delete-word ()
	"Chan 'backward-delete-word."
	(interactive)
	(let ((target-string "")
				(base-pos 0)
				(bword-pos 0)
				(candidate-pos 0)
				(curr-char)
				)
		(setq curr-char (string (char-after (1- (point)))))
		(if (string-match curr-char "[ \n] ")
				(call-interactively #'hungry-delete-backward)
			(progn
				(setq base-pos (point))
				(search-backward-regexp candidate-chars nil 'noerror)
				(setq candidate-pos (point))
				(backward-word)
				(setq bword-pos (point))
				(goto-char base-pos)
				(if (> candidate-pos bword-pos)
						(progn
							(ignore-errors (delete-region candidate-pos base-pos))
							(goto-char candidate-pos)
							;; (message "%s candpos : %d bword-pos %d" prev-candidate-char candidate-pos bword-pos)
							)
					(ignore-errors (delete-region (1- bword-pos) base-pos)))
				))
		)
	)


(global-set-key (kbd "M-c") nil)
(global-set-key (kbd "C-c C-x") nil)

(setq confirm-kill-emacs 'y-or-n-p)
(setq mark-ring-max 8)
(setq global-mark-ring-max 8)
(setq set-mark-command-repeat-pop t)
(global-set-key (kbd "S-SPC") 'toggle-korean-input-method)


(global-set-key (kbd "M-;") (lambda () (interactive)
															(let ((base-pos 0))
																(setq base-pos (point))
																(beginning-of-line)
																(call-interactively 'comment-line)
																(goto-char base-pos)
																(forward-line)
																(indent-for-tab-command)
																)))



(global-set-key (kbd "C-c k") (lambda() (interactive)
																(kill-buffer (buffer-name))))
(global-set-key (kbd "M-c k") (lambda() (interactive)
																(call-interactively 'other-window)
																(kill-buffer (buffer-name))
																(call-interactively 'other-window)))



(global-set-key (kbd "M-ESC ESC") 'keyboard-escape-quit)
(global-set-key (kbd "C-h SPC") 'helm-all-mark-rings)
(global-set-key (kbd "C-h C-SPC") 'helm-all-mark-rings)

(global-set-key (kbd "C-d") 'delete-forward-char)


(defun jong-forward-line (number)
	(interactive)
	(let ((curr-column (- (point) (progn (beginning-of-line)
																			 (point))))
				(max-column)
				(target-column))
		(when (not (numberp number))
			(error "Number was not Integer"))

		(forward-line number)
		;; (goto-char (+ (point) curr-column))
		(setq target-column (+ (point) curr-column))
		(setq max-column (progn (end-of-line)
														(point)))
		(if (> target-column max-column)
				(goto-char max-column)
			(goto-char target-column))
		(recenter-top-bottom (line-number-at-pos))))

(global-set-key (kbd "M-v") (lambda ()
															(interactive)
															(jong-forward-line -20)))

(global-set-key (kbd "C-v") (lambda ()
															(interactive)
															(jong-forward-line 20)))

(defun pop-local-or-global-mark ()
	"Pop to local mark if it exists or to the global mark if it does not."
	(interactive)
	(if (mark t)
			(pop-to-mark-command)
		(pop-global-mark)))


(defun jong-set-mark ()
	(interactive)
	(setq this-command-keys-shift-translated t)
	(if (not (use-region-p))
			(call-interactively 'set-mark-command)))




(defvar jong-keys-minor-mode-map
	(let ((map (make-sparse-keymap)))
		;; (define-key map (kbd "M-w") (lambda () (interactive) (jong-forward-line -1)))
		;; (define-key map (kbd "C-M-w") (lambda () (interactive) (jong-forward-line -1)))
		;; (define-key map (kbd "M-a") 'backward-char)
		;; (define-key map (kbd "M-s") (lambda () (interactive) (jong-forward-line 1)))
		;; (define-key map (kbd "C-M-s") (lambda () (interactive) (jong-forward-line 1)))
		;; (define-key map (kbd "M-d") 'forward-char)
		(define-key map (kbd "M-<backspace>") 'jong-common-kill-backward-word)
		(define-key map (kbd "C-<backspace>") 'jong-common-kill-backward-word)
		(define-key map (kbd "C-<delete>") 'jong-common-kill-forward-word)
		(define-key map (kbd "<S-up>") (lambda () (interactive)
																		 (jong-set-mark)
																		 (jong-forward-line -1)))
		(define-key map (kbd "<S-down>") (lambda () (interactive)
																			 (jong-set-mark)
																			 (jong-forward-line 1)))
		(define-key map (kbd "<S-left>") (lambda () (interactive)
																			 (jong-set-mark)
																			 (backward-char 1)))
		(define-key map (kbd "<S-right>") (lambda () (interactive)
																				(jong-set-mark)
																				(forward-char 1)))
		(define-key map (kbd "<C-S-up>") (lambda () (interactive)
																			 (jong-set-mark)
																			 (jong-forward-line -1)))
		(define-key map (kbd "<C-S-down>") (lambda () (interactive)
																				 (jong-set-mark)
																				 (jong-forward-line 1)))
		(define-key map (kbd "<C-S-left>") (lambda () (interactive)
																				 (jong-set-mark)
																				 (syntax-subword-backward 1)))
		(define-key map (kbd "<C-S-right>") (lambda () (interactive)
																					(jong-set-mark)
																					(syntax-subword-forward 1)))
		(define-key map (kbd "C-M-S-a") (lambda () (interactive)
																			(jong-set-mark)
																			(backward-word)))
		(define-key map (kbd "C-M-S-d") (lambda () (interactive)
																			(jong-set-mark)
																			(forward-word)))
		;; (define-key map (kbd "M-<backspace>") (lambda () (
		;; (progn (call-interactively 'backward-kill-word)
		;; (pop kill-ring))))
		;; (define-key map (kbd "M-<delete>") (lambda () (interactive)
		;; (progn (call-interactively 'forward-hf)
		;; (pop kill-ring))))
		map)
	"Jong-keys-minor-mode keymap.")


(define-minor-mode jong-keys-minor-mode
	"A minor mode so that my key settings override annoying major modes."
	:init-value t
	:lighter " jong-keys")

(defun enable-jong-keys-minor-mode()
	(interactive)
	(jong-keys-minor-mode 1))

(defun disable-jong-keys-minor-mode()
	(interactive)
	(jong-keys-minor-mode 0))


;; Back word with candidate characters.
(global-set-key (kbd "M-F") (lambda () (interactive)
															(jong-set-mark)
															(forward-word)))

(global-set-key (kbd "M-B") (lambda () (interactive)
															(jong-set-mark)
															(backward-word)))

(global-set-key (kbd "C-S-f") (lambda () (interactive)
																(jong-set-mark)
																(goto-char (1+ (point)))))

(global-set-key (kbd "C-S-b") (lambda () (interactive)
																(jong-set-mark)
																(goto-char (1- (point)))))

(global-set-key (kbd "C-S-a") (lambda () (interactive)
																(jong-set-mark)
																(beginning-of-line)))

(global-set-key (kbd "C-S-e") (lambda () (interactive)
																(jong-set-mark)
																(end-of-line)))

(global-set-key (kbd "C-S-a") (lambda () (interactive)
																(jong-set-mark)
																(beginning-of-line)))

(global-set-key (kbd "C-S-p") (lambda () (interactive)
																(jong-set-mark)
																(forward-line -1)))

(global-set-key (kbd "C-S-n") (lambda () (interactive)
																(jong-set-mark)
																(forward-line 1)))

(global-set-key (kbd "C--") 'jong-switch-last-two-buffers)
(global-set-key (kbd "C-x C-o") 'other-window)
(global-set-key (kbd "C-x p") (lambda() (interactive) (other-window -1)))
(global-set-key (kbd "C-c C-o") 'other-window)
(global-set-key (kbd "C-c b") 'helm-buffers-list)
(global-set-key (kbd "C-c C-b") 'helm-buffers-list)

(global-set-key (kbd "C-M-i") (lambda() (interactive) (scroll-other-window -15)))
(global-set-key (kbd "C-M-o") (lambda() (interactive) (scroll-other-window 15)))

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


;; remapping about the keybinding.
(define-key key-translation-map (kbd "<left>") (kbd "C-b"))
(define-key key-translation-map (kbd "<right>") (kbd "C-f"))
(define-key key-translation-map (kbd "<up>") (kbd "C-p"))
(define-key key-translation-map (kbd "<down>") (kbd "C-n"))
(define-key key-translation-map (kbd "C-<left>") (kbd "M-b"))
(define-key key-translation-map (kbd "C-<right>") (kbd "M-f"))
(define-key key-translation-map (kbd "C-S-<left>") (kbd "M-B"))
(define-key key-translation-map (kbd "C-S-<right>") (kbd "M-F"))
(define-key key-translation-map (kbd "C-S-<right>") (kbd "M-F"))





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

;; (global-set-key (kbd "C-c t") 'toggle-transparency)
(global-set-key (kbd "C-x C-0") 'delete-other-windows-vertically)

;; hide tool bar
(menu-bar-mode -1)
(tool-bar-mode -1)
(blink-cursor-mode -1)

(setq visible-bell nil)
(setq ring-bell-function 'ignore)

(defun lispy-parens ()
	"Setup parens display for lisp modes."
	(setq show-paren-delay 0)
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
	:ensure t
	:config
	(setq company-async-timeout 4)
	(setq company-idle-delay 0.01)
	(setq company-minimum-prefix-length 5)
	(setq company-auto-complete t)
	(global-set-key (kbd "C-<tab>") 'company-complete)
	(add-hook 'after-init-hook 'global-company-mode)
	(define-key company-active-map (kbd "M-p") nil)
	(define-key company-active-map (kbd "M-p") nil)
	(define-key company-active-map (kbd "C-p") 'company-select-previous)
	(define-key company-active-map (kbd "C-n") 'company-select-next))


(use-package company-quickhelp
	:ensure t
	:config
	(company-quickhelp-mode)
	(setq company-quickhelp-delay nil)
	(define-key company-active-map (kbd "C-c h") #'company-quickhelp-manual-begin)
	)

(use-package magit
	:ensure t
	:config
	(setq git-commit-summary-max-length 1000))

(use-package projectile
	:ensure t
	:init
	:config
	(projectile-mode 1)
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
(global-set-key (kbd "C-c p f") 'projectile-find-file)
(global-set-key (kbd "C-c p c") 'projectile-compile-project)
(global-set-key (kbd "C-c p r") 'projectile-run-project)
(global-set-key (kbd "C-c p s") 'jo-set-projectile-run-command)
(global-set-key (kbd "C-c w f") 'other-frame)

(use-package exec-path-from-shell
	:ensure t)
(require 'exec-path-from-shell)
(when (memq window-system '(mac ns x))
	(exec-path-from-shell-initialize))

(use-package ido
	:ensure t
	:config
	:init
	(ido-mode t)
	(setq ido-enable-flex-matching t))

(use-package  flycheck
	:ensure t
	:config
	(global-flycheck-mode t)
	)
;; :init
;; (global-flycheck-mode t)
;; (set-face-attribute 'flycheck-fringe-warning nil :foreground (face-attribute 'fringe :background )))

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


(defun jyc-run-python ()
	"Use run python program"
	(interactive)
	(compile (concat "python " (buffer-name))))


(defcustom  jong-kill-buffer-patterns nil
	"this is patters to kill buffer"
	:type 'list)
(setq jong-kill-buffer-patterns (list "*RTags*"
																			"*compilation*"
																			"*Occur*"
																			"*Help*"
																			"^\*godoc.*"
																			"*Warnings*"
																			"*xref*"
																			"*Node Shell*"
																			"*Google Translate*"
																			"*jong-output*"))

(defun jong-kill-temporary-buffers ()
	"Kill current buffer unconditionally."
	(interactive)
	(dolist (pattern jong-kill-buffer-patterns)
		(dolist (buffer (buffer-list))
			(when (string-match pattern (buffer-name buffer))
				(kill-buffer buffer))))
	)
;; (delete-above-below-window))
	

(global-set-key (kbd "C-g") (lambda () (interactive)
															(jong-kill-temporary-buffers)
															(keyboard-quit)))

(defun create-tags (dir-name)
	"Create tags file."
	(interactive "Directory: ")
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


(use-package org
	:ensure t)

(use-package markdown-mode
	:ensure t  :commands (markdown-mode gfm-mode)
	:mode (("README\\.md\\'" . gfm-mode)
				 ("\\.md\\'" . markdown-mode)
				 ("\\.markdown\\'" . markdown-mode))
	:init (setq markdown-command "multimarkdown"))


(use-package google-translate
	:ensure t
	:config
	(setq google-translate-default-source-language "en")
	(setq google-translate-default-target-language "ko")
	(setq google-translate-show-phonetic 1)
	(global-set-key (kbd "C-c g d") 'google-translate-at-point))


(require 'jong-packages)
(require 'jong-env-setting)
(require 'jong-common)
(require 'jong-project)

;; Langauges
(require 'jong-elisp)
(require 'jong-bash)
(require 'jong-tramp)
(require 'jong-scheme)
(require 'jong-cmake)
(require 'jong-cc)
(require 'jong-python)
(require 'jong-rust)

(require 'jong-scala)
(require 'jong-haskell)
(require 'jong-nodejs)
(require 'jong-go)

;; Utils
(require 'jong-network)
(require 'jong-http)
(require 'jong-html)
(require 'jong-dap-debug)
(require 'jong-term)
(require 'jong-grpc)

;; For Testing
;; (require 'jong-ether-test)
;; (require 'jong-brth-test)

(require 'jong-key-bindings)
(require 'jong-debug-settings)

(setq jong-go-run-command (format "./geth --datadir=~/testnet --verbosity 4 --bootnodes %s --syncmode \"full\" --cache=2048" (getenv "BOOTNODE")))
(setq jong-go-run-default-path "~/goworks/src/github.com/ethereum/go-ethereum/cmd/geth")

(set-cursor-color "#aa4444")
(set-face-background #'hl-line "#004500")
(global-hl-line-mode t)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-faces-vector
	 [default bold shadow italic underline bold bold-italic bold])
 '(ansi-color-names-vector
	 ["#073642" "#dc322f" "#859900" "#b58900" "#268bd2" "#d33682" "#2aa198" "#657b83"])
 '(beacon-color "#ff9da4")
 '(compilation-message-face (quote default))
 '(cua-global-mark-cursor-color "#2aa198")
 '(cua-normal-cursor-color "#839496")
 '(cua-overwrite-cursor-color "#b58900")
 '(cua-read-only-cursor-color "#859900")
 '(custom-enabled-themes (quote (sanityinc-tomorrow-blue)))
 '(custom-safe-themes
	 (quote
		("285d1bf306091644fb49993341e0ad8bafe57130d9981b680c1dbd974475c5c7" "830877f4aab227556548dc0a28bf395d0abe0e3a0ab95455731c9ea5ab5fe4e1" "2809bcb77ad21312897b541134981282dc455ccd7c14d74cc333b6e549b824f3" "1b8d67b43ff1723960eb5e0cba512a2c7a2ad544ddb2533a90101fd1852b426e" "a8245b7cc985a0610d71f9852e9f2767ad1b852c2bdea6f4aadc12cce9c4d6d0" "06f0b439b62164c6f8f84fdda32b62fb50b6d00e8b01c2208e55543a6337433a" "bb08c73af94ee74453c90422485b29e5643b73b05e8de029a6909af6a3fb3f58" "628278136f88aa1a151bb2d6c8a86bf2b7631fbea5f0f76cba2a0079cd910f7d" "0598c6a29e13e7112cfbc2f523e31927ab7dce56ebb2016b567e1eff6dc1fd4f" "82d2cac368ccdec2fcc7573f24c3f79654b78bf133096f9b40c20d97ec1d8016" default)))
 '(fci-rule-color "#073642")
 '(flycheck-color-mode-line-face-to-color (quote mode-line-buffer-id))
 '(frame-background-mode (quote dark))
 '(helm-completion-style (quote emacs))
 '(highlight-changes-colors (quote ("#d33682" "#6c71c4")))
 '(highlight-symbol-colors
	 (--map
		(solarized-color-blend it "#002b36" 0.25)
		(quote
		 ("#b58900" "#2aa198" "#dc322f" "#6c71c4" "#859900" "#cb4b16" "#268bd2"))))
 '(highlight-symbol-foreground-color "#93a1a1")
 '(highlight-tail-colors
	 (quote
		(("#073642" . 0)
		 ("#546E00" . 20)
		 ("#00736F" . 30)
		 ("#00629D" . 50)
		 ("#7B6000" . 60)
		 ("#8B2C02" . 70)
		 ("#93115C" . 85)
		 ("#073642" . 100))))
 '(hl-bg-colors
	 (quote
		("#7B6000" "#8B2C02" "#990A1B" "#93115C" "#3F4D91" "#00629D" "#00736F" "#546E00")))
 '(hl-fg-colors
	 (quote
		("#002b36" "#002b36" "#002b36" "#002b36" "#002b36" "#002b36" "#002b36" "#002b36")))
 '(hl-paren-colors (quote ("#2aa198" "#b58900" "#268bd2" "#6c71c4" "#859900")))
 '(magit-diff-use-overlays nil)
 '(nrepl-message-colors
	 (quote
		("#dc322f" "#cb4b16" "#b58900" "#546E00" "#B4C342" "#00629D" "#2aa198" "#d33682" "#6c71c4")))
 '(package-selected-packages
	 (quote
		(smartparens smartparens-stric protobuf-mode cider lsp-ui yaml-mode xterm-color xref-js2 whitespace-cleanup-mode which-key web-mode use-package undo-tree tide syntax-subword solarized-theme rtags restclient realgud racer prodigy popwin pcap-mode nodejs-repl modern-cpp-font-lock magit log4e js-comint indium hungry-delete helm-xref helm-projectile helm-go-package helm-dash helm-ag google-translate godoctor go-stacktracer go-rename go-guru go-errcheck go-eldoc go-dlv go-direx go-complete go-autocomplete flymake-go flycheck-rust flycheck-haskell exec-path-from-shell ensime elpy elisp-slime-nav elisp-refs dap-mode company-quickhelp company-lsp company-jedi company-go color-theme-sanityinc-tomorrow cmake-mode cmake-ide clang-format ccls cargo bash-completion avy autopair auto-package-update auto-highlight-symbol anaconda-mode)))
 '(pos-tip-background-color "#073642")
 '(pos-tip-foreground-color "#93a1a1")
 '(safe-local-variable-values
	 (quote
		((jong-project-sub-default-dir-3 . "/Users/swit-mac/go/src/swit/swit-image-cloud-function-golang/")
		 (jong-project-sub-command-2 . "./mockclient")
		 (jong-project-sub-default-dir-2 . "/Users/swit-mac/go/src/swit/swit-image-cloud-function-golang/")
		 (jong-project-sub-default-dir-3 . "/home/jongyoungcha/go/src/swit/swit-image-cloud-function-golang/")
		 (jong-project-sub-default-dir-2 . "/home/jongyoungcha/go/src/swit/swit-image-cloud-function-golang/")
		 (jong-project-cmd-test "none" "message")
		 (jong-project-sub-default-dir-3 . "/home/jongyoungcha/go/src/swit/swit-gcs-file-golang/")
		 (jong-project-sub-default-dir-2 . "/home/jongyoungcha/go/src/swit/swit-gcs-file-golang/")
		 (jong-project-sub-default-dir-3 . "/Users/swit-mac/go/src/swit/swit-gcs-file-golang/")
		 (jong-project-sub-default-dir-2 . "/Users/swit-mac/go/src/swit/swit-gcs-file-golang/")
		 (jong-project-sub-default-dir-3 . "/Users/swit-mac/go/src/swit/swit-grpc-activity-golang/")
		 (jong-project-sub-default-dir-2 . "/Users/swit-mac/go/src/swit/swit-grpc-activity-golang/")
		 (jong-project-sub-default-dir-3 . "/Users/swit-mac/go/src/swit/swit-apiV1/")
		 (jong-project-sub-default-dir-2 . "/Users/swit-mac/go/src/swit/swit-apiV1/")
		 (jong-project-sub-default-dir-3 . "/Users/swit-mac/go/src/swit/swit-grpc-workspace-golang/")
		 (jong-project-sub-default-dir-2 . "/Users/swit-mac/go/src/swit/swit-grpc-workspace-golang/")
		 (jong-project-sub-default-dir-3 . "/Users/swit-mac/go/src/swit/swit-api-golang/")
		 (jong-project-sub-default-dir-2 . "/Users/swit-mac/go/src/swit/swit-api-golang/")
		 (jong-project-sub-default-dir-3 . "/Users/swit-mac/goworks/src/swit/swit-grpc-asset-golang/")
		 (jong-project-sub-default-dir-2 . "/Users/swit-mac/goworks/src/swit/swit-grpc-asset-golang/")
		 (jong-project-sub-default-dir-3 . "/Users/swit-mac/goworks/src/swit/swit-api-golang/")
		 (jong-project-sub-default-dir-2 . "/Users/swit-mac/goworks/src/swit/swit-api-golang/")
		 (jong-project-sub-default-dir-3 . "/Users/swit-mac/goworks/src/awesomeProject/")
		 (jong-project-sub-default-dir-2 . "/Users/swit-mac/goworks/src/awesomeProject/")
		 (jong-project-sub-default-dir-3 . "/Users/swit-mac/goworks/src/github.com/jongyoungcha/Chanker/")
		 (jong-project-sub-default-dir-2 . "/Users/swit-mac/goworks/src/github.com/jongyoungcha/Chanker/")
		 (jong-project-sub-default-dir-3 . "/home/jongyoungcha/projects/test/")
		 (jong-project-sub-default-dir-2 . "/home/jongyoungcha/projects/test/")
		 (projectile-project-root . "/home/jongyoungcha/projects/cmake-project-template/")
		 (jong-project-sub-default-dir-3 . "/home/jongyoungcha/projects/Ants/")
		 (jong-project-sub-default-dir-2 . "/home/jongyoungcha/projects/Ants/")
		 (projectile-project-root . "/home/jongyoungcha/projects/Ants/")
		 (jong-project-sub-default-dir-3 . "/home/jongyoungcha/goworks/src/github.com/jongyoungcha/test/")
		 (jong-project-sub-default-dir-2 . "/home/jongyoungcha/goworks/src/github.com/jongyoungcha/test/")
		 (jong-project-sub-default-dir-3 . "/home/jongyoungcha/goworks/src/github.com/jongyoungcha/Chanker/")
		 (jong-project-sub-default-dir-2 . "/home/jongyoungcha/goworks/src/github.com/jongyoungcha/Chanker/")
		 (jong-project-sub-default-dir-3 . "/home/jongyoungcha/projects/Chanker/")
		 (jong-project-sub-default-dir-2 . "/home/jongyoungcha/projects/Chanker/")
		 (jong-project-sub-default-dir-3 . "/home/jongyoungcha/.emacs.d/")
		 (jong-project-sub-default-dir-2 . "/home/jongyoungcha/.emacs.d/")
		 (jong-project-sub-default-dir-3 . "/home/jongyoungcha/projects/actor-pattern/")
		 (jong-project-sub-default-dir-2 . "/home/jongyoungcha/projects/actor-pattern/")
		 (jong-project-sub-default-dir-3 . "/home/jongyoungcha/goworks/src/bitbucket.org/spooncast/__meari-server/")
		 (jong-project-sub-default-dir-2 . "/home/jongyoungcha/goworks/src/bitbucket.org/spooncast/__meari-server/")
		 (jong-project-sub-default-dir-3 . "/home/jongyoungcha/goworks/src/bitbucket.org/spooncast/meari-server/")
		 (jong-project-sub-default-dir-2 . "/home/jongyoungcha/goworks/src/bitbucket.org/spooncast/meari-server/")
		 (jong-project-sub-default-dir-3 . "/home/jongyoungcha/goworks/src/bitbucket.org/spooncast/gotest/")
		 (jong-project-sub-default-dir-2 . "/home/jongyoungcha/goworks/src/bitbucket.org/spooncast/gotest/")
		 (jong-project-sub-default-dir-3 . "/home/jongyoungcha/goworks/src/bitbucket.org/meari-server/")
		 (jong-project-sub-default-dir-2 . "/home/jongyoungcha/goworks/src/bitbucket.org/meari-server/")
		 (jong-project-sub-default-dir-3 . "/home/jongyoungcha/projects/rust-projects/rust_test/")
		 (jong-project-sub-default-dir-2 . "/home/jongyoungcha/projects/rust-projects/rust_test/")
		 (projectile-project-root . "/home/jongyoungcha/projects/rust-projects/rust_test/")
		 (jong-project-sub-command-3 . "none")
		 (jong-project-sub-default-dir-3 . "/home/jongyoungcha/goworks/src/github.com/jongyoungcha/meari-server-go/")
		 (jong-project-sub-command-2 . "none")
		 (jong-project-sub-default-dir-2 . "/home/jongyoungcha/goworks/src/github.com/jongyoungcha/meari-server-go/"))))
 '(smartrep-mode-line-active-bg (solarized-color-blend "#859900" "#073642" 0.2))
 '(term-default-bg-color "#002b36")
 '(term-default-fg-color "#839496")
 '(vc-annotate-background nil)
 '(vc-annotate-background-mode nil)
 '(vc-annotate-color-map
	 (quote
		((20 . "#dc322f")
		 (40 . "#c8805d801780")
		 (60 . "#bec073400bc0")
		 (80 . "#b58900")
		 (100 . "#a5008e550000")
		 (120 . "#9d0091000000")
		 (140 . "#950093aa0000")
		 (160 . "#8d0096550000")
		 (180 . "#859900")
		 (200 . "#66aa9baa32aa")
		 (220 . "#57809d004c00")
		 (240 . "#48559e556555")
		 (260 . "#392a9faa7eaa")
		 (280 . "#2aa198")
		 (300 . "#28669833af33")
		 (320 . "#279993ccbacc")
		 (340 . "#26cc8f66c666")
		 (360 . "#268bd2"))))
 '(vc-annotate-very-old-color nil)
 '(weechat-color-list
	 (quote
		(unspecified "#002b36" "#073642" "#990A1B" "#dc322f" "#546E00" "#859900" "#7B6000" "#b58900" "#00629D" "#268bd2" "#93115C" "#d33682" "#00736F" "#2aa198" "#839496" "#657b83")))
 '(window-divider-mode nil)
 '(xterm-color-names
	 ["#073642" "#dc322f" "#859900" "#b58900" "#268bd2" "#d33682" "#2aa198" "#eee8d5"])
 '(xterm-color-names-bright
	 ["#002b36" "#cb4b16" "#586e75" "#657b83" "#839496" "#6c71c4" "#93a1a1" "#fdf6e3"]))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(flymake-errline ((((class color)) (:background "#444444"))) t)
 '(flymake-error ((((class color)) (:background "#444444"))))
 '(flymake-warning ((((class color)) (:background "#4444aa"))))
 '(flymake-warnline ((((class color)) (:background "#4444aa"))) t)
 '(rtags-errline ((t (:background "IndianRed3" :foreground "white" :underline (:color "white" :style wave)))))
 '(rtags-warnline ((t (:background "royal blue" :foreground "white" :underline (:color "white" :style wave))))))
(put 'dired-find-alternate-file 'disabled nil)
