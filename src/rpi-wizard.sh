#!/bin/bash

# ============ Colors ============

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
ORANGE='\033[0;33m'
RESET='\033[0m'

# Displays a raw message.
# $1: The message to display.
function txt() {
    echo -e "${RESET}$1"
}

# Displays a blue message.
# $1: The message to display.
function blue() {
    echo -e "${BLUE}$1${RESET}"
}

# Displays a green message.
# $1: The message to display.
function green() {
    echo -e "${GREEN}$1${RESET}"
}

# Displays an error message when a command fails.
# $1: The error message to display.
function error {
  echo -e "${RED}[error]${RESET} $1"
  return 1
}

# Displays an information message.
# $1: The message to display.
function info {
  echo "${BLUE}[info]${RESET} $1"
}

# Displays a description of a function.
# $1: The function name.
function description () {
    info "${GREEN}The ${BLUE}$1${GREEN} function $2 ${RESET}\n"
    sleep 2
}
# ===============================

# ========== Variables ==========
global_user=$(whoami)
# ===============================

# ============ Tools ============

# Displays the title banner.
function display-banner () {
blue "______         _   _____        _                   _    _  _                        _    "
blue "| ___ \       (_) /  ___|      | |                 | |  | |(_)                      | |   "
blue "| |_/ / _ __   _  \ \`--.   ___ | |_  _   _  _ __   | |  | | _  ____  __ _  _ __   __| |  "
blue "|    / | '_ \ | |  \`--. \ / _ \| __|| | | || '_ \  | |/\| || ||_  / / _\` || '__| / _\` |"
blue "| |\ \ | |_) || | /\__/ /|  __/| |_ | |_| || |_) | \  /\  /| | / / | (_| || |   | (_| |   "
blue "\_| \_|| .__/ |_| \____/  \___| \__| \__,_|| .__/   \/  \/ |_|/___| \__,_||_|    \__,_|   "
blue "       | |                                 | |                                            "
blue "       |_|                                 |_|                                            \n"
}

# Gets the username and hostname from the host.json file.
function gethost() {
    if [ -f $RPI_SETUP_WIZARD_PATH/src/host.json ]; then
        username=$(jq -r '.username' $RPI_SETUP_WIZARD_PATH/src/host.json)
        hostname=$(jq -r '.hostname' $RPI_SETUP_WIZARD_PATH/src/host.json)
        txt "$username"
        txt "$hostname"
    else
        # No file found.
        return 1
    fi
}

# Displays the linked username and hostname.
function show-link() {
    if [ -f $RPI_SETUP_WIZARD_PATH/src/host.json ]; then
        username=$(gethost | head -n 1)
        hostname=$(gethost | tail -n 1)
        txt "Linked to user: $username, host: $hostname\n"
    fi
}
# ==============================

# ========== Functions =========

