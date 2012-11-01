#!/bin/bash
# Script to run SGE grid engine

# Move tweets to scratch disk 2

tweet_dir=/home/doan/scratch2/tweet_corpus/Japan-combined
tweet_dir_out=/home/doan/scratch2/tweet_corpus/Japan-processed

working_dir=/home/doan/scratch2/doan/TweetAnalysis/src
PYTHON=/usr/local/bin/python

for i in `ls $tweet_dir`
do
	#echo $tweet_dir/$i
	#qsub -S $PYTHON $working_dir/twitter_parser.py $tweet_dir/$i > $tweet_dir_out/$i.parsed
	$PYTHON $working_dir/twitter_parser.py $tweet_dir/$i > $tweet_dir_out/$i.parsed
done

