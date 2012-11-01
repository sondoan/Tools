# Count by date of tweets for plotting
# Run,
# python query-date-count.py <file name>
# Example,
# python query-date-count.py brendan/filtered/tweets-all.parsed

import os,sys,time,datetime

#start_date="2009-09-04"
#end_date="2010-05-09"

start_date=sys.argv[2]
end_date=sys.argv[3]


# Process the start_date
s_year=int(start_date.split('-')[0])
s_month=int(start_date.split('-')[1])
s_date=int(start_date.split('-')[2])

# Process the end_date
e_year=int(end_date.split('-')[0])
e_month=int(end_date.split('-')[1])
e_date=int(end_date.split('-')[2])

def main():

    #print "Hello world !"
    time1=datetime.date(s_year,s_month,s_date)
    time2=datetime.date(e_year,e_month,e_date)
    diff = datetime.timedelta(days=1)

    next = time1
    while next <= time2:
        next = next + diff
        next1 =next.strftime('%Y-%m-%d')
        #print next
        cmd="grep " + next1 + " " + sys.argv[1] + "|wc -l > ./tmp1"
        os.system(cmd)
        #print cmd
        temp_file = open("./tmp1","r")
        count_num = temp_file.read()
        print str(next) + "\t" + count_num.strip()
        temp_file.close()


if __name__=="__main__":
    main()
