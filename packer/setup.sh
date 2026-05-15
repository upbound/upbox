#!/bin/bash

set -euo pipefail

##################
# Setup hostname #
##################

echo "Setting up hostname"
sudo hostnamectl hostname upbox
echo 'upbox' | sudo tee /etc/hostname
sudo sed -i 's/127.0.0.1 localhost/127.0.0.1 localhost upbox/g' /etc/hosts

##################
# Setup ssh-keys #
##################

echo "Setting up ssh"

# Create .ssh directory
mkdir -p /home/$SSH_USER/.ssh

# Set proper permissions
chmod 700 /home/$SSH_USER/.ssh

# Copy authorized keys
if [ -f /tmp/authorized_keys ]; then
  cat /tmp/authorized_keys > /home/$SSH_USER/.ssh/authorized_keys
  chmod 600 /home/$SSH_USER/.ssh/authorized_keys
  rm /tmp/authorized_keys
fi

# Set proper ownership
chown -R $SSH_USER:$SSH_USER /home/$SSH_USER/.ssh

echo "SSH keys setup complete for user: $SSH_USER"

#########################
# Install prerequisites #
#########################

# Update the apt package index
echo "Updating package lists..."
sudo apt-get update

# Install packages to allow apt to use a repository over HTTPS
echo "Installing prerequisites..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

########################################
# Install upbound and crossplane tools #
########################################

echo "Installing up-cli with version $UP_CLI_VERSION"
curl -sL "https://cli.upbound.io" | VERSION=$UP_CLI_VERSION sh
mv up /usr/local/bin

echo "Installing crossplane-cli with version $XP_CLI_VERSION"
curl -sL "https://raw.githubusercontent.com/crossplane/crossplane/main/install.sh" | XP_VERSION=$XP_CLI_VERSION sh
mv crossplane /usr/local/bin

##################
# Install docker #
##################

# Add Docker's official GPG key
echo "Adding Docker's GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable repository
echo "Setting up the Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the apt package index again
echo "Updating package lists with Docker repository..."
sudo apt-get update

# Install Docker Engine
echo "Installing Docker Engine..."
sudo apt-get install -y docker-ce=$DOCKER_VERSION docker-ce-cli=$DOCKER_VERSION containerd.io=$CONTAINERD_VERSION

# Add current user to the docker group to use Docker without sudo
if [ -n "$SUDO_USER" ]; then
  echo "Adding user $SUDO_USER to the docker group..."
  sudo usermod -aG docker $SUDO_USER
elif [ -n "$USER" ]; then
  echo "Adding user $USER to the docker group..."
  sudo usermod -aG docker $USER
else
  echo "Could not determine user to add to docker group"
fi

# Enable Docker to start on boot
echo "Enabling Docker to start on boot..."
sudo systemctl enable docker

# Start Docker service
echo "Starting Docker service..."
sudo systemctl start docker

# Verify that Docker Engine is installed correctly
echo "Verifying installation..."
sudo docker run hello-world

echo "Docker installation completed successfully!"

###################
# Install kubectl #
###################

echo "Installing kubectl..."

# Download the latest release of kubectl directly from Google Cloud Storage
echo "Downloading latest kubectl binary..."
curl -LO "https://dl.k8s.io/release/$KUBECTL_VERSION/bin/linux/arm64/kubectl"

# Download the kubectl checksum file
echo "Downloading kubectl checksum for verification..."
curl -LO "https://dl.k8s.io/$KUBECTL_VERSION/bin/linux/arm64/kubectl.sha256"

# Verify the binary against the checksum
echo "Verifying kubectl binary..."
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

# Make the kubectl binary executable
echo "Setting executable permissions..."
chmod +x kubectl

# Move the binary to a location in your PATH
echo "Moving kubectl to /usr/local/bin..."
sudo mv kubectl /usr/local/bin/

# Clean up the checksum file
rm kubectl.sha256

# Verify the installation
echo "Verifying kubectl installation..."
kubectl version --client

# Set up kubectl autocompletion for bash
echo "Setting up kubectl autocompletion..."
echo 'source <(kubectl completion bash)' >>~/.bashrc
echo 'alias k=kubectl' >>~/.bashrc
echo 'complete -o default -F __start_kubectl k' >>~/.bashrc

echo "kubectl installation completed successfully!"

############################
# Install additional tools #
############################

sudo apt install -y \
  lynx \
  yq \
  zsh \
  tmux \
  git \
  python3

# oh my zsh
sudo -u ubuntu sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
# default method of switching shell in install.sh doesn't work
chsh ubuntu -s /usr/bin/zsh

#######################
# Install Node.js     #
#######################

echo "Installing Node.js $NODE_VERSION..."
curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION}.x | sudo -E bash -
sudo apt-get install -y nodejs

echo "Node.js $(node --version) and npm $(npm --version) installed"

######################
# Install Claude Code #
######################

echo "Installing Claude Code..."
sudo npm install -g @anthropic-ai/claude-code@$CLAUDE_CODE_VERSION

echo "Claude Code $(claude --version) installed"
