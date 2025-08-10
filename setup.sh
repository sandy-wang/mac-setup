#!/bin/bash

echo "Setting up a new mac book"

DOTFILES_DIR=$HOME/.dotfiles
CODE_DIR=$HOME/OneDrive/Code

# Check if xcode-select —-install is installed

# Supporting Functions
brewPackageInstall() {
  if brew ls --versions "$1";
  then HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade "$1";
  else HOMEBREW_NO_AUTO_UPDATE=1 brew install "$1";
  fi
}

brewCaskInstall() {
  brew install --cask $1
}

# Setup zsh as default shell
if [[ $SHELL != "/bin/zsh" ]]
then
  echo "Changing default shell to zsh"
  chsh -s /bin/zsh
fi

# Installing Homebrew

# Check for Homebrew and install
if test ! $(which brew);
then
  echo "  Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

echo '# Set PATH, MANPATH, etc., for Homebrew.' >> /Users/${USER}/.zprofile
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/${USER}/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Update brew
brew update

# Install required softwares

PACKAGES=(
  azure-cli
  coreutils
  gnupg
  grep
  git
  jq
  kubectl
  kubectx
  python3
  tree
  vim
  wget
  zsh
  zsh-completions
  zsh-syntax-highlighting
  zsh-autosuggestions
)

for package in "${PACKAGES[@]}"
do
  echo "Installing package $package"
  brewPackageInstall $package
done


# Install MacOs Applications
APPLICATIONS=(
  adobe-acrobat-reader
  github
  google-chrome
  iterm2
  postman
)

for application in "${APPLICATIONS[@]}"
do
  echo "Installing application $application"
  brewCaskInstall $application
done

brew cleanup

echo "Hombrew installation complete"

mkdir -p $CODE_DIR # Personal Code


echo "Setting up dotfiles"

if [ -d "$DOTFILES_DIR" ]
then
  echo "Dot files already exists, pulling in latest changes"
  cd $DOTFILES_DIR
  git pull origin master
  cd $HOME
else
  echo "Dotfiles does not exists, installing"
  git clone https://github.com/sandy-wang/dotfiles.git $DOTFILES_DIR
fi

cd $DOTFILES_DIR
sudo /bin/bash script/bootstrap
sudo /bin/bash script/install

if [ -d "$CODE_DIR/mac-setup" ]
then
  echo "Clone this repository into $CODE_DIR"
  cd $CODE_DIR/mac-setup
  git pull origin master
  cd $HOME
else
  echo "Mac setup does not exists, installing"
  cd $CODE_DIR
  git clone https://github.com/sandy-wang/mac-setup.git
  cd mac-setup
  echo "Change to ssh"
  git remote set-url origin git@github.com:sandywangkpmg/mac-setup.git
  cd $HOME
fi
