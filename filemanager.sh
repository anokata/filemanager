#!/bin/bash -i 

if [[ -z $1 ]]
then
#	echo "Needed amoumt of lines in first parameter"
#	exit 1
	declare -ri HEIGHT=20
else
	declare -ri HEIGHT=$1 
fi

declare -r LEFT_KEY='a'
declare -r RIGHT_KEY='d'
declare -r UP_KEY='w'
declare -r DOWN_KEY='s'
declare -r EDIT_KEY='e'
declare -r QUIT_KEY='q'
declare -r EXECUTE_KEY='x'



Documentation(){
	echo -e '\E[36m'"Very simple Bash-filemanager. (C)--=Messiah=--"
	echo -e '\E[31m'"$(basename $0) [HEIGHT=20]"
	echo -e '\E[31m'"Where HEIGHT - amount of lines on your console"
	echo -e '\E[35m'"Actions:"
	echo -e "\tw - Up\n\ts - Down\n\ta - Up to 10 pos\n\td - Down to 10 pos\n\te - Edit\n\tx - Execute"
	tput sgr0
	echo "Colors:"
	echo -en '\E[32m'"[Folder]   "
	tput sgr0
	echo -en '\E[33m'"Executable*   "
	tput sgr0	
	echo -e "Other files"
}

Quit(){
    stty echo
    clear
    exit 0
}

MoveCursor(){
	case "$action" in 
	   "moveUp") 
		if [[ $cursor > 0 ]]; then
			 let "cursor-=1"
		 else
			 let "cursor=$(($(ls -a | wc -l)-1))"
		 fi ;;
	   "moveDown") 
		if [[ $cursor == $(($(ls -a | wc -l)-1)) ]]; then
			 let "cursor=0"
		else
			 let "cursor+=1"
		fi ;;
	   "moveRight") if [[ $cursor  -le $(($(ls -a | wc -l)-10)) ]]; then
			let "cursor+=10"
			fi;;
	   "moveLeft")	if [[ $cursor -ge 10 ]]; then
			let "cursor-=10"
			fi;;
	   "edit") 
		if [[ -d ${List[$cursor]} ]]; then
			 cd "${List[$cursor]}"
			 let "cursor=0"
		else
			 view ${List[$cursor]}
		fi ;;
	   "execute")
		if [[ -x ${List[$cursor]} ]]; then
			stty echo
			clear
			./${List[$cursor]} 
			wait
			read -n 1
			clear
			stty -echo
		fi
	esac
}


stty -echo
echo -e "\033[?25l"
trap Quit EXIT
clear
Documentation
cursor=1
while true; do
	read -n 1 key
        case "$key" in
            $UP_KEY)	   action="moveUp";;
            $DOWN_KEY)	   action="moveDown";;
	        $LEFT_KEY)	   action="moveLeft";;
    	    $RIGHT_KEY)	   action="moveRight";;
            $EDIT_KEY)	   action="edit";;
    	    $EXECUTE_KEY)  action="execute";;
            $QUIT_KEY)     action="quit";;
            "")	           ;;
        esac
	MoveCursor
	[[ $action == "quit" ]] && Quit
	[[ -z $action ]] && continue
	clear
	action=""
	unset List
	let "i=0"
	echo -e '\E[36m'"Very simple Bash-filemanager. (C)--=Messiah=--"
	tput sgr0

	while read
	do
		List[$i]="$REPLY"
		let "i+=1"
	done< <(ls -a)

	let "page = (cursor / HEIGHT) * HEIGHT"
	
	for ((j=$page; j<$page + $HEIGHT; j++)) 
	do
		item=${List[$j]}
		if [[ $j == $cursor  ]]
		then
			if [[ -d $item ]]; then
				echo -e ">>>"'\E[32m'"[${item}]"
				tput sgr0
			elif [[ -x $item ]]; then
				echo -e ">>>"'\E[33m'"${item}*"
				tput sgr0
			else				
				echo -e ">>>${item}"
			fi
		else
			if [[ -n ${item} ]]; then
				if [[ -d $item ]]; then
                        	        echo -e "   "'\E[32m'"[${item}]"
                	                tput sgr0
				elif [[ -x $item ]]; then
					echo -e "   "'\E[33m'"${item}*"
					tput sgr0
                        	else
        	                        echo "   ${item}"
				fi
			fi
		fi
	done

done
stty echo
