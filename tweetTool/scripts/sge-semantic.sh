# Parallel running semantic processing

dir1=/home/doan/ploseone/src
dir2=/export/home/doan/scratch2/doan/brendan/PlosOne-Extra-Analys
dir3=/home/doan/ploseone/tools
PYTHON=/usr/local/bin/python

for i in `ls $dir2|grep parse` 
do
	qsub -S $PYTHON $dir1/semantic-post-processing.py $dir2/$i  > $dir2/$i-1
done
