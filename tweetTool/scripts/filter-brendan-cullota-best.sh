#!/bin/sh
# Filter by best result of Cullota's paper: 93/95% for train/test
# flu|cough|headache|sore throat
# Run.
# sh filter-brendan-cullota-best.sh 

brendan=/export/home/scratch2/doan/corpus/brendan/www.ark.cs.cmu.edu/unzip
#cullota_best=/export/home/scratch2/doan/corpus/brendan/www.ark.cs.cmu.edu/cullota_best
cullota_best=/export/home/scratch2/doan/brendan/PlosOne-Cullota

cd $brendan

# Note: Filter for each month due to prog stopped

#for i in `ls *2010-02*.gz`
#do
#    echo $i
#    awk -F '\t' '{print $1 "\t" $2 "\t" $4 "\t" $5}' $i|/bin/egrep -i "flu|cough|headache|sore throat" > $cullota_best/$i.parsed
#done

#for i in `ls *2010-03*.gz`
#do
#    echo $i
#    awk -F '\t' '{print $1 "\t" $2 "\t" $4 "\t" $5}' $i|/bin/egrep -i "flu|cough|headache|sore throat" > $cullota_best/$i.parsed
#done

#for i in `ls *2010-04*.gz`
#do
#    echo $i
#    awk -F '\t' '{print $1 "\t" $2 "\t" $4 "\t" $5}' $i|/bin/egrep -i "flu|cough|headache|sore throat" > $cullota_best/$i.parsed
#done

for i in `ls *.gz`
do
    echo $i
    awk -F '\t' '{print $1 "\t" $2 "\t" $4 "\t" $5}' $i|/bin/egrep -i "flu|cough|headache|sore throat" > $cullota_best/$i.parsed
done

