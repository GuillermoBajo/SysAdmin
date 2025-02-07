#!/bin/bash -x
###############################################################################################################
## This script is used to provision and configure a node in a Kubernetes cluster using K3s.                  ##
###############################################################################################################

# Variable definitions
HOSTNAME=$1
NODEIP=$2
MASTERIP=$3
NODETYPE=$4

# Timezone configuration
timedatectl set-timezone Europe/Madrid

cd /vagrant
# Change the hostname
echo $1 > /etc/hostname
hostname $1

# Update the /etc/hosts file to include the IP addresses and hostnames of all nodes
{ echo 192.168.1.201 w1; echo 192.168.1.202 w2
  echo 192.168.1.203 w3; cat /etc/hosts
} > /etc/hosts.new
mv /etc/hosts{.new,}

# Copy the K3s binary to the /usr/local/bin/ directory
cp k3s /usr/local/bin/

# K3s installation depending on the type of node

# If the node is a master node, install K3s in server mode
if [ $NODETYPE = "master" ]; then 
  INSTALL_K3S_SKIP_DOWNLOAD=true \
  ./install.sh server \
   # Access token to join the cluster
  --token "wCdC16AlP8qpqqI53DM6ujtrfZ7qsEM7PHLxD+Sw+RNK2d1oDJQQOsBkIwy5OZ/5" \
  # Network interface for Flannel
  --flannel-iface enp0s8 \
  # IP address the K3s server will bind to
  --bind-address $NODEIP \
   # Node IP address and name
  --node-ip $NODEIP --node-name $HOSTNAME \
   # Disable Traefik and ServiceLB
  --disable traefik \
  --disable servicelb \
  --node-taint k3s-controlplane=true:NoExecute 
  
  # Copy the K3s configuration file for remote access
  cp /etc/rancher/k3s/k3s.yaml /vagrant
  
else
  # If the node is a worker node, install K3s in agent mode
  INSTALL_K3S_SKIP_DOWNLOAD=true \
  # URL of the master server
  ./install.sh agent --server https://${MASTERIP}:6443 \
  # Access token to join the cluster
  --token "wCdC16AlP8qpqqI53DM6ujtrfZ7qsEM7PHLxD+Sw+RNK2d1oDJQQOsBkIwy5OZ/5" \
  # Node IP address, name, and Flannel configuration
  --node-ip $NODEIP --node-name $HOSTNAME --flannel-iface enp0s8
fi
