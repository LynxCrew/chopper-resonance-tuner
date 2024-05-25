#!/bin/bash

CONFIG_PATH="${HOME}/printer_data/config"
REPO_PATH="${HOME}/chopper-resonance-tuner"

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

function check_download {
    local chopperdirname chopperbasename
    chopperdirname="$(dirname ${REPO_PATH})"
    chopperbasename="$(basename ${REPO_PATH})"

    if [ ! -d "${REPO_PATH}" ]; then
        echo "[DOWNLOAD] Downloading Chopper-Tuner repository..."
        if git -C $chopperdirname clone https://github.com/LynxCrew/chopper-resonance-tuner.git $chopperbasename; then
            chmod +x ${REPO_PATH}/install.sh
            chmod +x ${REPO_PATH}/update.sh
            chmod +x ${REPO_PATH}/uninstall.sh
            printf "[DOWNLOAD] Download complete!\n\n"
        else
            echo "[ERROR] Download of Chopper-Tuner git repository failed!"
            exit -1
        fi
    else
        printf "[DOWNLOAD] Chopper-Tuner repository already found locally. Continuing...\n\n"
    fi
}

function link_extension {
    echo "[INSTALL] Linking extension to Klipper..."
	
	mkdir -p "${CONFIG_PATH}/Chopper-Tuner"

	ln -sf "${REPO_PATH}/chopper_tune.cfg" "${CONFIG_PATH}/Chopper-Tuner"
}

function install_dependencies {
    sudo apt update
    sudo apt-get install libatlas-base-dev libopenblas-dev
    # Reuse system libraries
    python -m venv --system-site-packages $REPO_PATH/.venv
    source $REPO_PATH/.venv/bin/activate

    pip install -r $REPO_PATH/wiki/requirements.txt
}

function restart_klipper {
    echo "[POST-INSTALL] Restarting Klipper..."
    sudo systemctl restart klipper
}


printf "\n======================================\n"
echo "- Chopper-Tuner install script -"
printf "======================================\n\n"


# Run steps
preflight_checks
check_download
install_dependencies
link_extension
restart_klipper
