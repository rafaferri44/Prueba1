#!/bin/bash
number=`^[0-9]+$`
function compile {
yarn cordova-build-android
}
# function firmarapk {

# }
# function firmaraab {

# }
function rebuilding {
# cordova platform remove android
# cordova platform add android
sed -i "s%defaultMinSdkVersion=19%defaultMinSdkVersion=21%g" "./src-cordova/platforms/android/build.gradle" # cambia la 19 por 21
sed -i 's%<manifest%<manifest xmlns:tools="http://schemas.android.com/tools"%g' './src-cordova/platforms/android/app/src/main/AndroidManifest.xml' # agrega las tools al manifest
sed -i 's%<application%<application android:allowBackup="false" android:fullBackupContent="false" tools:replace="allowBackup, fullBackupContent"%g' './src-cordova/platforms/android/app/src/main/Andr$'

# add in AndroidManifest
# <manifest xmlns:tools="http://schemas.android.com/tools"
# <application android:allowBackup="false" and android:fullBackupContent="false"
}
function errorselect {
list=`echo ${#archivo[@]}`
count=0;

	while [ $count != $list ];do
		echo -n $count-
		echo ${archivo[$count]} | cut -d"/" -f 6 
		let count=$count+1
	done
	arrange
}
function listfs {
	#Lista los plugins de un repositorio,en este caso esta puesto para el servidor gestiweb
	clear
	declare -a archivo=(`ssh gestiweb@192.168.3.12 ls -l /git/web/facturascripts/ | grep ^d | rev | cut -d' ' -f1 | rev`)
	errorselect
}

function arrange {
	#Se elije el plugin de los listados con la funcion carpeta y se ejecuta un git clone
	read -p "Elije el plugin a clonar -> " option
	count=0;
	let prueba=$list-1 

	if [ $option -gt $prueba ];then
			read -p "Por favor pulse un numero de los que hay en la lista"
			clear
			errorselect
	elif [ $option -lt $count ];then
			echo $count
			read -p "Por favor pulse un numero de los que hay en la lista"
			clear
			errorselect
	else
		pluginName=`echo ${archivo[$option]}`
		echo "Plugin selecionado -> $pluginName"
		refresh
	fi
}
 function refresh {
	 #Comprueba si el plugin ya existe y si ese plugin esta desfasado o actualizado
	read -p "Escribe donde quieres que se guarde el Plugin -> " save
	path=`grep name $pluginName/facturascripts.ini | cut -d" " -f3 | tr "'" " " | sed 's/ //g'`
 
	sleep 3
		if [ -d $save/$pluginName ];then
			echo "El plugin ya existe,se va comprobar si esta actualizado"
			check=`cd $save/$pluginName ; git status -s | egrep 'A|M|??' | cut -d" " -f1 | sed -n '1p'`
			if [ -z $check ];then
				echo -e "\e[32mActualizado\e[0m"
			else
				echo -e "\e[31mDesfasado\e[0m"
				
			fi
			read -p "Pulse enter para continuar"
		else
			echo "El plugin no existia,se va a crear en la ruta especificada"
			git clone gestiweb@192.168.3.12:/git/web/facturascripts/$pluginName $save/$pluginName
			mv $save/$pluginName $save/$path
			echo "El Plugin se ha guardado aqui -> $save/$path"
			
			fi
}
function mainfs {
clear
echo " 
1-> Crear Plugin
2-> Clonar Plugin
"
read -p "Elije una opción -> " plugin
case $plugin in 
		1)echo "Mantenimiento"
		exit
		;;
		2) listfs
		;;
esac
inicio
}
function listvue {
	#Establecemos primero un git clone para bajarnos el repostorio
	read -p "Escribe la ruta absoluta donde se guardará el repositorio -> " ruta
	clone
}
function clone {
	#Comprueba que plugins estan actualizados o desfasados
	if [ -d $ruta/ITL_DataSuite ];then
		echo "Ya existe una carpeta con el mismo nombre que el repositorio" 
		option=`cd $ruta/ITL_DataSuite ; git status -s | egrep 'A|M|??' | cut -d" " -f1 | sed -n '1p'`
			if [ -z $option ];then
				echo -e "\e[32mActualizado\e[0m"
			else
				echo -e "\e[31mDesfasado\e[0m"
				outdated
			fi
	else
		git clone gestiweb@192.168.3.12:/git/vue/ITL_DataSuite $ruta/ITL_DataSuite
		clone
		
	fi

}
function outdated {
	#En el caso de que este desfasado,cuando llega aqui se actualiza
	read -p "Desea actualizar-lo (S/n)? -> " update
	if [ $update == "S" ];then
		cd $ruta/ITL_DataSuite ; git commit -a -m "before merge"
		cd $ruta/ITL_DataSuite ; git pull
	fi
}
function pdavue {
clear
echo "
1 -> Git
2 -> Compilar
3 -> Firmar APK
4 -> Firmar AAB
5 -> Reconstruir plataformas"

read -p "Que desea hacer -> " vue

	case $vue in 
			1)
			listvue
			;;
			2) compile
			;;
			3)
			;;
			4)
			;;
			5) rebuilding
			;;
	esac 
}
function inicio {	
clear
echo "
1 -> FacturaScripts
2 -> PDA Vue
3 -> Exit"

read -p "Elije una opción " repositorio
case $repositorio in
	1)
	mainfs
	;;
	2)
	pdavue	
	;;
	3) exit
	;;
esac
}
inicio
