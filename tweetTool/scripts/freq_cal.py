# Tools for calculate freq of news based on weeks
# Run,
# python freq_cal.py <input file>
# Example
# python freq_cal.py freq.txt

import os
import sys

freq = {}

# Main function
def main():
    fin = open(sys.argv[1])
    for line in fin.readlines():
        items = line.strip().split("\t")
        year = items[1].split("/")[2]
        
        if freq.has_key((items[0],year)):
            freq[(items[0],year)] = freq[(items[0],year)] + int(items[2]) 
        else:
            freq[(items[0],year)] = int(items[2]) 
    fin.close()

    freq[('1','2010')] = freq[('1','2010')] + freq[('53','2009')]

    list1 = []
    for key in freq:
        list1.append((key[1],key[0]))

    for i in range(0,len(list1)):
        for j in range(i+1,len(list1)):
            if comp1(list1[i],list1[j])==1:
                # Swap
                temp=list1[i]
                list1[i] = list1[j]
                list1[j]=temp

    for item in list1[1:-1]:
        if item[1]!='53':
            print item[0] + '\t' + item[1] + '\t' + str(freq[(item[1],item[0])])

# Compare two item 
def comp1(a,b):
    if int(a[0]) > int(b[0]):
        return 1    
    if int(a[0])==int(b[0]) and int(a[1]) > int(b[1]):
       return 1
    return 0

if __name__=="__main__":
    main()
