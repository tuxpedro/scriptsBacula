#!/bin/bash
:<< --Abount--

        This script delete volumes
        @Author: Pedro
        @Date: 2018-09-11

--Abount--
clear
echo "#######################################################"
echo -e		 	" POOLS "
echo "-------------------------------------------------------"
echo -e "POOL ID POOL NAME"
#seleciona todos as pool que contem volumes
POOLS=$(mysql -u bacula -e "select DISTINCT m.PoolId, p.Name From Media m, Pool p WHERE m.PoolId = p.PoolId;" bacula)
POOLS=$(echo "$POOLS" | sed '1d')
echo "$POOLS"
echo "-------------------------------------------------------"
echo -e "Digite o ID da pools | 0 para sair:  "
read POOLID 

if [ "$POOLID" -eq 0 ]; then
	echo -e "Saindo ..."
	exit
fi

POOLNAME=($(echo "$POOLS" | awk '($1 == "'$POOLID'") {print $2}'))
echo -e "---------------------------------------------------------------"

Menu(){
	echo -e "Selecione a ação desejada"
	echo -e "---------------------------------------------------------------"
	echo  -e 
	echo -e "[ 1 ] Deletar todos os volumes da Pool $POOLNAME"
	echo -e "[ 2 ] Selecionar os volumes que deseja deletar da Pool $POOLNAME"
        echo -e "[ 3 ] Encerrar"
	echo 
	echo -n "Selecione uma opção: "
	read opcao
	case $opcao in
		1) deleteAll ;;
		2) deleteVolume ;;
		3) exit ;;
		*) "Opção desconhecida." ; clear ; Menu ;;
	esac
}

# Director of volumes
DIR=/mnt/backup/

deleteAll(){
        NAMEVOLUMES=$(mysql -u bacula -e "select VolumeName From Media Where PoolId = $POOLID;" bacula)
        NAMEVOLUMES=$(echo "$NAMEVOLUMES" | sed '1d')
	NAMEVOLUMES=($(echo "${NAMEVOLUMES}" | awk '{print $1}'))
        ROWSAFFECTED=$(mysql -u bacula -e "SELECT COUNT(MediaId) FROM Media WHERE PoolId =$POOLID;" bacula)
        ROWSAFFECTED=$(echo "$ROWSAFFECTED" | sed '1d')
	DIR=/mnt/backup/
	read -p "Deseja excluir os volumes da Pools $POOLNAME? [s/n] " -e -n 1 OP	
	if  [ $OP == "s" ] ; then
		mysql -u bacula -e "DELETE FROM Media WHERE PoolId =$POOLID;" bacula
		for ((i=0; i<$ROWSAFFECTED; i++)) do
			if [ -e "$DIR${NAMEVOLUMES[$i]}" ] ; then
        			echo -e "Deletetando o volume: " $DIR${NAMEVOLUMES[$i]}
				rm  -f $DIR${NAMEVOLUMES[$i]}
			fi
		done
	else
		Menu	
	fi
	echo -e "$ROWSAFFECTED registros afetados"
}

deleteVolume(){
	VOLUMES=$(mysql -u bacula -e "select MediaID, VolumeName From Media Where PoolId = $POOLID;" bacula)
	VOLUMES=$(echo "$VOLUMES" | sed '1d')
	clear
	echo "#######################################################"
	echo -e		 	" POOLS "
	echo "-------------------------------------------------------"
	echo -e "VOl. ID VOL. NAME"
	echo "$VOLUMES"
	echo -e "Digite o ID do volume que deseja deltar"
	read VOLID
	VOLNAME=($(echo "$VOLUMES" | awk '($1 == "'$VOLID'") {print $2}'))	
	DIR=/mnt/backup/
	read -p "Deseja excluir $VOLNAME? [s/n] " -e -n 1 OP	

	if  [ $OP == "s" ] ; then
		mysql -u bacula -e "DELETE FROM Media WHERE PoolId = $POOLID AND MediaID = $VOLID;" bacula
		if [ -e $DIR$VOLNAME ]; then
			echo -e "Deletetando o volume: $DIR$VOLNAME"
			rm  -f "$DIR$VOLNAME"
		else
			echo -e "O arquivo não $VOLNAME não existe no dir. $DIR saindo..."
                fi	
		
	else
		clear
		echo -e "\n"
		Menu	
	fi
}
Menu
