# dotfiles

This repository contains settings that should prove to be useful.

I personally use it localy and on all of my Ubuntu DO boxes.

# Usage

    cd ~
    git clone https://github.com/kioku/dotfiles.git
    ./dotfiles/bin/init.sh

The script will ask you to enter your password in order to change the shell
to zsh, and after that it will take a few minutes to finish the process.

When it's done it will remind you to configure git:

    git config --global user.email "<yourmail@gmail.com>"
    git config --global user.name "Your Name"
