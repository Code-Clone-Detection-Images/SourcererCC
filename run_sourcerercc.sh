#!/usr/bin/env bash
BUILD_DIR=../build

echo "Step 1: run the tokenizer"
echo "     1.1: update the ini file"

# update the list from which to draw the projects from
sed -i "s|FILE_projects_list =.*|FILE_projects_list=$HOME/input.lst|" "$SOURCERERCC_HOME/tokenizers/file-level/config.ini"

# update the File_extensions of the language to support java files as well:
sed -i "s|File_extensions =.*|File_extensions = .cpp .hpp .c .h .java|" "$SOURCERERCC_HOME/tokenizers/file-level/config.ini"

# no longer necessary, i use a copy to allow further modifications
# echo "     1.2: clean up the input folder according to rules"
# rm -rf bookkeeping_projs files_stats files_tokens logs

echo "     1.2: zipping all projects as necessary"
function folder_only_zips {
   for f in $(ls "$1"); do
      if [[ "$(file $f)" != *"Zip archive data"* ]]; then
         return 1
      fi
   done
   return 0
}

folder_only_zips $1
if [ $? -ne 0 ]; then
   echo "         > Zipping necessary"
   mkdir "$HOME/input"
   for f in $(ls "$1"); do
      zip "$HOME/input/$f.zip" "$1/$f"
   done
else
   echo "         > Do not zip"
   cp "$1" "$HOME/input"
fi

# we do need a list as it has been configured with the config. ini file
echo "$(ls $HOME/input)" > "$HOME/input.lst"

echo "     1.3: running the tokenizer"
cd "$HOME/input"
python "$SOURCERERCC_HOME/tokenizers/file-level/tokenizer.py" zip


echo "Step 2: run SourcererCC"

echo "     2.1: Setting up the blocks.file"
cat files_tokens/* > blocks.file
cp blocks.file "$SOURCERERCC_HOME/clone-detector/input/dataset/"

echo "     2.1: Configure the properties file"
sed -i "s|MIN_TOKENS=.*|MIN_TOKENS=35|" "$SOURCERERCC_HOME/clone-detector/sourcerer-cc.properties"

# TODO: maybe update threshold in runnodes.sh
echo "     2.2: run the controller"
## runnodes needs java and ant (silently)
python "$SOURCERERCC_HOME/clone-detector/controller.py"

echo "     2.3: aggregate the nodes"
cd "$SOURCERERCC_HOME/clone-detector"
cat NODE_*/output8.0/* > results.pairs
cat results.pairs