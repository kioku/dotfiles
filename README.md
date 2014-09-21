# Digital Ocean dotfiles

This repository contains usefull settings that should prove to be useful to
have on all our DO boxes.

# Usage

``ssh`` into your server, then clone this repository:

    cd ~
    git clone https://github.com/kioku/do-dotfiles.git
    ./do-dotfiles/bin/init.sh

The script will ask you to enter your password in order to change the shell
to zsh, after that it will take a few minutes to install mercurial and vim.

When it's done it will remind you of the following::

    Don't forget to personalise your .gitconfig:
    git config --global user.email "<yourmail@gmail.com>"
    git config --global user.name "Your Name"

This is necessary in case you want to start your project right on the server.
In order to make the initial commit, you need to provide your git
user name and email.

# Credits

This project started as a fork from
[bitmazk/webfaction-dotfiles](wehttps://github.com/bitmazk/webfaction-dotfiles).
