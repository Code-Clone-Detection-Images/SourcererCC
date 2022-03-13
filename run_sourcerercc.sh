#!/usr/bin/env bash

echo "[VARDUMP] CC_ARG=$CC_ARG; MYSQL_HOST=$MYSQL_HOST; PROJECTS_LIST=$PROJECTS_LIST;"

echo "Step 1: run the tokenizer"
# no longer necessary, i use a copy to allow further modifications
# echo "     1.1: clean up the input folder according to rules"
# rm -rf bookkeeping_projs files_stats files_tokens logs

echo "     1.1: zipping all projects as necessary"
function folder_only_zips {
   for f in $(ls "$1"); do
      echo $(file $1/$f)
      if [[ "$(file $1/$f)" != *"Zip archive data"* ]]; then
         return 1
      fi
   done
   return 0
}

folder_only_zips "$CC_ARG"
if [ $? -ne 0 ]; then
   echo "         > Zipping necessary"
   mkdir "$HOME/input"
   for f in $(ls "$CC_ARG"); do
      echo "$HOME/input/$f.zip"
      zip "$HOME/input/$f.zip" "$CC_ARG/$f"
   done
else
   echo "         > Do not zip"
   cp -r "$CC_ARG" "$HOME/input"
fi

# we do need a list as it has been configured with the config. ini file
# with -d -1 we get full paths
# https://stackoverflow.com/questions/27340307/list-file-using-ls-command-in-linux-with-full-path
# we do only produce one if there is not already one (the vm uses a preconfigured list which we keep
# so we can deterministically validate the resulsts)
if [[ ! -z "$PROJECTS_LIST" ]]; then
   echo "using project list given by var"
   cp "/home/sourcerercc-user/data/$PROJECTS_LIST" "$HOME/input.lst"
fi

if [ ! -r "$HOME/input.lst" ]; then
   echo "$(ls -d -1 "$HOME"/input/*)" > "$HOME/input.lst"
fi

# cat "$HOME/input.lst"

echo "     1.2: running the tokenizer"
cd "$HOME/input"
python3 "$SOURCERERCC_HOME/tokenizers/file-level/tokenizer.py" zip


echo "Step 2: prepare SourcererCC"

echo "     2.1: Find distinct token hashes"
python2 "$SOURCERERCC_HOME/scripts-data-analysis/pre-CC/step4/find-distinct-token-hashes.py" files_tokens/ files_stats/

echo "     2.2: analyze token hashes"
cp ./distinct-token-hashes/distinct-tokens.tokens "$SOURCERERCC_HOME/clone-detector/input/dataset/blocks.file"
cd "$SOURCERERCC_HOME/clone-detector/"
python2 controller.py

echo "     2.3: group the pairs"
cd "$SOURCERERCC_HOME/clone-detector"
# do not fail if there are no clones
# ls NODE_*/output8.0
cat NODE_*/output8.0/query_* > results.pairs || touch "$HOME/results.pairs"

echo "Step 3: import the database"

echo "     3.1: configure docker host"
# we patch the db.py so that it uses mysql-db-sourcerercc as host, not localhost
# this is done not with docker build so we can make use of MYSQL_HOST
sed -i "s|host *= *'localhost'|host='$MYSQL_HOST'|" "$SOURCERERCC_HOME/tokenizers/file-level/db-importer/db.py"
sed -i "s|host *= *'localhost'|host='$MYSQL_HOST'|" "$SOURCERERCC_HOME/tokenizers/file-level/db-importer/clone_finder.py"

echo "     3.2: prepare the database"
mysql --user=user --password=p --host "$MYSQL_HOST" < /initialize.sql

echo "     3.3: import the database"
python "$SOURCERERCC_HOME/tokenizers/file-level/db-importer/mysql-import.py" files user p oopslaDB "$HOME/input" "$HOME/results.pairs"

echo "     3.4: find clones in the database"
python "$SOURCERERCC_HOME/tokenizers/file-level/db-importer/clone_finder.py" user p oopslaDB

echo "     3.5: query the database"
mysql --user=user --password=p --host "$MYSQL_HOST" < /query.sql

[ -s "$HOME/results.pairs" ] || echo "[Warning] No result pairs found!"