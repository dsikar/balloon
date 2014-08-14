#!/bin/bash

# list logger files

myfolder=2607a

echo "Started processing $myfolder folder."
date

for f in ../data/$myfolder/*.*
do
	perl parse.pl $f >> ../report/$myfolder.report
done

echo "Finished processing $myfolder folder."
date
