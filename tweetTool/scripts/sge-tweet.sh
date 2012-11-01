#!/bin/sh

# Process tweets

dir1=/export/home/scratch2/TweetCorpus2009/ID-User
dir2=/export/home/scratch1/doan/corpus/brendan/www.ark.cs.cmu.edu/tweets
dir3=/home/doan/doan_recover/ploseone/src
PYTHON=/usr/local/bin/python

for i in `ls $dir2|grep tweet` 
do
#	qsub -S less $dir2/$i|$PYTHON $dir3/2tsv.py > $dir1/$i
	less $dir2/$i|$PYTHON $dir3/2tsv.py > $dir1/$i

done
