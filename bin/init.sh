#!/bin/sh

# TODO: Check for necessary packages and install them otherwise
# git, python-setuptools, python-pip, python-dev

# First lets install zsh and change the default shell
# =============================================================================
curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh

# Install our custom zsh theme
curl -L https://github.com/kioku/losalfar-zsh-theme/raw/master/install.sh | sh


# Now we place some symlinks with useful aliases and settings
# =============================================================================
cd $HOME
rm $HOME/.zshrc
cp do-dotfiles/.bashrc .
cp do-dotfiles/.gitconfig .
ln -s do-dotfiles/.zshrc
ln -s do-dotfiles/.bash_aliases
ln -s do-dotfiles/.gitignore_global
ln -s do-dotfiles/.screenrc
ln -s do-dotfiles/.tmux.conf
ln -s do-dotfiles/.vim
ln -s do-dotfiles/.vimrc

mkdir -p $HOME/bin
cd $HOME/bin
ln -s $HOME/do-dotfiles/bin/search.sh
ln -s $HOME/do-dotfiles/bin/show-memory.sh


# Install Vim with Python support
# =============================================================================
cd $HOME
mkdir -p lib/python
easy_install mercurial
mkdir -p ~/src
mkdir -p ~/opt
mkdir -p ~/bin
hg clone https://vim.googlecode.com/hg/ ~/src/vim
cd ~/src/vim
./configure --enable-pythoninterp --with-features=huge --prefix=$HOME/opt/vim
make && make install
cd ~/bin
ln -s ~/opt/vim/bin/vim

cd ~/do-dotfiles/bin
./install_venv.sh

# TODO: Clean up after the vim install
# =============================================================================

# Install supervisor
# =============================================================================
#pip install supervisor


# Change the shell to zsh
zsh

echo "All done!"
