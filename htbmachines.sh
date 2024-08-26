#!/bin/bash
#Colores 
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"
#Colores definidos 


main_url="https://htbmachines.github.io/bundle.js"
parameter_counter=0


function ctrl_c(){
echo -e "\n${redColour}[!] Saliendo...${endColour}\n\n"
tput cnorm; exit 1 
}
trap ctrl_c INT


function helpPanel(){
  echo -e "\n${purpleColour}[+]${endColour} ${grayColour}Panel de ayuda${endColour} ${yellowColour}->${endColour} ${turquoiseColour}-h${endColour} ${grayColour}Abrir panel de ayuda${endColour}"
  echo -e "                      ${turquoiseColour}-a${endColour} ${grayColour}Listar todas las máquinas existentes${endColour}"
  echo -e "                      ${turquoiseColour}-u${endColour} ${grayColour}Actualizar sistema${endColour}"
  echo -e "                      ${turquoiseColour}-o${endColour} ${grayColour}Buscar máquinas por IP específica${endColour}"
  echo -e "                      ${turquoiseColour}-y${endColour} ${grayColour}Buscar writeup de una máquina${endColour}"
  echo -e "                      ${turquoiseColour}-c${endColour} ${grayColour}Listar máquinas por certificado${endColour}"
  echo -e "                      ${turquoiseColour}-r${endColour} ${grayColour}Obtener shell de $0${endColour}"
  echo -e "                      ${turquoiseColour}-s${endColour} ${grayColour}Buscar máquinas por skill${endColour}"
} 

function getMachines(){
machineName=$1 
validacion=$(cat bundle.js | grep -i "name: \"$1\"" -A 8 | tr -d '"' | tr -d ',' | grep -vE "sku:|id:" | sed 's/^ *//g')
if [ "$validacion" ]; then 
echo -e "${yellowColour}[+]${endColour}${grayColour} Listando las propiedades de la máquina${endColour} ${purpleColour}$1${endColour}${grayColour}:${endColour}\n"
echo -e ${grayColour}"$(cat bundle.js | grep -i "name: \"$1\"" -A 8 | tr -d '"' | tr -d ',' | grep -vE "sku:|id:" | sed 's/^ *//g')"${endColour}
else 
echo -e "\n${redColour}[!] Debes de indicar una máquina${endColour}"
exit 1
fi
}

function updateFiles(){
if [ ! -f "bundle.js" ]; then 
echo -ne "\n${blueColour}[+]${endColour} ${grayColour}El archivo bundle.js no existe, ¿Deseas descargarlo?${endColour} " && read si_no
if [ "$si_no" == "si" ]; then 
curl -s $main_url >> bundle.js 
js-beautify bundle.js | sponge bundle.js 
elif [ "$si_no" == "no" ]; then 
exit 0
else 
  echo -e "\n${turquoiseColour}[!]${endColour} ${grayColour}Debes de decidir una acción${endColour}"
exit 0
fi
else 
echo -ne "\n${yellowColour}[+]${endColour} ${grayColour}El archivo existe, ¿Deseas revisar si hay actualizaciones?${endColour} " && read yes_or_no
if [ "$yes_or_no" == "si" ] || [ "$yes_or_no" == "s" ] || [ "$yes_or_no" == "S" ] || [ "$yes_or_no" == "y" ] || [ "$yes_or_no" == "Y" ] || [ "$yes_or_no" == "yes" ] || [ "$yes_or_no" == "Si" ]; then 
  curl -s $main_url >> bundle_temp.js 
  js-beautify bundle_temp.js | sponge bundle_temp.js
  md5_original_value=$(md5sum bundle.js | awk '{print $1}')
  md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
  if [ "$md5_original_value" == "$md5_temp_value" ]; then 
    echo -e "\n${blueColour}[+]${endColour} ${grayColour}No se encontraron actualizaciones, estas al día ;)${endColour}"
    rm bundle_temp.js 
  else 
echo -e "\n${yellowColour}[*]${endColour} ${grayColour}Hemos encontrado actualizaciones, esto podría tomar un tiempo...${endColour}"
rm bundle.js 
mv bundle_temp.js bundle.js 
echo -e "\n${blueColour}[+]${endColour} ${grayColour}Estas al día chaval ;)${endColour}"
  fi
elif [ "$yes_or_no" == "no" ] || [ "$yes_or_no" == "x" ] || [ "$yes_or_no" == "NO" ] || [ "$yes_or_no" == "n" ] || [ "$yes_or_no" == "No" ] || [ "$yes_or_no" == "N" ]; then 
exit 0
else 
echo -e "\n${redColour}[!] No puedes dejar un espacio en blanco${endColour}"
exit 1
fi
fi


}

