#!/bin/bash
repo=chopper-resonance-tuner
repo_path=~/chopper-resonance-tuner/

if [ "$(id -u)" = "0" ]; then
    echo "Script must run from non-root !!!"
    exit
fi

result_folder=~/printer_data/config/adxl_results/chopper_magnitude
if [ ! -d "$result_folder" ]; then # Проверка папки chopper_magnitude & создание
    mkdir -p "$result_folder"
    # echo "Make $result_folder direction successfully complete"
fi

g_shell_path=~/klipper/klippy/extras/
g_shell_name=gcode_shell_command.py
if [ -f "$g_shell_path/$g_shell_name" ]; then
     echo "Including $g_shell_name aborted, $g_shell_name already exists in $g_shell_path"
else
    sudo cp "$repo_path/$g_shell_name" $g_shell_path
    # echo "Copying $g_shell_name to $g_shell_path successfully complete"
fi

cfg_name=chopper_tune.cfg
cfg_path=~/printer_data/config/Chopper-Tuner/
cfg_incl_path=~/printer_data/config/printer.cfg

mkdir -p "${cfg_path}"
ln -sf "$repo_path/$cfg_name" $cfg_path

sudo apt update
sudo apt-get install libatlas-base-dev libopenblas-dev
sudo pip install -r "$repo_path/"wiki/requirements.txt