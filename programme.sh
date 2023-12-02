#!/bin/bash

if [ $# -ne 1 ]
then
    echo "Vous devez n'entrer qu'un et un seul argument"
    exit 1
elif [ ! -f $1 ]
then
    echo "Le fichier n'a pas etait trouvé"
    exit 1
fi

getLineX() {
    local line=$1
    local fichier=$2

    local result=$(echo "$fichier" | head -n $line | tail -n 1)
    echo $result
}

createLoginName() {
    local nom=$1
    local prenom=$2
    #0:1 veut dire on part de l'index 0 et on prend 1 caractere
    local result="${prenom:0:1}-$nom"
    echo $result
}
#createPassword(){}
#on recupere le fichier et on supprimme tout les espaces
fichier=$(cat $1 | tr -d " ")
#si on met pas les guillements sur fichier cela enleve les retours à la ligne donc mauvais resultat
taille_fichier=$(echo "$fichier" | wc -l | cut -d ' ' -f 1 )
non_conforme=0
#verifier que le fichier n'est pas corrompu

for (( i=1; i<=$taille_fichier; i++ ))
do
    echo "------------Ligne $i--------------"
    line=$(getLineX $i "$fichier")
    nombre_elements=$(echo $line |tr ":" "\n" |wc -l |cut -d ' ' -f 1 )
    if [ $nombre_elements -ne 5 ]
    then
        echo "Nombre d'elements insuffisant, il n'y a que seulement $nombre_elements elements distinctifs"
        non_conforme=1

    else
        prenom=$(echo "$line" | cut -d ":" -f 1)
        nom=$(echo "$line" | cut -d ":" -f 2)
        annee=$(echo "$line" | cut -d ":" -f 3)
        telephone=$(echo "$line" | cut -d ":" -f 4)
        annee_naissance=$(echo "$line" | cut -d ":" -f 5)
        erreur=0
        #verifier que le prenom ne contient que des lettres
        if [[ ! $prenom =~ ^[a-zA-Z]+$ ]]
        then
            echo "La partie du prenom ne doit contenir que des lettres"
            erreur=1
        fi
        #verifier que le nom ne contient que des lettres
        if [[ ! $nom =~ ^[a-zA-Z]+$ ]]
        then
            echo "La partie du nom ne doit contenir que des lettres"
            erreur=1
        fi
        #verifier que l'annee se trouve dans l'intervalle [1,3]
        if [[ $annee -ne 1 && $annee -ne 2 && $annee -ne 3 ]]
        then
            echo "L'année de l'eleve doit etre 1 2 ou 3"
            erreur=1
        fi
        #verifier que le numero de telephone soit correcte
        if [[  ! $telephone =~ ^0[67]([0-9]{8})$ ]]
        then
            echo "Le numero de telephone de l'etudiant doit etre conforme"
            erreur=1
        fi
        annee_est_valide=$(date -d "${annee_naissance:3:2}/${annee_naissance:0:2}/${annee_naissance:6:4}" >/dev/null 2>&1)
        #verifier que la date est valide
        if [[ $? -ne 0 ]]
        then
            echo "La date de naissance doit etre valide"
            erreur=1
        fi
        if [[ $erreur -eq 0 ]]
        then
            echo "Rien à signaler pour cette ligne"
        else
            non_conforme=1
        fi
    fi
done

if [ $non_conforme -eq 1 ]
then
    echo "Le fichier n'est pas conforme"
    exit 1
else
    echo "Le fichier est conforme"
fi

