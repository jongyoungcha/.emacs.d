;;; Code

(use-package dash
  :ensure t
  :config
  (dash-enable-font-lock))

(use-package helm-dash
  :ensure t
  :config)

(use-package dash-functional
  :ensure t
  :config)


(use-package elisp-slime-nav
  :ensure t
  :config
  (dolist (hook '(emacs-lisp-mode-hook ielm-mode-hook))
	(add-hook hook 'elisp-slime-nav-mode))
  )

(use-package elisp-refs
  :ensure t
  :config)


(use-package log4e
  :ensure t
  :config
  (log4e:deflogger "hoge" "%t [%l] %m" "%H:%M:%S" '((fatal . "fatal")
													(error . "error")
													(warn  . "warn")
													(info  . "info")
													(debug . "debug")
													(trace . "trace"))))


(define-key emacs-lisp-mode-map (kbd "C-c r .") 'elisp-slime-nav-find-elisp-thing-at-point)
(define-key emacs-lisp-mode-map (kbd "C-c r ,") 'elisp-refs-symbol)
(define-key emacs-lisp-mode-map (kbd "C-c C-u") 'xref-pop-marker-stack)
(define-key emacs-lisp-mode-map (kbd "C-c g f") 'edebug-defun)
(define-key emacs-lisp-mode-map (kbd "C-M-i") (lambda() (interactive) (scroll-other-window 15)))
(define-key emacs-lisp-mode-map (kbd "C-M-o") (lambda() (interactive) (scroll-other-window -15)))




(provide 'jong-elisp)

