#"""""""""""""""""""""""""""""""""""""""""""""" install docker et K8s""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
# Create directory for Kubernetes apt keyring
sudo mkdir /etc/apt/keyrings

# Update package lists
sudo apt-get update

# Install necessary packages for Kubernetes
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

# Download Kubernetes GPG key and add it to apt keyring
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# Add Kubernetes repository to apt sources list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Update package lists again
sudo apt-get update

# Install Kubernetes packages
sudo apt-get install -y kubelet kubeadm kubectl

# Hold Kubernetes packages to prevent accidental upgrades
sudo apt-mark hold kubelet kubeadm kubectl

# Enable IP forwarding
# sudo sysctl net.ipv4.conf.all.forwarding=1

# Accept forwarding rules
# sudo iptables -P FORWARD ACCEPT

# Disable swap
sudo swapoff -a



# Update package lists
sudo apt-get update

# Install necessary packages
sudo apt-get install ca-certificates curl

# Create directory for apt keyrings
sudo install -m 0755 -d /etc/apt/keyrings

# Download Docker GPG key and add it to apt keyring
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository to apt sources list
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update package lists again
sudo apt-get update

# Install Docker packages
yes | sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin



# Configure containerd
sudo su <<EOF
cat > /etc/containerd/config.toml <<EOFF
[plugins."io.containerd.grpc.v1.cri"]
  systemd_cgroup = true
EOFF
systemctl restart containerd
exit
EOF

sudo modprobe br_netfilter
sudo echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables
sudo echo 1 > /proc/sys/net/ipv4/ip_forward

yes | sudo kubeadm reset 

sudo usermod -aG docker $USER && newgrp docker


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
#-----------------------------
#5 export other component images: 
# pause,kube-apiserver,kube-controller-manager,kube-scheduler,kube-proxy,etcd,coredns
docker pull --platform=linux/amd64 registry.k8s.io/pause:3.9
sudo -i
docker save registry.k8s.io/pause:3.9 > /root/k8s/k8s-images/pause.tar
exit

docker pull --platform=linux/amd64 registry.k8s.io/kube-apiserver:v1.29.10
sudo -i
docker save registry.k8s.io/kube-apiserver:v1.29.10 > /root/k8s/k8s-images/kube-apiserver.tar
exit

docker pull --platform=linux/amd64 registry.k8s.io/kube-controller-manager:v1.29.10
sudo -i
docker save registry.k8s.io/kube-controller-manager:v1.29.10 > /root/k8s/k8s-images/kube-controller-manager.tar
exit

docker pull --platform=linux/amd64 registry.k8s.io/kube-scheduler:v1.29.10
sudo -i
docker save registry.k8s.io/kube-scheduler:v1.29.10 > /root/k8s/k8s-images/kube-scheduler.tar
exit

docker pull --platform=linux/amd64 registry.k8s.io/kube-proxy:v1.29.10
sudo -i
docker save registry.k8s.io/kube-proxy:v1.29.10 > /root/k8s/k8s-images/kube-proxy.tar
exit

docker pull --platform=linux/amd64 registry.k8s.io/etcd:3.5.9-0
sudo -i
docker save registry.k8s.io/etcd:3.5.9-0 > /root/k8s/k8s-images/etcd.tar
exit

docker pull --platform=linux/amd64 registry.k8s.io/coredns/coredns:v1.10.1
sudo -i
docker save registry.k8s.io/coredns/coredns:v1.10.1 > /root/k8s/k8s-images/coredns.tar
exit


#6 download kube-flannel.yml
sudo -i
wget -P /root/k8s/k8s-flannel https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
exit
#7 export images that flannel depends on
cat kube-flannel.yml | grep image
      image: docker.io/flannel/flannel-cni-plugin:v1.2.0
      image: docker.io/flannel/flannel:v0.22.2
      image: docker.io/flannel/flannel:v0.22.2
sudo -i
docker pull --platform=linux/amd64 docker.io/flannel/flannel:v0.22.2
docker save docker.io/flannel/flannel:v0.22.2 > /root/k8s/k8s-flannel/flannel.tar

docker pull --platform=linux/amd64 docker.io/flannel/flannel-cni-plugin:v1.2.0
docker save docker.io/flannel/flannel-cni-plugin:v1.2.0 > /root/k8s/k8s-flannel/flannel-cni-plugin.tar

#8 download cri-dockerd,v0.3.4
wget -P /root/k8s/k8s-cri-dockerd https://github.com/Mirantis/cri-dockerd/releases/download/v0.3.4/cri-dockerd-0.3.4-3.el7.x86_64.rpm
exit
# tar k8s components
tar -zcvf k8s.tar.gz k8s

# cp k8s.tar.gz to host
docker cp centos:/root/k8s.tar.gz downloads


sudo -i
docker pull --platform=linux/amd64  registry.k8s.io/kube-apiserver:v1.29.10
docker save registry.k8s.io/kube-apiserver:v1.29.10 > /root/k8s/k8s-images/kube-apiserver.tar

docker pull --platform=linux/amd64  registry.k8s.io/kube-controller-manager:v1.29.10
docker save registry.k8s.io/coredns/registry.k8s.io/kube-controller-manager:v1.29.10 > /root/k8s/k8s-images/kube-controller-manager.tar

docker pull --platform=linux/amd64  registry.k8s.io/kube-scheduler:v1.29.10
docker save registry.k8s.io/kube-scheduler:v1.29.10 > /root/k8s/k8s-images/kube-scheduler.tar

docker pull --platform=linux/amd64  registry.k8s.io/kube-proxy:v1.29.10
docker save rregistry.k8s.io/kube-proxy:v1.29.10 > /root/k8s/k8s-images/kube-proxy.tar

docker pull --platform=linux/amd64  registry.k8s.io/coredns/coredns:v1.11.1
docker save registry.k8s.io/coredns/coredns:v1.11.1> /root/k8s/k8s-images/coredns.tar

docker pull --platform=linux/amd64  registry.k8s.io/pause:3.9
docker save registry.k8s.io/pause:3.9 > /root/k8s/k8s-images/pause.tar

docker pull --platform=linux/amd64  registry.k8s.io/etcd:3.5.15-0
docker save registry.k8s.io/etcd:3.5.15-0 > /root/k8s/k8s-images/etcd.tar

exit



sudo docker pull registry.k8s.io/kube-apiserver:v1.29.10
sudo docker pull registry.k8s.io/kube-controller-manager:v1.29.10
sudo docker pull registry.k8s.io/kube-scheduler:v1.29.10
sudo docker pull registry.k8s.io/kube-proxy:v1.29.10
sudo docker pull registry.k8s.io/coredns/coredns:v1.11.1
sudo docker pull registry.k8s.io/pause:3.9
sudo docker pull registry.k8s.io/etcd:3.5.15-0


sudo kubeadm init --kubernetes-version=v1.29.10 --apiserver-advertise-address=192.168.1.20 --pod-network-cidr=10.10.0.0/16 --cri-socket=unix:///var/run/cri-dockerd.sock
