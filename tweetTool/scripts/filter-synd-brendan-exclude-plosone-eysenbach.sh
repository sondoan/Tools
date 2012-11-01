#!/bin/sh
# Filter following the paper of Polgreen in PLoS One
# Using 4 keywords: h1n1, swine flu, swineflu
# Run.
# sh filter-synd-brendan-exclude-plosone-eysenbach.sh 

brendan=/export/home/scratch1/doan/corpus/brendan/www.ark.cs.cmu.edu/unzip
filtered=/export/home/scratch2/doan/brendan/PlosOne-Eysenbach

cd $brendan
for i in `ls *.gz`
do
    echo $i
    awk -F '\t' '{print $1 "\t" $2 "\t" $4 "\t" $5}' $i|/bin/egrep -i "h1n1|swineflu|swine flu" > $filtered/$i.parsed
done

