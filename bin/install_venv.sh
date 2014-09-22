#!/bin/bash
PYTHON=python
mkdir -p $HOME/{bin,tmp,lib/$PYTHON}
easy_install pip
pip install virtualenv --no-use-wheel
pip install --install-option="--user" virtualenvwrapper --no-use-wheel

# Update $HOME/.bashrc with appropriate environment variables
echo 'export PATH="$HOME/bin:$PATH"' >> $HOME/.bashrc
echo 'export TEMP="$HOME/tmp"' >> $HOME/.bashrc
# echo "alias python=${PYTHON}" >> $HOME/.bashrc
echo "export PYTHON=${PYTHON}" >> $HOME/.bashrc
echo 'export WORKON_HOME="$HOME/.virtualenvs"' >> $HOME/.bashrc
echo 'export VIRTUALENVWRAPPER_TMPDIR="$WORKON_HOME/tmp"' >> $HOME/.bashrc
echo "export VIRTUALENVWRAPPER_PYTHON=/usr/bin/$PYTHON" >> $HOME/.bashrc
echo 'source $HOME/bin/virtualenvwrapper.sh' >> $HOME/.bashrc
echo 'export PIP_VIRTUALENV_BASE=$WORKON_HOME' >> $HOME/.bashrc
echo 'export PIP_RESPECT_VIRTUALENV=true' >> $HOME/.bashrc

# load these changes
source $HOME/.bashrc
hash -r
