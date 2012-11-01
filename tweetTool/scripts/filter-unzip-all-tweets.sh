#!/bin/sh
# Gzip and gunzip all tweets
# sh filter-unzip-all-tweets.sh

tweets=/export/home/scratch2/doan/corpus/brendan/www.ark.cs.cmu.edu/tweets

cd $tweets

for i in `ls *.gz`
do
    echo $i
    gunzip $i
done

