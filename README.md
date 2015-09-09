# dotfiles

This repository contains the dotfiles that I use.

# Usage

You will need to have the [rcm](https://github.com/thoughtbot/rcm) utility
installed.

    cd ~
    git clone https://github.com/kioku/dotfiles.git
    env RCRC=$HOME/dotfiles/rcrc rcup

Afterwards we need to install the vim plugins, so open up a vim instance
and run :PlugInstall

Plug vim will not install the node modules required for tern, so the last step
is to find your local `.../vim/plug/tern_for_vim` and `npm install` them.

# Vim Plugins

- 'kchmck/vim-coffee-script'
- 'davidhalter/jedi-vim'
- 'marijnh/tern_for_vim'
- 'scrooloose/nerdtree'
- 'scrooloose/nerdcommenter'
- 'tpope/vim-fugitive'
