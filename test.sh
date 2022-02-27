#!/usr/bin/env bash

echo "Running Test"
./run.sh "test_source/projects" "test_source/projects.txt" | sed -n -e '/     3.5: query the database/,$p' | diff test_source/expected -
   # print [p] starting from "     3.5: query the database" until end of file ",$"
if [ $? -eq 0 ]; then
   echo "success"
   exit 0
else
   echo "fail"
   exit 1
fi