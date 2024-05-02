#!/bin/bash

CONFIG_PATH="${HOME}/printer_data/config"
REPO_PATH="${HOME}/chopper-resonance-tuner"
green=$(echo -en "\e[92m")
red=$(echo -en "\e[91m")
cyan=$(echo -en "\e[96m")
white=$(echo -en "\e[39m")

set -eu
export LC_ALL=C


function preflight_checks {
    if [ "$EUID" -eq 0 ]; then
        echo "[PRE-CHECK] This script must not be run as root!"
        exit -1
    fi

    if [ "$(sudo systemctl list-units --full -all -t service --no-legend | grep -F 'klipper.service')" ]; then
        printf "[PRE-CHECK] Klipper service found! Continuing...\n\n"
    else
        echo "[ERROR] Klipper service not found, please install Klipper first!"
        exit -1
    fi
}

function uninstall_macros {
    local yn
    while true; do
        read -p "${cyan}Do you really want to uninstall Chopper-Tuner? (Y/n):${white} " yn
        case "${yn}" in
          Y|y|Yes|yes)
            if [ -d "${CONFIG_PATH}/Chopper-Tuner" ]; then
                chmod -R 777 "${CONFIG_PATH}/Chopper-Tuner"
                rm -R "${CONFIG_PATH}/Chopper-Tuner"
                echo "${green}Chopper-Tuner config folder removed"
            else
                echo "${red}Chopper-Tuner config folder not found!"
            fi

            if [ -d "${REPO_PATH}" ]; then
                chmod -R 777 "${REPO_PATH}"
                rm -R "${REPO_PATH}"
                echo "${green}Chopper-Tuner folder removed"
            else
                echo "${red}Chopper-Tuner folder not found!"
            fi
            break;;
          N|n|No|no|"")
            exit 0;;
          *)
            echo "${red}Invalid Input!";;
        esac
    done
}

preflight_checks
uninstall_macros
