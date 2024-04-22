#!/bin/bash -x
###############################################################################################################
## Este script se utiliza para aprovisionar y configurar un nodo en un clúster de Kubernetes utilizando K3s. ##
###############################################################################################################

# Definición de variables
HOSTNAME=$1
NODEIP=$2
MASTERIP=$3
NODETYPE=$4

# Cnfiguración de la zona horaria
timedatectl set-timezone Europe/Madrid

cd /vagrant
# Cambiar el nombre del host
echo $1 > /etc/hostname
hostname $1

# Actualización del archivo /etc/hosts para incluir las direcciones IP y nombres de host de todos los nodos
{ echo 192.168.1.201 w1; echo 192.168.1.202 w2
  echo 192.168.1.203 w3; cat /etc/hosts
} > /etc/hosts.new
mv /etc/hosts{.new,}

# Copiar el binario de K3s al directorio /usr/local/bin/
cp k3s /usr/local/bin/

# Instalación de K3s dependiendo del tipo de nodo

# Si el nodo es un nodo maestro, se instala K3s en modo servidor
if [ $NODETYPE = "master" ]; then 
  INSTALL_K3S_SKIP_DOWNLOAD=true \
  ./install.sh server \
   # Token de acceso para unirse al clúster
  --token "wCdC16AlP8qpqqI53DM6ujtrfZ7qsEM7PHLxD+Sw+RNK2d1oDJQQOsBkIwy5OZ/5" \
  # Interfaz de red para Flannel
  --flannel-iface enp0s8 \
  # Dirección IP a la que se enlazará el servidor de K3s
  --bind-address $NODEIP \
   # Dirección IP y nombre del nodo
  --node-ip $NODEIP --node-name $HOSTNAME \
   # Deshabilitar Traefik y ServiceLB
  --disable traefik \
  --disable servicelb \
  --node-taint k3s-controlplane=true:NoExecute 
  
  # Copiar el archivo de configuración de K3s para acceso remoto
  cp /etc/rancher/k3s/k3s.yaml /vagrant
  
else
  # Si el nodo es un nodo de trabajo, se instala K3s en modo agente
  INSTALL_K3S_SKIP_DOWNLOAD=true \
  # URL del servidor maestro
  ./install.sh agent --server https://${MASTERIP}:6443 \
  # Token de acceso para unirse al clúster
  --token "wCdC16AlP8qpqqI53DM6ujtrfZ7qsEM7PHLxD+Sw+RNK2d1oDJQQOsBkIwy5OZ/5" \
  # Dirección IP, nombre del nodo y configuración de Flannel
  --node-ip $NODEIP --node-name $HOSTNAME --flannel-iface enp0s8
fi
