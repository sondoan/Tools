# This program will split the sentences in output file into training and testing
# Randomly choose training/testing data by line number
# Automatic split into k-folds, each fold contains train/test directories
# Run
# python split_data.py <input file> <k-fold number> <test directory>
# python split_data.py ../concat_rm.blank.txt 5 CV

import sys
import os
import random

sentNum = []
sentHash = {}
fin = open(sys.argv[1])
count = 0
for line in fin.readlines():
    count = count + 1
    sentHash[count] = line
fin.close

total = count
for i in range(1,total+1):
    sentNum.append(i)

k_num = int(sys.argv[2])
num_fold = int(total/k_num)

####################
# Split into k-folds
####################
FoldSet = []
i=0
Remain = sentNum
while i<k_num-1:
    Fold = set(random.sample(Remain,num_fold))
    Remain = set(Remain)-Fold
    i= i+1
    FoldSet.append(Fold)
FoldSet.append(Remain)

# For testing
#for item in FoldSet:
#    print len(item)

######################### 
# Create a directory and 
# split into train/test 
#########################
path = './'
CV_dir = path + sys.argv[3]+'-CV' + str(k_num)
#os.removedirs(CV_dir)
os.mkdir(CV_dir)

for i in range(1,k_num+1):
    fold_dir = CV_dir +'/fold'+str(i)
    os.mkdir(fold_dir)

    train = fold_dir + '/train'
    test  = fold_dir + '/test'

    os.mkdir(train)
    os.mkdir(test)

    # Write train/test file into each fold 
    train_file = train + '/train.txt'
    test_file = test + '/test.txt'

    # ===================================
    # Split training data set
    # ===================================
    fin = open(train_file,'w')
    Remain = set(sentNum)-set(FoldSet[i-1])
    tempList = list(Remain)
    for item in tempList:
        if sentHash.has_key(item) and len(sentHash[item].strip())>0:
            temp1= sentHash[item].strip()
            temp2= temp1.replace('\'','')
            fin.write(temp2+'\n')            
    fin.close()

    fin1 = open(train_file+'.inp','w')
    fin2 = open(train_file+'.out','w')
    Remain = set(sentNum)-set(FoldSet[i-1])
    tempList = list(Remain)
    for item in tempList:
        if sentHash.has_key(item) and len(sentHash[item].strip())>0:
            temp1= sentHash[item].strip()
            temp2= temp1.replace('\'','')
            temp3 = temp2.split('\t')
            fin1.write('\t'.join(temp3[0:2])+'\n')
            fin2.write(temp3[2]+'\n')
    fin2.close()
    fin1.close()

    # ===================================
    # Split testing data set
    # ===================================
    fin = open(test_file,'w')
    tempList = list(FoldSet[i-1])
    for item in tempList:
        if sentHash.has_key(item) and len(sentHash[item].strip())>0:
            temp1= sentHash[item].strip()
            temp2= temp1.replace('\'','')
            fin.write(temp2+'\n')
    fin.close()

    fin1 = open(test_file+'.inp','w')
    fin2 = open(test_file+'.out','w')
    tempList = list(FoldSet[i-1])
    for item in tempList:
        if sentHash.has_key(item) and len(sentHash[item].strip())>0:
            temp1= sentHash[item].strip()
            temp2= temp1.replace('\'','')
            temp3 = temp2.split('\t')
            fin1.write('\t'.join(temp3[0:2])+'\n')
            fin2.write(temp3[2]+'\n')
    fin2.close()
    fin1.close()
