# Gmail Gnus GPG Guide (GGGG)

This page is about sending and receiving encrypted mail using
[Gmail](https://mail.google.com/), [Gnus](http://www.gnus.org/) and
[GPG](https://www.gnupg.org/). If you're just interested in sending
and receiving encrypted mail, you should probably see [Email
Self-Defense](https://emailselfdefense.fsf.org/) by the [Free Software
Foundation](https://www.fsf.org/).

I'm assuming you know a bit about all the tools involved: **Gmail** is
Google's email service. **Gnus** is a mail and news reader that comes
with [Emacs](https://www.gnu.org/software/emacs/). **GPG** is actually
GnuPG, a complete and free implementation of the OpenPGP standard as
defined by [RFC4880](http://www.ietf.org/rfc/rfc4880.txt) (also known
as PGP). My problem has always been putting it all together. Hopefully
this page will help you do just that.

We're going to use Gmail to send and receive encrypted mail. Google is
doing a good job defending us against criminals. This setup will not
prevent network analysis from criminal investigators and US spying
agencies. People will be able to reconstruct who you're communicating
with because the email senders and recipients are never hidden. This
setup will also not prevent you and your partners from making mistakes
such as leaving unencrypted emails lying on their computers. And finally,
this setup will also not help you if your computer has been taken over
by a government
[Trojan](https://en.wikipedia.org/wiki/Trojan_horse_%28computing%29)
(malware such as
[keystroke loggers](https://en.wikipedia.org/wiki/Keystroke_logging) or
screen loggers). But,
[defense in depth](https://en.wikipedia.org/wiki/Defense_in_depth_%28computing%29)
is important. Every little thing helps. And it definitely makes mass
surveillance much harder and more expensive to do.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-refresh-toc -->
**Table of Contents**

- [Getting a secret key for GPG](#getting-a-secret-key-for-gpg)
- [Exchanging public keys with partners](#exchanging-public-keys-with-partners)
- [Encrypting a file](#encrypting-a-file)
- [Getting a password for Gmail](#getting-a-password-for-gmail)
- [Storing your Gmail password for Gnus, using GPG to encrypt it](#storing-your-gmail-password-for-gnus-using-gpg-to-encrypt-it)
- [Setting up Gnus for Gmail](#setting-up-gnus-for-gmail)
- [Run Gnus](#run-gnus)
- [Send encrypted mail](#send-encrypted-mail)
- [Bonus Material](#bonus-material)
    - [Keyservers](#keyservers)
    - [Trust](#trust)
    - [Testing](#testing)
    - [Web Key Directory](#web-key-directory)
- [Troubleshooting](#troubleshooting)
    - [Windows](#windows)
    - [Mac](#mac)
- [Further Reading](#further-reading)

<!-- markdown-toc end -->

## Getting a secret key for GPG

We'll generate a new secret key using GPG. A secret key is like your
identity. You need to keep it safe. Every secret key comes with a public
key. This is what other people will need to send you email. You'll have
to get it to them somehow. In return you will get the public keys of
your partners. Both secret and public keys are stored in keyrings in
your home directory.

Here's what an initial run of gpg looks like:

```
guest@melanobombus:~$ gpg --list-keys
gpg: directory '/home/guest/.gnupg' created
gpg: keybox '/home/guest/.gnupg/pubring.kbx' created
gpg: /home/guest/.gnupg/trustdb.gpg: trustdb created
```

For this example, I did not change any settings in my `gpg.conf`. If
you're interested in learning more, you might want to read
[GPG / Mutt / Gmail](https://gist.github.com/bnagy/8914f712f689cc01c267)
by Ben Nagy.

Let's create our secret key using `gpg --gen-key`.

Here's what you want to answer:

1. a name
2. an email address
5. a passphrase

A *passphrase* is like a very long password. Use a good one and don't
forget it. All your other passwords will end up being protected by
this one passphrase.

Here's what the entire process looks like:

```
guest@melanobombus:~$ gpg --gen-key
gpg (GnuPG) 2.2.12; Copyright (C) 2018 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Note: Use "gpg --full-generate-key" for a full featured key generation dialog.

GnuPG needs to construct a user ID to identify your key.

Real name: Alex Schroeder
Email address: alex@gnu.org
You selected this USER-ID:
    "Alex Schroeder <alex@gnu.org>"

Change (N)ame, (E)mail, or (O)kay/(Q)uit? o
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
gpg: key AE495BC63253DDE8 marked as ultimately trusted
gpg: directory '/home/guest/.gnupg/openpgp-revocs.d' created
gpg: revocation certificate stored as '/home/guest/.gnupg/openpgp-revocs.d/ABEF08C34DB4DB8A73EBBBB8AE495BC63253DDE8.rev'
public and secret key created and signed.

pub   rsa3072 2020-05-07 [SC] [expires: 2022-05-07]
      ABEF08C34DB4DB8A73EBBBB8AE495BC63253DDE8
uid                      Alex Schroeder <alex@gnu.org>
sub   rsa3072 2020-05-07 [E] [expires: 2022-05-07]
```

The output here lists your fingerprint. You can reprint this using the
command `gpg --fingerprint` and an email address. In my case:

```
guest@melanobombus:~$ gpg --fingerprint
/home/guest/.gnupg/pubring.kbx
------------------------------
pub   rsa3072 2020-05-07 [SC] [expires: 2022-05-07]
      ABEF 08C3 4DB4 DB8A 73EB  BBB8 AE49 5BC6 3253 DDE8
uid           [ultimate] Alex Schroeder <alex@gnu.org>
sub   rsa3072 2020-05-07 [E] [expires: 2022-05-07]
```

I like to expire my keys. This simplifies things because I don't have to
worry about revocation certificates and all that. If you do, you could
learn more by reading
[Creating the perfect GPG keypair](https://alexcabal.com/creating-the-perfect-gpg-keypair/)
by Alex Cabal.

Also note that the message told you about a revocation certificate it
created. If you keep it somewhere safe, you'll be able to tell other
people that your key got compromised and that it shouldn't be used
anymore, in a cryptographically secure manner. This assumes that your
enemies might be trying to spoof your friends, telling them that you
switched keys when in fact you haven't. The revocation certificate is
how you tell them you *are* switching keys!

Usually, you don't have to do that. Instead, you'll *extend* your key,
moving the expiration day up a year or two.

## Exchanging public keys with partners

This is what we would send our partners:

```
guest@melanobombus:~$ gpg --export --armor alex@gnu.org
-----BEGIN PGP PUBLIC KEY BLOCK-----

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
5BklAoTR0s26VD63cQSIKLwt0V+u
=hQcc
-----END PGP PUBLIC KEY BLOCK-----
```

They would save this block in a file such as `alex.pub` and import it.
Here, I got a public key from a friend and imported it.

```
guest@melanobombus:~$ gpg --import roland.pub
gpg: key A5E1F208237B14BE: public key "Roland Li <roland@li.name>" imported
gpg: Total number processed: 1
gpg:               imported: 1
```

If you meet your partners face to face, giving them a copy of your
public key is easy. If you never met, it's harder. How do you make sure
that criminals didn't interfere? This is called a
[man-in-the-middle attack](https://en.wikipedia.org/wiki/Man-in-the-middle_attack).
You could make it harder by publishing your fingerprint on various
channels. Attackers would have to replace these fingerprints everywhere.
It's not perfect, but it's much better than nothing.

```
guest@melanobombus:~$ gpg --fingerprint alex@gnu.org
pub   rsa3072 2020-05-07 [SC] [expires: 2022-05-07]
      ABEF 08C3 4DB4 DB8A 73EB  BBB8 AE49 5BC6 3253 DDE8
uid           [ultimate] Alex Schroeder <alex@gnu.org>
sub   rsa3072 2020-05-07 [E] [expires: 2022-05-07]
```

The fingerprint is right here: `ABEF 08C3 4DB4 DB8A 73EB BBB8 AE49
5BC6 3253 DDE8`. Put it on your web page, in your email signatures,
tweet it, and so on.

## Encrypting a file

Let's encrypt a file before we get started. Use Emacs to create a text
file and save it as `message.txt`. Use `M-x epa-encrypt-file` to
encrypt the file. You'll see a buffer where you can tell Emacs who the
recipients are:

```
Select recipients for encryption.
If no one is selected, symmetric encryption will be performed.
- ‘m’ to mark a key on the line
- ‘u’ to unmark a key on the line
[Cancel][OK]

  u AE495BC63253DDE8 Alex Schroeder <alex@gnu.org>
  - A5E1F208237B14BE Roland Li <roland@li.name>
```

These are the people GPG knows about: the key you created and the key
you imported. Hopefully you will be adding many more.

Move the line marked with the `u`. This is the key with "ultimate
trust", your own.

Use `m` to mark both your key and Roland's key and press `RET` on the
OK button. GPG will tell you that there's no way to know that this key
does in fact belong to the person it claims to belong to, but what are
you going to do? Use it anyway.

Now, you'll have an encrypted file called `message.txt.gpg` next to
the unencrypted `message.txt` file and both you and Roland can decrypt
it. Note that if you didn't mark your own key, then you would not be
able to read the encrypted file.

Don't name your file for the things you're talking about or you'll be
giving away important information.

## Getting a password for Gmail

This setup assumes that you have
[enabled 2-step authentication](https://www.google.com/landing/2step/)
for your Gmail account. If you haven't done that, you should do that
first.

Now, you'll need to
[get an app password for your Gmail account](https://security.google.com/settings/security/apppasswords).
Visit the link and generate a new one. Where it says "Select app" pick
"Other" and answer "Emacs". Where it say "Select device" answer "laptop"
or whatever. These two are just used to generate a good looking name in
the list above. This app password allows an app to access your Gmail
account even though you enabled 2-step authentication. The benefit is
that you can disable this password and generate a new one once you learn
that somebody may have stolen it.

Let's assume that the password generated is "thisismysecretpw".

## Storing your Gmail password for Gnus, using GPG to encrypt it

We want Gnus to know about this password. Gnus uses a file called
`~./authinfo.gpg` for all your passwords. This file will be protected by
the passphrase for your GPG key!

Edit the file:

```
guest@melanobombus:~$ emacs ~/.authinfo.gpg
```

This is the content of your new file. Make sure to *change email address
and password!*

```
machine imap.gmail.com login kensanata@gmail.com password thisismysecretpw port 993
machine smtp.gmail.com login kensanata@gmail.com password thisismysecretpw port 587
```

When you save the file, Emacs will ask you about the recipients:

```
Select recipients for encryption.
If no one is selected, symmetric encryption will be performed.
- ‘m’ to mark a key on the line
- ‘u’ to unmark a key on the line
[Cancel][OK]

  u AE495BC63253DDE8 Alex Schroeder <alex@gnu.org>
  - A5E1F208237B14BE Roland Li <roland@li.name>
```

Move the line marked with the `u`. This is the key with "ultimate
trust", your own. Hit `m` and tab to the `[OK]` button, hit Enter.
Only you will be able to read the file.

If you exit Emacs and try to open the file again, you'll be asked for
your passphrase. Excellent!

## Setting up Gnus for Gmail

Gnus is a powerful tool. Originally, it was intended to read news on
USENET. Then backends were added and now it can read RSS files, mail in
various formats, and more. We'll use it to access Gmail via IMAP and to
send mail via SMTP.

When sending your first email from Gnus, you might get a STARTTLS error.
If you’re using [Homebrew](http://brew.sh/) in Mac OS X, you can install
the necessary package with `brew install gnutls`.

We'll keep our settings in a separate `~/.gnus` file. Gnus will read
this file when it starts.

```elisp
(setq ;; You need to replace this email address with your own!
      user-mail-address "alex@gnu.org"
      ;; You need to replace this key ID with your own key ID!
      mml-secure-openpgp-signers '("AE495BC63253DDE8")
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
      ;; Gmail system labels have the prefix [Gmail], which matches
      ;; the default value of gnus-ignored-newsgroups. That's why we
      ;; redefine it.
      gnus-ignored-newsgroups "^to\\.\\|^[0-9. ]+\\( \\|$\\)\\|^[\"]\"[#'()]"
      ;; The agent seems to confuse nnimap, therefore we'll disable it.
      gnus-agent nil
      ;; We don't want local, unencrypted copies of emails we write.
      gnus-message-archive-group nil
      ;; We want to be able to read the emails we wrote.
      mml-secure-openpgp-encrypt-to-self t)

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
```

## Run Gnus

Do it now! Start Emacs and run `M-x gnus`. You will be prompted for your
passphrase to unlock the Gmail password, and then Gnus will start
running. You should see something like the following:

```
       1: INBOX
      22: [Gmail]/All Mail
     984: [Gmail]/Spam
     174: [Gmail]/Trash
    7806: [Gmail]/Chats
      19: [Gmail]/Important
*      0: [Gmail]/Starred
```

## Send encrypted mail

Let's test sending some encrypted mail. Hit `m` to create a message
buffer. The tag `<#secure method=pgpmime mode=encrypt>` makes sure that
Emacs will encrypt the mail before sending it.

```
To: roland@li.name
Subject: Testing Gnus Setup
From: Guest User <alex@gnu.org>
--text follows this line--
<#secure method=pgpmime mode=encrypt>
Hi Roland

This is a test for my tutorial.

Cheers
Alex
```

The message log in the echo area should says something like the following:

```
Sending via mail...
Opening STARTTLS connection to `smtp.gmail.com:587'...done
Sending email
Sending email done
Sending...done
```

Done!

If you go back to your `*Group*` buffer, you might want to verify that
the email got sent. Use `3 L` to display all the groups at level three,
even if they are empty. You should see a group called `[Gmail]/Sent Mail`.
Enter it, and move to the end. You should see the mail you just wrote:

```
O. [   ?: -> roland@li.name      ] Testing Gnus Setup
```

When you enter it, Gnus will ask you: `Decrypt (PGP) part? (y or n)`.
If you answer correctly, you will see the email you sent. Maybe you'll
have to provide your passphrase again. The only reason you can read
this email is because it was encrypted both for the mail recipient
(Roland) and your own key (because of the `mml2015-signers` setting).

Here you go:

```
From: Guest User <alex@gnu.org>
Subject: Testing Gnus Setup
To: roland@li.name
Date: Fri, 24 Jul 2015 14:38:53 +0200 (16 minutes, 4 seconds ago)

Hi Roland

This is a test for my tutorial.

Cheers
Alex
```

This is it. We're done. Everything else is bonus material.

## Bonus Material

This section is not necessarily required if all you want to do is send
encrypted mail to friends and family. If you want to send encrypted
mail to strangers, however, this section is for you.

### Keyservers

Remember how I said that giving people you meet face to face a copy of
your public key is easy. Well, if you are not too worried then people
could look up public keys online. This would be a kind of service that
allows you to search for the public keys of people by name or email
address. These services exist and they are called keyservers.

Use `gpg --search` to search for a key:

```
guest@melanobombus:~$ gpg --search kensanata@gmail.com
gpg: data source: https://209.244.105.201:443
(1)	Alex Schroeder <alex@gnu.org>
	Alex Schroeder <kensanata@gmail.com>
	Alex Schroeder <kensanata@keybase.io>
	Alex Schroeder <alex@alexschroeder.ch>
	  8192 bit RSA key C78CA29BACECFEAE, created: 2015-03-01, expires: 2020-01-20 (expired)
(2)	Alex Schroeder <alex@gnu.org>
	Alex Schroeder <alex@emacswiki.org>
	Alex Schroeder <kensanata@gmail.com>
	  1024 bit DSA key 757368E7353AEFEF, created: 2002-07-10, expires: 2015-08-20 (revoked) (expired)
Keys 1-2 of 2 for "kensanata@gmail.com".  Enter number(s), N)ext, or Q)uit > 
```

I guess I've let these keys expire! Oops.

### Trust

In order to avoid the warning about untrusted keys, I'm simply going
to trust them all. Create a config file called `~/.gnupg/gpg.conf`
with the following:

```
# More like "Web of Mistrust", amirite??
trust-model always
```

### Testing

Now we can do a little test with a bot! This is based on the [Email
Self-Defense](https://emailselfdefense.fsf.org/) site by the *Free
Software Foundation*.

Export your public key as explained above and paste it into an email
to `edward-en@fsf.org` with a subject such as "hello bot". This first
email is not going to be encrypted. That's why you need to *delete*
the `<#secure method=pgpmime mode=encrypt>` tag. This time only,
promised!

You'll get back a reply:

```
Hello, I am Edward, the friendly GnuPG bot.

I received your public key. Thanks.

- Edward, the friendly GnuPG bot
```

Next, retrieve his public key from the keyserver. That's why we needed
the keyserver: to get keys of strangers.

```
guest@melanobombus:~$ gpg --search edward-en@fsf.org
gpg: data source: https://209.244.105.201:443
(1)	Edward the GPG Bot <edward@fsf.org>
	Edward, the GPG Bot <edward-en@fsf.org>
	GnuPGボットのEdward <edward-ja@fsf.org>
	Edward, l'amichevole bot GnuPG <edward-it@fsf.org>
	Edward, le gentil robot de GnuPG <edward-fr@fsf.org>
	Edward, el simpático robot GnuPG <edward-es@fsf.org>
	Edward, o amigo robô de GnuPG <edward-pt-br@fsf.org>
	Edward, robotul GnuPG cel prietenos <edward-ro@fsf.org>
	Edward, arkadaş canlısı GnuPG botu <edward-tr@fsf.org>
	Edward, der freundliche GnuPG Roboter <edward-de@fsf.org>
	Эдвард, дружелюбный GnuPG бот <edward-ru@fsf.org>
	Edward, το φιλικό ρομπότ του GnuPG <edward-el@fsf.org
	  2048 bit RSA key 9FF2194CC09A61E8, created: 2014-06-29
Keys 1-1 of 1 for "edward-en@fsf.org".  Enter number(s), N)ext, or Q)uit > 1
gpg: key 9FF2194CC09A61E8: 7504 signatures not checked due to missing keys
gpg: key 9FF2194CC09A61E8: public key "Edward, el simpático robot GnuPG <edward-es@fsf.org>" imported
gpg: no need for a trustdb check with 'always' trust model
gpg: Total number processed: 1
gpg:               imported: 1
```

And now we can send him an email, signed and encrypted. This time we
won't be removing the `<#secure method=pgpmime mode=encrypt>` tag!

We should get back another reply:

```
I received your message and decrypted it.

Your signature was verified.
```

Yay!

### Web Key Directory

If you add the following to `~/.gnupg/gpg.conf`, gpg tries to get the
key not only from the keyserver but also via Web Key Directory (WKD):

```
auto-key-locate local,keyserver,wkd
```

If you check the [WKD wiki page](https://wiki.gnupg.org/WKD), you'll
see that not many organisations are using it. Perhaps one day!

## Troubleshooting

This section is for all the things that might go wrong.

### Windows

If you installed Emacs for Windows and you're reading an email message
containing HTML, Gnus will try to render it for you. This uses the
libxml2 library which doesn't come with the default installation.
You'll see an empty mail body and Emacs will show "libxml2 library not
found" in the echo area. This is sad but what are you going to do?
Install `libxml2`, of course!

The [Emacs README](https://ftp.gnu.org/gnu/emacs/windows/README) tells
you to install it from Eli Zaretskii's collection [on
SourceForge](http://sourceforge.net/projects/ezwinports/files/). The
important part is that the files in its `bin` directory are on your
`PATH`.


### Mac

I recommend using [Homebrew](http://brew.sh/) to install GPG and
Pinentry. Pinentry is a little program to allow you to enter a PIN.
That's the tool used to enter your passphrase if you don't want Emacs
to handle it for you.

```
brew install gnupg
brew install pinentry-mac
```

On a Mac, when decrypting a message using Emacs started from the GUI,
you'll see a simple, cut off message saying
`epa-file--find-file-not-found-function: Opening input file:
Decryption failed,`. Something is wrong!

If you only use Emacs within terminal windows, no problem. No need to
do anything. Skip this section!

We need to make sure that the agent uses **pinentry for a Mac**. This
is what I have in my `~/.gnupg/gpg-agent.conf`.

```
pinentry-program /usr/local/bin/pinentry-mac
enable-ssh-support
```

If you don't do that, the default `pinentry` is linked to
`pinentry-curses` which will work in a terminal but it won't work in
Emacs!

```
┌────────────────────────────────────────────────────────────────────────────────────┐
│ Please enter the passphrase to unlock the secret key for the OpenPGP certificate:  │
│ "Alex Schroeder <kensanata@gmail.com>"                                             │
│ 4096-bit RSA key, ID 0EC5C708,                                                     │
│ created 2015-07-24 (main key ID 7893C0FD).                                         │
│                                                                                    │
│                                                                                    │
│ Passphrase *****************************************************************______ │
│                                                                                    │
│            <OK>                                                  <Cancel>          │
└────────────────────────────────────────────────────────────────────────────────────┘
```

## Further Reading

* [Encrypting and decrypting documents](https://www.gnupg.org/gph/en/manual/x110.html),
  in *The GNU Privacy Handbook*
* [Making and verifying signatures](https://www.gnupg.org/gph/en/manual/x135.html),
  also in *The GNU Privacy Handbook*
* [Harden Your GnuPG Configuration](https://www.designed-cybersecurity.com/tutorials/harden-gnupg-config/)
* [Operational PGP](https://gist.github.com/grugq/03167bed45e774551155)
* [Creating a new GPG key](http://keyring.debian.org/creating-key.html)