function searchIP(){
ipMachine=$1
machineName=$(cat bundle.js | grep -i "ip: \"$1" -B 3 | grep -vE "sku:|id:" | sed 's/--//g' | grep name | tr -d '"' | tr -d ',' | awk 'NR==1' | sed 's/name://g' | sed 's/^ *//g')
if [ "$machineName" ]; then 
echo -e "\n${blueColour}[+]${endColour} ${grayColour}La IP ${turquoiseColour}$1${endColour} ${grayColour}le pertenece a la máquina${endColour} ${purpleColour}$machineName${endColour}" 
echo -ne "\n${blueColour}[+]${endColour} ${grayColour}¿Deseas listar las propiedades de la máquina${endColour} ${purpleColour}$machineName${endColour}${grayColour}?${endColour} " && read si_no 
if [ "$si_no" == "si" ]; then 
getMachines $machineName 
elif [ "$si_no" == "no" ]; then 
exit 0
else 
  echo -e "\n${redColour}[!] Debe de haber contenido entre tu elección${endColour}"
exit 1
fi
else 
echo -e "\n${redColour}[!] La IP $1 no existe${endColour}"
fi

}

function getYoutubeLink(){
writeup=$1
validtor=$(cat bundle.js | grep -i "$1" -A 8 | grep youtube | awk 'NR==1' | tr -d ',' | tr -d '"' | awk 'NF{print $NF}')
if [ "$validtor" ]; then 
echo -e "\n${blueColour}[+]${endColour} ${grayColour}Aquí tienes el writeup de la máquina${endColour} ${purpleColour}$1${endColour} ${yellowColour}- >${endColour} ${turquoiseColour}$validtor${endColour}"
else 
echo -e "\n${redColour}[-] No se encontro el writeup de la máquina $1${endColour}"
fi
}

function getCerts(){
certs=$1
validator=$(cat bundle.js | grep -i "like: \"$certs\"" -A 4 | grep name | tr -d '"' | tr -d ',' | awk 'NF{print $NF}' | column | sed 's/^ */ /g') 
if [ "$validator" ]; then 
echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Listando las máquinas que requieren de skill${endColour} ${purpleColour}$1${endColour}${grayColour}:${endColour}"
echo -e "\n$validator"
else 
echo -e "\n[!] No se encontraron máquinas que requieran de skill tipo $1"
fi

}

function shell(){
shellHelp
  while true; do 
    echo -ne "htbsearch.io > " && read command
if [ "$command" == "h" ]; then 
shellHelp
elif [ "$command" == "u" ]; then 
  updateFiles 
elif [ "$command" == "clear" ]; then
  clear  
else 
echo -e "\n${redColour}[-]${endColour} ${grayColour}Command not found "\"${redColour}$command${endColour}${grayColour}"\"${endColour}"
shellHelp | grep -vE "Esta|proceso"
fi
  done
}

function shellHelp(){
  echo -e "\n${yellowColour}[+]${endColour} ${grayColour}Esta revershe shell aun esta en proceso :)${endColour}"
  echo -e "${blueColour}[*]${endColour} ${grayColour}Comandos existentes actuales:${endColour}" 
  echo -e "\t ${purpleColour}h)${endColour} ${grayColour}Llamar al panel de ayuda${endColour}"
  echo -e "\t ${purpleColour}u)${endColour} ${grayColour}Descargar o buscar actualizaciones${endColour}"
  echo -e "\t ${purpleColour}clear)${endColour} ${grayColour}Limpiar pantalla${endColour}"
} 

function getSkills(){
skill=$1 
validator=$(cat bundle.js | grep "skills: " -B 7 | grep "$1" -w -i -B 7 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column) 
if [ "$validator" ]; then 
  echo -e "\n${blueColour}[+]${endColour} ${grayColour}Listando máquinas que requieran de habilidades tipo${endColour} ${turquoiseColour}$1${endColour}\n"
cat bundle.js | grep "skills: " -B 7 | grep "$1" -w -i -B 7 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column 
else 
echo -e "\n${redColour}[-] No encontramos la dificultad $1${endColour}"
fi
}





while getopts "uhm:i:y:c:rs:" arg; do 
case $arg in 
  h);;
  m)machineName=$OPTARG; let parameter_counter+=1;; 
  u)let parameter_counter+=2;;
  i)ipMachine=$OPTARG; let parameter_counter+=3;;
  y)writeup=$OPTARG; let parameter_counter+=4;; 
  c)certs=$OPTARG; let parameter_counter+=5;; 
  r)let parameter_counter+=6;;
  s)skill=$OPTARG; let parameter_counter+=7;; 

  esac
done 






if [ "$parameter_counter" -eq 1 ]; then 
getMachines $machineName
elif [ "$parameter_counter" -eq 2 ]; then
updateFiles
elif [ "$parameter_counter" -eq 3 ]; then 
searchIP $ipMachine 
elif [ "$parameter_counter" -eq 4 ]; then 
  getYoutubeLink $writeup
elif [ "$parameter_counter" -eq 5 ]; then 
getCerts $certs 
elif [ "$parameter_counter" -eq 6 ]; then 
  shell shellHelp
elif [ "$parameter_counter" -eq 7 ]; then 
  getSkills $skill
else 
  helpPanel
fi
