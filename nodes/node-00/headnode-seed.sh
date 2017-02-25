#!/usr/bin/env bash

# We will need to install some packages on the head node in order to manage the rest of the nodes.
# I'm starting with a raspbian jessie base image
# First of all, I need to install a few packages for development purposes

function info_msg () {
    echo "--/###::/__:  ${1} "
    echo " "
}

function enter_the_sudo () {
    info_msg "Entering sudo"
    info_msg "Waiting for task to complete: ${1}"
    EXEC=$(sudo ${1})
    echo "${EXEC}"
    echo " "
}

function install_devenv_packages () {
    info_msg "Installing: Development environment packages for the headnode"
    enter_the_sudo """apt-get update"""
    enter_the_sudo """apt-get install -y \
    git \
    vim \
    htop
    """
}

function clone_source () {
    SRC_URI= ${1}
    PROJ_NAME=${2}
    info_msg "Operation: create ./source directory"
    mkdir -vp ./source
    pushd  ./source/
    info_msg "Git Checkout: ${1} into ./source/${2}"
    git clone "${1}"
    popd
    
}

function install_docker_engine () {
    info_msg "Installing: docker-engine from hypriot script"
    info_msg "[WAIT]: Please wait for task to complete"
    info_msg "[WAIT]: Downloading and running hypriot docker-script"
    EXEC=$(curl -s https://packagecloud.io/install/repositories/Hypriot/Schatzkiste/script.deb.sh | sudo bash)
    echo "${EXEC}"
    info_msg "[WAIT]: Installing docker-hypriot" 
    enter_the_sudo "apt-get install -y docker-hypriot=1.10.3-1"
    info_msg "[WAIT]: adding aatchison user to docker group"
    enter_the_sudo "usermod -aG docker aatchison"  ### <--- set username etc in the system setup
    info_msg "[WAIT]: enable docker service "
    enter_the_sudo "systemctl enable docker.service"
    info_msg "Get Source: rpi-docker-builder"
    clone_source 'https://github.com/hypriot/rpi-docker-builder.git'
    cd source/rpi-docker-builder
    info_msg "[WAIT]: running build.sh script"
    enter_the_sudo """bash ./build.sh"""
    info_msg "[WAIT]: running run-builder.sh script"
    enter_the_sudo """bash ./run-builder.sh"""
}

function bootstrap_system () {
    install_docker_engine
     
}

# Initial dev packages
install_devenv_packages

# bootstrap system
bootstrap_system
  
