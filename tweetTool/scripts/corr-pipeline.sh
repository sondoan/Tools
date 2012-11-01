# Pipeline to automatically process 
# $1: Method name, for example, Culotta, Polgreen, Eysenbach
# For example 
# $1=../PlosOne-Eysenbach/
# Example,
# sh corr-pipeline.sh ../PlosOne-Eysenbach/

dir1=/home/doan/ploseone/src
dir2=$1
dir3=/home/doan/ploseone/tools

python $dir1/query-date-count1.py $dir2/tweets-all.txt > $dir2/tweets-all.txt-by-date
python $dir1/freq_cal.py  $dir2/tweets-all.txt-by-date > $dir2/tweets-all.txt-by-week

# Remove first and last line
#sed -n '1d;$d;p' $dir2/tweets-all-flu.parsed.roles.xml1-$1-text.count.1 > $dir2/tweets-all-flu.parsed.roles.xml1-$1-text.count-week

# **************************************
# Calculate correlation and output score
# **************************************

cp -f $dir2/tweets-all.txt-by-week $dir3/tmp-count

cd $dir3
R --slave --vanilla < ./report_score.R 
