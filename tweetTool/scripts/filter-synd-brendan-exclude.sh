#!/bin/sh
# Exclude patterns
# Idea: 2 level filter: 1 used grep , 1 used inversion option of grep
# Filter followed Cullota'paper.
# flu - (shot|vaccine|season|http|swine|h1n1)
# Run.
# sh filter-synd-brendan-exclude.sh 

brendan=/export/home/scratch2/doan/corpus/brendan/www.ark.cs.cmu.edu/unzip
#filtered=/export/home/scratch2/doan/corpus/brendan/www.ark.cs.cmu.edu/filtered2
#filtered=/export/home/scratch2/doan/corpus/brendan/www.ark.cs.cmu.edu/filtered-flu-nospace
filtered=/export/home/scratch2/doan/corpus/brendan/www.ark.cs.cmu.edu/filtered-respiratory-syndrome-http
#filtered=/export/home/scratch2/doan/corpus/brendan/www.ark.cs.cmu.edu/filtered-respiratory-syndrome
respiratory_synd=/export/home/doan/dizzie/data/syndrome-list/synd7



cd $brendan

for i in `ls *2009-08-*.gz`
do
    echo $i
#    awk -F '\t' '{print $1 "\t" $2 "\t" $4 "\t" $5}' $i|/bin/egrep -i "flu" |grep -v 'http' |grep -v 'shot'|grep -v 'season'|grep -v 'h1n1'|grep -v 'vaccine'|grep -v 'swine'  > $filtered/$i.parsed
#    awk -F '\t' '{print $1 "\t" $2 "\t" $4 "\t" $5}' $i|/bin/egrep -i "flu " |grep -v 'http' > $filtered/$i.parsed
#    awk -F '\t' '{print $1 "\t" $2 "\t" $4 "\t" $5}' $i|/bin/egrep -i -f $respiratory_synd |grep -v 'http' > $filtered/$i.parsed
#    awk -F '\t' '{print $1 "\t" $2 "\t" $4 "\t" $5}' $i|/bin/egrep -i -f $respiratory_synd > $filtered/$i.parsed

done

