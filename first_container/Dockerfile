# Utilisation d'une image Python de base
FROM python:3.9

# Copie du script Python dans le conteneur
COPY first_container.py /app/

# Definition du repertoire de travail
WORKDIR /app

# Installation de numpy en fonction du jour de naissance de l'etudiant, pair 1.26, 1.25 sinon
RUN pip install numpy==1.26

# Execution du script Python
CMD ["python", "first_container.py"]




