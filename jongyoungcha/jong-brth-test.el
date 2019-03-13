;;; Code

(defcustom jong-brth-user "root"
  "ID for connection."
  :type 'string)

(defcustom jong-brth-passwd "dusrn"
  "Passwd for connection."
  :type 'string)

(defcustom jong-brth-node-list (list "192.168.55.100"
									 "192.168.55.101"
									 "192.168.55.102"
									 "192.168.55.103"
									 "192.168.0.160"
									 "192.168.0.161"
									 "192.168.0.162"
									 "192.168.0.163")
  "Berith node list."
  :type 'list)


(defun jong-brth-print-node-list()
  (interactive)
  (message "%s" jong-brth-node-list))


(setq jong-brth-test-datadir (format "%s/%s" (getenv "HOME") "testdir"))
(setq jong-brth-highlights
	  '(("test\\|success\\|done\\|INFO\\|" . font-lock-function-name-face)
		("failed\\|Failed\\|FAILED\\|warn\\|Warn\\|WARN\\|" . font-lock-warning-face)))


(define-derived-mode jong-brth-attach-mode eshell-mode "BRTH-ATTCH"
  (setq font-lock-defaults '(jong-brth-highlights)))


(defun jong-brth-get-log-buffer-name (node-host)
  (format "*brth-node-log-%s*" node-host))



(defun jong-brth-show-node-log (node-host)
  "A."
  (let ((node-host-buffer-name (jong-brth-get-log-buffer-name node-host))
		(node-host-buffer))
	(if (setq node-host-buffer (get-buffer node-host-buffer-name))
		(if (get-buffer-process node-host-buffer)
			(progn
			  (switch-to-buffer node-host-buffer)
			  (goto-char (point-min))
			  (goto-char (point-max)))
		  (with-current-buffer (get-buffer-create node-host-buffer-name)
			(setq default-directory (format "/ssh:%s@%s:" jong-brth-user node-host))
			(ignore-errors (async-shell-command "tail -f ./geth.log" (current-buffer) (current-buffer)))
			(other-window 1)
			(sleep-for 1)
			(goto-char (point-min))
			(goto-char (point-max))
			))
	  (with-current-buffer (get-buffer-create node-host-buffer-name)
		(setq default-directory (format "/ssh:%s@%s:" jong-brth-user node-host))
		(ignore-errors (async-shell-command "tail -f ./geth.log" (current-buffer) (current-buffer)))
		(other-window 1)
		(sleep-for 1)
		(goto-char (point-min))
		(goto-char (point-max)))
	  ))
  )

(defun jong-brth-select-nodes-log ()
  (interactive)
  (let ((selected-node nil))
	(setq selected-node  (helm :sources (helm-build-sync-source "Berith nodes for log."
										  :candidates jong-brth-node-list
										  :fuzzy-match t
										  :action (lambda (node)
													node))
							   :buffer "*jong-berith-nodes-log*"))
	(when selected-node (jong-brth-show-node-log selected-node))
	)
  )

(defun jong-brth-get-attach-buffer-name (node-host)
  (format "*brth-node-attach-%s*" node-host))

(defun jong-brth-show-node-attach (node-host)
  "A."
  (let ((node-host-buffer-name (jong-brth-get-log-buffer-name node-host))
		(node-host-buffer))
	(if (setq node-host-buffer (get-buffer node-host-buffer-name))
		(if (get-buffer-process node-host-buffer)
			(progn
			  (switch-to-buffer node-host-buffer)
			  (goto-char (point-min))
			  (goto-char (point-max)))
		  (with-current-buffer (get-buffer-create node-host-buffer-name)
			(setq default-directory (format "/ssh:%s@%s:" jong-brth-user node-host))
			(ignore-errors (async-shell-command "geth --datadir=~/testnet--nodiscover attach" (current-buffer) (current-buffer)))
			(other-window 1)
			(sleep-for 1)
			(goto-char (point-min))
			(goto-char (point-max))
			))
	  (with-current-buffer (get-buffer-create node-host-buffer-name)
		(setq default-directory (format "/ssh:%s@%s:" jong-brth-user node-host))
		(ignore-errors (async-shell-command "geth --datadir=~/testnet--nodiscover attach" (current-buffer) (current-buffer)))
		(other-window 1)
		(sleep-for 1)
		(goto-char (point-min))
		(goto-char (point-max)))
	  ))
  )

(defun jong-brth-select-node-attach ()
  (interactive)
  (let ((selected-node nil))
	(setq selected-node (helm :sources (helm-build-sync-source "Berith nodes for attach."
										 :candidates jong-brth-node-list
										 :fuzzy-match t
										 :action (lambda (node)
												   node))
							  :buffer "*jong-berith-nodes-attach*"))
	(when selected-node (jong-brth-show-node-attach selected-node))
	)
  )



(defun jong-brth-test-attach ()
  (interactive)
  (let ((buffer-name "*brth-attach*"))
	(with-current-buffer (get-buffer-create buffer-name)
	  (jong-brth-attach-mode)
	  (display-buffer (current-buffer))
	  (jong-brth-test-exec-cmd "geth attach"))
	)
  )

(defun jong-brth-test-new-account ()
  (interactive)
  (let ((buffer-name "*brth-attach*"))
	(with-current-buffer (get-buffer buffer-name)
	  (display-buffer (current-buffer))
	  (jong-brth-test-exec-cmd "personal.newAccount(\"jongyoungcha\")")
	  ))
  )

(define-derived-mode jong-brth-log-mode eshell-mode "BRTH-LOG"
  (setq font-lock-defaults '(jong-brth-highlights)))


(defun jong-brth-test-log ()
  (interactive)
  )


(provide 'jong-brth-test)