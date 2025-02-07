#!/bin/bash

# This script allows you to define, start, or stop a VM on a remote server.
# It has two modes of operation:
# 1. Interactive: If no parameters are provided when running the script, 
#    options will be displayed for the user to interact with the script.
# 2. From a configuration file: If a configuration file is provided as a 
#    parameter, the script will read instructions from the file and execute 
#    the corresponding actions.

# Verify the number of parameters provided
if [ $# -eq 0 ]; then
    # Display options to the user
    echo "This script will allow you to define, start, or stop a VM until you choose the exit option."
    while true; do
        echo "Options:"
        echo "1. Define a VM"
        echo "2. Start a VM"
        echo "3. Stop a VM"
        echo "4. Exit"

        # Read the user's choice
        read option

        # Check the selected option and execute the corresponding action
        case $option in
            1)
                echo "Enter the name of the VM you want to define:"
                read name
                ssh -n a842748@155.210.154.204 "cd /../../misc/alumnos/as2/as22023/a842748 && virsh -c qemu:///system define $name.xml"
                ;;
            2)
                echo "Enter the name of the VM you want to start:"
                read name
                ssh a842748@155.210.154.204 "virsh -c qemu:///system start $name"
                ;;
            3)
                echo "Enter the name of the VM you want to stop:"
                read name
                ssh a842748@155.210.154.204 "virsh -c qemu:///system shutdown $name"
                ;;
            4)
                echo "You have selected to exit, goodbye!"
                exit 0
                ;;
            *)
                echo "Error: Invalid option. Please select an option between 1 and 4."
                exit 1
                ;;
        esac
    done

elif [ $# -eq 1 ]; then
    file=$1
    if [ ! -f $file ]; then
        echo "The file $file does not exist."
        exit 1
    fi
    
    while IFS=' ' read -r code vm_name; do
        case $code in
            1)
                ssh -n a842748@155.210.154.204 "cd ~/misc/alumnos/as2/as22023/a842748 && virsh -c qemu:///system define $vm_name"
                ;;
            2)
                ssh -n a842748@155.210.154.204 "virsh -c qemu:///system start $vm_name"
                ;;
            3)
                ssh -n a842748@155.210.154.204 "virsh -c qemu:///system shutdown $vm_name"
                ;;
            *)
                echo "Error: Invalid action number in the file."
                exit 1
                ;;
        esac
    done < $file
else
    echo "Incorrect number of parameters. Usage: ./pr1_adsis.sh [config_file]"
fi
