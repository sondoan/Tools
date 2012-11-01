# Simple parser for twitter messages
# Written by Son Doan, July, 2010
# Extract important information from Twitter: id,text,language,time,location

import os
import sys
import time

check_id = {}

def norm(str):
	return str.strip('{').strip('}').strip('"')

def main():
	# Open file name
	#fname = open(sys.argv[1])

	for line in sys.stdin:
		# skip if no line
		if len(line.strip())==0:
			continue
		dict={}
		# Scan the text and parse the tweet
		items=line.strip().split(",\"")
		#print items
		for str in items:
			#print str
			line=str.split("\":")
			key=norm(line[0])
			if len(line)>1:
				val=line[1].strip()
			else:
				val=""	
			#print key + " -> " + val

			if dict.has_key(key):
				dict[key].append(val)
			else:
				dict[key]=[val]
	
		# Handling error 
		if not dict.has_key('created_at'):
			dict['created_at']=['"Sat Jul 01 06:06:02 +0000 2010"']
		if not dict.has_key('lang'):
			dict['lang']=['']
		if not dict.has_key('text'):
			dict['text']=['']
		if not dict.has_key('id'):
			dict['id']=['','']
		if not dict.has_key('location'):
			dict['location']=['']
		#print dict
		times=dict['created_at']
		# Sort by time and then take the first one
		for i in range(0,len(times)):
			for j in range(i+1,len(times)):
				times_i = norm(times[i])
				times_j = norm(times[j])

				if len(times_i)==30:
					ti=time.mktime(time.strptime(times_i,"%a %b %d %H:%M:%S +0000 %Y"))
				else:
					ti=time.mktime(time.strptime("Sat Apr 30 15:40:07 +0000 2010","%a %b %d %H:%M:%S +0000 %Y"))

				if len(times_j)==30:
					tj=time.mktime(time.strptime(times_j,"%a %b %d %H:%M:%S +0000 %Y"))
				else:
					tj=time.mktime(time.strptime("Sat Apr 30 15:40:07 +0000 2010","%a %b %d %H:%M:%S +0000 %Y"))
					

				if ti<tj:
					# Swap time i and j
					temp=times[i]
					times[i]=times[j]
					times[j]=temp
		#print times
		# Take the first time
		if len(norm(times[0]))==30:
			t=time.strptime(norm(times[0]),"%a %b %d %H:%M:%S +0000 %Y")
		else:
			t=time.strptime("Sat Apr 30 15:40:07 +0000 2010","%a %b %d %H:%M:%S +0000 %Y")

		# Take the time format such as 2010-07-10
		timeline = time.strftime("%Y-%m-%d %H:%M:%S",t)
			
		idx = norm(dict['id'][-1])
		if not check_id.has_key(idx) and dict['text'][0].find("http://")==-1:
			print timeline+'\t'+ norm(dict['lang'][0])+'\t'+norm(dict['location'][0])+'\t'+norm(dict['id'][-1])+'\t'+dict['text'][0]
			check_id[idx]=1

	#fname.close()

if __name__=="__main__":
	main()

