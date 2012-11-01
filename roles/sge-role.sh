#!/bin/bash

# Script to run SGE grid engine
tweet_dir=/home/doan/ploseone/PlosOne-Extra-Analys
role_dir=/home/doan/ploseone/roles
PERL=/usr/bin/perl

for i in `ls $tweet_dir|grep test`
do
	#echo $i	
	#echo $tweet_dir/$i
	#qsub -S $PEAL $role_dir/parse.pl $tweet_dir/$i $tweet_dir/$i.parse
	qsub -S $PERL $role_dir/parse.pl $tweet_dir/$i $tweet_dir/$i.parse
done
