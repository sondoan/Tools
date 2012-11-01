#!/bin/sh

# Filter each syndrome by keywords 
path1=/export/home/doan/dizzie/data/syndrome-list

#/bin/egrep -i -f $path1/$1 $2

#/bin/egrep -i -f $path1/synd1 $1 > $1.synd1
/bin/egrep -i -f $path1/synd2 $1 > $1.synd2
/bin/egrep -i -f $path1/synd3 $1 > $1.synd3
/bin/egrep -i -f $path1/synd4 $1 > $1.synd4
/bin/egrep -i -f $path1/synd5 $1 > $1.synd5
/bin/egrep -i -f $path1/synd6 $1 > $1.synd6
/bin/egrep -i -f $path1/synd7 $1 > $1.synd7

