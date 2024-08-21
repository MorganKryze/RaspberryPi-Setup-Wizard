#!/bin/bash

# ================================== COLORS ===================================
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
ORANGE='\033[0;33m'
RESET='\033[0m'
LINK='\033[0;36m'
UNDERLINE='\033[4m'

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
  txt "${RED}[ ERROR ]${RESET} $1${RESET}"
  return 1
}

# Displays an information message.
# $1: The message to display.
function info {
  echo "${BLUE}[ INFO ]${RESET} $1${RESET}"
}

# Displays a warning message.
# $1: The message to display.
function warning {
  echo "${ORANGE}[ WARNING ]${RESET} $1${RESET}"
}

# Displays a success message.
# $1: The message to display.
function success {
  echo "${GREEN}[ SUCCESS ]${RESET} $1${RESET}"
}

# Displays a description of a function.
# $1: The function name.
function description () {
    info "${GREEN}The ${BLUE}$1${GREEN} command $2 ${RESET}\n"
    sleep 2
}
# =============================================================================

# ============================== VARIABLES ====================================
global_user=$(whoami)
ALIASES_PATH="https://raw.githubusercontent.com/MorganKryze/.dotfiles/main/rpi_shell/.aliases"
ZSHENV_PATH="https://raw.githubusercontent.com/MorganKryze/.dotfiles/main/rpi_shell/.zshenv"

username=""
hostname=""
ip_address=""
# =============================================================================

# ================================ TOOLS ======================================

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
        info "Linked to user: ${ORANGE}$username${RESET}, host: ${ORANGE}$hostname${RESET} at IP: ${ORANGE}$ip_address${RESET}."
    else 
        warning "Not linked to a Raspberry Pi. Consider running '${BLUE}rpi link ${RED}<username> <hostname>${RESET}'."
    fi
}
# =============================================================================

# =============================== Functions ===================================

