#!/bin/sh
# Exclude patterns
brendan=/export/home/scratch2/doan/corpus/brendan/www.ark.cs.cmu.edu/unzip
filtered=/export/home/scratch2/doan/corpus/brendan/www.ark.cs.cmu.edu/nello_best

pattern=/export/home/scratch2/doan/corpus/brendan/www.ark.cs.cmu.edu/nello_best/words-pattern

cd $brendan

for i in `ls *2010-05-*.gz`
do
    echo $i
    awk -F '\t' '{print $1 "\t" $2 "\t" $4 "\t" $5}' $i|/bin/egrep -i -f $pattern> $filtered/$i.parsed

done

#awk -F '\t' '{print $1 "\t" $2 "\t" $4 "\t" $5}' tweets.2010-04-26.gz|/bin/egrep -i -f $pattern> $filtered/tweets.2010-04-26.gz.parsed
#awk -F '\t' '{print $1 "\t" $2 "\t" $4 "\t" $5}' tweets.2010-04-27.gz|/bin/egrep -i -f $pattern> $filtered/tweets.2010-04-27.gz.parsed
#awk -F '\t' '{print $1 "\t" $2 "\t" $4 "\t" $5}' tweets.2010-04-28.gz|/bin/egrep -i -f $pattern> $filtered/tweets.2010-04-28.gz.parsed
#awk -F '\t' '{print $1 "\t" $2 "\t" $4 "\t" $5}' tweets.2010-04-29.gz|/bin/egrep -i -f $pattern> $filtered/tweets.2010-04-29.gz.parsed
#awk -F '\t' '{print $1 "\t" $2 "\t" $4 "\t" $5}' tweets.2010-04-30.gz|/bin/egrep -i -f $pattern> $filtered/tweets.2010-04-30.gz.parsed


