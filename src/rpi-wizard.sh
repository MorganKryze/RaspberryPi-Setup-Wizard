#!/bin/bash

# ============ Colors ============

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
ORANGE='\033[0;33m'
RESET='\033[0m'

# ===============================

# ========== Variables ==========
global_user=$(whoami)
# ===============================

# ============ Tools ============

# Displays the title banner.
function display-banner () {

echo "______         _   _____        _                   _    _  _                        _    "
echo "| ___ \       (_) /  ___|      | |                 | |  | |(_)                      | |   "
echo "| |_/ / _ __   _  \ \`--.   ___ | |_  _   _  _ __   | |  | | _  ____  __ _  _ __   __| |  "
echo "|    / | '_ \ | |  \`--. \ / _ \| __|| | | || '_ \  | |/\| || ||_  / / _\` || '__| / _\` |"
echo "| |\ \ | |_) || | /\__/ /|  __/| |_ | |_| || |_) | \  /\  /| | / / | (_| || |   | (_| |   "
echo "\_| \_|| .__/ |_| \____/  \___| \__| \__,_|| .__/   \/  \/ |_|/___| \__,_||_|    \__,_|   "
echo "       | |                                 | |                                            "
echo -e "       |_|                                 |_|                                            \n"

}

# Gets the username and hostname from the host.json file.
function gethost() {
    if [ -f $RPI_SETUP_WIZARD_PATH/src/host.json ]; then
        username=$(jq -r '.username' $RPI_SETUP_WIZARD_PATH/src/host.json)
        hostname=$(jq -r '.hostname' $RPI_SETUP_WIZARD_PATH/src/host.json)
        echo "$username"
        echo "$hostname"
    else
        # No file found.
        return 1
    fi
}

# Displays an error message when a command fails.
function error {
  echo "$RED $1 $RESET"
  return 1
}

function show-link() {
    if [ -f $RPI_SETUP_WIZARD_PATH/src/host.json ]; then
        username=$(gethost | head -n 1)
        hostname=$(gethost | tail -n 1)
        echo -e "Linked to user: $username, host: $hostname\n"
    fi
}

# ==============================

# ========== Functions =========

# Raspberry Pi Wizard function.
function rpi() {

    # Adds the Raspberry Pi Wizard to the shell "path".
    function init() {
        declare -g project_path=$(pwd)
        script_path=$project_path/src/rpi-wizard.sh

        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo -e "\n# Raspberry Pi Wizard executable" >> ~/.zshrc || error "Failed to append to .zshrc file." || return 1
            echo -e "source $script_path" >> ~/.zshrc
            echo -e "export RPI_SETUP_WIZARD_PATH=$project_path \n" >> ~/.zshrc

            echo "Added the following line to your .zshrc file:"
            echo -e "source $script_path \n"
            echo -e "Restart your terminal to use the 'rpi' command globally.\n"
        else
            echo "Consider adding the following line to your .bashrc/.zshrc/your config file:"
            echo "source $script_path"
        fi

        echo "Ensure that the path ends with '.../RaspberryPi-Setup-Wizard/src/rpi-wizard.sh'"
    }

    # Stores the username and hostname in a JSON file.
    function link() {
        usr=$1
        host=$2

        storage="{
 \"username\": \"$usr\",
 \"hostname\": \"$host\"
}"

        echo "$storage" > $RPI_SETUP_WIZARD_PATH/src/host.json || error "Failed to create the host.json file." || return 1
    }

    # Removes the host.json file.
    function unlink() {
        if [ -f $RPI_SETUP_WIZARD_PATH/src/host.json ]; then
            rm $RPI_SETUP_WIZARD_PATH/src/host.json
        else
            echo "Failed to remove the config file."
        fi
    }

    # Adds an SSH key to the Raspberry Pi.
    function add-ssh() {
        usr=$(<(gethost) head -n 1)
        if [ $? -ne 0 ]; then
            error "Failed to get the username and hostname." || return 1
        fi
        host=$(<(gethost) tail -n 1)
        
    	echo -e "Creating SSH key \n"
        ssh-keygen -f /Users/$global_user/.ssh/$host -C "$host" -N "$1"

    	echo "Copying SSH key to $host, you will need to enter the password for $usr\n"
    	sleep 2
        ssh-copy-id -o StrictHostKeyChecking=no -i /Users/$global_user/.ssh/$host.pub $usr@$host.local

    	echo "Adding $host to ~/.ssh/config\n"
        tempfile=$(mktemp)
        cat <<EOF > "$tempfile"
Host $host
  HostName $host.local
  User $usr
  IdentityFile ~/.ssh/$host
EOF
        cat ~/.ssh/config >> "$tempfile"
        mv "$tempfile" ~/.ssh/config

    	echo "Testing SSH connection to $host, consider exiting to pursue configuration\n"
        ssh $host
    }


    case $# in
    0)
        display-banner

        echo "Open source Raspberry Pi wizard tool."
        echo "Licensed under the MIT License, Yann M. Vidamment © 2024."
        echo "https://github.com/MorganKryze/RaspberryPi-Setup-Wizard/"
        sleep 0.5
        echo -e "\n=============================================================================\n"
        sleep 0.5
        show-link

        echo "Usage: rpi [init|link|unlink|ssh] ..."
        ;;
    1)
        case $1 in
            init)
                init
                ;;
            link)
                echo "Usage: rpi link <username> <hostname>"
                ;;
            unlink)
                unlink
                ;;
            ssh)
                add-ssh
                ;;
            *)
                echo "Unknown command: $1"
                ;;
        esac
        ;;
    2)
        case $1 in
            init)
                echo "Usage: rpi init"
                ;;
            link)
                echo "Usage: rpi link <username> <hostname>"
                ;;
            unlink)
                echo "Usage: rpi unlink"
                ;;
            ssh)
                add-ssh $2
                ;;
            *)
                echo "Unknown command: $1"
                ;;
        esac
        ;;
    *)
        case $1 in
            init)
                echo "Usage: rpi init"
                ;;
            link)
                if [ $# -eq 3 ]; then
                    link $2 $3
                else
                    echo "Usage: rpi link <username> <hostname>"
                fi
                ;;
            unlink)
                unlink
                ;;
            ssh)
                echo "Usage: rpi ssh [passphrase]"
                ;;
            *)
                echo "Unknown command: $1"
                ;;
        esac
        ;;
    esac    
}



