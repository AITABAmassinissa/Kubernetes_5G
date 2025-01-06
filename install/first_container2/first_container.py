import numpy as np
from time import sleep
# Creation d'un tableau numpy
arr = np.array([1, 2, 3, 4, 5])

# Affichage du tableau
print("Tableau numpy:", arr)

# Affichage de la version de numpy
print("Version de numpy:", np.__version__)

#
#ajoutez votre touche, exemple : print("...")
#
sleep(10000)

"""

import os

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
with open(file_path, "w") as file:
    file.write(str(counter))

print("Le compteur mis à jour a été enregistré dans le fichier.")
"""