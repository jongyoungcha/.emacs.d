
(require 'cl)
;;; Code:

(defcustom ether-target-eshell nil
  "Arguments about running ethereum node."
  :type 'string)
(setq ether-target-eshell "*chan-dlv-server*")

(defcustom jong-run-local-ethnode-args "--datadir=~/testnet --verbosity 4 --syncmode \"full\" --cache=2048"
  "Arguments about running ethereum node."
  :type 'string)

(cl-defstruct ether-node
  name
  host
  user
  passwd
  privkey-path
  testnet-dir)

(setenv "BOOTNODE" "enode:\/\/c76ba3e26c694db780e78c4f0a48bcc681ed167fc1cc303167d1f595235ac356d02b24c605fdf251cbb0278a19196f6e61776a818f9d009eee2394952f4ab770@192.168.50.13:30310")


(defcustom main-node
  :type 'ether-node)
(setq main-node (make-ether-node
                 :name "ethermain"
                 :host "192.168.130.100"
                 :user "jongyoungcha"
                 :passwd "jongyoungcha"
                 :testnet-dir "~/testnet"))

(defcustom main-node-info
  :type 'string)
(setq main-node-info "")

(defcustom genesis-json-path
  :type 'string)
(setq genesis-json-path "~/genesis.json")


(defcustom genesis-poa-json-path
  :type 'staring)
(setq genesis-poa-json-path "~/genesis-poa.json")


(defcustom ether-node-list
  :type 'list)
(setq ether-node-list (list
                       ;; (make-ether-node
                       ;; :name "ethernode1"
                       ;; :host "192.168.130.101"
                       ;; :user "jongyoungcha"
                       ;; :passwd "jongyoungcha"
                       ;; :privkey-path "~/.ssh/ethernode1_rsa"
                       ;; :testnet-dir "~/testnet")
                       (make-ether-node
                        :name "channode1"
                        :host "192.168.1.46"
                        :user "root"
                        :passwd "root"
                        :privkey-path "~/.ssh/channode1_rsa"
                        :testnet-dir "~/testnet")
                       (make-ether-node
                        :name "channode3"
                        :host "192.168.1.48"
                        :user "root"
                        :passwd "root"
                        :privkey-path "~/.ssh/channode3_rsa"
                        :testnet-dir "~/testnet")
                       ;; (make-ether-node
                       ;; :name "ethernodeinner"
                       ;; :host "192.168.56.102"
                       ;; :user "jongyoungcha"
                       ;; :passwd "jongyoungcha"
                       ;; :privkey-path "~/ethernode_keys/ethernodeinner_rsa"
                       ;; :testnet-dir "~/testnet")
                       ))


(defun connect-node-tramp (node)
  (interactive)
  (let ((default-directory)
        (node-buffer-name))
    (setq node-buffer-name (format "*eshell-%s*" (ether-node-name node)))
    (with-current-buffer (get-buffer-create node-buffer-name)
      (setq default-directory (format "/ssh:%s@%s:%s"
                                      (ether-node-user node)
                                      (ether-node-host node)
                                      (ether-node-testnet-dir node)))
      (display-buffer node-buffer-name)
      (eshell-mode)
      )))


(defun chan-make-node-infos (&optional dir)
  (interactive)
  (let((base-dir "~")
       (output-buffer "*chan-nodes*")
       (testnet-dir))
    (if dir
        (setq base-dir dir))
    
    (dolist (elem-node ether-node-list)
      (with-current-buffer (get-buffer-create output-buffer)
	     (display-buffer output-buffer)
	     (eshell-command (format "ssh %s" (ether-node-name elem-node)) (current-buffer))
	     )
      
      ;; (ignore-errors (eshell-mode))
      ;; (display-buffer (current-buffer))
      ;; (setq default-directory (format "/ssh:%s@%s:~"
      ;; (ether-node-user elem-node)
      ;; (ether-node-host elem-node)))
      ;; (call-process-shell-command (format "ssh %s" (ether-node-name elem-node)) nil (current-buffer))
      ;; (display-buffer "*Eshell Command Output*")
      ;; (if (locate-file "geth" exec-path)
      ;; (progn
      ;; (call-process-shell-command (format "geth --datadir=%s --nodiscover console"
      ;; (ether-node-testnet-dir elem-node)))
      ;; (ignore-errors (term-mode))
      ;; (autopair-newline)
      ;; (goto-char (point-max))
      ;; (insert "amdin.nodeInfo.enode")
      ;; (autopair-newline)
      ;; )
      ;; (insert "***Couldnt not found geth executable...***")
      ;; )
      )))



(defun chan-eshell-exec-cmd (target-buffer cmd)
  (condition-case ex
      (with-current-buffer target-buffer
        (ignore-errors (eshell-return-to-prompt))
        (autopair-newline)
        (goto-char (point-max))
        (insert cmd)
        (autopair-newline)
        (ignore-errors (eshell-return-to-prompt))
        )))


(defun chan-connect-node-ssh (node)
  (let ((target-buffer))
    (setq target-buffer "*EShell Command output*")
    (with-current-buffer (get-buffer-create target-buffer)
      (display-buffer target-buffer)
      (eshell-command "ls")
      (eshell-command (format "ssh ethernode_inner"))
      )))


(defun chan-add-peer-ethernode (target-buffer)
  (interactive)
  (let ((cmd-addpeer))
    (with-current-buffer target-buffer
      (autopair-newline)
      (goto-char (point-max))
      (setq cmd-addpeer (format "admin.addPeer(\"%s\")" (ether-node-enode main-node)))
      (insert cmd-addpeer)
      (autopair-newline)
      ))
  )


(defun chan-init-ethernodes ()
  (interactive)
  (let ((target-buffer)
        (base-host)
        (testnet-dir))
    (dolist (elem-node ether-node-list)
      (setq base-host (format "/ssh:%s" (ether-node-name elem-node)))
      (setq testnet-dir (ether-node-testnet-dir elem-node))
      (setq target-buffer (format "*%s*" (ether-node-name elem-node)))
      (with-current-buffer (get-buffer-create target-buffer)
        (setq default-directory (format "%s:~" base-host))
        (start-file-process "~/goworks/bin/geth"
                            (get-buffer-create target-buffer)
                            "/bin/bash" "-c"
                            (format "~/goworks/bin/geth --nodiscover --datadir=%s console" testnet-dir))
        (ignore-errors (call-interactively 'term-mode))
        
        (goto-char (point-max))
        (insert "personal.newAccount(\"jongyoungcha\")")
        (autopair-newline)
        (insert "personal.newAccount(\"jongyoungcha\")")
        (autopair-newline)
        (insert "personal.unlockAccount(eth.accounts[0], \"jongyoungcha\", 0)")
        (autopair-newline)
        (insert "personal.unlockAccount(eth.accounts[1], \"jongyoungcha\", 0)")
        
        (chan-add-peer-ethernode (current-buffer))
        
        (display-buffer target-buffer)
        )))
  )

(defun jong-run-local-ethnode-console ()
  (interactive)
  (let ((magic-second 0))
    (with-current-buffer (get-buffer "main.go")
      (jong-run-dlv-cs-otherframe)
      (while (not (get-buffer "*gud-connect*"))
        (if (> (1+ magic-second) 5))
        (message "waiting...")
        (sleep-for 1))
      (condition-case ex
          (with-current-buffer (get-buffer "*gud-connect*")
            (goto-char (point-max))
            ;; (insert (format "r --datadir=~/testnet --verbosity 4 --bootnodes %s --syncmode \"full\" --cache=2048 console" (getenv "BOOTNODE")))
			(insert (format "r --datadir=~/testnet --verbosity 4  --syncmode \"full\" --cache=2048 console"))
			(autopair-newline)
            ;; (insert "c")
            ;; (autopair-newline)
			)
        (message "running delve of local ethernode was failed...")))
    )
  )




(defun jong-run-local-ethnode-set-args ()
  (interactive)
  "Arguments about running ethereum node."
  (setq jong-run-local-ethnode-args (read-string "(Ether test) Please input the arguments :"))
  (message "Next jong-run-local-ethnode()'s arguemtns : %s" jong-run-local-ethnode-args)
  )

(defun jong-run-local-ethnode ()
  (interactive)
  (let ((magic-second 0))
    (with-current-buffer (get-buffer "main.go")
      (jong-run-dlv-cs-otherframe)
      (while (not (get-buffer "*gud-connect*"))
        (if (> (1+ magic-second) 5))
        (message "waiting...")
        (sleep-for 1))
      (condition-case ex
          (with-current-buffer (get-buffer "*gud-connect*")
            (goto-char (point-max))
            ;; (insert (format "r --datadir=~/testnet --verbosity 4 --bootnodes %s --syncmode \"full\" --cache=2048" (getenv "BOOTNODE")))
			(insert (format "r %s" jong-run-local-ethnode-args))
            (autopair-newline)
            ;; (insert "c")
            ;; (autopair-newline)
			)
        (message "running delve of local ethernode was failed...")))
    )
  )



(defun jong-init-local-ethnode (is-ethash)
  (let ((genesis-output-buffer "*chan-init-ether-local-genesis*")
        (account-output-buffer "*chan-init-ether-local-account*"))
    (with-current-buffer (get-buffer-create genesis-output-buffer)
      (ignore-errors (shell-mode))
      (goto-char (point-max))
      (display-buffer (current-buffer))
      (ignore-errors (delete-directory "~/testnet" t))
      (ignore-errors (make-directory "~/testnet"))
	  (if is-ethash
		  (copy-file genesis-json-path "~/testnet/genesis.json" t)
		(copy-file genesis-json-path ))
      (call-process-shell-command
       "geth --datadir=~/testnet --cache=2048 init ~/testnet/genesis.json" nil t))
    
    (with-current-buffer (get-buffer-create account-output-buffer)
      (start-process-shell-command "geth" account-output-buffer (format "geth --datadir=~/testnet --bootnodes %s --cache=2048 console" (getenv "BOOTNODE")))
      (display-buffer (current-buffer))
      (ignore-errors (shell-mode))
      (goto-char (point-max))
      (insert "personal.newAccount(\"jongyoungcha\")")
      (autopair-newline)
      (insert "personal.newAccount(\"jongyoungcha\")")
      (autopair-newline)
      (insert "personal.unlockAccount(eth.accounts[0], \"jongyoungcha\", 0)" )
      (autopair-newline)
      (insert "personal.unlockAccount(eth.accounts[1], \"jongyoungcha\", 0)")
      (autopair-newline)
      (ignore-errors (term-mode)))
    )
  )


(defun jong-init-local-ethnode-ethash ()
  (interactive)
  (jong-init-local-ethnode t))


(defun jong-init-local-ethnode-clique ()
  (interactive)
  (jong-init-local-ethnode nil))




(defun chan-ether-send-transaction ()
  "Send transaction coinbase to accounts[1]."
  (interactive)
  (condition-case ex
      (with-current-buffer ether-target-eshell
        (goto-char (point-max))
        (insert (format "eth.sendTransaction({from:eth.coinbase, to:eth.accounts[1], value:1})"))
        (eshell-send-input)
        (goto-char (point-max))
        (eshell-return-to-prompt))
    (message ex))
  )

(defun chan-ether-new-account ()
  "This is unlock coinbase."
  (interactive)
  (condition-case ex
      (with-current-buffer ether-target-eshell
        (goto-char (point-max))
        (insert (format "personal.newAccount(\"jongyoungcha\")"))
        (eshell-send-input)
        (goto-char (point-max))
        (eshell-return-to-prompt))
    (message ex))
  )


(defun chan-ether-unlock-account0 ()
  "This is unlock coinbase."
  (interactive)
  (condition-case ex
      (with-current-buffer ether-target-eshell
        (goto-char (point-max))
        (insert (format "personal.unlockAccount(eth.accounts[0], \"jongyoungcha\", 0)"))
        (eshell-send-input)
        (goto-char (point-max))
        (eshell-return-to-prompt))
    (message ex))
  )


(defun chan-ether-unlock-account1 ()
  "This is unlock coinbase."
  (interactive)
  (condition-case ex
      (with-current-buffer ether-target-eshell
        (goto-char (point-max))
        (insert (format "personal.unlockAccount(eth.accounts[1], \"jongyoungcha\", 0)"))
        (eshell-send-input)
        (goto-char (point-max))
        (eshell-return-to-prompt))
    (message ex))
  )


(defun chan-ether-get-peers ()
  "This is unlock coinbase."
  (interactive)
  (condition-case ex
      (with-current-buffer ether-target-eshell
        (goto-char (point-max))
        (insert (format "admin.peers"))
        (eshell-send-input)
        (goto-char (point-max))
        (eshell-return-to-prompt))
    (message ex))
  )


(defun chan-ether-init-testnet ()
  "Initialize the testnet."
  (interactive)
  (condition-case ex
      ;; (with-current-buffer (eshell-return-to-prompt)
      (with-current-buffer (get-buffer "*eshell*")
        ;; (insert (format "admin.peers"))
        (goto-char (point-max))
        (Insert "ls")
        (eshell-send-input)
        (eshell-return-to-prompt)
        (goto-char (point-max))
        (eshell-return-to-prompt)
        )
    )
  )

(provide 'jong-ether-test)