# ===============================



# echo -e "Available functions:\n"
    # for func in rpi-install rpi-uninstall rpi-update rpi-configure rpi-start rpi-stop rpi-restart rpi-shutdown rpi-reboot; do
    #     echo -e "  ${BLUE}$func:${RESET}"
    #     case "$func" in
    #     "rpi-install")
    #         echo -e "    Create a new Conda environment.\n"
    #         echo -e "    Usage: ${GREEN}env-create${RESET} ${RED}[--language|-l] <language> [--version|-v] <version> [--name|-n] <env_name>${RESET}"
    #         echo -e "      ${RED}--language, -l:${RESET} The programming language for the environment (python, dotnet, r, js)."
    #         echo -e "      ${RED}--version, -v:${RESET} The version of the language to use."
    #         echo -e "      ${RED}--name, -n:${RESET} The name of the environment to create."
    #         ;;
    #     "rpi-uninstall")
    #         echo -e "    Uninstall Raspberry Pi OS and its dependencies.\n"
    #         echo -e "    Usage: ${GREEN}rpi-uninstall${RESET}"
    #         ;;
    #     "rpi-update")
    #         echo -e "    Update the system and installed packages.\n"
    #         echo -e "    Usage: ${GREEN}rpi-update${RESET}"
    #         ;;
    #     "rpi-configure")
    #         echo -e "    Configure the Raspberry Pi settings.\n"
    #         echo -e "    Usage: ${GREEN}rpi-configure${RESET}"
    #         ;;
    #     "rpi-start")
    #         echo -e "    Start the Raspberry Pi.\n"
    #         echo -e "    Usage: ${GREEN}rpi-start${RESET}"
    #         ;;
    #     "rpi-stop")
    #         echo -e "    Stop the Raspberry Pi.\n"
    #         echo -e "    Usage: ${GREEN}rpi-stop${RESET}"
    #         ;;
    #     "rpi-restart")
    #         echo -e "    Restart the Raspberry Pi.\n"
    #         echo -e "    Usage: ${GREEN}rpi-restart${RESET}"
    #         ;;
    #     "rpi-shutdown")
    #         echo -e "    Shutdown the Raspberry Pi.\n"
    #         echo -e "    Usage: ${GREEN}rpi-shutdown${RESET}"
    #         ;;
    #     "rpi-reboot")
    #         echo -e "    Reboot the Raspberry Pi.\n"
    #         echo -e "    Usage: ${GREEN}rpi-reboot${RESET}"
    #         ;;
    #     *)
    #         echo -e "  ${RED}No help text available.${RESET}"
    #         ;;
    #     esac
    #     echo ""
    # done