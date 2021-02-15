#!/bin/bash

function tercerMenu() {  
clear  
let operacion=$menu2-1
opcion=${service[$operacion]}
echo "Ha elejido usted la opcion -> $opcion "

read -p "
1- Parar servicio
2- Reiniciar servicio
3- Iniciar servicio
4- Borrar volumen
5- Borrar imagen
6- Borrar contenedor
7- Destruir
8- Pues atras 
Elije una opcion -> " menu3
case $menu3 in
    1)
        docker stop $opcion
        echo "Docker-compose se ha detenido"
        tercerMenu

    ;;
    2)
        docker restart $opcion
        echo "Docker-compose se ha reiniciado"
        tercerMenu
    ;;
    3)
        docker start $opcion
        echo "Docker-compose se ha iniciado"
        tercerMenu
    ;;
    4)
        echo "En Desarollo,volviendo al menu "
        sleep 1
        tercerMenu
    ;;
    5)
        #Borrar imagen
        a=`sudo docker ps -a --format "{{.Names}} {{.Image}}" -f name=$opcion | cut -d":" -f2 | cut -d" " -f2`
        idimage=`docker image ls --format "{{.Repository}} {{.ID}}" -f reference=$a | cut -d" " -f2`
        # echo $a
        # echo "$idimage" | sed 's/ //g'
        if [ -z $idimage ];then
            echo "No hay ninguna imagen para este servicio"
            sleep 2
            tercerMenu
        else
            echo $a
            echo $idimage
            docker rmi -f $idimage
            echo "Se ha borrado la imagen con ID:$idimage,volviendo al menu"
            sleep 2
            tercerMenu
        fi
    ;;
    6)
        #Borrar contenedor
        secure=`docker container ls -a -f name=postgresql_service --format "{{.Names}}"`
        if [ -z $secure ];then
            echo "Este servicio no tiene ningun contenedor"
            sleep 2
            tercerMenu
        else
            idcontenedor=`docker container ls -a --format "{{.ID}} {{.Names}}" -f name=$opcion | cut -d" " -f1`
            docker container stop $idcontenedor
            docker container rm $idcontenedor
            echo "Se ha eliminado el contenedor con ID:$idcontenedior,volviendo al menu "
            sleep 2
            tercerMenu
        fi
    ;;
    7)
        #BOOOOOOOOOOOOOOOOOOOOOOOOOOOM
        echo "En Desarollo,volviendo al menu "
        sleep 1
        tercerMenu

    ;;
    8)
        segundoMenu
    ;;
esac
}
function segundoMenu() {
clear
declare -a service=(`docker ps -a --format "{{.Names}}"`)
all=`echo ${#service[@]}`
count=0
echo "Servicios :"
while [ $count -lt $all ];
do
     z=${service[$count]}
    let count=$count+1
    echo $count- $z
done
let return=$all+1
echo "$return- Atras"
read -p "
Elije una opcion -> " menu2 

if [ $menu2 == $return ];then
    primerMenu
else
    tercerMenu
fi
}
function compose() {
compose=`which docker-compose`
if [ ! $compose ];then
     curl -L "https://github.com/docker/compose/releases/download/1.28.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
     chmod +x /usr/local/bin/docker-compose
    docker-compose --version
    sleep 2
    echo "Se ha instalado docker-compose"
    primerMenu
else
    echo "Docker-compose ya esta instalado"
    read -p "Desea desinstalarlo? S/n -> " otromas
    case $otromas in
    [Ss]* )    rm /usr/local/bin/docker-compose

    ;; 
    [Nn]* )
    ;;
  esac
    sleep 2
    primerMenu
fi
}
function desinstalar() {
    ##Desintalamos docker 
    dpkg -l | grep -i docker
    read -p "Estos son los paquetes que se van a desinstalar,esta seguro? S/n -> " sure
    case $sure in
    [Ss]* )
             apt-get purge -y docker-engine docker docker.io docker-ce docker-ce-cli
             apt-get autoremove -y --purge docker-engine docker docker.io docker-ce  
        ##Los comandos anteriores no eliminarán imágenes, contenedores, volúmenes o 
        ##archivos de configuración creados por el usuario en su host
        ##Para eliminarlos usaremos estos
             rm -rf /var/lib/docker /etc/docker
             rm /etc/apparmor.d/docker
             groupdel docker
             rm -rf /var/run/docker.sock
    ;; 
    [Nn]* ) echo "Operacion cancelada"
            primerMenu
    ;;
  esac
  ##Desintalamos docker-compose
