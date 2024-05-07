#!/bin/bash


print_fancy_message() {
    echo -e "\e[1m$1\e[0m"
}


spinner() {
    local pid=$1
    local delay=0.25
    local spinstr='|/-\'
    while ps -p $pid > /dev/null; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}


progress_bar() {
    local duration=$1
    local progress=0
    local bar="##################################################"
    local numchars=${#bar}
    local increment=$(( (duration * 10) / numchars ))

    while [ $progress -lt $duration ]; do
        echo -ne "\r["
        for ((i=0; i<progress; i+=increment)); do
            echo -ne "${bar:$i:1}"
        done
        for ((i=progress; i<numchars; i++)); do
            echo -ne " "
        done
        echo -ne "] $progress/$duration seconds"
        let progress+=$increment
        sleep 0.1
    done
    echo
}


echo -e "\n"
print_fancy_message "**********************************************"
print_fancy_message "*                                            *"
print_fancy_message "*         Welcome to Docker Pentest          *"
print_fancy_message "*                                            *"
print_fancy_message "**********************************************"
echo -e "\n"


echo "Creating Pentest network with subnet 10.10.1.0/24..."
docker network create pentest --attachable --subnet 10.10.1.0/24 & spinner $!
progress_bar 10


echo "Pulling Metasploitable2 image..."
docker pull tleemcjr/metasploitable2 & spinner $!
progress_bar 10


echo "Running Metasploitable2 container..."
docker run --network pentest --ip 10.10.1.3 --rm --name metasploitable2 --hostname metasploitable2 -it tleemcjr/metasploitable2 /bin/bash


echo "Pentest environment setup complete!"
