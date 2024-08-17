#!/bin/bash

#============ Colors ============

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
ORANGE='\033[0;33m'
RESET='\033[0m'

# ===============================

#============ Tools =============

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

function gethost() {
    if [ -f host.json ]; then
        username=$(jq -r '.username' host.json)
        hostname=$(jq -r '.hostname' host.json)
        echo "$username"
        echo "$hostname"
    else
        # No file found.
        return 1
    fi
}

# ===============================

#============ Functions =========

function rpi() {
    case $# in
        0)
        
            display-banner

            echo "Usage: rpi [init|link|unlink] ..."
            ;;
        1)
            case $1 in
                init)
                    echo "Usage: rpi init <username> <hostname>"
                    ;;
                link)
                    echo "Usage: rpi link <config_file>"
                    ;;
                unlink)
                    unlink
                    ;;
                *)
                    echo "Unknown command: $1"
                    ;;
            esac
            ;;
        *)
            case $1 in
                init)
                    init $2 $3
                    ;;
                link)
                    link $2
                    ;;
                unlink)
                    unlink
                    ;;
                *)
                    echo "Unknown command: $1"
                    ;;
            esac
            ;;
    esac
}




function init() {
    script_path=$(pwd)/rpi_wizard.sh
    echo $script_path

}

function link() {
    if [ "$#" -ne 2 ]; then
        echo "Usage: rpi link <username> <hostname>"
        exit 1
    fi

    usr=$1
    host=$2

    storage="{
     \"username\": \"$usr\",
     \"hostname\": \"$host\"
    }"

    echo "$storage" > host.json
}

function unlink() {
    if [ -f host.json ]; then
        rm host.json
    else
        echo "No link found."
    fi
}

# ===============================


# display-banner

#     echo "Open source Raspberry Pi wizard tool."
#     echo "Licensed under the MIT License, Yann M. Vidamment © 2024."
#     echo "https://github.com/MorganKryze/RaspberryPi-Setup-Wizard/"
#     sleep 0.5
#     echo -e "\n=============================================================================\n"
#     sleep 0.5

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