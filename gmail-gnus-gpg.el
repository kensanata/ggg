;;; gmail-gnus-gpg.el --- example setup for encrypted mail reading

;; Dedicated to the public domain.

;;; Commentary:

;; See the README.md file for more information. This file could by your
;; ~/.gnus file, or you could pull it into your ~/.emacs file. Be sure
;; to change the `user-mail-address' and the key id in
;; `mml-secure-openpgp-signers'.

;; Code:

(setq ;; You need to replace this email address with your own!
      user-mail-address "kensanata@gmail.com"
      ;; You need to replace this key ID with your own key ID!
      mml-secure-openpgp-signers '("7893C0FD")
      ;; This tells Gnus to get email from Gmail via IMAP.
      gnus-select-method
      '(nnimap "gmail"
               ;; It could also be imap.googlemail.com if that's your server.
               (nnimap-address "imap.gmail.com")
               (nnimap-server-port 993)
               (nnimap-stream ssl))
      ;; This tells Gnus to use the Gmail SMTP server. This
      ;; automatically leaves a copy in the Gmail Sent folder.
      smtpmail-smtp-server "smtp.gmail.com"
      smtpmail-smtp-service 587
      ;; Tell message mode to use SMTP.
      message-send-mail-function 'smtpmail-send-it
      ;; This is where we store the password.
      nntp-authinfo-file "~/.authinfo.gpg"
      ;; Gmail system labels have the prefix [Gmail], which matches
      ;; the default value of gnus-ignored-newsgroups. That's why we
      ;; redefine it.
      gnus-ignored-newsgroups "^to\\.\\|^[0-9. ]+\\( \\|$\\)\\|^[\"]\"[#'()]"
      ;; The agent seems to confuse nnimap, therefore we'll disable it.
      gnus-agent nil
      ;; We don't want local, unencrypted copies of emails we write.
      gnus-message-archive-group nil
      ;; We want to be able to read the emails we wrote.
      mml2015-encrypt-to-self t)

;; Attempt to encrypt all the mails we'll be sending.
(add-hook 'message-setup-hook 'mml-secure-message-encrypt)

;; Add two key bindings for your Gmail experience.
(add-hook 'gnus-summary-mode-hook 'my-gnus-summary-keys)

(defun my-gnus-summary-keys ()
  (local-set-key "y" 'gmail-archive)
  (local-set-key "$" 'gmail-report-spam))

(defun gmail-archive ()
  "Archive the current or marked mails.
This moves them into the All Mail folder."
  (interactive)
  (gnus-summary-move-article nil "nnimap+imap.gmail.com:[Gmail]/All Mail"))

(defun gmail-report-spam ()
  "Report the current or marked mails as spam.
This moves them into the Spam folder."
  (interactive)
  (gnus-summary-move-article nil "nnimap+imap.gmail.com:[Gmail]/Spam"))

;;; gmail-gnus-gpg.el ends here
