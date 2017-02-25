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
            echo $(ping -c 3 ${HOST_NAME})
        done
}

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

while getopts "h?vp:" opt; do
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
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

echo "verbose=$verbose, output_file='$output_file', Leftovers: $@"

# End of file
