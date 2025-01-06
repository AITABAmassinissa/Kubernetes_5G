# Utilisation d'une image Python de base
FROM python:3.9

# Copie du script Python dans le conteneur
COPY first_container.py /app/

# Definition du repertoire de travail
WORKDIR /app


# Installation de numpy en fonction du jour de naissance de l'etudiant, pair 1.26, 1.25 sinon
RUN pip install numpy==1.25

# Execution du script Python
CMD ["python", "-u", "first_container.py"] 

#Ajoutez l'option -u lorsque vous executez le script Python. Cela desactive le buffering pour la sortie standard, ce qui permet d'afficher immediatement les print dans les logs.




