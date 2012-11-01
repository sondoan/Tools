# Count the tweet number by date 
# Run,
# python query-num-count.py <file name>
# Example,
# python query-num-count.py brendan/unzip

import os,sys,time,datetime

start_date="2009-09-04"
end_date="2010-05-09"

# Process the start_date
s_year=int(start_date.split('-')[0])
s_month=int(start_date.split('-')[1])
s_date=int(start_date.split('-')[2])

# Process the end_date
e_year=int(end_date.split('-')[0])
e_month=int(end_date.split('-')[1])
e_date=int(end_date.split('-')[2])

def main():

#    # List file names from <dir>
#    dir = sys.argv[1]
#    files = os.listdir(dir)
#    for item in files:
#        print item

    #print "Hello world !"
    time1=datetime.date(s_year,s_month,s_date)
    time2=datetime.date(e_year,e_month,e_date)
    diff = datetime.timedelta(days=1)

    next = time1
    while next <= time2:
        next = next + diff
        next1 =next.strftime('%Y-%m-%d')

        next_2day = next + diff
        next_2day1 = next_2day.strftime('%Y-%m-%d')

        prev = next - diff
       
        #print next

        # Count the total number of tweets
        cmd = "grep " + str(next) + " " + sys.argv[1] + "tweets."+str(next)+".gz.map|wc> ./tmp2"
        cmd1 = "grep " + str(next) + " " + sys.argv[1] + "tweets."+str(next_2day1)+".gz.map|wc> ./tmp3"

        cmd2 = "grep " + str(next) + " " + sys.argv[1] + "tweets."+str(prev)+".gz.map|wc> ./tmp4" 

#        os.system(cmd)
#        os.system(cmd1)
        print cmd2
#        os.system(cmd2)
##
##        temp_file2 = open("./tmp2","r")
##        count_num2 = temp_file2.read()
##        temp_file2.close()
##
##        temp_file3 = open("./tmp3","r")
##        count_num3 = temp_file3.read()
##        temp_file3.close()
#
##        print str(next) + "\t" + count_num2.strip().split()[0] + "\t" + count_num3.strip().split()[0]
#
#        temp_file4 = open("./tmp4","r")
#        count_num4 = temp_file4.read()
#        temp_file4.close()
#
#        print str(next) + "\t" + count_num4.strip().split()[0] 

if __name__=="__main__":
    main()
