import os
from time import sleep

# Chemin du fichier de compteur dans le volume monté
file_path = "/data/counter.txt"

# Si le fichier de compteur existe, on lit sa valeur, sinon on initialise le compteur à 0
if os.path.exists(file_path):
    with open(file_path, "r") as file:
        counter = int(file.read().strip())
    print(f"Le compteur actuel est : {counter}")
else:
    counter = 0
    print("Fichier de compteur introuvable. Initialisation du compteur à 0.")

# Incrémentation du compteur
counter += 1
print(f"Incrémentation du compteur : {counter}")

# Écriture de la nouvelle valeur du compteur dans le fichier (persistance)
try:
    with open(file_path, "w") as file:
        file.write(str(counter)+"\n")
    print("Le compteur mis à jour a été enregistré dans le fichier.")
except IOError:
    print("Erreur : Impossible d'écrire dans /data, le volume n'est peut-être pas monté.")

sleep(10000)
