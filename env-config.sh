#!/bin/bash

# ------------------------------------------------------------------------------
# | Helper functions                                                           |
# ------------------------------------------------------------------------------

# Render a success message
e_success() {
    printf "$(tput setaf 64)✔ %s$(tput sgr0)\n" "$@"
}

# Render a warning message
e_warning() {
    printf "$(tput setaf 182)! %s$(tput sgr0)\n" "$@"
}

# Render an option message
e_option_message() {
    printf "\n$(tput setaf 7)%s$(tput sgr0)\n" "$@"
}

# Render an error
e_error() {
    printf "$(tput setaf 1)✖ %s$(tput sgr0)\n" "$@"
}

# Verify if cmd exists
cmd_exists() {
    if [[ $(type -P $1) ]]; then
      return 0
    fi
    return 1
}

# Verify if docker network exists
docker_lan_exists() {
    return $(sudo docker network ls |grep $1 &> /dev/null)
}

# Make a question
question() {
    printf "\n"
    e_warning "$@"
    read -p "Continue? (y/n) " -n 1
}

is_confirmed() {
    if [[ "$REPLY" =~ ^[Yy]$ ]]; then
      return 0
    fi
    return 1
}

# Verify if git config exists
git_config_exists() {
    if [[ -n $(git config --global --list |grep $1) ]]; then
      return 0
    fi
    return 1
}

# Verify if package exists
package_exists() {
    return $(grep ^ /etc/apt/sources.list /etc/apt/sources.list.d/* | grep $1 &> /dev/null)
}


# ------------------------------------------------------------------------------
# | Installation                                                                |
# ------------------------------------------------------------------------------


echo " "
echo "PHP | GIT | Docker | Composer | GIT | MELD installation"

# Printing options
echo "1) Install Docker, PHP(5.6, 7.1, 7.2 e 7.3), Composer, GIT, MELD"
echo "x) Sair"


# Option read
read -p "Enter your option: " option

# Options process
case "$option" in
    1)
        # Installing GIT
        e_option_message "1.1) Installing GIT, Meld:"
        sudo apt update
        if !cmd_exists 'git'; then
            sudo apt install git -y
        fi

        if !cmd_exists 'meld'; then
            sudo apt install meld -y
        fi
        e_successo "Success"

        e_option_message "1.1.2) Configuring GIT"

        git config --global core.autocrlf input
        git config --global color.ui auto

        if !git_config_existe 'user'; then
            e_warning 'GIT User config'
            read -p "Type your name: " gitFullName
            git config --global user.name "$gitFullName"

            read -p "GIT: Digite seu e-mail: " gitEmail
            git config --global user.email "$gitEmail"
        fi

        if !git_config_existe 'mymeld'; then
            sudo cp git-meld.sh /usr/local/bin
            sudo chmod 777 /usr/local/bin/git-meld.sh
            cat git-meld-config.txt >> ~/.gitconfig
        fi

        e_successo "Success"

        # Install PHP
        e_option_message "1.2) Add PHP Repository (ondrej/php):"
        if !package_exists 'ondrej/php'; then
            sudo add-apt-repository ppa:ondrej/php -y
            sudo apt-get update
        fi
        e_successo "Success"

        e_option_message "1.3) Installing PHP 5.6:"
        if !cmd_exists 'php5.6'; then
            sudo apt install php5.6-cli php-common php5.6-common php5.6-json php5.6-opcache php5.6-readline php5.6-xml php5.6-intl php5.6-mcrypt php5.6-mbstring php5.6-soap php5.6-curl php5.6-zip -y
        fi
        e_successo "Success"

        e_option_message "1.4) Installing PHP 7.1:"
        if !cmd_exists 'php7.1'; then
            sudo apt install php7.1-cli php-common php7.1-common php7.1-json php7.1-opcache php7.1-readline php7.1-xml php7.1-intl php7.1-mcrypt php7.1-mbstring php7.1-soap php7.1-curl php7.1-zip -y
        fi
        e_successo "Success"

        e_option_message "1.5) Installing PHP 7.2:"
        if ! cmd_exists 'php7.2'; then
            sudo apt install php7.2-cli php-common php7.2-common php7.2-json php7.2-opcache php7.2-readline php7.2-xml php7.2-intl php7.2-mbstring php7.2-soap php7.2-curl php7.2-zip -y
        fi
        e_successo "Success"

        e_option_message "1.6) Installing PHP 7.3:"
        if ! cmd_exists 'php7.3'; then
            sudo apt install php7.3-cli php-common php7.3-common php7.3-json php7.3-opcache php7.3-readline php7.3-xml php7.3-intl php7.3-mbstring php7.3-soap php7.3-curl php7.3-zip -y
        fi
        e_successo "Success"

        # Composer Install
        e_option_message "1.7) Installing Composer:"
        if ! cmd_exists 'composer'; then
            sudo apt install composer -y
        fi
        e_successo "Success"

        # Docker install
        e_option_message "1.8) Adding Docker Repository and Install Docker:"
        if ! cmd_exists 'apt-transport-https'; then
            sudo apt install apt-transport-https -y
        fi

        if ! cmd_exists 'ca-certificates'; then
            sudo apt install ca-certificates -y
        fi

        if ! cmd_exists 'curl'; then
            sudo apt install curl -y
        fi

        if ! cmd_exists 'software-properties-common'; then
            sudo apt install software-properties-common -y
        fi

        if ! package_exists 'deb \[arch=amd64\] https://download.docker.com/linux/ubuntu'; then
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
            sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
            sudo apt update
        fi

        if ! cmd_exists 'docker'; then
            sudo apt install docker-ce -y
        fi
        if ! cmd_exists 'docker-compose'; then
            sudo apt install docker-compose -y
        fi
        e_successo "Success"

        e_option_message "1.9) Add Docker to user:"
        sudo usermod -aG docker $(whoami)
        e_successo "Success"

        # Read network name
        read -p "Enter your network name: " network

        e_option_message "1.10) Creating network: $network"
        if ! docker_lan_exists "$network"; then
            sudo docker network create -d bridge "$network"
        fi

        e_option_message "1.11) Enable docker service:"
        sudo systemctl enable docker
        e_successo "Success"

        e_option_message "1.12) Starting Docker service:"
        sudo systemctl start docker
        e_successo "Success"
    ;;
    [xX])
        echo "#################"
        echo "#               #"
        echo "#               #"
        echo "#    Good bye   #"
        echo "#               #"
        echo "#               #"
        echo "#################"
        exit 1
    ;;

    *)
        echo $"Invalid options! Type: [1|x]"
        exit 1
esac