# Raspberry Pi Wizard function.
function rpi() {

    function help() {
        display-banner

        echo "Open source Raspberry Pi wizard tool."
        echo "Licensed under the MIT License, Yann M. Vidamment © 2024."
        echo "https://github.com/MorganKryze/RaspberryPi-Setup-Wizard/"
        sleep 1
        echo -e "\n=============================================================================\n"
        sleep 0.5
        show-link

        info "Available commands:\n"

        for func in help init link unlink ssh; do
            blue "  $func:"
            case "$func" in
            "help")
                green "    Display the help text for each command.\n"
                echo -e "    Usage: ${BLUE}rpi help${RESET}"
                ;;
            "init")
                green "    Add the Raspberry Pi Wizard to the shell path.\n"
                echo -e "    Usage: ${BLUE}rpi init${RESET}"
                ;;
            "link")
                green "    Link the Raspberry Pi to a username and hostname.\n"
                echo -e "    Usage: ${BLUE}rpi link${RESET} ${RED}<username> <hostname>${RESET}"
                echo -e "      ${RED}username:${RESET} The username of the Raspberry Pi."
                echo -e "      ${RED}hostname:${RESET} The hostname of the Raspberry Pi."
                ;;

            "unlink")
                green "    Unlink the Raspberry Pi from a username and hostname.\n"
                echo -e "    Usage: ${BLUE}rpi unlink${RESET}"
                ;;

            "ssh")
                green "    Add an SSH key to the Raspberry Pi.\n"
                echo -e "    Usage: ${BLUE}rpi ssh${RESET} ${ORANGE}[passphrase]${RESET}"
                echo -e "      ${ORANGE}passphrase:${RESET} The passphrase for the SSH key."
                ;;

            *)
                error "  No help text available."
                ;;
            esac
            echo ""
            sleep 0.2
        done
    }
    
    # Adds the Raspberry Pi Wizard to the shell "path".
    function init() {
        description init "adds the Raspberry Pi Wizard shell script to your terminal path (MacOS)."

        declare -g project_path=$(pwd)
        script_path=$project_path/src/rpi-wizard.sh

        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo -e "\n# Raspberry Pi Wizard executable" >> ~/.zshrc || error "Failed to append to .zshrc file." || return 1
            echo -e "source $script_path" >> ~/.zshrc
            echo -e "export RPI_SETUP_WIZARD_PATH=$project_path \n" >> ~/.zshrc

            info "Added the following line to your .zshrc file:"
            txt "# Raspberry Pi Wizard executable"
            txt "source ${ORANGE}$script_path${RESET}"
            txt "export RPI_SETUP_WIZARD_PATH=${ORANGE}$project_path${RESET} \n"

            info "Restart your terminal to use the 'rpi' command globally.\n"
        else
            info "Consider adding the following lines to your .bashrc/.zshrc/your config file:"
            echo -e "# Raspberry Pi Wizard executable"
            echo -e "source ${ORANGE}$script_path${RESET}"
            echo -e "export RPI_SETUP_WIZARD_PATH=${ORANGE}$project_path${RESET} \n"
        fi

        info "Ensure that the first path ends with ${ORANGE}'.../RaspberryPi-Setup-Wizard/src/rpi-wizard.sh'${RESET}"
}

    # Stores the username and hostname in a JSON file.
    function link() {
        description link "stores the username and hostname of the current used RPi in a JSON file."
        usr=$1
        host=$2

        storage="{
 \"username\": \"$usr\",
 \"hostname\": \"$host\"
}"

        echo "$storage" > $RPI_SETUP_WIZARD_PATH/src/host.json || error "Failed to create the host.json file." || return 1
        info "Successfully linked to user: $usr, host: $host"
    }

    # Removes the host.json file.
    function unlink() {
        description unlink "removes the host.json file from the Raspberry Pi Wizard."

        if [ -f $RPI_SETUP_WIZARD_PATH/src/host.json ]; then
            rm $RPI_SETUP_WIZARD_PATH/src/host.json
        else
            error "No host.json file found. Consider running 'rpi link <username> <hostname>' beforehand." || return 1
        fi

        info "Successfully unlinked the Raspberry Pi."
    }

    # Adds an SSH key to the Raspberry Pi.
    function add-ssh() {
        description ssh "adds an SSH key to the Raspberry Pi for passwordless login."

        info "Getting the username and hostname from the host.json file.\n"
        usr=$(gethost | head -n 1)
        if [ $? -ne 0 ]; then
            error "Failed to get the username and hostname. Consider running 'rpi link <username> <hostname>'." || return 1
        fi
        host=$(gethost | tail -n 1)
        
    	info "Creating new SSH key \n"
        ssh-keygen -f /Users/$global_user/.ssh/$host -C "$host" -N "$1"

    	info "Copying SSH key to $host, you will need to enter the password for $usr\n"
    	sleep 2
        ssh-copy-id -o StrictHostKeyChecking=no -i /Users/$global_user/.ssh/$host.pub $usr@$host.local

    	info "Adding $host to ~/.ssh/config\n"
        tempfile=$(mktemp)
        cat <<EOF > "$tempfile"
Host $host
  HostName $host.local
  User $usr
  IdentityFile ~/.ssh/$host
EOF
        cat ~/.ssh/config >> "$tempfile"
        mv "$tempfile" ~/.ssh/config

    	info "You can now SSH into $host with 'ssh $host'\n"
    }


    case $# in
    0)
        help
        ;;
    1)
        case $1 in
            init)
                init
                ;;
            link)
                info "Usage: rpi link <username> <hostname>"
                ;;
            unlink)
                unlink
                ;;
            ssh)
                add-ssh
                ;;
            help)
                help
                ;;
            *)
                error "Unknown command: $1"
                ;;
        esac
        ;;
    2)
        case $1 in
            init)
                info "Usage: rpi init"
                ;;
            link)
                info "Usage: rpi link <username> <hostname>"
                ;;
            unlink)
                info "Usage: rpi unlink"
                ;;
            ssh)
                add-ssh $2
                ;;
            help)
                info "Usage: rpi help"
                ;;
            *)
                error "Unknown command: $1"
                ;;
        esac
        ;;
    *)
        case $1 in
            init)
                info "Usage: rpi init"
                ;;
            link)
                if [ $# -eq 3 ]; then
                    link $2 $3
                else
                    info "Usage: rpi link <username> <hostname>"
                fi
                ;;
            unlink)
                unlink
                ;;
            ssh)
                info "Usage: rpi ssh [passphrase]"
                ;;
            help)
                info "Usage: rpi help"
                ;;
            *)
                error "Unknown command: $1"
                ;;
        esac
        ;;
    esac    
}
# ===============================
