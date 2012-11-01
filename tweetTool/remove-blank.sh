# Sanitize the data
# Example,

# Remove blank lines
for i in `ls $1`
do
	sed '/^$/d' $1/$i > $1/$i.cleaned
done
