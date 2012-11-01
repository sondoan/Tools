#!/bin/sh
# Exclude patterns
# Idea: 2 level filter: 1 used grep , 1 used inversion option of grep
# Run.
# sh filter-synd-brendan-exclude-plosone.sh 

brendan=/export/home/scratch1/doan/corpus/brendan/www.ark.cs.cmu.edu/unzip
filtered=/export/home/scratch2/doan/brendan/PlosOne-Extra1-http
respiratory_synd=/home/doan/ploseone/src/synd7
exclude1=/home/doan/ploseone/src/exclude

cd $brendan
for i in `ls *.gz`
do
    echo $i
#    awk -F '\t' '{print $1 "\t" $2 "\t" $4 "\t" $5}' $i|/bin/grep -v "http"|/bin/egrep -i -f $respiratory_synd|/bin/grep -v -i -f $exclude1 > $filtered/$i.parsed
    awk -F '\t' '{print $1 "\t" $2 "\t" $4 "\t" $5}' $i|/bin/grep -v "http"|/bin/egrep -i -f $respiratory_synd > $filtered/$i.parsed
done

