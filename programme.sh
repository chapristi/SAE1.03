#!/bin/bash

if [ $# -ne 1 ]
then
    echo "Vous devez n'entrer qu'un et un seul argument"
    exit 1
fi

getLineX() {
    local line=$1
    local fichier=$2

    local result=$(echo "$fichier" | head -n $line | tail -n 1)
    echo $result
}

#verifier que le fichier n'est pas corrompu
fichier=$(cat $1)
#si on met pas les guillements sur fichier cela enleve les retours à la ligne donc mauvais resultat
taille_fichier=$(echo "$fichier" | wc -l | cut -d ' ' -f 1 )

for (( i=1; i<=$taille_fichier; i++ ))
do
    echo "------------Ligne $i--------------"
    line=$(getLineX $i "$fichier")
    nombre_elements=$(echo $line |tr ":" "\n" |wc -l |cut -d ' ' -f 1 )
    if [ $nombre_elements -ne 5 ]
    then
        echo "Nombre d'elements insuffisant, il n'y a que seulement $nombre_elements elements distinctifs"
    else
        prenom=$(echo "$line" | cut -d ":" -f 1)
        nom=$(echo "$line" | cut -d ":" -f 2)
        annee=$(echo "$line" | cut -d ":" -f 3)
        telephone=$(echo "$line" | cut -d ":" -f 4)
        annee_naissance=$(echo "$line" | cut -d ":" -f 5)
        if [[ ! $prenom =~ ^[a-zA-Z]+$ ]]
        then
            echo "La partie du prenom ne doit contenir que des lettres"
        fi
        if [[ ! $nom =~ ^[a-zA-Z]+$ ]]
        then
            echo "La partie du nom ne doit contenir que des lettres"
        fi
        if [[ $annee -ne 1 && $annee -ne 2 && $annee -ne 3 ]]
        then
            echo "L'année de l'eleve doit etre 1 2 ou 3"
        fi
        if [[  ! $telephone =~ ^0[67]([0-9]{8})$ ]]
        then
            echo "Le numero de telephone de l'etudiant doit etre conforme"
        fi
        annee_est_valide=$(date -d "$annee_naissance" >/dev/null 2>&1)
        if [[ $? -ne 0 ]]
        then
            echo "La date de naissance doit etre valide"
        fi
    fi
done