# Raspberry Pi Wizard main function.
function rpi() {

    function intro() {
        display-banner

        txt "Open-source Raspberry Pi wizard tool."
        txt "Licensed under the MIT License, Yann M. Vidamment © 2024."
        txt "${LINK}https://github.com/MorganKryze/RaspberryPi-Setup-Wizard/${RESET}"
        txt "\n=============================================================================\n"
        sleep 1
        show-link
    }

    function functions() {
        info "Type '${BLUE}rpi help${RESET}' ${UNDERLINE}alone${RESET} or ${UNDERLINE}followed by the command name${RESET} to get more information."

        info "Available commands:"
        
        for func in help init update link unlink connect ssh env docker git firewall; do
            blue "  $func"
            case "$func" in
            "help")
                green "    Display the help text for each command."
                ;;
            "init")
                green "    Add the Raspberry Pi Wizard to the shell path."
                ;;
            "update")
                green "    Update the Raspberry Pi Wizard by pulling the latest changes from the repository."
                ;;
            "link")
                green "    Link the Raspberry Pi to a username and hostname."
                ;;
            "unlink")
                green "    Unlink the Raspberry Pi from a username and hostname."
                ;;  
            "connect")
                green "    Connect to the Raspberry Pi using SSH."
                ;;
            "ssh")    
                green "    Add an SSH key to the Raspberry Pi."
                ;;
            "env")        
                green "    Set up the Raspberry Pi environment with ZSH, Oh My Zsh, Git, Neofetch, LSD, and custom aliases."
                ;;
            "docker")
                green "    Set up Docker on the Raspberry Pi."
                ;;
            "git")
                green "    Configure git on the Raspberry Pi to a specific account."
                ;;
            "firewall")
                green "    Set up a custom firewall on the Raspberry Pi."
                ;;
            *)
                error "  No help text available."
                ;;
            esac
            sleep 0.1
        done
    }

    # Displays the help text for each command.
    # $1: The function name.
    function help() {
        description help "displays the help text for each command."

        if [ $# -eq 1 ]; then
            case $1 in
            help)
                blue "  help:"
                green "    Display the help text for each command."
                txt "    Usage: ${BLUE}rpi help ${ORANGE}[command]${RESET}"
                txt "      ${ORANGE}command:${RESET} The command name to display the help text."
                ;;
            init)
                blue "  init:"
                green "    Add the Raspberry Pi Wizard to the shell path."
                txt "    Usage: ${BLUE}rpi init${RESET}"
                ;;
            update)
                blue "  update:"
                green "    Update the Raspberry Pi Wizard by pulling the latest changes from the repository."
                txt "    Usage: ${BLUE}rpi update${RESET}"
                ;;
            link)
                blue "  link:"
                green "    Link the Raspberry Pi to a username and hostname."
                txt "    Usage: ${BLUE}rpi link${RESET} ${RED}<username> <hostname>${RESET}"
                txt "      ${RED}username:${RESET} The username of the Raspberry Pi."
                txt "      ${RED}hostname:${RESET} The hostname of the Raspberry Pi."
                ;;
            unlink)
                blue "  unlink:"
                green "    Unlink the Raspberry Pi from a username and hostname."
                txt "    Usage: ${BLUE}rpi unlink${RESET}"
                ;;
            connect)
                blue "  connect:"
                green "    Connect to the Raspberry Pi using SSH."
                txt "    Usage: ${BLUE}rpi connect${RESET}"
                ;;
            ssh)
                blue "  ssh:"
                green "    Add an SSH key to the Raspberry Pi."
                txt "    Usage: ${BLUE}rpi ssh${RESET} ${ORANGE}[passphrase]${RESET} ${ORANGE}[--fail2ban|-f]${RESET}"
                txt "      ${ORANGE}passphrase:${RESET} The passphrase for the SSH key."
                txt "      ${ORANGE}--fail2ban, -f:${RESET} Install fail2ban alongside the SSH key."
                ;;
            env)
                blue "  env:"
                green "    Set up the Raspberry Pi environment with ZSH, Oh My Zsh, Git, Neofetch, LSD, and custom aliases."
                txt "    Usage: ${BLUE}rpi env${RESET}"
                ;;
            docker)
                blue "  docker:"
                green "    Set up Docker on the Raspberry Pi."
                txt "    Usage: ${BLUE}rpi docker${RESET} ${ORANGE}[--portainer|-p]${RESET}"
                txt "      ${ORANGE}--portainer, -p:${RESET} Install Portainer alongside docker to manage containers."
                ;;
            git)
                blue "  git:"
                green "    Configure git on the Raspberry Pi to a specific account."
                txt "    Usage: ${BLUE}rpi git${RESET} ${RED}<email>${RESET}"
                txt "      ${RED}email:${RESET} The email for the git configuration."
                ;;
            firewall)
                blue "  firewall:"
                green "    Set up
                a custom firewall on the Raspberry Pi."
                txt "    Usage: ${BLUE}rpi firewall${RESET} ${ORANGE}[--enable|-e|--disable|-d]${RESET}"
                txt "      ${ORANGE}--enable, -e:${RESET} Enable the firewall."
                txt "      ${ORANGE}--disable, -d:${RESET} Disable the firewall."
                ;;
            *)

                error "Command not found. No help text available."
                ;;
            esac
        else
            intro 

            info "Available commands:"
            for func in help init update link unlink connect ssh env docker git firewall; do
                blue "  $func:"
                case "$func" in
                "help")
                    green "    Display the help text for each command."
                    txt "    Usage: ${BLUE}rpi help ${ORANGE}[command]${RESET}"
                    txt "      ${ORANGE}command:${RESET} The command name to display the help text."
                    ;;
                "init")
                    green "    Add the Raspberry Pi Wizard to the shell path."
                    txt "    Usage: ${BLUE}rpi init${RESET}"
                    ;;
                "update")
                    green "    Update the Raspberry Pi Wizard by pulling the latest changes from the repository."
                    txt "    Usage: ${BLUE}rpi update${RESET}"
                    ;;
                "link")
                    green "    Link the Raspberry Pi to a username and hostname."
                    txt "    Usage: ${BLUE}rpi link${RESET} ${RED}<username> <hostname>${RESET}"
                    txt "      ${RED}username:${RESET} The username of the Raspberry Pi."
                    txt "      ${RED}hostname:${RESET} The hostname of the Raspberry Pi."
                    ;;
                "unlink")
                    green "    Unlink the Raspberry Pi from a username and hostname."
                    txt "    Usage: ${BLUE}rpi unlink${RESET}"
                    ;;
                "connect")
                    green "    Connect to the Raspberry Pi using SSH."
                    txt "    Usage: ${BLUE}rpi connect${RESET}"
                    ;;
                "ssh")
                    green "    Add an SSH key to the Raspberry Pi."
                    txt "    Usage: ${BLUE}rpi ssh${RESET} ${ORANGE}[passphrase]${RESET} ${ORANGE}[--fail2ban|-f]${RESET}"
                    txt "      ${ORANGE}passphrase:${RESET} The passphrase for the SSH key."
                    txt "      ${ORANGE}--fail2ban, -f:${RESET} Install fail2ban alongside the SSH key."
                    ;;
                "env")
                    green "    Set up the Raspberry Pi environment with ZSH, Oh My Zsh, Git, Neofetch, LSD, and custom aliases."
                    txt "    Usage: ${BLUE}rpi env${RESET}"
                    ;;
                "docker")
                    green "    Set up Docker on the Raspberry Pi."
                    txt "    Usage: ${BLUE}rpi docker${RESET} ${ORANGE}[--portainer|-p]${RESET}"
                    txt "      ${ORANGE}--portainer, -p:${RESET} Install Portainer alongside docker to manage containers."
                    ;;
                "git")
                    green "    Configure git on the Raspberry Pi to a specific account."
                    txt "    Usage: ${BLUE}rpi git${RESET} ${RED}<email>${RESET}"
                    txt "      ${RED}email:${RESET} The email for the git configuration."
                    ;;
                "firewall")
                    green "    Set up a custom firewall on the Raspberry Pi."
                    txt "    Usage: ${BLUE}rpi firewall${RESET} ${ORANGE}[--enable|-e|--disable|-d]${RESET}"
                    txt "      ${ORANGE}--enable, -e:${RESET} Enable the firewall."
                    txt "      ${ORANGE}--disable, -d:${RESET} Disable the firewall."
                    ;;
                *)
                    error "Command not found. No help text available."
                    ;;
                esac
                txt ""
                sleep 0.2
            done
        fi
    }
    
    # Adds the Raspberry Pi Wizard to the shell "path".
    function init() {
        description init "adds the Raspberry Pi Wizard shell script to your terminal path (MacOS)."

        info "Adding the Raspberry Pi Wizard to your terminal path..."
        declare -g project_path=$(pwd)
        script_path=$project_path/src/rpi-wizard.sh

        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo -e "\n# Raspberry Pi Wizard executable" >> ~/.zshrc || error "Failed to append to .zshrc file." || return 1
            echo -e "source $script_path" >> ~/.zshrc
            echo -e "export RPI_SETUP_WIZARD_PATH=$project_path \n" >> ~/.zshrc

            info "Added the following line to your .zshrc file:"
            txt "# Raspberry Pi Wizard executable"
            txt "source ${ORANGE}$script_path${RESET}"
            txt "export RPI_SETUP_WIZARD_PATH=${ORANGE}$project_path${RESET}"

            info "Restart your terminal to use the 'rpi' command globally."
        else
            info "Consider adding the following lines to your .bashrc/.zshrc/your config file:"
            txt "# Raspberry Pi Wizard executable"
            txt "source ${ORANGE}$script_path${RESET}"
            txt "export RPI_SETUP_WIZARD_PATH=${ORANGE}$project_path${RESET} "
        fi

        success "Ensure that the first path ends with ${ORANGE}'.../RaspberryPi-Setup-Wizard/src/rpi-wizard.sh'${RESET}."
    }

    # Updates the Raspberry Pi Wizard by pulling the latest changes from the repository.
    function rpi-update() {
        description update "updates the Raspberry Pi Wizard by pulling the latest changes from the repository."

        info "Updating the Raspberry Pi Wizard..."
        cd $RPI_SETUP_WIZARD_PATH || error "Failed to change directory to the Raspberry Pi Wizard." || return 1
        git pull origin main || error "Failed to update the Raspberry Pi Wizard." || return 1

        cd - || error "Failed to change directory back to the previous location." || return 1

        success "The Raspberry Pi Wizard has been updated."
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
        success "Currently linked to user: $usr, host: $host."
    }

    # Removes the host.json file.
    function unlink() {
        description unlink "removes the host.json file from the Raspberry Pi Wizard."

        if [ -f $RPI_SETUP_WIZARD_PATH/src/host.json ]; then
            rm $RPI_SETUP_WIZARD_PATH/src/host.json
        else
            error "No host.json file found. Consider running '${BLUE}rpi link ${RED}<username> <hostname>${RESET}' first." || return 1
        fi

        success "Unlinked the Raspberry Pi."
    }

    # Connects to the Raspberry Pi using SSH.
    function connect() {
        description connect "connects to the Raspberry Pi using SSH."

        info "Getting the username and hostname from the host.json file..."
        get-host-info || error "Failed to get the username and hostname. Consider running '${BLUE}rpi link ${RED}<username> <hostname>${RESET}' first." || return 1

        show-link

        info "Connecting to $hostname...\n"
        ssh $hostname
    }

    # Adds an SSH key to the Raspberry Pi.
    # $1: The passphrase for the SSH key.
    # $2: Wether to install fail2ban or not.
    function add-ssh() {
        description ssh "adds an SSH key to the Raspberry Pi for passwordless login."

        info "Getting the username and hostname from the host.json file..."
        get-host-info || error "Failed to get the username and hostname. Consider running '${BLUE}rpi link ${RED}<username> <hostname>${RESET}' first." || return 1
        
        show-link

        PASSPHRASE=""
        FAIL2BAN=false
        if [ $# -eq 1 ]; then
            if [[ "$1" == "--fail2ban" || "$1" == "-f" ]]; then
                FAIL2BAN=true
            else
                PASSPHRASE=$1
            fi

        elif [ $# -eq 2 ]; then
            if [[ "$1" == "--fail2ban" || "$1" == "-f" ]]; then
                FAIL2BAN=true
                PASSPHRASE=$2
            elif [[ "$2" == "--fail2ban" || "$2" == "-f" ]]; then
                FAIL2BAN=true
                PASSPHRASE=$1
            else
                error "Invalid arguments. Usage: ${BLUE}rpi ssh${RESET} ${ORANGE}[passphrase]${RESET} ${ORANGE}[--fail2ban|-f]${RESET}" || return 1
            fi
        fi

        if ssh $hostname "command -v python >/dev/null 2>&1"; then
            warning "SSH key already exists on $hostname. Skipping..."
        else
            info "Creating new SSH key..."
            ssh-keygen -f /Users/$global_user/.ssh/$hostname -C "$hostname" -N "$PASSPHRASE" || error "Failed to create new SSH key." || return 1

    	    info "Copying SSH key to $hostname, you will need to enter the password for $usr..."
    	    sleep 2
            ssh-copy-id -o StrictHostKeyChecking=no -i /Users/$global_user/.ssh/$hostname.pub $usr@$hostname.local || error "Failed to copy SSH key to $hostname." || return 1

    	    info "Adding $hostname to ~/.ssh/config file..."
            tempfile=$(mktemp)
            cat <<EOF > "$tempfile"
Host $hostname
  HostName $hostname.local
  User $usr
  IdentityFile ~/.ssh/$hostname

EOF
            cat ~/.ssh/config >> "$tempfile"
            mv "$tempfile" ~/.ssh/config

    	    success "You can now SSH into $hostname with 'ssh $hostname' or 'rpi connect'."
        fi

        if [ "$FAIL2BAN" = true ]; then
            if ssh $hostname "command -v fail2ban-client >/dev/null 2>&1"; then
                warning "fail2ban is already installed on $hostname. Skipping..."
            else
                
                info "Installing fail2ban on $hostname..."
                ssh $hostname "sudo apt-get install fail2ban -y" || error "Failed to install fail2ban on $hostname." || return 1

                info "Configuring fail2ban..."
                ssh $hostname "sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local" || error "Failed to copy jail.conf to jail.local." || return 1
                ssh $hostname "sudo sed -i '/\[sshd\]/,+8d' /etc/fail2ban/jail.local" || error "Failed to remove previous SSH configuration" || return 1
                ssh $hostname "sudo echo '[sshd]
enabled = true
filter = sshd
port = ssh
banaction = iptables-multiport
bantime = -1
maxretry = 3
logpath = %(sshd_log)s
backend = %(sshd_backend)s' | sudo tee -a /etc/fail2ban/jail.local > /dev/null" || error "Failed to add SSH configuration to fail2ban." || return 1

                info "Restarting fail2ban..."
                ssh $hostname "sudo service fail2ban restart" || error "Failed to restart fail2ban." || return 1

                success "fail2ban is now running on $hostname."
            fi
        fi
    }

    # Sets up the Raspberry Pi environment with ZSH, Oh My Zsh, Git, Neofetch, LSD, and custom aliases.
    function env() {
        description env "sets up the Raspberry Pi environment with ZSH, Oh My Zsh, Git, Neofetch, LSD, and custom aliases."

        info "Getting the username and hostname from the host.json file..."
        get-host-info || error "Failed to get the username and hostname. Consider running '${BLUE}rpi link ${RED}<username> <hostname>${RESET}' first." || return 1
        
        show-link

	    info "Updating and Upgrading packages..."
	    ssh $hostname "sudo apt-get update && sudo apt-get upgrade -y" || error "Failed to connect to $host. Consider running '${BLUE}rpi ssh${RESET}' first." || return 1

	    info "Installing ZSH..."
	    if ! ssh $hostname "command -v zsh >/dev/null 2>&1"; then
	    	ssh $hostname "sudo apt-get install zsh -y" || error "Failed to install ZSH." || return 1
	    	ssh $hostname "chsh -s $(which zsh)" || error "Failed to set ZSH as the default shell." || return 1
        else 
            warning "ZSH is already installed. Skipping..."
            ssh $hostname "zsh --version"
	    fi

	    info "Installing Git..."
	    if ! ssh $hostname "command -v git >/dev/null 2>&1"; then
	    	ssh $hostname "sudo apt-get install git -y" || error "Failed to install Git." || return 1
        else 
            warning "Git is already installed. Skipping..."
            ssh $hostname "git --version"
	    fi

	    info "Installing Oh My Zsh..."
	    if ssh $hostname "command -v omz >/dev/null 2>&1"; then
	    	ssh $hostname "sh -c $(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || error "Failed to install Oh My Zsh." || return 1
	    	ssh $hostname "sed -i '/ZSH_THEME=/d' ~/.zshrc && sed -i '1iZSH_THEME=\"candy\"' ~/.zshrc" || error "Failed to set ZSH_THEME." || return 1

	    	ssh $hostname "sudo chown -R 1000:1000 ~/.oh-my-zsh" || error "Failed to change ownership of Oh My Zsh." || return 1
	    	ssh $hostname "sudo git clone https://github.com/zsh-users/zsh-autosuggestions /home/$username/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
	    	ssh $hostname "sudo git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/$username/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

	    	ssh $hostname "sed -i '/plugins=(git)/d' ~/.zshrc && sed -i '1iplugins=(git zsh-autosuggestions zsh-syntax-highlighting)' ~/.zshrc"
        else 
            warning "Oh My Zsh is already installed. Skipping..."
            ssh $hostname "omz version"
	    fi

	    info "Installing Neofetch..."
	    if ! ssh $hostname "command -v neofetch >/dev/null 2>&1"; then
	    	ssh $hostname "sudo apt-get install neofetch -y" || error "Failed to install Neofetch." || return 1
	    	ssh $hostname "echo neofetch >> ~/.zshrc"
        else 
            warning "Neofetch is already installed. Skipping..."
            ssh $hostname "neofetch --version"
	    fi

	    info "Installing lsd..."
	    if ! ssh $hostname "command -v lsd >/dev/null 2>&1"; then
	    	ssh $hostname "sudo apt-get install lsd -y" || error "Failed to install lsd." || return 1
        else 
            warning "lsd is already installed. Skipping..."
            ssh $hostname "lsd --version"
	    fi

        info "Adding aliases and .zshenv..."
        if ! ssh $hostname "test -f ~/.aliases"; then
            ssh $hostname "curl -O $ALIASES_PATH > ~/.aliases" || error "Failed to add aliases file." || return 1
        else 
            warning "Aliases file already exists. Skipping..."
        fi
        if ! ssh $hostname "test -f ~/.zshenv"; then
            ssh $hostname "curl -O $ZSHENV_PATH > ~/.zshenv" || error "Failed to add .zshenv file." || return 1
        else
            warning ".zshenv file already exists. Skipping..."
        fi

        info "Installing unattended-upgrades..."
        if ! ssh $hostname "command -v unattended-upgrades >/dev/null 2>&1"; then
            ssh $hostname "sudo apt-get install unattended-upgrades -y" || error "Failed to install unattended-upgrades." || return 1

            info "Removing previous configuration..."
            ssh $hostname "sudo rm /etc/apt/apt.conf.d/20auto-upgrades" || error "Failed to remove 20auto-upgrades. Please check permissions." || return 1
            ssh $hostname "sudo rm /etc/apt/apt.conf.d/50unattended-upgrades"

            info "Adding new configuration..."
            ssh $hostname "sudo curl -O https://raw.githubusercontent.com/MorganKryze/RaspberryPi-Setup-Wizard/main/conf/20auto-upgrades > /etc/apt/apt.conf.d/20auto-upgrades" || error "Failed to add 20auto-upgrades. Please check permissions." || return 1
            ssh $hostname "sudo curl -O https://raw.githubusercontent.com/MorganKryze/RaspberryPi-Setup-Wizard/main/conf/50unattended-upgrades > /etc/apt/apt.conf.d/50unattended-upgrades" || error "Failed to add 50unattended-upgrades. Please check permissions." || return 1

            info "Enabling unattended-upgrades..."
            ssh $hostname "sudo unattended-upgrade -d" || error "Failed to enable unattended-upgrades." || return 1
        else 
            warning "unattended-upgrades is already installed. Skipping..."
        fi

	    info "Removing 'NO WARRANTY' welcome message..."
	    ssh $hostname "touch ~/.hushlogin"

	    warning "Rebooting in 5 sec, please wait a few moments."
	    sleep 5
	    ssh $hostname "sudo reboot"

	    info "Rebooting..."
	    sleep 45

	    success "$hostname is now ready to use."
    }

    # Sets up Docker on the Raspberry Pi.
    # $1: Install Portainer.
    function docker() {
        description docker "sets up Docker on the Raspberry Pi."

        info "Getting the username and hostname from the host.json file..."
        get-host-info || error "Failed to get the username and hostname. Consider running '${BLUE}rpi link ${RED}<username> <hostname>${RESET}' first." || return 1
        
        show-link

	    PORTAINER=false
        if [[ "$1" == "--portainer" || "$1" == "-p" ]]; then
            PORTAINER=true
        fi

        info "Setting up working directories..."
        ssh $hostname "mkdir -p /home/$username/containers_data" || warning "Failed to create working directories"

        info "Checking if Docker is installed..."
        if ! ssh $hostname "command -v docker >/dev/null 2>&1"; then
            ssh $hostname "curl -fsSL https://get.docker.com | sh" || error "Failed to install Docker on $hostname" || return 1
        else
            warning "Docker is already installed"
            ssh $hostname "docker --version" || error "Failed to get Docker version" || return 1
        fi

	    info "Adding $username to the Docker group..."
	    if ! ssh $hostname "groups $username | grep -q docker"; then
	    	ssh $hostname "sudo usermod -aG docker $username" || error "Failed to add $username to the Docker group" || return 1
        else
            warning "$username is already in the Docker group, current groups:"
            ssh $hostname "groups $username" || error "Failed to get $username groups" || return 1
	    fi

	    info "Installing lazydocker..."
        if ! ssh $hostname "command -v lazydocker >/dev/null 2>&1"; then
            ssh $hostname "curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | zsh" || error "Failed to install lazydocker on $hostname" || return 1
            ssh $hostname "sudo ln -s /home/$username/.local/bin/lazydocker /usr/bin/" || error "Failed to create symlink for lazydocker" || return 1
        else
            warning "lazydocker is already installed"
            ssh $hostname "lazydocker --version" || error "Failed to get lazydocker version" || return 1
        fi

	    warning "Rebooting in 5 sec, please wait a few moments."
	    sleep 5

	    ssh $hostname "sudo reboot" || error "Failed to reboot $hostname" || return 1

	    info "Waiting for $hostname to reboot..."
	    sleep 45

	    success "Docker is now set up on $hostname"

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
            info "Installing Portainer on $hostname..."
            ssh $hostname "sudo docker volume create portainer_data"
            ssh $hostname "sudo docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce"

            info "Fixing Portainer permissions..."
            if [ -f /portainer ]; then
                warning "Portainer directory does not exist, creating it"
                ssh $hostname "sudo mkdir /portainer"
            fi
	        ssh $hostname "sudo chown -R 1000:1000 /portainer" || error "Failed to fix Portainer permissions. Consider checking the directory permissions."

	    	success "Portainer is now running on at ${LINK}http://$ip_address:9000${RESET}"
	    fi
    }

    # Configures git on the Raspberry Pi to a specific account.
    # $1: The email for the git configuration.
    function setup-git() {
        description git "configures git on the Raspberry Pi to a specific account."

        info "Getting the username and hostname from the host.json file..."
        get-host-info || error "Failed to get the username and hostname. Consider running '${BLUE}rpi link ${RED}<username> <hostname>${RESET}' first." || return 1

        show-link

    	info "Generating SSH key pair for $hostname..."
    	ssh $hostname "ssh-keygen -t ed25519 -C "$1" -f ~/.ssh/id_ed25519" || error "Failed to generate SSH key pair" || return 1

    	info "Starting the ssh-agent in the background..."
    	ssh $hostname "eval "$(ssh-agent -s)"" || error "Failed to start the ssh-agent in the background" || return 1

    	info "Adding hithub as known hosts for ssh..."
    	ssh $hostname "echo "Host github.com
      IgnoreUnknown UseKeychain
      AddKeysToAgent yes
      UseKeychain yes
      IdentityFile ~/.ssh/id_ed25519" > ~/.ssh/config" || error "Failed to add github as known hosts for ssh" || return 1

    	info "Adding your SSH private key to the ssh-agent..."
    	ssh $hostname "ssh-add ~/.ssh/id_ed25519" || error "Failed to add your SSH private key to the ssh-agent" || return 1

    	info "Go to https://github.com/settings/keys and add the following SSH public key:"
    	ssh $hostname "cat ~/.ssh/id_ed25519.pub" || error "Failed to display the SSH public key" || return 1

        info "Setting up username and email..."
    	ssh $hostname "git config --global user.name $username" || error "Failed to set up username" || return 1
    	ssh $hostname "git config --global user.email $1" || error "Failed to set up email" || return 1
    
    	success "Git is now set up on $hostname"
    }

    # Sets up a firewall on the Raspberry Pi.
    # $1: Enable or disable the firewall.
    function firewall() {
        description firewall "sets up a custom firewall on the Raspberry Pi."

        info "Getting the username and hostname from the host.json file..."
        get-host-info || error "Failed to get the username and hostname. Consider running '${BLUE}rpi link ${RED}<username> <hostname>${RESET}' first." || return 1

        show-link

        ENABLE=false
        DISABLE=false

        if [[ "$1" == "--enable" || "$1" == "-e" ]]; then
            ENABLE=true
        elif [[ "$1" == "--disable" || "$1" == "-d" ]]; then
            DISABLE=true
        else
            warning "No option specified, only setting up UFW"
            sleep 2
        fi

        if ssh $hostname "sudo ufw status" >/dev/null 2>&1; then
            warning "UFW is already installed on $hostname."
            ssh $hostname "sudo ufw status" || error "Failed to get UFW status" || return 1
        else 
            info "Installing UFW..."
	        ssh $hostname "sudo apt-get install ufw -y" || error "Failed to install UFW on $hostname" || return 1

	        info "Setting up UFW on $hostname:"
            info "Denying all incoming connections..."
	        ssh $hostname "sudo ufw default deny incoming" || error "Failed to deny all incoming connections" || return 1

            info "Allowing all outgoing connections..."
	        ssh $hostname "sudo ufw default allow outgoing" || error "Failed to allow all outgoing connections" || return 1

            info "Allowing SSH connections and limiting them (prevent from bruteforce)..."
	        ssh $hostname "sudo ufw allow ssh" || error "Failed to allow SSH connections" || return 1
	        ssh $hostname "sudo ufw limit ssh" || error "Failed to limit SSH connections" || return 1
        fi

        warning "Please make sure to allow other ports if needed before enabling UFW."
        info "To see all ports currenty used, type: \"sudo netstat -tuln\"."
        info "To allow a port, use: \"sudo ufw allow <port>\" and to deny a port, use \"sudo ufw deny <port>\"."
        sleep 3

        if [ "$ENABLE" = true ] || [ "$DISABLE" = true ]; then
            function get_ufw_status() {
                ssh $hostname "sudo ufw status | awk '/Status:/{print \$2}'"
            }
            ufw_status=$(get_ufw_status)

            if [ "$ENABLE" = true ]; then
                if [[ "$ufw_status" == "active" ]]; then
                    error "UFW is already enabled."
                else
                    info "Enabling UFW..."
                    ssh $hostname "sudo ufw enable" || error "Failed to enable UFW" || return 1

                    ufw_status=$(get_ufw_status)
                    if [[ "$ufw_status" == "active" ]]; then
                        success "UFW is now enabled on $hostname."
                    else 
                        error "Failed to enable UFW."
                    fi
                fi
            elif [ "$DISABLE" = true ]; then
                if [[ "$ufw_status" == "inactive" ]] then
                    error "UFW is already disabled."
                else
                    info "Disabling UFW..."
                    ssh $hostname "sudo ufw disable" || error "Failed to disable UFW" || return 1

                    ufw_status=$(get_ufw_status)
                    if [[ "$ufw_status" == "inactive" ]]; then
                        success "UFW is now disabled on $hostname."
                    else 
                        error "Failed to disable UFW."
                    fi
                fi
            else
            fi
        else
        success "UFW is now set up on $hostname"
        fi
    }

    case $# in
    0)
        intro
        functions
        ;;
    1)
        case $1 in
            help)
                help
                ;;
            init)
                init
                ;;
            update)
                rpi-update
                ;;
            link)
                error "Usage: ${BLUE}rpi link ${RED}<username> <hostname>${RESET}"
                ;;
            unlink)
                unlink
                ;;
            connect)
                connect
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
            git)
                error "Usage: ${BLUE}rpi git ${RED}<email>${RESET}"
                ;;
            firewall)
                firewall
                ;;
            *)
                error "Unknown command: \"$1\""
                ;;
        esac
        ;;
    2)
        case $1 in
            help)
                help $2
                ;;
            init)
                error "Usage: ${BLUE}rpi init"
                ;;
            update)
                error "Usage: ${BLUE}rpi update"
                ;;
            link)
                error "Usage: ${BLUE}rpi link ${RED}<username> <hostname>${RESET}"
                ;;
            unlink)
                error "Usage: ${BLUE}rpi unlink"
                ;;
            connect)
                error "Usage: ${BLUE}rpi connect"
                ;;
            ssh)
                add-ssh $2
                ;;
            env)
                error "Usage: ${BLUE}rpi env"
                ;;
            docker)
                if [[ "$2" == "--portainer" || "$2" == "-p" ]]; then
                    docker $2
                else 
                    error "Unknown option: \"$2\""
                fi
                ;;
            git)
                setup-git $2
                ;;
            firewall)
                if [[ "$2" == "--enable" || "$2" == "-e" || "$2" == "--disable" || "$2" == "-d" ]]; then
                    firewall $2
                else 
                    error "Unknown option: \"$2\""
                fi
                ;;
            *)
                error "Unknown command: \"$1\""
                ;;
        esac
        ;;
    *)
        case $1 in
            help)
                error "Usage: ${BLUE}rpi help ${ORANGE}[command]${RESET}"
                ;;
            init)
                error "Usage: ${BLUE}rpi init"
                ;;
            update)
                error "Usage: ${BLUE}rpi update"
                ;;
            link)
                if [ $# -eq 3 ]; then
                    link $2 $3
                else
                    error "Usage: ${BLUE}rpi link ${RED}<username> <hostname>${RESET}"
                fi
                ;;
            unlink)
                unlink
                ;;
            connect)
                error "Usage: ${BLUE}rpi connect"
                ;;
            ssh)
                if [ $# -eq 3 ]; then
                    add-ssh $2 $3
                else
                    error "Usage: ${BLUE}rpi ssh ${ORANGE}[passphrase]${RESET} ${ORANGE}[--fail2ban|-f]${RESET}"
                fi
                ;;
            env)
                env
                ;;
            docker)
                error "Usage: ${BLUE}rpi docker ${ORANGE}[--portainer|-p${RESET}"
                ;;
            git)
                error "Usage: ${BLUE}rpi git ${RED}<email>${RESET}"
                ;;
            firewall)
                error "Usage: ${BLUE}rpi firewall ${ORANGE}[--enable|-e|--disable|-d]${RESET}"
                ;;
            *)
                error "Unknown command: \"$1\""
                ;;
        esac
        ;;
    esac    
}
# =============================================================================
