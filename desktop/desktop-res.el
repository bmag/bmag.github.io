(require 'desktop)

(defun sy-save-shell-buffer (desktop-dirname)
  ;; we only need to save the current working directory
  default-directory)

(defun sy-create-shell-buffer (_file-name buffer-name misc)
  "MISC is the value returned by `sy-save-shell-buffer'.
_FILE-NAME is nil."
  (let ((default-directory misc))
    ;; create a shell buffer named BUFFER-NAME in directory MISC
    (shell buffer-name)))

;; save all shell-mode buffers
(add-hook 'shell-mode-hook (lambda () (setq-local desktop-save-buffer #'sy-save-shell-buffer)))
;; restore all shell-mode buffers
(add-to-list 'desktop-buffer-mode-handlers '(shell-mode . sy-create-shell-buffer))

(setq desktop-path `(,(expand-file-name "save-dir/")))
(desktop-save-mode)
(desktop-read)
