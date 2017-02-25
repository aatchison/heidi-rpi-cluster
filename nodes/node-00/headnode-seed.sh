#!/usr/bin/env bash

# We will need to install some packages on the head node in order to manage the rest of the nodes.
# I'm starting with a raspbian jessie base image
# First of all, I need to install a few packages for development 

# roughly set top level directory if run from node-00/directory
TOP=.

# enviroment variable inclues
ENV_DIR=${TOP}/env
source ${ENV_DIR}/project
source ${ENV_DIR}/cluster

# function includes
BASH_INC=${TOP}/bin/bash/include
source ${BASH_INC}/sys_os_func
source ${BASH_INC}/display_func


# print project info to terminal
source bin/bash/include/welcome_message

function install_devenv_packages () {
    info_msg "Installing: Development environment packages for the headnode"
    enter_the_sudo "apt-get update"
    install_package " git vim htop "
}


function clone_source () {
    SRC_URI= ${1}
    PROJ_NAME=${2}
    info_msg "Operation: create ./source directory"
    mkdir -vp ./source
    pushd  ./source/
    info_msg "Git Checkout: ${1} into ./source/${2}"
    echo $( git clone "${1}" 1>&2 )
    popd
    
}

function install_docker_engine () {
    info_msg "Installing: docker-engine from hypriot script"
    info_msg "[WAIT]: Please wait for task to complete"
    info_msg "[WAIT]: Downloading and running hypriot docker-script"
    echo $(curl -s https://packagecloud.io/install/repositories/Hypriot/Schatzkiste/script.deb.sh | sudo bash 1>&2 )
    echo "${EXEC}"
    info_msg "[WAIT]: Installing docker-hypriot" 
    install_package "docker-hypriot"
    info_msg "[WAIT]: adding aatchison user to docker group"
    enter_the_sudo "usermod -aG docker aatchison"  ### <--- set username etc in the system setup
    info_msg "[WAIT]: enable docker service "
    enter_the_sudo "systemctl enable docker.service"
    
    info_msg "[DISABLED]Get Source: rpi-docker-builder"
    #clone_source 'https://github.com/hypriot/rpi-docker-builder.git'
    #cd source/rpi-docker-builder
    #info_msg "[WAIT]: running build.sh script"
    #enter_the_sudo "./build.sh"
    #info_msg "[DISABLED][WAIT]: running run-builder.sh script"
    #enter_the_sudo "./run-builder.sh"
}

function bootstrap_system () {
    install_docker_engine    
}

# Initial dev packages
install_devenv_packages

# bootstrap system
bootstrap_system
 
