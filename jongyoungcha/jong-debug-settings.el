;;; Code:

;; (dap-register-debug-template "SwitNodeV1"
;; (list :type "node"
;; :args "-i"
;; :cwd nil
;; :env '(("DEBUG" . "1"))
;; :target-module (expand-file-name "~/go/src/swit/swit-apiv1/")
;; :request "launch"
;; :name "SwitNodev1"))

;; (dap-register-debug-template "SwitFileGo"
;; (list :type "go"
;; :args "-i"
;; :env '(
;; ("BUCKET_NAME" . "test-swit")
;; ("FILE_SERVICE_PORT" . "10040")
;; ("SWIT_FILE_LOG_LEVEL" ."debug")
;; ("GOOGLE_STORAGE_CREDENTIALS" . "/Users/swit-mac/swit-gke-resource-access.json")
;; )
;; :program "/Users/swit-mac/go/src/swit/swit-gcs-file-golang/server"
;; :request "launch"
;; :mode "exec"
;; :name  "SwitFileGo"))


(defvar jong-debug-setting-path (format "%s/.emacs.d/jongyoungcha/jong-debug-settings.el" (getenv "HOME")))

(defun jong-debug-setting-toggle-open-file()
  "Open the dap-debug setting file."
  (interactive)
  (if (get-buffer "jong-debug-settings.el")
	  (kill-buffer (get-buffer "jong-debug-settings.el"))
	(find-file-at-point jong-debug-setting-path))
  )

(dap-register-debug-template "koscomtls"
							 (list :type "go"
								   :args "call -u https://naver.com -X POST -d \'test message\'"
								   :env '(
										  ("MTLS_SENTBIZ_CRT_PATH" . "/Users/richard/koscom_dev_sentbe_com.crt")
										  ("MTLS_SENTBIZ_KEY_PATH" . "/Users/richard/koscom.dev.sentbe.com.key")
										  ("MTLS_SENTBIZ_FULL_CHAIN_PATH" . "/Users/richard/koscom_dev_sentbe_com.pem")
										  )
								   :program "/Users/richard/go/src/demeter/cmd/koscommtls/main.go"
								   :envFile nil
								   :buildFlags "-gcflags '-N -l'"
								   :request "launch"
								   :mode "debug"
								   :name  "koscomtls"))


(provide 'jong-debug-settings)
