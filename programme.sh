#!/bin/bash

show_error() {
    echo "Erreur: $1"
    return 0
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

    local prenom=$(echo "$line" | cut -d ":" -f 2)
    local nom=$(echo "$line" | cut -d ":" -f 1)
    local annee=$(echo "$line" | cut -d ":" -f 3)
    local telephone=$(echo "$line" | cut -d ":" -f 4)
    local date_naissance=$(echo "$line" | cut -d ":" -f 5)
    local jour_naissance=$(echo $date_naissance | cut -d "/" -f 1)
    local mois_naissance=$(echo $date_naissance | cut -d "/" -f 2 )
    local annee_naissance=$(echo $date_naissance | cut -d "/" -f 3)

    validate_regex "$prenom" "^[A-Z][a-z]+(-[a-z]+)?$"|| { err=1 ; show_error "Le champ prenom ne doit contenir que des lettres et commencer par une majuscule: $prenom"; }
    validate_regex "$nom" "^[A-Z][a-z]+(-[a-z]+)?$" || { err=1 ; show_error "Le champ nom ne doit contenir que des lettres et commencer par une majuscule: $nom"; }

    validate_student_year "$annee" || { err=1   ; show_error "L'annee de l'etudiant doit etre 1, 2, ou 3: $year"; }

    validate_regex "$telephone" "^0[67]([0-9]{8})$" ||   { err=1   ; show_error "Le champ téléphone doit etre correcte: $telephone"; }
    #date utilise un format de date different du notre donc on le change
    validate_date "$mois_naissance/$jour_naissance/$annee_naissance" ||   { err=1   ; show_error "Le champ de la date doit etre valide: $date_naissance"; }
    
    echo $err
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
elif [ ! -f $1 ] || [ ! -r $1 ]
then
    show_error "Le fichier : $1 n'a pas ete trouve ou est illisible" 
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
else
	echo "le fichier est conforme"
fi


umask 077

for ligne in $file_content
do
		nomFamille=$(echo $ligne | cut -d ':' -f1)
		prenom=$(echo $ligne | cut -d ':' -f2)
		annee=$(echo $ligne | cut -d ':' -f3)
		numeroTelephone=$(echo $ligne | cut -d ':' -f4)
		date_de_naissance=$(echo $ligne |cut -d ':' -f5)
		

		jour_de_naissance=$(echo $date_de_naissance |cut -d '/' -f1)
        mois_de_naissance=$(echo $date_de_naissance |cut -d '/' -f2)
        annee_de_naissance=$(echo $date_de_naissance |cut -d '/' -f3)
		nom_utilisateur="${prenom:0:1}_$nomFamille"
        
		# MOT DE PASSE
       
		mois_en_lettre=$(date -d "$mois_de_naissance" +"%B")
   
		lettre_du_nomFamille=$(echo $nomFamille| fold -w1 | shuf -n1 | tr "[a-z]" "[A-Z]")
        
		lettre_du_prenom=$(echo $nomFamille | fold -w1 | shuf -n1 | tr "[A-Z]" "[a-z]")
		chiffre_numeroTelephone=${numeroTelephone:2:1}
		caractere_special=$(echo "&$%*:@;.,?#!|[]{}()_+*/-=" | fold -w1 | shuf -n1)
		lettre_du_mois=${mois_en_lettre:0:1}
		mdp="$lettre_du_nomFamille$lettre_du_prenom$chiffre_numeroTelephone$caractere_special$lettre_du_mois"

        if [ ! id "$nom_utilisateur" >/dev/null 2>&1 ]
        then 
            sudo useradd -g annee$annee -m -d "/home/$nom_utilisateur" -s /bin/bash $nom_utilisateur
		    sudo mkdir -p /home/$nom_utilisateur/.vscode/
            sudo cp -r $HOME/.vscode/extensions/ /home/$nom_utilisateur/.vscode/extensions
            sudo chown -R "$nom_utilisateur:annee$annee" /home/$nom_utilisateur/.vscode
	    	sudo echo "$nom_utilisateur:$mdp" >> passwords.txt
		    contenu_fichier="$nomFamille:$prenom:$nom_utilisateur:$mdp"
            sudo echo $contenu_fichier >> "annee$annee"
            echo "L'utilisateur $nom_utilisateur a bien ete cree avec succes"
        else
            echo "L'utilisateur $nom_utilisateur existe deja"
        fi
done


sudo chpasswd < passwords.txt > /dev/null 2>&1
rm passwords.txt
