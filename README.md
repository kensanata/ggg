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
- [Getting a password for Gmail](#getting-a-password-for-gmail)
- [Storing your Gmail password for Gnus, using GPG to encrypt it](#storing-your-gmail-password-for-gnus-using-gpg-to-encrypt-it)
- [Setting up Gnus for Gmail](#setting-up-gnus-for-gmail)
- [Run Gnus](#run-gnus)
- [Send encrypted mail](#send-encrypted-mail)
- [Bonus Material](#bonus-material)
    - [Keyservers](#keyservers)
    - [Keybase](#keybase)
- [Troubleshooting](#troubleshooting)
    - [Windows](#windows)
    - [Mac](#mac)
    - [GPG 2.0 and the GPG Agent](#gpg-20-and-the-gpg-agent)
    - [Migrating from GPG 2.0 to GPG 2.1](#migrating-from-gpg-20-to-gpg-21)
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
Guest@Megabombus:~$ gpg --list-keys
gpg: directory `/Users/Guest/.gnupg' created
gpg: new configuration file `/Users/Guest/.gnupg/gpg.conf' created
gpg: WARNING: options in `/Users/Guest/.gnupg/gpg.conf' are not yet active during this run
gpg: keyring `/Users/Guest/.gnupg/pubring.gpg' created
gpg: /Users/Guest/.gnupg/trustdb.gpg: trustdb created
```

For this example, I did not change any settings in my `gpg.conf`. If
you're interested in learning more, you might want to read
[GPG / Mutt / Gmail](https://gist.github.com/bnagy/8914f712f689cc01c267)
by Ben Nagy.

Let's create our secret key using `gpg --gen-key`.

Here's what you want to answer:

1. we want the default kind of key (option 1: RSA and RSA)
2. we want the largest size (4096 bits, but [feel free to use 2048](https://www.gnupg.org/faq/gnupg-faq.html#default_rsa2048))
3. we want the key to be valid for one year (1y)
4. we'll provide our name and our email address to identify the key
5. we'll provide a passphrase

A *passphrase* is like a very long password. Use a good one and don't
forget it. All your other passwords will end up being protected by
this one passphrase.

Here's what the entire process will look like:

```
Guest@Megabombus:~$ gpg --gen-key
gpg (GnuPG/MacGPG2) 2.0.27; Copyright (C) 2015 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
Your selection? 1
RSA keys may be between 1024 and 4096 bits long.
What keysize do you want? (2048) 4096
Requested keysize is 4096 bits
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 1y
Key expires at Sat Jul 23 10:15:55 2016 CEST
Is this correct? (y/N) y

GnuPG needs to construct a user ID to identify your key.

Real name: Alex Schroeder
Email address: kensanata@gmail.com
Comment:
You selected this USER-ID:
    "Alex Schroeder <kensanata@gmail.com>"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? o
You need a Passphrase to protect your secret key.

We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
gpg: key 7893C0FD marked as ultimately trusted
public and secret key created and signed.

gpg: checking the trustdb
gpg: 3 marginal(s) needed, 1 complete(s) needed, PGP trust model
gpg: depth: 0  valid:   1  signed:   0  trust: 0-, 0q, 0n, 0m, 0f, 1u
gpg: next trustdb check due at 2016-07-23
pub   4096R/7893C0FD 2015-07-24 [expires: 2016-07-23]
      Key fingerprint = 1A38 75FD 21ED 85BE 5AC6  BF49 5C1A C924 7893 C0FD
uid       [ultimate] Alex Schroeder <kensanata@gmail.com>
sub   4096R/0EC5C708 2015-07-24 [expires: 2016-07-23]
```

The output here lists your Key ID. You need to remember this Key ID.
We're going to refer to it further down.

Where is the Key ID? Here are the important lines:

```
pub   4096R/7893C0FD 2015-07-24 [expires: 2016-07-23]
      Key fingerprint = 1A38 75FD 21ED 85BE 5AC6  BF49 5C1A C924 7893 C0FD
```

The first line lists the ID `7893C0FD` and the fingerprint ends in the
same eight characters, `7893 C0FD`. You can reprint this using the
command `gpg --fingerprint` and an email address. In my case:

```
Guest@Megabombus:~$ gpg --fingerprint kensanata@gmail.com
pub   4096R/7893C0FD 2015-07-24 [expires: 2016-07-23]
      Key fingerprint = 1A38 75FD 21ED 85BE 5AC6  BF49 5C1A C924 7893 C0FD
uid       [ultimate] Alex Schroeder <kensanata@gmail.com>
sub   4096R/0EC5C708 2015-07-24 [expires: 2016-07-23]
```

I like to expire my keys. This simplifies things because I don't have to
worry about revocation certificates and all that. If you do, you could
learn more by reading
[Creating the perfect GPG keypair](https://alexcabal.com/creating-the-perfect-gpg-keypair/)
by Alex Cabal.

## Exchanging public keys with partners

This is what we would send our partners:

```
Guest@Megabombus:~$ gpg --export --armor kensanata@gmail.com
-----BEGIN PGP PUBLIC KEY BLOCK-----
Comment: GPGTools - https://gpgtools.org

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
HU096ZFYc0U5vz6d5BY=
=uIuY
-----END PGP PUBLIC KEY BLOCK-----
```

They would save this block in a file such as `alex.pub` and import it.
Here, I got a public key from a friend called "oliof" and imported it.

```
Guest@Megabombus:~$ gpg --import oliof.pub
gpg: key 5F871B02: public key "keybase.io/oliof <oliof@keybase.io>" imported
gpg: Total number processed: 1
gpg:               imported: 1  (RSA: 1)
```

If you meet your partners face to face, giving them a copy of your
public key is easy. If you never met, it's harder. How do you make sure
that criminals didn't interfere? This is called a
[man-in-the-middle attack](https://en.wikipedia.org/wiki/Man-in-the-middle_attack).
You could make it harder by publishing your fingerprint on various
channels. Attackers would have to replace these fingerprints everywhere.
It's not perfect, but it's much better than nothing.

```
Guest@Megabombus:~$ gpg --fingerprint kensanata@gmail.com
pub   4096R/7893C0FD 2015-07-24 [expires: 2016-07-23]
      Key fingerprint = 1A38 75FD 21ED 85BE 5AC6  BF49 5C1A C924 7893 C0FD
uid       [ultimate] Alex Schroeder <kensanata@gmail.com>
sub   4096R/0EC5C708 2015-07-24 [expires: 2016-07-23]
```

The fingerprint is right here: `1A38 75FD 21ED 85BE 5AC6 BF49 5C1A C924
7893 C0FD`. Put it on your web page, in your email signatures, tweet it,
and so on. Consider using [Keybase](https://keybase.io/). It allows you
to "Get a public key, safely, starting just with someone's social media
username(s)." We'll talk about it [down below](#keybase).

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
Guest@Megabombus:~$ emacs ~/.authinfo.gpg
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
- `m' to mark a key on the line
- `u' to unmark a key on the line
[Cancel][OK]

  u 5C1AC9247893C0FD Alex Schroeder <kensanata@gmail.com>
  - FF13FA295F871B02 keybase.io/oliof <oliof@keybase.io>
```

Move the line marked with the `u`. This is the key with "ultimate trust"
-- your own. Hit `m` and tab to the `[OK]` button, hit Enter.

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
To: oliof@keybase.io
Subject: Testing Gnus Setup
From: Guest User <kensanata@gmail.com>
--text follows this line--
<#secure method=pgpmime mode=encrypt>
Hi Oliof

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
O. [   ?: -> oliof@keybase.io    ] Testing Gnus Setup
```

When you enter it, Gnus will ask you: `Decrypt (PGP) part? (y or n)`.
If you answer correctly, you will see the email you sent. Maybe you'll
have to provide your passphrase again. The only reason you can read
this email is because it was encrypted both for the mail recipient
(oliof) and your own key (because of the `mml2015-signers` setting).

Here you go:

```
From: Guest User <kensanata@gmail.com>
Subject: Testing Gnus Setup
To: oliof@keybase.io
Date: Fri, 24 Jul 2015 14:38:53 +0200 (16 minutes, 4 seconds ago)

Hi Oliof

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

Modify your config file is `~/.gnupg/gpg.conf` and it probably already
has a line there saying:

```
keyserver hkp://keys.gnupg.net
```

If you want, you can leave it right there. If you want the connection
from your machine to the key server to be *secured*, this is
unfortunately not enough. In this case you want the schema to be
`hkps` instead of `hkp`.

Modify your `~/.gnupg/gpg.conf` and replace the existing keyserver
line with the following line:

```
keyserver hkps://keys.openpgp.org
```

I'm also going to "trust" them all, so I've changed this setting:

```
# More like "Web of Mistrust", amirite??
trust-model always
```

Now we can do a little test with a bot!

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
Guest@Megabombus:~$ gpg --search edward-en@fsf.org
gpg: searching for "edward-en@fsf.org" from hkps server hkps.pool.sks-keyservers.net
(1) Edward the GPG Bot <edward@fsf.org>
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
      2048 bit RSA key C09A61E8, created: 2014-06-29
Keys 1-1 of 1 for "edward-en@fsf.org".  Enter number(s), N)ext, or Q)uit > 1
gpg: requesting key C09A61E8 from hkps server hkps.pool.sks-keyservers.net
gpg: key C09A61E8: public key "Edward, el simpático robot GnuPG <edward-es@fsf.org>" imported
gpg: no need for a trustdb check with `always' trust model
gpg: Total number processed: 1
gpg:               imported: 1  (RSA: 1)
```

And now we can send him an email, signed and encrypted. This time we
won't be removing the `<#secure method=pgpmime mode=encrypt>` tag!

We should get back another reply:

```
I received your message and decrypted it.

Your signature was verified.
```

Yay!

### Keybase

Remember what I wrote about the *Web of Trust*? More like the *Web Of
Mistrust*! Why is that? Here's how it works. The basic problem is that
I need to get the key from me to you without anybody getting in the
way, claiming to be you, getting my messages, reading them, encrypting
them again for you, and sending them on. That's
a
[Man-in-the-Middle Attack](https://en.wikipedia.org/wiki/Man-in-the-middle_attack).

The *Web of Trust* solution is this: If there's a chain of people that
trust each other, and are willingt to prove it using electronic
signatures, then me and you don't need to meet in person. I trust B, B
trusts C, C trusts you, and since we all went to key signing parties
and signed each other's keys, C signing your key, B signing C's key,
and me signing B's key, trusting the id documents that we showed each
other, a program can establish that your key is in fact your key and
and not a key by the ominous man in the middle.

If you're like me, however, then you're not going to key signing
parties and most of your friends don't sign keys, and you don't trust
yourself to actually verify official looking documents presented to
you by strangers, so it all falls appart.
Enter [Keybase](https://keybase.io/).

If I know you via some social media such as Facebook or Twitter, and I
trust the company, then you can post a note using your key and I'll be
able to verify whether the key I have actually belongs to you. It's
not great, but it certainly beats no checking at all, which is what
happens when nobody ever goes to these key signing parties.

Here's how it would work. We have a keybase account and our friend has
a keybase account. We already logged in and provided some identity of
our own. You can read about that on the Keybase website. I'm only
going to talk about the GPG interaction.

First, let's search for our friend on Keybase:

```
Guest@Megabombus:~$ keybase search oliof
oliof twitter:oliof github:oliof reddit:oliof dns://mausdompteur.de
```

Looks like that's the one we're looking for. Use `keybase id` to check
their identity or skip right ahead and follow them. We'll get to see
the same information. Let's follow some of the links and verify that
this is in fact the person we're friends with. Once we're happy, we
can answer the prompts at the end.

```
Guest@Megabombus:~$ keybase follow oliof
▶ INFO Identifying oliof
✔ public key fingerprint: 3F52 9A92 95BA 3B5F C0AC 51FC FF13 FA29 5F87 1B02
✔ public key fingerprint: DAA5 6B12 9C14 D9A5 D7CF 9620 E6DF 6411 D205 2305
✔ public key fingerprint: 44FC 4A78 1A34 8B84 CA64 B4BD 187C 634F 6F28 287D
✔ admin of DNS zone mausdompteur.de: found TXT entry keybase-site-verification=3FxhCxIB1ZThFffAN6e3cgyIUUBdr6888HnguupxE0E
✔ "oliof" on reddit: https://www.reddit.com/r/KeybaseProofs/comments/38c5yz/my_keybase_proof_redditoliof_keybaseoliof/
✔ "oliof" on github: https://gist.github.com/e1ba51d40d9c8099439f
✔ "oliof" on twitter: https://twitter.com/oliof/status/605819241867001858
Is this the oliof you wanted? [Y/n] 
Publicly follow? [Y/n] 
```

Here's the interesting part: Now that we're following them, we can
pull their public key into our public keyring. As our friend appears
to have three public keys, we'll be getting three different keys:

```
Guest@Megabombus:~$ keybase pgp pull
...
▶ INFO Imported key for oliof.
▶ INFO Imported key for oliof.
▶ INFO Imported key for oliof.
...
```

With that done, I can send them email using Gnus, Gmail, and GPG. 👍

It behooves us to remember, however, what this means: anybody can now
look up our crypto friends on Keybase. This is called
[social network analysis](https://en.wikipedia.org/wiki/Social_network_analysis#Practical_applications).
Perhaps you don't mind using Keybase with strangers because you can be
pretty sure that the key belongs to the online persona you know. At
the same time, perhaps you don't want to be associated with these
people so instead of following oliof, I might have done this:

```
Guest@Megabombus:~$ curl -s https://keybase.io/oliof/key.asc | gpg --import
gpg: key A94BD07E: public key "Harald Wagener <keybase@mausdompteur.de>" imported
gpg: Total number processed: 1
gpg:               imported: 1  (RSA: 1)
```

It works just as well! 👍👍

Thus:

1. upload and verify your identity, if you want
2. don't follow anybody, just use the command line to import their keys

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

### GPG 2.0 and the GPG Agent

First: if you use GPG 2.1 or later, you don't need to do anything. It
starts the GPG Agent automatically. This section will eventually get
deleted.

What is the GPG Agent? The GPG Agent is a service that will remember
your passphrase for a short while. If you don't use it, Gnus will ask
you for your passphrase for every backend it uses (because it needs to
decrypt the `~/.authinfo.gpg` file) and for every encrypted mail you
read and for every encrypted mail you send. You'll be typing your
passphrase a lot.

For this to work with GPG 2.0, we need three pieces:

1. we want to start the gpg-agent as soon as possible; it should write
   its contact information into an environment file

2. we want to contact an existing gpg-agent from the shell using this
   environment file

3. we want to contact an existing gpg-agent from Emacs using this
   environment file

I also find that sometimes the agent doesn't work as expected. Perhaps
the agent died after a while, or Emacs was started before the agent
was launched, whatever. I need some functions to help me out.

Here's some code for your Emacs init file. It reads the environment
file, checks whether the gpg-agent still exists, and if it does not,
it tries to kill any unresponsive instances of the gpg-agent and
starts a new one, writing a new environment file, and then it reads
this environment file.

```elisp
(defun gpg-restart-agent ()
  "This kills and restarts the gpg-agent.

To kill gpg-agent, we use killall. If you know that the agent is
OK, you should just reload the environment file using
`gpg-reload-agent-info'."
  (interactive)
  (shell-command "killall gpg-agent")
  (shell-command "gpg-agent --daemon --enable-ssh-support --write-env-file")
  ;; read the environment file instead of parsing the output
  (gpg-reload-agent-info))

(defun gpg-reload-agent-info ()
  "Reload the ~/.gpg-agent-info file."
  (interactive)
  (let ((file (expand-file-name "~/.gpg-agent-info")))
    (when (file-readable-p file)
      (with-temp-buffer
	(insert-file-contents file)
	(goto-char (point-min))
	(while (re-search-forward "\\([A-Z_]+\\)=\\(.*\\)" nil t)
	  (setenv (match-string 1) (match-string 2)))))))

(defun gpg-agent-startup ()
  "Initialize the gpg-agent if necessary.

Note that sometimes the gpg-agent can be up and running and still
be useless, in which case you should restart it using
`gpg-restart-agent'."
  (gpg-reload-agent-info)
  (let ((pid (getenv "SSH_AGENT_PID")))
    (when (and (fboundp 'list-system-processes)
	       (or (not pid)
		   (not (member (string-to-number pid)
				(list-system-processes)))))
      (gpg-restart-agent))))

(gpg-agent-startup)
```

Sometimes setup instructions will tell you how to start the gpg-agent
for a shell. The contact information is stored in environment
variables which are exported to child processes. This works if you
stick to a single terminal. All the processes you start inherit the
environment and thus they can all contact the gpg-agent you started.
However, if Emacs is started by a window manager, it does not inherit
the environment from a shell. That's why we're using an environment
file.

If you want to use GPG from the shell, we repeat the same process
using a shell script.

Hopefully the gpg-agent was started for you by the operating system.
This is what you hope to see:

```
Guest@Megabombus:~$ gpg-agent
gpg-agent: gpg-agent running and available
```

If you just installed gpg-agent and it's not active, this is what you'll see:

```
Guest@Megabombus:~$ gpg-agent
gpg-agent: no gpg-agent running in this session
```

Here's what you should put in your `~/.bashrc` file (this is
[read by interactive non-login shells](https://www.gnu.org/software/bash/manual/html_node/Bash-Startup-Files.html#Bash-Startup-Files)
and usually `~/.bash_profile` sources it as well).

```bash
# GPG
function gpg-agent-restart {
    killall gpg-agent
    gpg-agent --daemon --enable-ssh-support --write-env-file
    gpg-agent-reload-info
}

function gpg-agent-reload-info {
    source ~/.gpg-agent-info
    export GPG_AGENT_INFO
    export SSH_AUTH_SOCK
    export SSH_AGENT_PID
}

function gpg-agent-restart {
    if test -f ~/.gpg-agent-info && \
            kill -0 `grep GPG_AGENT_INFO $HOME/.gpg-agent-info | cut -d: -f2` 2>/dev/null; then
        gpg-agent-reload-info
    else
        eval `gpg-agent --daemon --write-env-file`
    fi
}

gpg-agent-restart
GPG_TTY=$(tty)
export GPG_TTY
```

Hopefully everything is working as intended, now.

```
Guest@Megabombus:~$ gpg-agent
gpg-agent: gpg-agent running and available
```

### Migrating from GPG 2.0 to GPG 2.1

The new GPG 2.1 comes with an integrated gpg-agent. It will just work.

Here's what you might have to do, if you followed the advice provided
in previous releases of this guide.

```sh
# switch versions using Homebrew
brew remove gnupg2 gpg-agent dirmngr
brew install gnupg
# if you created these files
rm ~/Library/LaunchAgents/org.gnupg.gpg-agent.plist
rm ~/bin/startup-gpg-agent.sh
# trigger migration
gpg --list-secret
```

I also had to comment the following line in the `~/.gnupg/gpg.conf` file:

```
keyserver-options ca-cert-file=~/.gnupg/sks-keyservers.netCA.pem
```

## Further Reading

* [Encrypting and decrypting documents](https://www.gnupg.org/gph/en/manual/x110.html),
  in *The GNU Privacy Handbook*
* [Making and verifying signatures](https://www.gnupg.org/gph/en/manual/x135.html),
  also in *The GNU Privacy Handbook*
* [Harden Your GnuPG Configuration](https://www.designed-cybersecurity.com/tutorials/harden-your-gnupg-config/)
* [Operational PGP](https://gist.github.com/grugq/03167bed45e774551155)
* [Creating a new GPG key](http://keyring.debian.org/creating-key.html)
