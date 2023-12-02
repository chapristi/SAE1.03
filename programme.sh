#!/bin/bash

show_error() {
    echo "Error: $1"
}

validate_date() {
    local date_str=$1
    date -d "$date_str" >>/dev/null 2>&1
    return $?
}

validate_alphabetic() {
    local input=$1
    if [[ ! $input =~ ^[a-zA-Z]+$ ]]; then
        show_error "Les champs nom et prenom ne doivent contenir que des lettres: $input"
        return 1
    fi
}

validate_student_year() {
    local year=$1
    if [[ $year -ne 1 && $year -ne 2 && $year -ne 3 ]]; then
        show_error "L'annee de l'etudiant peut etre 1, 2, ou 3: $year"
        return 1
    fi
}

validate_phone_number() {
    local phone=$1
    if [[ ! $phone =~ ^0[67]([0-9]{8})$ ]]; then
        show_error "Format du numero de telephone non correcte: $phone"
        return 1
    fi
}
getLineX() {
    local line=$1
    local file=$2

    local result=$(echo "$file" | head -n $line | tail -n 1)
    echo $result
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


    validate_alphabetic "$prenom" || non_conforme=1;err=1
    validate_alphabetic "$nom" || non_conforme=1;err=1
    validate_student_year "$annee" || non_conforme=1;err=1
    validate_phone_number "$telephone" || non_conforme=1;err=1
    #date utilise un format de date different du notre donc on le change
    validate_date "${annee_naissance:3:2}/${annee_naissance:0:2}/${annee_naissance:6:4}" || non_conforme=1;err=1
    
    if [ $err -ne 0 ]
    then
        echo "La ligne $current_line est valide."
    fi
}


if [ $# -ne 1 ]; then
    show_error "Vous devez entrez un seul argument"
    exit 1
elif [ ! -f "$1" ]; then
    show_error "Le fichier n'a pas ete trouve: $1"
    exit 1
fi

#on supprimme les espaces
file_content=$(cat "$1" | tr -d " ")

number_of_lines=$(echo "$file_content" | wc -l | cut -d ' ' -f 1 )
echo $number_of_lines
non_conforme=0


for ((current_line = 1; current_line <= $number_of_lines; current_line++))
do
    echo "------------Ligne $current_line--------------"
    current_line_content=$(getLineX "$current_line" "$file_content")
    process_line "$current_line_content" "$current_line"
done

if [ $non_conforme -eq 1 ]
then
    echo "Le fichier n'est pas conforme"
    exit 1
else
    echo "Le fichier est conforme"
fi

