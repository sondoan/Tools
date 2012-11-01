# Sanitize the data
# Example,

# Remove first and last line
for i in `ls $1`
do
	sed -n '1d;$d;p' $1/$i > $1/$i.cleaned
done
