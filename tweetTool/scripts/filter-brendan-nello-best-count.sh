#!/bin/sh
# Count each parsed file of tweets
filtered=/export/home/scratch2/doan/corpus/brendan/www.ark.cs.cmu.edu/nello_best
pattern=/export/home/scratch2/doan/corpus/brendan/www.ark.cs.cmu.edu/nello_best/words-pattern
count=/export/home/doan/dizzie/src/query-date-count.py

cd $filtered

for i in `ls *.gz.parsed`
do
    cmd="python "$count" "$filtered
    $cmd/$i > ./$i-count
done



