#!/bin/bash

FILE_NAME="README.md"

# First time only.
# -------------------------------
git tag 0.1
git describe --tags --long
date "+%d-%m-%Y, %H:%M:%S"
# -------------------------------
timeStamp=$(date)
ver=$(sh git-revision.sh)
sed -i -e "s/\([v/V]ersion\).*/Version $ver/" $FILE_NAME
sed -i -e "s/\(> Last modified:\).*/> Last modified: $timeStamp  /" $FILE_NAME
# Iterative (full document).
# sed -i -e "s/\([v/V]ersion\).*/Version $ver/g" $FILE_NAME
echo "Version updated to $ver" 
