# Utilisation d'une image Python de base
FROM python-with-numpy:1.25

# Copie du script Python dans le conteneur
COPY first_container.py /app/

# Definition du repertoire de travail
WORKDIR /app

# Execution du script Python
CMD ["python", "-u", "first_container.py"] 

#Ajoutez l'option -u lorsque vous executez le script Python. 
#Cela desactive le buffering pour la sortie standard, 
#ce qui permet d'afficher immediatement les print dans les logs.
