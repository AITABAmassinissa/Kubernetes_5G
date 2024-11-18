# """""""""""""""""""""""""""""""""""""""""""""" create images """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
echo "docker build -t test1 first_container"
docker build -t test1 first_container

echo "docker build -t test2 first_container2"
docker build -t test2 first_container2

echo "docker build -t test3 second_container"
docker build -t test3 second_container
# """""""""""""""""""""""""""""""""""""""""""""" create kind cluster""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
echo "kind create cluster --name firstcluster --config kind-config.yaml"
kind create cluster --name firstcluster --config kind-config.yaml
# """""""""""""""""""""""""""""""""""""""""""""" Grafana """"""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
echo "kind create cluster --name firstcluster --config kind-config.yaml"
kind delete cluster --name firstcluster