#    rm /usr/local/bin/docker-compose

}
function instalacion() {

sisOp=`lsb_release -d | cut -d":" -f2 | cut -d" " -f1 | sed 's/ //g'`

if [ $sisOp == "Deepin" -o $sisOp == "Debian" ];then
    
     apt-get update
    clear
    echo "Se acaban de actualizar los paquetes "
    sleep 1
    echo "Se van a instalar paquetes para el funcionamiento del apt"
    sleep 1
    clear 
     apt-get install \ apt-transport-https \ ca-certificates \ curl \ gnupg-agent \ software-properties-common
    ##Agregue la clave GPG oficial de Docker
    curl -fsSL https://download.docker.com/linux/debian/gpg |  apt-key add -
    ##Verifique que ahora tiene la clave con la huella digital 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88, buscando los últimos 8 caracteres de la huella digital.
    
     apt-key fingerprint 0EBFCD88 
    read -p "Verifique que la clave es igual 9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88 (S/n) -> " ns
    case $ns in
    [Ss]* ) ##Actualice el aptíndice del paquete e instale la última versión de Docker Engine y containerd, o vaya al siguiente paso para instalar una versión específica
             apt-get update
             apt-get install docker-ce docker-ce-cli containerd.io
            clear
            count1=0
            declare -a dockers=`apt-cache madison docker-ce | cut -d"|" -f2`
            dockermax=${#dockers[@]}
            while [ $count1 -lt $dockermax ];do
                z=${dockers[$count1]}
                let count1=$count1+1
                echo $count1- $z
            done
            read -p "Instale una versión específica -> " version
            version=${dockers[$version-1]}
            apt-get install docker-ce=$version docker-ce-cli=$version containerd.io
            compose
    ;; 
    [Nn]* ) echo "Operacion cancelada"
            exit
    ;;
  esac

elif [ $sisOp == "Ubuntu"];then
    
  ##Primero actualizamos los paquetes
  apt-get update
  ##A continuación, instale algunos paquetes de requisitos previos que le permiten a apt usar paquetes mediante HTTPS
  apt install apt-transport-https ca-certificates curl software-properties-common
  ##Agregue la clave GPG para el repositorio oficial de Docker a su sistema
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  ##Agregue el repositorio de Docker a las fuentes de APT
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
  ##Actualice la base de datos de paquetes usando los paquetes de Docker del repositorio que acaba de agregar
  apt-get update
  ##Asegúrese de que va a instalar desde el repositorio de Docker en vez del repositorio de Ubuntu predeterminado
  apt-cache policy docker-ce

  ##Por ultimo instalamos docker
  apt-get install docker-ce

    echo "Docker se ha instalado correctamente en Ubuntu,quieres ver su estado? -> S/n " estado
    case $ns in
    [Ss]* ) systemctl status docker
            read -p "Pulse enter para volver al menu incial"
            primerMenu
    ;; 
    [Nn]* ) clear
            echo "Volvera al menu incial "
            sleep 1
            primerMenu
    ;;
  esac

   
fi
}

function instalar() {
comprobacion=`which docker`

if [ $comprobacion ];then
    echo "Usted ya tiene instalado docker"
    read -p "Desea desinstalarlo ? S/n -> " desis
    case $desis in
    [Ss]* ) desinstalar
    ;; 
    [Nn]* ) 
    ;;
    esac
    read -p "Desea instalar docker-compose? S/n -> " sncompose
    
    case $sncompose in
    [Ss]* ) compose
    ;; 
    [Nn]* ) echo "Operacion cancelada"
            sleep 1
            primerMenu
    ;;
    esac
else
    read -p "Desea instalar docker? S/n -> " sn
    case $sn in
    [Ss]* ) instalacion
    ;; 
    [Nn]* ) echo "Operacion cancelada"
            sleep 1
            primerMenu
    ;;
  esac

fi
}
function primerMenu() {
clear
if [ $warning == 0 ];then
echo -e "\e[91m WARNING: Esta script solo instala en Debian y Ubuntu\e[0m"
warning=1
fi
read -p "
0- Install Docker
1- Servicios
2- Borrar Volumenes
3- Borrar imagenes
4- Borrar contenedores
5- Borrar Todo
6- Salir
Elije una opcion del menu -> " menu1

case $menu1 in
    0)
        #Install Docker
        instalar
    ;;
    1)
        #menu2
        segundoMenu
    ;;
    2) 
        docker volume prune
        echo "Se han borrado los volumenes"
        sleep 1
        primerMenu
    ;;
    3)
        docker image prune
        echo "Se han borrado las imagenes"
        sleep 1
        primerMenu
    ;;
    4)
        docker container prune
        echo "Se han borrado los contenedores"
        sleep 1
        primerMenu
    ;;
    5)
    read -p "Esta seguro que quiere eliminar volumenes,imagenes y contenedores? S/n -> " deuna
    case $deuna in
    [Ss]* ) 
        docker volume prune --force
        docker image prune --force
        docker container prune --force
        echo "Se ha borrado todo"
        sleep 1
        primerMenu
    ;; 
    [Nn]* ) echo "Operacion cancelada"
            sleep 1
            primerMenu
    ;;
    esac
    ;;
    6)
        exit
    ;;
esac    
}
warning=0
primerMenu
