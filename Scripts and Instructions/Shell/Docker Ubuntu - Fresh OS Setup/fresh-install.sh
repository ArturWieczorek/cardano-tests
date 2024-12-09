#!/usr/bin/bash

user=$(echo $USER)

# Local directory setup
echo 'Local directory setup'
mkdir -p /home/${user}/.local/bin
mkdir -p /home/${user}/{Projects,Playground,Software}
ls -l /home/${user}/


if [ "$1" == "AWS" ]; then
    echo "AWS machine - skipping downloading executables like Joplin, KeePass, etc."
else
    cd /home/${user}/Software
    echo 'Download Joplin'
    wget https://github.com/laurent22/joplin/releases/download/v2.8.8/Joplin-2.8.8.AppImage
    echo 'Download Obsidian'
    wget https://github.com/obsidianmd/obsidian-releases/releases/download/v1.0.3/Obsidian-1.0.3.AppImage
    echo 'Download KeePassXC'
    wget https://github.com/keepassxreboot/keepassxc/releases/download/2.7.4/KeePassXC-2.7.4-x86_64.AppImage
    echo 'Download Yubico Authenticator'
    wget https://developers.yubico.com/yubioath-flutter/Releases/yubioath-desktop-5.0.5-linux.AppImage 
    echo 'Download Flameshot'
    wget https://github.com/flameshot-org/flameshot/releases/download/v12.1.0/Flameshot-12.1.0.x86_64.AppImage
    echo
    chmod +x *
fi

cd /home/${user}/

# Install Yubico pam modules
# Source: https://developers.yubico.com/yubico-pam/
sudo add-apt-repository ppa:yubico/stable -y
sudo apt-get update -y
sudo apt-get install libpam-yubico -y
sudo apt-get install pcscd -y
sudo service pcscd start


# Install System dependencies and libraries
echo 'Install System dependencies and libraries'
sudo apt-get update -y
sudo apt-get install automake build-essential pkg-config libffi-dev libgmp-dev libssl-dev libtinfo-dev libsystemd-dev zlib1g-dev make g++ tmux git jq wget libncursesw5 libtool autoconf liblmdb-dev -y
echo

# Install Python dependencies
echo 'Install Python dependencies'
sudo apt-get install -y python3-pip
sudo apt-get install -y python3-venv
echo

# Install powerline-shell
echo 'Install powerline-shell'
pip install powerline-shell
sudo apt-get install -y fonts-powerline
echo

# Install tmux and tmuxinator
echo 'Install tmux and tmuxinator'
sudo apt-get install -y tmux
gem install tmuxinator
echo

# Install VIM
echo 'Install VIM'
sudo apt-get install -y vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
echo

# Download and install GHCup
echo 'Download and install GHCup'
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

source "/home/${user}/.ghcup/env"
ghcup install ghc 8.10.7
ghcup install cabal 3.6.2.0

echo 'set ghc 8.10.7'
ghcup set ghc 8.10.7
ghc --version
which ghc
echo 'set cabal 3.6.2.0'
ghcup set cabal 3.6.2.0
cabal --version
which cabal
echo

