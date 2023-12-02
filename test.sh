#!/bin/bash

# Function to display error messages
show_error() {
    echo "Error: $1"
}

# Function to validate date format
validate_date() {
    local date_str=$1
    date -d "$date_str" >/dev/null 2>&1
    return $?
}

# Function to check if a string contains only letters
validate_alphabetic() {
    local input=$1
    if [[ ! $input =~ ^[a-zA-Z]+$ ]]; then
        show_error "The input must contain only letters: $input"
        return 1
    fi
}

# Function to check if the student year is valid
validate_student_year() {
    local year=$1
    if [[ $year -lt 1 || $year -gt 3 ]]; then
        show_error "The student year must be 1, 2, or 3: $year"
        return 1
    fi
}

# Function to check if the phone number is valid
validate_phone_number() {
    local phone=$1
    if [[ ! $phone =~ ^0[67]([0-9]{8})$ ]]; then
        show_error "Invalid phone number format: $phone"
        return 1
    fi
}
getLineX() {
    local line=$1
    local fichier=$2

    local result=$(echo "$fichier" | head -n $line | tail -n 1)
    echo $result
}

# Function to process each line in the file
process_line() {
    local line=$1
    local current_line=$2
    local err=0

    local prenom=$(echo "$line" | cut -d ":" -f 1)
    local nom=$(echo "$line" | cut -d ":" -f 2)
    local annee=$(echo "$line" | cut -d ":" -f 3)
    local telephone=$(echo "$line" | cut -d ":" -f 4)
    local annee_naissance=$(echo "$line" | cut -d ":" -f 5)

    # ... Additional validations ...

    # Example of using the validation functions
    validate_alphabetic "$prenom" || non_conforme=1;err=1
    validate_alphabetic "$nom" || non_conforme=1;err=1
    validate_student_year "$annee" || non_conforme=1;err=1
    validate_phone_number "$telephone" || non_conforme=1;err=1
    validate_date "${annee_naissance:3:2}/${annee_naissance:0:2}/${annee_naissance:6:4}" || non_conforme=1;err=1
    
    if [ $err -ne 0 ]
    then
        echo "Line $current_line is valid."
    fi
}

# Main script starts here

if [ $# -ne 1 ]; then
    show_error "You must enter exactly one argument."
    exit 1
elif [ ! -f "$1" ]; then
    show_error "File not found: $1"
    exit 1
fi

# Read the file and remove spaces
file_content=$(cat "$1" | tr -d " ")

number_of_lines=$(echo "$file_content" | wc -l | cut -d ' ' -f 1 )
echo $number_of_lines
non_conforme=0


# Loop through each line
for ((current_line = 1; current_line <= $number_of_lines; current_line++)); do
    echo "------------Line $current_line--------------"
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

