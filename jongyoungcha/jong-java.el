;;; Code:

(defconst jong-java-output-buffer-name "*jong-java-output*"
	"A Ouput Buffur of java.")

(defconst jong-java-output-buffer-name "*jong-java-debug*"
	"A Debug Buffur of java.")

(defcustom jong-java-process-names-to-kill '("PlatformServerApplication")
	"Target Processes to kill in java mode."
	:group 'jong-java
	:type 'list)

(add-to-list #'jong-kill-buffer-patterns jong-java-output-buffer-name)
;; (add-to-list #'jong-kill-buffer-patterns "\\*out\\*[\\<2\\>]*")
(add-to-list #'jong-kill-buffer-patterns "*HTTP Response*")

(defun jong-java-install-maven ()
	(interactive)
	(let ((maven-uri "http://mirror.navercorp.com/apache/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz")
	(target-file "apache-maven-3.6.0-bin.tar.gz")
	(extracted-dir "apache-maven-3.6.0")
	(cmd))
		(setq cmd (concat
				 "cd;"
				 (format "wget %s;" maven-uri)
				 (format "tar -xvf %s;" target-file)
				 (format "cd %s" extracted-dir)))
		(with-current-buffer (get-buffer-create jong-java-output-buffer-name)
			(display-buffer (current-buffer))
			(async-shell-command cmd (current-buffer) (current-buffer))
			)
		)
	)


(defun jong-java-install-eclim-server ()
	(interactive)
	(let ((cmd))
		(setq cmd (concat
							 "cd;"
							 (format "wget http://mirrors.neusoft.edu.cn/eclipse/technology/epp/downloads/release/2019-03/R/eclipse-jee-2019-03-R-linux-gtk-x86_64.tar.gz")
							 "tar -xvf eclipse-jee-2019-03-R-linux-gtk-x86_64.tar.gz;"
							 (format "wget https://github.com/ervandew/eclim/releases/download/2.8.0/eclim_2.8.0.bin;")
							 "chmod 744 ./eclim_2.8.0.bin;"
							 "./eclim_2.8.0.bin;"
							 ))
		(with-current-buffer (get-buffer-create jong-java-output-buffer-name)
			(display-buffer (current-buffer))
			(async-shell-command cmd (current-buffer) (current-buffer))
			)
		)
	)


(defun jong-java-kill-target-processes ()
	(interactive)
	(let ((cmd)
	(pid)
	(pname))
		(with-current-buffer (get-buffer-create jong-java-output-buffer-name)
			(dolist (pname jong-java-process-names-to-kill)
	(display-buffer (current-buffer))
	(setq cmd (format "ps -ef | grep %s | awk '{print $2}' | xargs -i kill -9 {}" pname))
	(async-shell-command cmd (current-buffer) (current-buffer)))
			)
		)
	)

(defun jong-java-debug-mode-screen ()
	(interactive)
	(jong-common-set-window-1-2 (buffer-name (current-buffer)) "*out*" "*dap-ui-repl*"))

(use-package projectile :ensure t)
(use-package treemacs :ensure t)
(use-package lsp-mode :ensure t)
(use-package hydra :ensure t)
;; (use-package company-lsp :ensure t)
;; (use-package lsp-ui
;; :ensure t
;; :after lsp-mode
;; :diminish lsp-ui
;; :init (lsp-ui-mode)
;; :config
;; (setq lsp-ui-peek-enable nil)
;; (setq lsp-ui-sideline-enable nil)
;; (setq lsp-ui-doc-enable nil)
;; (setq lsp-ui-flycheck-enable t))

(use-package lsp-java
	:ensure t
	:after lsp
	:config
	(add-hook 'java-mode-hook 'lsp)
	(setq lsp-java-vmargs
			(list
				 "-noverify"
				 "-Xmx1G"
				 "-XX:+UseG1GC"
				 "-XX:+UseStringDeduplication"
				 (format "-javaagent:/%s/%s" (getenv "HOME") ".m2/repository/org/projectlombok/lombok/1.18.2/lombok-1.18.2.jar")))
	)

;; (require 'lsp-java-boot)

;; (require 'lsp-java-boot)
;; (add-hook 'lsp-mode-hook #'lsp-lens-mode)
;; (add-hook 'java-mode-hook #'lsp-java-boot-lens-mode)

;; (use-package dap-mode
;; :ensure t :after lsp-mode
;; :config
;; (dap-mode t)
;; (dap-ui-mode t))

(use-package dap-java :after (lsp-java))
;; (use-package lsp-java-treemacs :after (treemacs))



(define-key java-mode-map (kbd "C-c c k") 'jong-java-kill-target-processes)
(define-key java-mode-map (kbd "C-c c c") 'lsp-java-build-project)
(define-key java-mode-map (kbd "C-c c g") 'dap-debug)
(define-key java-mode-map (kbd "C-c c p") 'eclim-project-create)
(define-key java-mode-map (kbd "C-c r s") 'helm-imenu)
(define-key java-mode-map (kbd "C-c r r") 'lsp-rename)
(define-key java-mode-map (kbd "C-c r .") 'lsp-find-definition)
(define-key java-mode-map (kbd "C-c r ,") 'lsp-find-references)
(define-key java-mode-map (kbd "C-c d d") 'lsp-ui-doc-show)
(define-key java-mode-map (kbd "C-g") (lambda()
					(interactive)
					(display-buffer (get-buffer "*out*"))
					(ignore-errors (with-current-buffer (get-buffer "*out*")
							 ((set (make-local-variable 'window-point-insertion-type) t)))
									 (jong-kill-temporary-buffers)
									 (keyboard-quit))))

(define-key java-mode-map (kbd "<f5>") (lambda()
					 (interactive)
					 (call-interactively 'dap-java-debug)
					 (other-window 1)
					 (keyboard-quit)
					 (sleep-for 1)
					 (display-buffer (get-buffer "*out*"))))

(define-key java-mode-map (kbd "<f8>") 'dap-continue)
(define-key java-mode-map (kbd "<f9>") 'dap-breakpoint-toggle)
(define-key java-mode-map (kbd "<f10>") 'dap-next)
(define-key java-mode-map (kbd "<f11>") 'dap-step-in)
(define-key java-mode-map (kbd "<f12>") 'dap-step-in)
(define-key java-mode-map (kbd "C-=") 'jong-dap-debug-goto-repl)


;; (defun jong-java-setting-coding-style()
;; "Setting environment and key bindings."
;; Set the indentation.
;; (defvar c-default-style)
;; (defvar c-basic-offset)

;; (setq c-default-style "linux")
;; (setq-default indent-tabs-mode t
;; tab-width 4
;; c-basic-offset 4)
;; )


(add-hook 'java-mode-hook 'jong-java-setting-environment)


(defun jong-java-setting-environment()
	"Setting environment and keybindings."
	(clang-format-buffer)
	)

(provide 'jong-java)
