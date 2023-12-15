#!/bin/bash

createLoginName() {
    local nom=$1
    local prenom=$2
    #0:1 veut dire on part de l'index 0 et on prend 1 caractere
    local result="${prenom:0:1}-$nom"
    echo $result
}
#createUserPassword(){}

show_error() {
    echo "Error: $1"
}

validate_date() {
    local date_str=$1
    date -d "$date_str" >/dev/null 2>&1
    if [ $? -eq 1 ]
    then
        return 1
    fi
    return 0
}
validate_regex(){
    local input=$1
    local regex=$2

    if [[ ! $input =~ $regex ]]
    then
        return 1
    fi
    return 0
}


validate_student_year() {
    local year=$1
    if [[ $year -ne 1 && $year -ne 2 && $year -ne 3 ]]
    then
        return 1
    fi
    return 0
}


process_line() {
    local line=$1
    local current_line=$2
    local err=0

    local prenom=$(echo "$line" | cut -d ":" -f 1)
    local nom=$(echo "$line" | cut -d ":" -f 2)
    local annee=$(echo "$line" | cut -d ":" -f 3)
    local telephone=$(echo "$line" | cut -d ":" -f 4)
    local annee_naissance=$(echo "$line" | cut -d ":" -f 5)
    local jour_naissance=$(echo $annee_naissance | cut -d "/" -f 1)
    local mois_naissance=$(echo $annee_naissance | cut -d "/" -f 2 )
    local annee_naissance=$(echo $annee_naissance | cut -d "/" -f 3)

    validate_regex "$prenom" "^[A-Z][a-zA-Z]+$" || (err=1;show_error "Le champ prenom ne doit contenir que des lettres et commencer par une majuscule: $prenom")

    validate_regex "$nom" "^[A-Z][a-zA-Z]+$" || (err=1;show_error "Le champ prenom ne doit contenir que des lettres et commencer par une majuscule: $nom")

    validate_student_year "$annee" || (err=1;show_error "L'annee de l'etudiant peut etre 1, 2, ou 3: $year")

    validate_regex "$telephone" "^0[67]([0-9]{8})$" ||( err=1;show_error "Le champ téléphone doit etre correcte: $telephone")
    #date utilise un format de date different du notre donc on le change
    validate_date "$mois_naissance/$jour_naissance/$annee_naissance" || (err=1; show_error "Le champ de la date doit etre valide: $date_str")
    
    if [ $err -eq 0 ]
    then
        echo "La ligne $current_line est valide."
        return 0
    else
        return 1
    fi
}

if [ $# -ne 1 ]
then
    show_error "Vous devez entrez un seul argument"
    exit 1
#on verifie que le fichier existe
elif [ ! -f $1 ] 
then
    show_error "Le fichier n'a pas ete trouve: $1"
    exit 1
fi

#on supprimme les espaces
file_content=$(cat $1 | tr -d " ")
non_conforme=0
current_line=0
#verification sur toute les lignes du fichier
for current_line_content in  $file_content
do
    ((current_line=$current_line+1)) 
    echo "------------Ligne $current_line--------------"
    process_line "$current_line_content" "$current_line"
    if [ $? -ne 0 ]
    then
        non_conforme=1
    fi 
done

if [ $non_conforme -eq 1 ]
then
    echo "Le fichier n'est pas conforme"
    exit 1
fi





