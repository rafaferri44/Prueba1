#!/bin/bash

function carpeta {
	declare -a archivo=(`ssh gestiweb@('IP') ls -l /git/web/facturascripts/ | grep ^d | rev | cut -d' ' -f1 | rev`)
	list=`echo ${#archivo[@]}`
	count=0;

	while [ $count != $list ];do
		echo -n $count-
		echo ${archivo[$count]} | cut -d"/" -f 6
		let count=$count+1
	done
	organizar
}

function organizar {
	read -p "Elije el plugin a clonar -> " option
	pluginName=`echo ${archivo[$option]}`
	echo "Plugin selecionado -> $pluginName"
	git clone gestiweb@('IP'):/git/web/facturascripts/$pluginName
	mv $pluginName `cat $pluginName/facturascripts.ini | grep ^name | cut -d"=" -f2 | tr "'" " "`
}

read -p "Se recojeran los datos de sus plugins,desea continuar S/n? " a

if [ $a = "S" -o $a = "s" ];then
	clear
	echo "Aqui estan todos los plugins ->"
	carpeta
else 
	exit
fi