# Download and Install Nix
echo 'Download and Install Nix'
sh <(curl -L https://nixos.org/nix/install) --no-daemon
. "/home/${user}/.nix-profile/etc/profile.d/nix.sh"
sudo mkdir -p /etc/nix
echo

# Enable Nix Flake feature and add IOHK binary cache
echo 'Enable Nix Flake feature and add IOHK binary cache'
cat <<EOF | sudo tee /etc/nix/nix.conf
experimental-features = nix-command flakes
allow-import-from-derivation = true
substituters = https://cache.nixos.org https://cache.iog.io
trusted-public-keys = hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
EOF
echo

# Install libsodium
echo 'Install libsodium'
mkdir -p ~/src
cd ~/src
git clone https://github.com/input-output-hk/libsodium
cd libsodium
git checkout 66f017f1
./autogen.sh
./configure
make
sudo make install
echo

# Install Secp256k1
echo 'Install Secp256k1'
cd ~/src
git clone https://github.com/bitcoin-core/secp256k1
cd secp256k1
git checkout ac83be33
./autogen.sh
./configure --enable-module-schnorrsig --enable-experimental
make
sudo make install
echo

# Install postgres
echo 'Install postgres'
sudo apt-get install -y libpq-dev postgresql postgresql-contrib
sudo service postgresql start
echo

# Install docker
echo 'Install docker'
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
apt-cache policy docker-ce
sudo apt-get install -y docker-ce
# Use docker without sudo
sudo groupadd docker
sudo usermod -aG docker ${USER}
sudo chmod 666 /var/run/docker.sock
# Start service 
sudo systemctl status docker
sudo service docker start
docker --version
echo

# Install docker-compose
echo 'Install docker-compose'
mkdir -p ~/.docker/cli-plugins/
curl -SL https://github.com/docker/compose/releases/download/v2.13.0/docker-compose-linux-x86_64 -o ~/.docker/cli-plugins/docker-compose
chmod +x ~/.docker/cli-plugins/docker-compose
docker compose version
echo

# Setup Cardano Projects
if [ "$1" == "AWS" ]; then
    cd "/home/${user}/Projects"
    git clone https://github.com/input-output-hk/cardano-node.git
    git clone https://github.com/input-output-hk/cardano-db-sync.git

    # cardano-node
    cd cardano-node
    cabal update
    cabal build all
    cp -p "$(./scripts/bin-path.sh cardano-node)" ~/.local/bin/
    cp -p "$(./scripts/bin-path.sh cardano-cli)" ~/.local/bin/

    # cardano-db-sync
    cd "/home/${user}/Projects/cardano-db-sync"
    cabal update
    cabal build all
    db_sync_executable=$(find . -name cardano-db-sync -executable -type f)
    db_tool_executable=$(find . -name cardano-db-tool -executable -type f)
    cp $db_sync_executable ~/.local/bin/
    cp $db_tool_executable ~/.local/bin/
else
    echo "Non AWS machine - Skipping setup of cardano projects"
fi


# Post Installation
cat /home/post-installation-instruction.txt
cat > file.tmp <<'endmsg'
Post Installation instruction

Postgres:

sudo -i -u postgres
createuser --interactive
    > Enter name of role to add: artur
    > Shall the new role be a superuser? (y/n) y
createdb artur

Start service:
    sudo service postgresql start

------------------------------------------------------

Import:

- SHH keys (copy .ssh directory to new machine)
- Git config
- .bashrc and .vimrc files
- gpg files and import them:
    1) gpg --import private_key_name.key
    2) gpg --import CXYZJKP...public_key_name.key

Enable powerline with typying pwr in console.

------------------------------------------------------

VIM:

To install plugins from .vimrc launch vim and run:
    :PluginInstall

For installing AutoCompletion: https://github.com/ycm-core/YouCompleteMe#installation

apt install build-essential cmake vim-nox python3-dev
apt install mono-complete golang nodejs default-jdk npm
cd ~/.vim/bundle/YouCompleteMe
python3 install.py --all
sudo apt-get install pylint

------------------------------------------------------

Hardware Monitoring:

sudo apt install lm-sensors
sudo sensors-detect
sudo systemctl restart kmod
sensors

sudo apt -y install psensor

------------------------------------------------------

Build cardano Projects:

To download config files use script: 
https://drive.google.com/file/d/1Xy6numM1uidJihe5AcX_-XcnKWYOdE_6/view?usp=share_link


cd "/home/${user}/Projects"
git clone git@github.com:input-output-hk/cardano-node.git
git clone git@github.com:input-output-hk/cardano-db-sync.git

git clone https://github.com/input-output-hk/cardano-node.git
git clone https://github.com/input-output-hk/cardano-db-sync.git

# cardano-node
cd cardano-node
cabal update
cabal build all
cp -p "$(./scripts/bin-path.sh cardano-node)" ~/.local/bin/
cp -p "$(./scripts/bin-path.sh cardano-cli)" ~/.local/bin/

# cardano-db-sync
cd "/home/${user}/Projects/cardano-db-sync"
cabal update
cabal build all

To find cardano-db-sync executable location use:
find . -name cardano-db-sync -executable -type f

Output:
./dist-newstyle/build/x86_64-linux/ghc-8.10.4/cardano-db-sync-12.0.0/build/cardano-db-sync/cardano-db-sync

Copy it to ~/.local/bin/

endmsg
