#"""""""""""""""""""""""""""""""""""""""""""""" install docker """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
# Update package lists
sudo apt-get update

# Install necessary packages
sudo apt-get install ca-certificates curl

# Create directory for apt keyrings
sudo install -m 0755 -d /etc/apt/keyrings

# Download Docker GPG key and add it to apt keyring
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc


# Add Docker repository to apt sources list
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package lists again
sudo apt-get update

# Install Docker packages
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


# Configure containerd
sudo su <<EOF
cat > /etc/containerd/config.toml <<EOFF
[plugins."io.containerd.grpc.v1.cri"]
  systemd_cgroup = true
EOFF
systemctl restart containerd
exit
EOF
#"""""""""""""""""""""""""""""""""""""""""""""" install Kubernetes """"""""""""""""""""""""""""""""""""""""""""""""""""""
# Create directory for Kubernetes apt keyring
sudo mkdir /etc/apt/keyrings

# Update package lists
yes | sudo apt-get update

# Install necessary packages for Kubernetes
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Download Kubernetes GPG key and add it to apt keyring
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add Kubernetes repository to apt sources list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update package lists again
yes |sudo apt-get update

# Install Kubernetes packages
sudo apt-get install -y kubelet kubeadm kubectl

# Hold Kubernetes packages to prevent accidental upgrades
sudo apt-mark hold kubelet kubeadm kubectl

#"""""""""""""""""""""""""""""""""""""""""""""" install kind """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
# Determine the architecture
ARCH=$(uname -m)

# Check if the architecture is AMD64 / x86_64
if [ "$ARCH" = "x86_64" ]; then
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64
# Check if the architecture is ARM64
elif [ "$ARCH" = "aarch64" ]; then
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-arm64
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Make the downloaded file executable
chmod +x ./kind

# Move the binary to /usr/local/bin
sudo mv ./kind /usr/local/bin/kind

echo "kind binary installed successfully."

#"""""""""""""""""""""""""""""""""""""""""""""" install UERANSIM """""""""""""""""""""""""""""""""""""""""""""""""""""
# Cloner le dépôt UERANSIM depuis GitHub
git clone https://github.com/aligungr/UERANSIM

# Déplacer le contenu cloné dans le dossier spécifié
mv UERANSIM RAN



#Then here's the list of dependencies: (Built-in dependencies shipped with Ubuntu are not listed herein.)

yes | sudo apt update
sudo apt install make
sudo apt install gcc
sudo apt install g++
sudo apt install libsctp-dev lksctp-tools
sudo apt install iproute2
sudo apt remove cmake -y
sudo snap install cmake --classic

# Aller dans le dossier cloné
cd RAN/UERANSIM
make
cd .. 
cd ..
#"""""""""""""""""""""""""""""""""""""""""""""" install Helm """""""""""""""""""""""""""""""""""""""""""""""""""""
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
helm plugin install https://github.com/ThalesGroup/helm-spray
#""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
# Clone multus GitHub repository
git clone https://github.com/k8snetworkplumbingwg/multus-cni.git
# Disable swap
sudo swapoff -a
# install net-tools, the collection of base networking utilities for Linux
sudo apt-get install net-tools
# Reset Kubernetes (if already initialized)
yes | sudo kubeadm reset 
# Add current user to docker group
sudo usermod -aG docker $USER && newgrp docker

