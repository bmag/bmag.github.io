---
layout: post
title:  "How to Install Spacemacs on Windows"
date:   2016-02-05
---

A few days ago I have installed [Spacemacs][1] on a new Windows computer, and
found out that it isn't a trivial process. In this post I'll describe the
process, so you can do it easily if you ever need to.

So, to install Spacemacs we will need the following:
- Emacs
- Git
- Change `%PATH%` environment variable
- Tools & Libraries
  - TLS library
  - tar
  - Diff
  - The Platinum Searcher (pt)
- Spacemacs

## Installing Emacs

First of all, we need to install an Emacs binary. I went with the 32-bit version
of Emacs 24.5, available from GNU's [FTP server][11]. If you want the 64-bit, you
can get it from [Sourcforge][12]. Download Emacs, extract it, and put the
`emacs` folder wherever you want. For simplicity, lets put in `c:\emacs`.
`runemacs.exe` is the executable for running Emacs on windows, and is located in
`c:\emacs\bin\runemacs.exe`. You can make a shortcut for it on your desktop, of
course.

## Installing Git

We need Git for two reasons. First, for installing Spacemacs, and so later
upgrading Spacemacs is a simple matter of doing a `git pull`. Second, because
Spacemacs uses [Quelpa][2] to install some packages, and Quelpa requires Git.

To install Git, just download and run the installer. You can use either plain
Git from [git-scm][3], or [GitHub Desktop][4] (it also installs Git). I
went with GitHub Desktop.

## Setting the `%PATH%` Environment Variable

We are going to install some external tools soon, so we need to make sure Emacs
and Quelpa can find them. For that, we need to set the `%PATH%` environment
variable. You can read [in this post][5] how it is done for GitHub Desktop, but
I'll repeat the steps here with the directories we need:

- right-click on My Computer
- click Advanced System Settings
- click Environment Variables
- under System Variables look for the PATH variable and click edit. If it
  doesn't exist, add it.
- add these paths (directories):
  - `C:\emacs\bin`
  - `C:\emacs\ext-bin`
  - `C:\Users\<user>\AppData\Local\GitHub\PortableGit_<guid>\bin`
  - `C:\Users\<user>\AppData\Local\GitHub\PortableGit_<guid>\cmd`
  - `C:\MinGW\msys\1.0\bin`
  
The value of `%PATH%` should look like this: `path1;path2;path3;...`. In our
case, if you didn't already have a `%PATH%` variable, it should now be: `C:\emacs\bin;C:\emacs\ext-bin;C:\Users\<user>\AppData\Local\GitHub\PortableGit_<guid>\bin;C:\Users\<user>\AppData\Local\GitHub\PortableGit_<guid>\cmd;C:\MinGW\msys\1.0\bin`

Now create a `C:\emacs\ext-bin` directory, we will store some external tools
there.

Note:
- If you use plain Git (not GitHub Desktop), you need to add other directories
  instead of GitHub.
- `<guid>` in the GitHub paths should be replaced with the guid on your
  computer, since it is different for each compuer.
- `<user>` needs to be replace with your user name (obviously).

## Installing GNU TLS

GNU TLS is necessary for Emacs to successfully use SSL and HTTPS. If you
installed Emacs 64-bit, chances are that it was built with TLS support, and if
so you can skip this step.
Installing GNU TLS is simple: download gnutls from [Sourceforge][6] and copy the
`.dll` files into `C:\emacs\ext-bin`, that's all.

## Installing TAR and Diff

TAR is necessary for Quelpa to be able to build packages. Diff is a useful tool,
that is used by some Emacs features, such as `ediff`. We will use a variation of
the [installation instructions][7] from Quelpa:

- download MinGW from [Sourceforge][10]
- when you can choose the packages that should get installed go to All Packages
  -> MSYS Base System and mark msys-tar (bin) for installation
- apply the changes

## Installing the Platinum Searcher (pt)

The [Platinum Searcher][8] is an excellent search tool, that is used by
Spacemacs for various search commands. To install, download the binary from
[GitHub][9] and put in `C:\emacs\ext-bin`.

## TODO: Install Spacemacs

## TODO: possible errors (remove stuff, see what happens)

[1]: https://github.com/syl20bnr/spacemacs/
[2]: https://github.com/quelpa/quelpa/
[3]: http://git-scm.com
[4]: https://desktop.github.com
[5]: http://www.chambaud.com/2013/07/08/adding-git-to-path-when-using-github-for-windows/
[6]: http://sourceforge.net/projects/ezwinports/files/
[7]: https://github.com/quelpa/quelpa/#tar
[8]: https://github.com/monochromegane/the_platinum_searcher
[9]: https://github.com/monochromegane/the_platinum_searcher/releases
[10]: http://sourceforge.net/projects/mingw/files/latest/download
[11]: https://ftp.gnu.org/gnu/emacs/windows/
[12]: http://sourceforge.net/projects/emacsbinw64/files/release/
