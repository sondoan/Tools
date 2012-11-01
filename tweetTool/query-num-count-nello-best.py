# Count the tweet number by date 
# Run,
# python query-num-count.py <dir name>
# Example,
# python query-num-count.py brendan/nello_best

import os,sys,time,datetime

DateTable = {}

def main():

    # List file names from <dir>
    dir = sys.argv[1]
    files = os.listdir(dir)
    for item in files:
        if item.find("-count") > 0:
#            print item
            filename = dir + item
            fin=open(filename,"r")
            for line in fin.readlines():
                line1 = line.strip().split('\t')
                date = line1[0]
                num = line1[1]
                #print date
                #print num

                if DateTable.has_key(date):
                    DateTable[date] = DateTable[date] + int(num)
                else:
                    DateTable[date] = int(num)
            fin.close()
            
#    print DateTable

    for  key in sorted(DateTable.iterkeys()):
        print str(key) + "\t" + str(DateTable[key])

if __name__=="__main__":
    main()
