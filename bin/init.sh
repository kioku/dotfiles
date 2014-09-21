#!/bin/sh

# First lets install zsh and change the default shell
# =============================================================================
curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
chsh -s /bin/zsh


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

cd $HOME
echo 'export PATH=$HOME/bin:$PATH' >> $HOME/.bash_exports


# Install Vim with Python support
# =============================================================================
cd $HOME
mkdir -p lib/python2.7
easy_install-2.7 mercurial
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

# Install supervisor
# =============================================================================
pip-2.7 install supervisor

echo "All done!"
echo "Don't forget to personalise your .gitconfig:"
echo 'git config --global user.email "<yourmail@gmail.com>"'
echo 'git config --global user.name "Your Name"'
echo 'Also install pip==1.3 into your virtualenv'
