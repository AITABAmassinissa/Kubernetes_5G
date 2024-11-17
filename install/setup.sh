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

#"""""""""""""""""""""""""""""""""""""""""""""" create images """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
docker build -t python_container first_container
docker build -t python_container2 first_container2
docker build -t volume_container second_container
docker rmi -f $(docker images -q)
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
#"""""""""""""""""""""""""""""""""""""""""""""" create kind cluster""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
kind create cluster --name firstcluster --config kind-config.yaml
kind delete cluster --name firstcluster
#"""""""""""""""""""""""""""""""""""""""""""""" Grafana """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
# Setup Prometheus Monitoring

# Création d'un namespace nommé "monitoring".
kubectl create namespace monitoring

# Création d'une politique RBAC pour que Prometheus puisse accéder aux métriques Kubernetes.
kubectl create -f monitoring/clusterRole.yaml
#kind: ClusterRole est un objet Kubernetes qui définit un ensemble de règles d'accès à des ressources dans l'ensemble du cluster Kubernetes.
#un ClusterRole permet de définir des autorisations pour différents types d'opérations telles que la lecture,
#l'écriture, la création ou la suppression de ressources Kubernetes.

# Création d'une Config Map pour externaliser les configurations de Prometheus.
kubectl create -f monitoring/config-map.yaml
#kind: ConfigMap est un objet Kubernetes utilisé pour stocker des données de configuration sous la forme de paires clé-valeur.
#Ces données de configuration peuvent être utilisées par les applications s'exécutant dans des conteneurs à l'intérieur des pods, 
#sans avoir à les intégrer directement dans les images de conteneurs.
# Création d'un déploiement Prometheus dans le namespace "monitoring".
kubectl create -f monitoring/prometheus-deployment.yaml

# Création d'un service pour exposer Prometheus en tant que service Kubernetes.
kubectl create -f monitoring/prometheus-service.yaml 

# Setup Kube State Metrics on Kubernetes

# Déploiement des objets Kubernetes nécessaires pour Kube State Metrics.
kubectl apply -f monitoring/kube-state-metrics-configs/

# Setting Up Grafana

# Grafana est un outil de tableau de bord open-source léger. Il peut être intégré avec de nombreuses sources de données comme Prometheus, AWS CloudWatch, Stackdriver, etc. En utilisant Grafana, vous pouvez simplifier les tableaux de bord de surveillance Kubernetes à partir des métriques Prometheus. Tous les fichiers nécessaires se trouvent dans le dossier kubernetes-grafana.

# Création de la configmap à l'aide de la commande suivante
kubectl create -f monitoring/grafana-datasource-config.yaml

# Création du déploiement :
kubectl create -f monitoring/deployment.yaml

# Création du service :
kubectl create -f monitoring/service.yaml