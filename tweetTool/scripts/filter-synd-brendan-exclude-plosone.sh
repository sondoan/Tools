#!/bin/sh
# Exclude patterns
# Idea: 2 level filter: 1 used grep , 1 used inversion option of grep
# Run.
# sh filter-synd-brendan-exclude-plosone.sh 

brendan=/export/home/scratch1/doan/corpus/brendan/www.ark.cs.cmu.edu/unzip
filtered=/export/home/scratch2/doan/brendan/PlosOne
respiratory_synd=/home/doan/doan_recover/dizzie/data/syndrome-list/synd7

cd $brendan
for i in `ls *.gz`
do
    echo $i
    awk -F '\t' '{print $1 "\t" $2 "\t" $4 "\t" $5}' $i|/bin/egrep -i -f $respiratory_synd > $filtered/$i.parsed
done

