# Match if for parsed file

dir1=/home/doan/ploseone/src
dir2=/export/home/doan/scratch2/doan/brendan/PlosOne-Extra-Analys-Geo
PYTHON=/usr/local/bin/python

for i in `ls $dir2|grep tweet-geo` 
do
	$PYTHON $dir1/semantic-match.py $dir2/tweets-all.txt  $dir2/$i  > $dir2/$i-temp
done

cat $dir2/*-temp > $dir2/tweets-all.xml2
rm -f $dir2/*-temp

