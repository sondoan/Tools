# Pipeline to automatically process after semantic processing
# $1: File name, file with suffix SEM1
# For example 
# If Input file is tweets-all-flu.parsed.roles.xml1-filter-by-nagation-SEM1 
# $1 = filter-by-nagation-SEM1 
# Example,
# sh sem-pipe.sh filter-by-nagation-SUBJ-SEM1

dir1=/export/home/doan/dizzie/src
dir2=/export/home/doan/dizzie/src/brendan/filtered-respiratory-syndrome
dir3=/export/home/doan/dizzie/src/brendan/tools

python $dir1/semantic-post-processing.py $dir2/tweets-all-flu.parsed.roles.xml1 > $dir2/tweets-all-flu.parsed.roles.xml1-$1
python $dir3/match-id-forSEM.py $dir2/tweets-all-flu.parsed $dir2/tweets-all-flu.parsed.roles.xml1-$1 >  $dir2/tweets-all-flu.parsed.roles.xml1-$1-text
python $dir1/query-date-count1.py $dir2/tweets-all-flu.parsed.roles.xml1-$1-text >  $dir2/tweets-all-flu.parsed.roles.xml1-$1-text.count
python $dir1/freq_cal.py  $dir2/tweets-all-flu.parsed.roles.xml1-$1-text.count > $dir2/tweets-all-flu.parsed.roles.xml1-$1-text.count-week

# Remove first and last line
#sed -n '1d;$d;p' $dir2/tweets-all-flu.parsed.roles.xml1-$1-text.count.1 > $dir2/tweets-all-flu.parsed.roles.xml1-$1-text.count-week

# **************************************
# Calculate correlation and output score
# **************************************

cp -f $dir2/tweets-all-flu.parsed.roles.xml1-$1-text.count-week $dir3/tmp-count

cd $dir3
R --slave --vanilla < ./report_score.R 