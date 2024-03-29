# details: This code "rename" the database in mongodb, export data, and then import data again, but the new name"
# date: 28/09/2023
# by: deliverst
# status: BETA
# todo:

# 1.- delete database in mongoose
# 2.- clean the folders created when dumped

nameCurrentDatabas="cobranza"
newNameDatabase="corpfiscal-db"
folderToSaveDatabase="temp"

mongodump -d "$nameCurrentDatabas" -o "$folderToSaveDatabase"
mv "$folderToSaveDatabase/$nameCurrentDatabas" "$folderToSaveDatabase/$newNameDatabase"
mongorestore --nsInclude="$newNameDatabase.*" "$folderToSaveDatabase"
