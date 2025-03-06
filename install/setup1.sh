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
sudo usermod -aG docker $USER && newgrp docker