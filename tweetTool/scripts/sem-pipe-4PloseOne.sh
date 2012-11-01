# Pipeline to automatically process after semantic processing
# $1: File name, file with suffix SEM1
# For example 
# If Input file is tweets-all-flu.parsed.roles.xml1-filter-by-nagation-SEM1 
# $1 = filter-by-nagation-SEM1 
# Example,
# sh sem-pipe.sh filter-by-nagation-SUBJ-SEM1

dir1=/home/doan/ploseone/src
dir2=/export/home/doan/scratch2/doan/brendan/PlosOne-Extra-Analys-Geo
dir3=/home/doan/ploseone/tools
PYTHON=/usr/local/bin/python

for i in `ls $dir2|grep tweet-geo` 
do
	$PYTHON $dir1/semantic-post-processing.py $dir2/$i  > $dir2/$i-1
	$PYTHON $dir3/match-id-forSEM.py $dir2/tweets-all.txt $dir2/$i-1 > $dir2/$i-2
done

cat $dir2/*-2 > $dir2/all.parse-2
$PYTHON $dir1/query-date-count1.py $dir2/all.parse-2 >  $dir2/all.parse-3
$PYTHON $dir1/freq_cal.py  $dir2/all.parse-3 > $dir2/all.parse-4

# Remove first and last line
#sed -n '1d;$d;p' $dir2/tweets-all-flu.parsed.roles.xml1-$1-text.count.1 > $dir2/tweets-all-flu.parsed.roles.xml1-$1-text.count-week

rm -f $dir2/tweet-geo*-* 

# **************************************
# Calculate correlation and output score
# **************************************

cp -f $dir2/all.parse-4 $dir3/tmp-count

rm -f $dir2/all.parse-*

cd $dir3
R --slave --vanilla < ./report_score.R 
