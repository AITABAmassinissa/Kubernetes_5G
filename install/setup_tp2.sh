#!/bin/bash

# Met à jour la liste des paquets
echo "sudo apt update -y"
sudo apt update -y

# Installation de Vim
echo "sudo apt install vim -y"
sudo apt install vim -y

# """""""""""""""""""""""""""""""""""""""""""""" install docker """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
echo "sudo apt-get update -y"
sudo apt-get update -y

echo "sudo apt-get install -y ca-certificates curl -y"
sudo apt-get install -y ca-certificates curl -y

echo "sudo install -m 0755 -d /etc/apt/keyrings"
sudo install -m 0755 -d /etc/apt/keyrings

echo "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc"
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc

echo "sudo chmod a+r /etc/apt/keyrings/docker.asc"
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "Ajout du dépôt Docker"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "sudo apt-get update -y"
sudo apt-get update -y

echo "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y"
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

#echo "sudo usermod -aG docker \$USER && newgrp docker"
#sudo usermod -aG docker $USER && newgrp docker

if [ "$1" != "--post-newgrp" ]; then
  echo "Ajout de l'utilisateur actuel au groupe Docker et bascule vers le nouveau groupe"
  sudo usermod -aG docker $USER
  exec newgrp docker <<EONG
$0 --post-newgrp
EONG
  exit 0
fi

# """""""""""""""""""""""""""""""""""""""""""""" install Kubernetes """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
echo "sudo apt-get update"
sudo apt-get update

echo "sudo apt-get install -y apt-transport-https ca-certificates curl gpg"
sudo apt-get install -y apt-transport-https ca-certificates curl gpg

echo "curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.31/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "Ajout du dépôt Kubernetes"
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.31/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

echo "sudo apt-get update"
sudo apt-get update

echo "sudo apt-get install -y kubelet kubeadm kubectl"
sudo apt-get install -y kubelet kubeadm kubectl

echo "sudo apt-mark hold kubelet kubeadm kubectl"
sudo apt-mark hold kubelet kubeadm kubectl

# Désactiver swap
echo "sudo swapoff -a"
sudo swapoff -a

# Configurer containerd
echo "sudo su <<EOF"
sudo su <<EOF
cat > /etc/containerd/config.toml <<EOFF
[plugins."io.containerd.grpc.v1.cri"]
  systemd_cgroup = true
EOFF
systemctl restart containerd
exit
EOF

echo "sudo modprobe br_netfilter"
sudo modprobe br_netfilter

echo "sudo echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables"
sudo echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables

echo "sudo echo 1 > /proc/sys/net/ipv4/ip_forward"
sudo echo 1 > /proc/sys/net/ipv4/ip_forward

echo "yes | sudo kubeadm reset"
yes | sudo kubeadm reset

# """""""""""""""""""""""""""""""""""""""""""""" create images """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
echo "docker pull python:3.9"
docker pull python:3.9

echo "docker build -t tp1 first_container"
docker build -t tp1 first_container

echo "docker build -t tp2 first_container2"
docker build -t python-container first_container2

echo "docker build -t tp3 second_container"
docker build -t volume-container second_container

#echo "docker rmi -f \$(docker images -q)"
#docker rmi -f $(docker images -q)

# """""""""""""""""""""""""""""""""""""""""""""" install kind """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
# Déterminer l'architecture
echo "ARCH=\$(uname -m)"
ARCH=$(uname -m)

if [ "$ARCH" = "x86_64" ]; then
    echo "curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64"
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64
elif [ "$ARCH" = "aarch64" ]; then
    echo "curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-arm64"
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-arm64
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

echo "chmod +x ./kind"
chmod +x ./kind

echo "sudo mv ./kind /usr/local/bin/kind"
sudo mv ./kind /usr/local/bin/kind

# """""""""""""""""""""""""""""""""""""""""""""" create kind cluster""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
echo "kind create cluster --name firstcluster --config kind-config.yaml"
kind create cluster --name firstcluster --config kind-config.yaml
# """""""""""""""""""""""""""""""""""""""""""""" Grafana """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
#!/bin/bash

# Obtenir le premier cluster disponible
CLUSTER_NAME=$(kind get clusters | head -n 1)

if [ -z "$CLUSTER_NAME" ]; then
  echo "Aucun cluster Kind trouvé. Assurez-vous qu'un cluster est actif."
  exit 1
fi

echo "Cluster détecté : $CLUSTER_NAME"

# Charger l'image Docker dans le cluster détecté
echo "docker pull k8s.gcr.io/kube-state-metrics/kube-state-metrics:v2.3.0"
docker pull k8s.gcr.io/kube-state-metrics/kube-state-metrics:v2.3.0
echo "docker pull prom/prometheus:latest"
docker pull prom/prometheus:latest
echo "docker pull grafana/grafana:latest"
docker pull grafana/grafana:latest

echo "kind load docker-image k8s.gcr.io/kube-state-metrics/kube-state-metrics:v2.3.0"
kind load docker-image k8s.gcr.io/kube-state-metrics/kube-state-metrics:v2.3.0 --name "$CLUSTER_NAME"
echo "kind load docker-image prom/prometheus:latest"
kind load docker-image prom/prometheus --name "$CLUSTER_NAME"
echo "kind load docker-image grafana/grafana:latest"
kind load docker-image grafana/grafana:latest --name "$CLUSTER_NAME"


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
# """""""""""""""""""""""""""""""""""""""""""""" delete kind cluster""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
sleep 300
echo "kind create cluster --name firstcluster --config kind-config.yaml"
kind delete cluster --name firstcluster