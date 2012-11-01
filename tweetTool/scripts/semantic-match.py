# Match id for semantic information
# Run
# python semantic-match.py ../PlosOne-Extra-Analys-Geo/tweets-all.txt ../PlosOne-Extra-Analys-Geo/parseaa

import sys,os

def main():

    List = {}
    fin1 = open(sys.argv[1],"r")
    for line in fin1.readlines():
    	id = line.split("\t")[0]
	List[id]=1
    fin1.close()

    fin = open(sys.argv[2],"r")
    content = ""
    for line in fin.readlines():
        content = content + line

    SentDict1 = {}
    doclist = content.split("</text>")
    for item in doclist:
        if len(item.split())>0:
            idx = item.split("<raw>")[0].split("\"")[1]
	    if List.has_key(idx):
            	print item + '</text>'
    fin.close()

if __name__=="__main__":
    main()
