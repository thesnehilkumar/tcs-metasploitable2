#!/bin/bash

print_fancy_message() {
    echo -e "\e[1m$1\e[0m"
}

spinner() {
    local pid=$1
    local delay=0.25
    local spinstr='|/-\'
    while ps -p $pid > /dev/null; do
        printf " [%c]  " "$spinstr"
        local temp=${spinstr#?}
        spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b"
    done
}

progress_bar() {
    local duration=$1
    local progress=0
    local bar="##################################################"
    local numchars=${#bar}
    local increment=$(( (duration * 10) / numchars ))

    while [ $progress -lt $duration ]; do
        echo -ne "\r["
        local i=0
        while [ $i -lt $((progress * numchars / duration)) ]; do
            echo -ne "#"
            ((i++))
        done
        while [ $i -lt $numchars ]; do
            echo -ne " "
            ((i++))
        done
        echo -ne "] $progress/$duration seconds"
        let progress+=$increment
        sleep 0.1
    done
    echo
}

check_and_install_docker() {
    if ! command -v docker &> /dev/null; then
        echo "Error: Docker is not installed. Installing Docker..."
        sudo apt-get update
        sudo apt-get install -y docker.io
        sudo systemctl start docker
        sudo systemctl enable docker
    fi
}

echo -e "\n"
print_fancy_message "**********************************************"
print_fancy_message "*                                            *"
print_fancy_message "*         Welcome to Docker Pentest          *"
print_fancy_message "*                                            *"
print_fancy_message "**********************************************"
echo -e "\n"

if check_and_install_docker; then
    echo "Creating Pentest network with subnet 10.10.1.0/24..."
    if docker network create pentest --attachable --subnet 10.10.1.0/24; then
        spinner $!
        progress_bar 10
        echo "Pulling Metasploitable2 image..."
        if docker pull tleemcjr/metasploitable2; then
            spinner $!
            progress_bar 10
            echo "Running Metasploitable2 container..."
            if docker run --network pentest --ip 10.10.1.3 --rm --name metasploitable2 --hostname metasploitable2 -it tleemcjr/metasploitable2 /bin/bash; then
                echo "Pentest environment setup complete!"
            else
                echo "Error: Failed to run Metasploitable2 container."
            fi
        else
            echo "Error: Failed to pull Metasploitable2 image."
        fi
    else
        echo "Error: Failed to create Pentest network."
    fi
else
    echo "Error: Docker installation failed."
fi

echo -e "\n"
echo "Script created by: Snehil Kumar"