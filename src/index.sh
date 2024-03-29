#!/bin/bash

# details: tool to backup database in mongo, import export local and remote, get oneliner to connect remote db
# date: 29/DIC/22
# by: deliverst
# todo: write README.txt
# status: finish

# import env
# source "config/env.sh"
source "config/colors.sh"

# echo "user: $user"
# echo "pass: $pass"
# echo "cluster: $cluster"
# echo "id: $id"
# echo "importDb: $importDb"
# echo "exportDb: $importDb"
exportDb="$importDb"
# op run --no-masking --env-file="./config/.env" -- ./index.sh

# default folders
backupFolder=backup-history
exportFolder=export-dbs

function Help() {
	clear
	op=($(cat index.sh | grep -E "^#?\s?function" | sed -E 's/(function |\(\)|\{)//g' | xargs))
	echo ""
	echo -e "	Database: ------------ $exportDb ------------"
	echo ""
	echo -e "	1.- ${op[0]} $lgray # Print this menu$end"
	echo -e "	2.- ${op[1]} $lgray # Get oneliner to conect to mongodb atlas with configuration$end"
	echo -e "	3.- ${op[5]} $lred DISABLE BY DEFAULT $end $lgray # Export local database and import remote in mongodb atlas$end"
	# echo -e "	3.- ${op[5]} $lgray # Export local database and import remote in mongodb atlas$end"
	echo -e "	4.- ${op[6]} $lgray # Export remote database and import in local database$end"
	echo -e "	5.- ${op[7]} $lgray # Backup local database$end"
	echo -e "	6.- ${op[8]} $lgray # Backup remote database$end"
	echo -e "	7.- ${op[9]} $lgray # Import DB previews backup, in local$end"
	echo -e "	0.- Exit"
	echo ""
}

function getCLIConnection() {

	command="mongosh \"mongodb+srv://$cluster.$id.mongodb.net/$exportDb\" --apiVersion 1 --username $user --password $pass"
	echo $command | pbcopy
	echo ""
	echo -e "---- COMMAND TO CONNECT WITH MONGOSH ---- $lcyan the command was copied to clipboard $end"
	echo "$command"
	echo ""

	commandEnv="mongodb+srv://$user:$pass@$cluster.$id.mongodb.net/$exportDb?retryWrites=true&w=majority"
	echo "---- LINE TO ADD IN .ENV ----"
	echo "$commandEnv"

	echo ""
}

function initialConfig() {
	if [[ ! -d "$backupFolder" ]]; then
		mkdir -p "$exportFolder/remote" "$exportFolder/local" "$backupFolder/remote" "$backupFolder/local"
	fi
}

function getCurrentDate() {
	date=$(date +%x | sed 's/\//-/g')
	hourIn12=$(date +%I)
	letterTime=$(date +%p | tr '[:upper:]' '[:lower:]')
	time=$(date +%X | sed -Ee"s/^[[:digit:]][[:digit:]]/$hourIn12/" -e 's/:/-/g')
	echo "$date"_"$time$letterTime" #-> 12-28-22.07-44-02 <MM><DD><YY>.<HH><MM><SS><PM or AM>
}

function backup() {
	from=$1 #local or remote
	outputFile="./$backupFolder/$from/$exportDb"_"$(getCurrentDate).tar.gz"
	inputFile="$exportFolder/$from/$exportDb"
	tar -cvzf "$outputFile" "$inputFile"
	echo ""
	echo ""
	echo -e "	$lcyan the backup history and compress was saved on $outputFile $end"
	echo -e "	$lcyan the backup was saved on $exportFolder/$from/$exportDb and was copied on clipboard $end"
	echo ""
	echo ""
	echo "$exportFolder/$from/$exportDb" | pbcopy
}

# ----------🔴 WARNING!!! THIS FUNCTION EXPORT LOCAL AND IMPORT IN REMOTE OVERWRITE THE DATA IN REMOTE WARNING!!!🔴----------
# 	from="local"
# 	mongodump -d "$exportDb" -o "$exportFolder/$from"
# 	mongorestore --uri="mongodb+srv://$cluster.$id.mongodb.net/" --nsInclude="$importDb.*" -u $user -p $pass "$exportFolder/$from"
# 	backup "$from"

function exportLocal_ImportRemote() {
	echo "this function is disabled"
}

#🟢
function exportRempote_ImportLocal() {
	from="remote"
	mongodump --uri="mongodb+srv://$cluster.$id.mongodb.net/" -d "$exportDb" -u $user -p $pass -o "$exportFolder/$from"
	mongorestore --nsInclude="$importDb.*" "$exportFolder/$from/" # mongorestore <name-of-database-in-db> <path-name-of-database-to-import>
	backup "$from"
}

function backupLocal() {
	from="local"
	mongodump -d "$exportDb" -o "$exportFolder/$from"
	backup $from
}

function backupRemote() {
	from="remote"
	mongodump --uri="mongodb+srv://$cluster.$id.mongodb.net/" -d "$exportDb" -u $user -p $pass -o "$exportFolder/$from"
	backup "$from"
}

function importLocalToLocalMDB() {
	local from="local"
	mongorestore --nsInclude="$importDb.*" "$exportFolder/$from/"
}

function menu() {
	if [ "$#" -eq 0 ]; then
		initialConfig
		Help
		while [[ $op != "" ]]; do
			read -n 1 -p "Choise an option: " op
			echo ""
			case $op in
			"1") Help ;;
			"2") getCLIConnection ;;
			# "3") exportLocal_ImportRemote ;;
			"4") exportRempote_ImportLocal ;;
			"5") backupLocal ;;
			"6") backupRemote ;;
			"7") importLocalToLocalMDB ;;
			"0") break ;;
			*) echo -e "${BRed}Selected option ${BCyan}'$op'${NC} ${BRed}couldn't be find in the list of provided options${NC}" ;;
			esac
		done
	fi
}

menu
