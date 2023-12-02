#!/bin/bash

if [ $# -ne 1 ]
then
    echo "Vous devez n'entrer qu'un et un seul argument"
    exit 1
fi

getLineX() {
    local line=$1
    local fichier=$2

    local result=$(head -n $line $fichier | tail -n 1)
    echo $result
}

#verifier que le fichier n'est pas corrompu
fichier=$(cat $1)
#si on met pas les guillements sur fichier cela enleve les retours à la ligne donc mauvais resultat
taille_fichier=$(echo "$fichier" | wc -l | cut -d ' ' -f 1 )
for (( i=1; i<=$taille_fichier; i++ ))
do  
  line=$(getLineX $i $fichier)
  nombre_elements=$(echo $line |tr ":" "\n" | wc -l)
  if [ $nombre_elements -ne 5]
  then
    exit 1
  fi
  

done