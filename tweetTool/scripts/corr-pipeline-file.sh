# Pipeline to automatically process 
# $1: input file name
# For example 
# $1=../PlosOne-Eysenbach/tweets-all.txt
# Example,
# sh corr-pipeline.sh ../PlosOne-Eysenbach/

dir1=/home/doan/ploseone/src
dir2=$1
dir3=/home/doan/ploseone/tools

python $dir1/query-date-count1.py $dir2 > $dir2-1
python $dir1/freq_cal.py  $dir2-1 > $dir2-2

# Remove first and last line
#sed -n '1d;$d;p' $dir2/tweets-all-flu.parsed.roles.xml1-$1-text.count.1 > $dir2/tweets-all-flu.parsed.roles.xml1-$1-text.count-week

# **************************************
# Calculate correlation and output score
# **************************************

cp -f $dir2-2 $dir3/tmp-count

cd $dir3
R --slave --vanilla < ./report_score.R 

# Clean the directory
rm $dir2-1 $dir2-2

