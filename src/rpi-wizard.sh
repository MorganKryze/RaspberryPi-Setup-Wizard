#!/bin/bash

# ============ Colors ============

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
ORANGE='\033[0;33m'
RESET='\033[0m'
LINK='\033[0;36m'

# Displays a raw message.
# $1: The message to display.
function txt() {
    echo -e "${RESET}$1"
}

# Displays a blue message.
# $1: The message to display.
function blue() {
    txt "${BLUE}$1${RESET}"
}

# Displays a green message.
# $1: The message to display.
function green() {
    txt "${GREEN}$1${RESET}"
}

# Displays an error message when a command fails.
# $1: The error message to display.
function error {
  txt "${RED}[ ERROR ]${RESET} $1"
  return 1
}

# Displays an information message.
# $1: The message to display.
function info {
  echo "${BLUE}[ INFO ]${RESET} $1"
}

# Displays a warning message.
# $1: The message to display.
function warning {
  echo "${ORANGE}[ WARNING ]${RESET} $1"
}

# Displays a success message.
# $1: The message to display.
function success {
  echo "${GREEN}[ SUCCESS ]${RESET} $1"
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
ALIASES_PATH="https://raw.githubusercontent.com/MorganKryze/.dotfiles/main/rpi_shell/.aliases"
ZSHENV_PATH="https://raw.githubusercontent.com/MorganKryze/.dotfiles/main/rpi_shell/.zshenv"

username=""
hostname=""
ip_address=""
# ===============================

# ============ Tools ============

# Displays the title banner.
function display-banner () {
blue " _____         _   _____        _                   _    _  _                        _    "
blue "| ___ \       (_) /  ___|      | |                 | |  | |(_)                      | |   "
blue "| |_/ / _ __   _  \ \`--.   ___ | |_  _   _  _ __   | |  | | _  ____  __ _  _ __   __| |  "
blue "|    / | '_ \ | |  \`--. \ / _ \| __|| | | || '_ \  | |/\| || ||_  / / _\` || '__| / _\` |"
blue "| |\ \ | |_) || | /\__/ /|  __/| |_ | |_| || |_) | \  /\  /| | / / | (_| || |   | (_| |   "
blue "\_| \_|| .__/ |_| \____/  \___| \__| \__,_|| .__/   \/  \/ |_|/___| \__,_||_|    \__,_|   "
blue "       | |                                 | |                                            "
blue "       |_|                                 |_|                                            \n"
}

# Gets the username and hostname from the host.json file.
function get-host-info() {
    if [ -f $RPI_SETUP_WIZARD_PATH/src/host.json ]; then
        user=$(jq -r '.username' $RPI_SETUP_WIZARD_PATH/src/host.json | tr -d '"')
        user=$(printf "%s" "$user")
        declare -g username=$user

        host=$(jq -r '.hostname' $RPI_SETUP_WIZARD_PATH/src/host.json | tr -d '"')
        host=$(printf "%s" "$host")
        declare -g hostname=$host

        ip=$(ssh $host "hostname -I" | awk '{print $1}')
        ip=$(printf "%s" "$ip")
        if [ -z "$ip" ]; then
            ip="None"
        fi
        declare -g ip_address=$ip
    else
        # No file found.
        return 1
    fi
}

# Displays the linked username and hostname.
function show-link() {
    if [ -f $RPI_SETUP_WIZARD_PATH/src/host.json ]; then
        get-host-info
        info "Linked to user: ${ORANGE}$username${RESET}, host: ${ORANGE}$hostname${RESET} at IP: ${ORANGE}$ip_address${RESET}\n"
    else 
        warning "No host.json file found. Consider running 'rpi link <username> <hostname>'.\n"
    fi
}
# ==============================

# ========== Functions =========

# Raspberry Pi Wizard main function.
function rpi() {

    function help() {
        display-banner

        echo "Open-source Raspberry Pi wizard tool."
        echo "Licensed under the MIT License, Yann M. Vidamment © 2024."
        echo "${LINK}https://github.com/MorganKryze/RaspberryPi-Setup-Wizard/${RESET}"
        sleep 1.5
        txt "\n=============================================================================\n"
        sleep 0.5
        show-link

        info "Available commands:\n"

        for func in help init link unlink ssh env; do
            blue "  $func:"
            case "$func" in
            "help")
                green "    Display the help text for each command.\n"
                txt "    Usage: ${BLUE}rpi help${RESET}"
                ;;

            "init")
                green "    Add the Raspberry Pi Wizard to the shell path.\n"
                txt "    Usage: ${BLUE}rpi init${RESET}"
                ;;

            "link")
                green "    Link the Raspberry Pi to a username and hostname.\n"
                txt "    Usage: ${BLUE}rpi link${RESET} ${RED}<username> <hostname>${RESET}"
                txt "      ${RED}username:${RESET} The username of the Raspberry Pi."
                txt "      ${RED}hostname:${RESET} The hostname of the Raspberry Pi."
                ;;

            "unlink")
                green "    Unlink the Raspberry Pi from a username and hostname.\n"
                txt "    Usage: ${BLUE}rpi unlink${RESET}"
                ;;

            "ssh")
                green "    Add an SSH key to the Raspberry Pi.\n"
                txt "    Usage: ${BLUE}rpi ssh${RESET} ${ORANGE}[passphrase]${RESET}"
                txt "      ${ORANGE}passphrase:${RESET} The passphrase for the SSH key."
                ;;
            
            "env")
                green "    Set up the Raspberry Pi environment with ZSH, Oh My Zsh, Git, Neofetch, LSD, and custom aliases.\n"
                txt "    Usage: ${BLUE}rpi env${RESET}"
                ;;
            
            "docker")
                green "    Set up Docker on the Raspberry Pi.\n"
                txt "    Usage: ${BLUE}rpi docker${RESET} ${ORANGE}[--portainer|-p]${RESET}"
                txt "      ${ORANGE}--portainer, -p:${RESET} Install Portainer alongside docker to manage containers."
                ;;

            *)
                error "  No help text available."
                ;;
            esac
            txt ""
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
            txt "# Raspberry Pi Wizard executable"
            txt "source ${ORANGE}$script_path${RESET}"
            txt "export RPI_SETUP_WIZARD_PATH=${ORANGE}$project_path${RESET} \n"
        fi

        success "Ensure that the first path ends with ${ORANGE}'.../RaspberryPi-Setup-Wizard/src/rpi-wizard.sh'${RESET}"
}

    # Stores the username and hostname in a JSON file.
    # $1: The username of the Raspberry Pi.
    # $2: The hostname of the Raspberry Pi.
    function link() {
        description link "stores the username and hostname of the current used RPi in a JSON file."
        usr=$1
        host=$2

        storage="{
 \"username\": \"$usr\",
 \"hostname\": \"$host\"
}"

        echo "$storage" > $RPI_SETUP_WIZARD_PATH/src/host.json || error "Failed to create the host.json file." || return 1
        success "Currently linked to user: $usr, host: $host"
    }

    # Removes the host.json file.
    function unlink() {
        description unlink "removes the host.json file from the Raspberry Pi Wizard."

        if [ -f $RPI_SETUP_WIZARD_PATH/src/host.json ]; then
            rm $RPI_SETUP_WIZARD_PATH/src/host.json
        else
            error "No host.json file found. Consider running 'rpi link <username> <hostname>' first." || return 1
        fi

        success "Unlinked the Raspberry Pi."
    }

    # Adds an SSH key to the Raspberry Pi.
    # $1: The passphrase for the SSH key.
    function add-ssh() {
        description ssh "adds an SSH key to the Raspberry Pi for passwordless login."

        info "Getting the username and hostname from the host.json file.\n"
        get-host-info || error "Failed to get the username and hostname. Consider running 'rpi link <username> <hostname>' first." || return 1
        
        show-link
        
    	info "Creating new SSH key \n"
        ssh-keygen -f /Users/$global_user/.ssh/$hostname -C "$hostname" -N "$1"

    	info "Copying SSH key to $hostname, you will need to enter the password for $usr\n"
    	sleep 2
        ssh-copy-id -o StrictHostKeyChecking=no -i /Users/$global_user/.ssh/$hostname.pub $usr@$hostname.local

    	info "Adding $hostname to ~/.ssh/config\n"
        tempfile=$(mktemp)
        cat <<EOF > "$tempfile"
Host $hostname
  HostName $hostname.local
  User $usr
  IdentityFile ~/.ssh/$hostname

EOF
        cat ~/.ssh/config >> "$tempfile"
        mv "$tempfile" ~/.ssh/config

    	success "You can now SSH into $hostname with 'ssh $hostname'\n"
    }

    # Sets up the Raspberry Pi environment with ZSH, Oh My Zsh, Git, Neofetch, LSD, and custom aliases.
    function env() {
        description env "sets up the Raspberry Pi environment with ZSH, Oh My Zsh, Git, Neofetch, LSD, and custom aliases."

        info "Getting the username and hostname from the host.json file.\n"
        get-host-info || error "Failed to get the username and hostname. Consider running 'rpi link <username> <hostname>' first." || return 1
        
        show-link

	    info "Updating and Upgrading packages\n"
	    ssh $hostname "sudo apt-get update && sudo apt-get upgrade -y" || error "Failed to connect to $host. Consider running 'rpi ssh' first." || return 1

	    info "Installing ZSH\n"
	    if ! ssh $hostname "command -v zsh >/dev/null 2>&1"; then
	    	ssh $hostname "sudo apt-get install zsh -y"
	    	ssh $hostname "chsh -s $(which zsh)"
        else 
            warning "ZSH is already installed. Skipping..."
            ssh $hostname "zsh --version"
	    fi

	    info "Installing Git\n"
	    if ! ssh $hostname "command -v git >/dev/null 2>&1"; then
	    	ssh $hostname "sudo apt-get install git -y"
        else 
            warning "Git is already installed. Skipping..."
            ssh $hostname "git --version"
	    fi

	    info "Installing Oh My Zsh\n"
	    if ssh $hostname "[ ! -d \"~/.oh-my-zsh\" ]"; then
	    	ssh $hostname "sh -c $(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	    	ssh $hostname "sed -i '/ZSH_THEME=/d' ~/.zshrc && sed -i '1iZSH_THEME=\"candy\"' ~/.zshrc"

	    	ssh $hostname "sudo chown -R 1000:1000 ~/.oh-my-zsh"
	    	ssh $hostname "sudo git clone https://github.com/zsh-users/zsh-autosuggestions /home/$username/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
	    	ssh $hostname "sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/$username/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

	    	ssh $hostname "sed -i '/plugins=(git)/d' ~/.zshrc && sed -i '1iplugins=(git zsh-autosuggestions zsh-syntax-highlighting)' ~/.zshrc"
        else 
            warning "Oh My Zsh is already installed. Skipping..."
            ssh $hostname "omz version"
	    fi

	    info "InstaNeofetch\n"
	    if ! ssh $hostname "command -v neofetch >/dev/null 2>&1"; then
	    	ssh $hostname "sudo apt-get install neofetch -y"
	    	ssh $hostname "echo neofetch >> ~/.zshrc"
        else 
            warning "Neofetch is already installed. Skipping..."
            ssh $hostname "neofetch --version"
	    fi

	    info "Installing lsd\n"
	    if ! ssh $hostname "command -v lsd >/dev/null 2>&1"; then
	    	ssh $hostname "sudo apt-get install lsd -y"
        else 
            warning "lsd is already installed. Skipping..."
            ssh $hostname "lsd --version"
	    fi

        info "Adding aliases and .zshenv\n"
        if ! ssh $hostname "test -f ~/.aliases"; then
            ssh $hostname "curl -O $ALIASES_PATH > ~/.aliases"
        else 
            warning "Aliases file already exists. Skipping..."
        fi
        if ! ssh $hostname "test -f ~/.zshenv"; then
            ssh $hostname "curl -O $ZSHENV_PATH > ~/.zshenv"
        else
            warning ".zshenv file already exists. Skipping..."
        fi

	    info "Removing 'NO WARRANTY' welcome message.\n"
	    ssh $hostname "touch ~/.hushlogin"

	    warning "Rebooting in 5 sec, please wait a few moments.\n"
	    sleep 5
	    ssh $hostname "sudo reboot"

	    info "Rebooting...\n"
	    sleep 45

	    success "$hostname is now ready to use.\n"
    }

    # Sets up Docker on the Raspberry Pi.
    # $1: Install Portainer.
    function docker() {
        description docker "sets up Docker on the Raspberry Pi."

        info "Getting the username and hostname from the host.json file.\n"
        get-host-info || error "Failed to get the username and hostname. Consider running 'rpi link <username> <hostname>' first." || return 1
        
        show-link

	    PORTAINER=false
        if [[ "$1" == "--portainer" || "$1" == "-p" ]]; then
            PORTAINER=true
        fi

        info "Checking if Docker is installed\n"
        if ! ssh $hostname "command -v docker >/dev/null 2>&1"; then
            ssh $hostname "curl -fsSL https://get.docker.com | sh" || error "Failed to install Docker on $hostname" || return 1
        else
            warning "Docker is already installed\n"
            ssh $hostname "docker --version" || error "Failed to get Docker version" || return 1
        fi

	    info "Adding $username to the Docker group\n"
	    if ! ssh $hostname "groups $username | grep -q docker"; then
	    	ssh $hostname "sudo usermod -aG docker $username" || error "Failed to add $username to the Docker group" || return 1
        else
            warning "$username is already in the Docker group, current groups:\n"
            ssh $hostname "groups $username" || error "Failed to get $username groups" || return 1
	    fi

	    info "Installing lazydocker\n"
        if ! ssh $hostname "command -v lazydocker >/dev/null 2>&1"; then
            ssh $hostname "curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | zsh" || error "Failed to install lazydocker on $hostname" || return 1
            ssh $hostname "sudo ln -s /home/$username/.local/bin/lazydocker /usr/bin/" || error "Failed to create symlink for lazydocker" || return 1
        else
            warning "lazydocker is already installed\n"
            ssh $hostname "lazydocker --version" || error "Failed to get lazydocker version" || return 1
        fi

	    warning "Rebooting in 5 sec, please wait a few moments.\n"
	    sleep 5

	    ssh $hostname "sudo reboot" || error "Failed to reboot $hostname" || return 1

	    info "Waiting for $hostname to reboot.\n"
	    sleep 45

	    success "Docker is now set up on $hostname\n"

        if [ "$PORTAINER" = false ]; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                read -r response"?Do you want to install Portainer to manage your containers? (y/N):"
            else
                read -p "Do you want to install Portainer to manage your containers? (y/N):" response
            fi

            if [[ "$response" =~ ^([yY])$ ]]; then
                PORTAINER=true
            fi
        fi
    
	    if [ "$PORTAINER" = true ]; then
            info "Installing Portainer on $hostname...\n"
            ssh $hostname "sudo docker volume create portainer_data"
            ssh $hostname "sudo docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce"

            info "Fixing Portainer permissions\n"
            if [ -f /portainer ]; then
                warning "Portainer directory does not exist, creating it...\n"
                ssh $hostname "sudo mkdir /portainer"
            fi
	        ssh $hostname "sudo chown -R 1000:1000 /portainer" || error "Failed to fix Portainer permissions. Consider checking the directory permissions."

	    	success "Portainer is now running on at ${LINK}http://$ip_address:9000\n${RESET}"
	    fi
    }


    case $# in
    0)
        help
        ;;
    1)
        case $1 in
            help)
                help
                ;;
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
            env)
                env
                ;;
            docker)
                docker
                ;;
            *)
                error "Unknown command: $1"
                ;;
        esac
        ;;
    2)
        case $1 in
            help)
                info "Usage: rpi help"
                ;;
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
            env)
                info "Usage: rpi env"
                ;;
            docker)
                if [[ "$2" == "--portainer" || "$2" == "-p" ]]; then
                    docker $2
                else 
                    error "Unknown option: $2"
                fi
                ;;
            *)
                error "Unknown command: $1"
                ;;
        esac
        ;;
    *)
        case $1 in
            help)
                info "Usage: rpi help"
                ;;
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
            env)
                env
                ;;
            docker)
                info "Usage: rpi docker [--portainer|-p]"
                ;;
            *)
                error "Unknown command: $1"
                ;;
        esac
        ;;
    esac    
}
# ===============================
