#!/bin/bash

# Este script permite definir, poner en marcha o detener una VM en un servidor remoto.
# Tiene dos modos de uso:
# 1. Interactivo: Si no se proporciona ningún parámetro al ejecutar el script, se mostrarán
#    opciones al usuario para interactuar con el script.
# 2. Desde un archivo de configuración: Si se proporciona un archivo de configuración como 
#    parámetro al ejecutar el script, leerá las instrucciones del archivo y ejecutará las acciones correspondientes.


# Verificar el número de parámetros proporcionados
if [ $# -eq 0 ]; then
    # Mostrar opciones al usuario
    echo "Este script le permitirá definir, poner en marcha o detener una VM hasta que escoja la opción de salir."
    while true; do
        echo "Opciones:"
        echo "1. Definir una VM"
        echo "2. Poner en marcha una VM"
        echo "3. Detener una VM"
        echo "4. Salir"

        # Leer la opción del usuario
        read opcion

        # Comprobar la opción seleccionada y ejecutar la acción correspondiente
        case $opcion in
            1)
                echo "Introduzca el nombre de la VM que desea definir:"
                read nombre
                ssh -n a842748@155.210.154.204 "cd /../../misc/alumnos/as2/as22023/a842748 && virsh -c qemu:///system define $nombre.xml"
                ;;
            2)
                echo "Introduzca el nombre de la VM que desea poner en marcha:"
                read nombre
                ssh a842748@155.210.154.204 "virsh -c qemu:///system start $nombre"
                ;;
            3)
                echo "Introduzca el nombre de la VM que desea detener:"
                read nombre
                ssh a842748@155.210.154.204 "virsh -c qemu:///system shutdown $nombre"
                ;;
            4)
                echo "Ha seleccionado salir, ¡adiós!"
                exit 0
                ;;
            *)
                echo "Error: Opción no válida. Por favor, seleccione una opción del 1 al 4."
                exit 1
                ;;
        esac
    done

elif [ $# -eq 1 ]; then
    archivo=$1
    if [ ! -f $archivo ]; then
        echo "El archivo $archivo no existe."
        exit 1
    fi
    
    while IFS=' ' read -r codigo nombre_vm; do
        case $codigo in
            1)
                ssh -n a842748@155.210.154.204 "cd ~/misc/alumnos/as2/as22023/a842748 && virsh -c qemu:///system define $nombre_vm"
                ;;
            2)
                ssh -n a842748@155.210.154.204 "virsh -c qemu:///system start $nombre_vm"
                ;;
            3)
                ssh -n a842748@155.210.154.204 "virsh -c qemu:///system shutdown $nombre_vm"
                ;;
            *)
                echo "Error: Número de acción no válido en el archivo."
                exit 1
                ;;
        esac
    done < $archivo
else
    echo "Numero de parametros incorrecto. Usage: ./pr1_adsis.sh [fichero_config]"
fi

