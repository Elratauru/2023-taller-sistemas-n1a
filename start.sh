#!/bin/bash
# Obligatorio 1 de Taller de Tecnologias 2023 N1A
# Bruno Acosta 313080 - Alfonso Carvallo 250427 - Mauricio Martinez 255043.

# Main Loop Function.
function menuPrincipal {
    # This creates the file in case it doesn't exist.
    [ -f users.txt ] || touch users.txt

    clear
    echo "Bienvenido!"
    echo " "
    echo "1) Ingresar Usuario y Contraseña"
    echo "2) Ingresar al sistema."
    echo "3) Salir del Sistema."
    echo " "
    read -p "Ingrese una opción: " option

    case $option in
        1)
            addUser
            ;;
        2)
            login
            ;;
        3)
            clear
            exit 
            ;;
        *)
            echo "Opción inválida..."
            sleep 1
            clear
            menuPrincipal
            ;;
    esac
}

# Set New User main menu function.
function addUser {
    echo " "
    read -p "Ingrese un nombre de usuario: " user

    while [ $(grep -i -c  "^$user" users.txt) != "0" ]; 
    do
        echo "El usuario $user, ya existe. Pruebe con otro usuario."
        sleep 1
        read -p "Ingrese un nombre de usuario: " user
        ocurrencias=$(grep -i -c  "^$user" users.txt)
    done
    
    read -rsp "Ingrese una contraseña: " pass
    timestamp=$(date +%s);
    echo "$user:$pass:$timestamp" >> users.txt
    echo " "
    echo "Usuario $user creado exitosamente"
    sleep 2
    clear #Prueba que funcione git
    menuPrincipal
}

# Login Function, Reads an user and a pass and tries to authenticate through.
function login {
    read -p "Ingrese su nombre de usuario: " user
    read -rsp  "Ingrese su contraseña: " pass

    if [ $(grep -c "^$user:$pass:" users.txt) = "1" ] 
    then
        # Get Older Timestamp and update it with the new one.
        updateLastSeen $user $pass
        
        letter="a"  
        menuLogged
    else
        # Usuario y/o contraseña inválidos
        echo "Usuario y/o contraseña inválidos"
        sleep 2
        clear
        login
    fi
}

# Change Password Main Function
# Params user
function changePass {
    # Get the current Pass from the authenticated user. test comit bacosta 
    read -rsp "Ingrese contraseña actual del usuario $1: " actualpass \
	&& echo

    # Load the user password into function.
    currentPassword=$(getUserPassword $1)

    # Check both.
    if [ $actualpass = $currentPassword ]
    then
        read -rsp "Ingrese contraseña nueva para $1  " newpass \
		&& echo
        sed -i "s/$1\:$(getUserPassword $1)/$1\:$newpass/" users.txt     
		
        # Echo message and wait for a few secs.
        echo "La contraseña ha sido actualizada!"
        sleep 2
        clear
    else
        # Try Again.
        echo "La contraseña no coincide con la del usuario $1, intente nuevamente... "
        sleep 2
        changePass $1
    fi

    menuLogged
}

# Getter for User Password
# Returns string
function getUserPassword() {
    grep -i "^$1:" users.txt | cut -d ":" -f2
}

# Timestamp Function, Get the last seen.
# Params user
# Returns Timestamp.
function getLastSeen() {
    grep "^$1:" users.txt | cut -d ":" -f3
}

# Updates LastSeen for user
# Params user, password
function updateLastSeen() {
    # Calculate Timestamp
    timestamp=$(date +%s);

    # Replace the timestamp 
    sed -i "s/$(getLastSeen $1 $2)/$timestamp/" users.txt
}

# Helper Function reads a letter and stores it.
function readKeyword {
    clear
    read -p "Ingrese una palabra clave para almacenar: " letter
    sleep 1
    clear
    menuLogged $letter
}

# Validates that the keyword exists and is setup.
function validateKeyword() {
    if [ -z $1 ];
    then 
        echo "Necesitas una palabra clave para continuar."
        sleep 2
        menuLogged
    fi
}

# Searches on dictionary.
# Parameters $1 is the key
function findInDictionary() {
    validateKeyword $1

    echo "Estas son las palabras que empiezan con $1: "
    cat diccionario.txt | grep "^$1\w*" --text | awk '{print $1}'

    echo "Presiona cualquier tecla para continuar..."
    read -n 1 -s

    menuLogged $letter
}

# Counts Words on dictionary.
# Parameters $1 is the key
function countInDictionary() {
    validateKeyword $1

    echo "La cantidad de palabras encontradas que empieza con $1 son:"
    cat diccionario.txt | grep "^$1\w*" --text | awk '{print NR-1}' | wc -w

    echo "Presiona cualquier tecla para continuar..."
    read -n 1 -s

    menuLogged $letter
}

# Counts Words on dictionary.
# Parameters $1 is the key
function saveFromFoundInDictionary() {
    validateKeyword $1

    echo "Guardando archivo.txt con las coincidencias..."
    cat diccionario.txt | grep "^$1\w*" --text | awk '{print $1}' | (echo -e "$(date): "; cat) > archivo.txt
    sleep 2

    menuLogged $letter
}

# This function as as the main menu after login in.
function menuLogged() {
    clear
    echo "Bienvenido $user"
    lastSeen=$(getLastSeen $user)
    echo "Usted ingresó por última vez el dia $(date +'%Y-%m-%d a las %H:%M:%S' -d "@$lastSeen")"
    echo " "
    echo "------MENU PRINCIPAL-----"
    echo "1) Cambiar Contraseña."

    if [ -z $1 ];
    then echo "2) Escoger una palabra clave."
    else echo "2) Cambiar la palabra clave. Palabra clave actual: $1" 
    fi

    echo "3) Buscar palabras en el diccionario que empiezen con la palabra clave actual."
    echo "4) Contar las palabras de la Opción 3."
    echo "5) Guardar las palabras en un archivo.txt, en conjunto con la fecha y hora de realizado el informe."
    echo "6) Volver al Menú Principal."
    echo " "
    read -p "Ingrese una opción: " option

     case $option in
        1)
            changePass $user
            ;;
        2)
            readKeyword
            ;;
        3)
            findInDictionary $1
            ;;
        4)
            countInDictionary $1
            ;;
        5)
            saveFromFoundInDictionary $1
            ;;
            
        6)  clear
            menuPrincipal
            ;;
        *) echo "Opcion Invalida."
            menuLogged
            ;;
     esac
}

# Main Menu loop
while true
do
    menuPrincipal
done