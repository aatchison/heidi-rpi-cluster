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

########
# the following is from : 
# http://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash

function ping_hosts() {
    host_list=(${1})
    for host in ${host_list[@]}
        do
            HOST_NAME=${CLUSTER_NAME}-$host
            info_msg "Pinging Host: ${HOST_NAME}"
            ping -c 3 ${HOST_NAME}
        done
}

function reboot_hosts() {
    host_list=(${1})
    for host in ${host_list[@]}
        do
            HOST_NAME=${CLUSTER_NAME}-$host
            info_msg "Rebooting Host: ${HOST_NAME}"
            echo $(ssh -t ${HOST_NAME} sudo reboot 1>&2)
        done
}

function poweroff_hosts() {
    host_list=(${1})
    for host in ${host_list[@]}
        do
            HOST_NAME=${CLUSTER_NAME}-$host
            info_msg "Shutting Down Host: ${HOST_NAME}"
            echo $(ssh -t ${HOST_NAME} sudo poweroff 1>&2)
        done
}

function remote_command() {
    host_list=(${1})
    host_command=${2}
    for host in ${host_list[@]}
        do
            HOST_NAME=${CLUSTER_NAME}-$host
            info_msg "Running Command: ${host_command} on Host: ${HOST_NAME}"
            echo $(ssh -t ${HOST_NAME} ${host_command} 1>&2)
        done
}

function get_host_ip() {
    host_list=(${1})
    host_command=${2}
    for host in ${host_list[@]}
        do
            HOST_NAME=${CLUSTER_NAME}-$host
            info_msg "Get IP: ${host_command} on Host: ${HOST_NAME}"
            echo $(ssh -t ${HOST_NAME} ip a 1>&2)
        done
}

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

while getopts "h?vproci:" opt; do
    case "$opt" in
    h|\?)
        echo "show help"
        exit 0
        ;;
    v)  verbose=1
        echo ${verbose}
        ;;
    p|\?)  ping_hosts "${OPTARG}"
        ;;
    r|\?)  reboot_hosts "${OPTARG}"
        ;;
    o|\?)  poweroff_hosts "${OPTARG}"
        ;;
    c|\?)  remote_command "${OPTARG}" "${3}"
        ;;
    i|\?)  get_host_ip "${OPTARG}"
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

echo "verbose=$verbose, output_file='$output_file', Leftovers: $@"

# End of file
