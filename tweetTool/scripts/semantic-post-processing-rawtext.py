# Post processing program to process raw text only

import sys,os

Resp="asthmatic|cough|sore throat|tonsillitis|sinusitis|rales|rhonchi|rales on auscultation|lung sounds|breathing difficulties|shortness of breath|dyspnoea|dyspnea|apnea|short of breath|respiratory distress|breathing trouble|gasping for air|stop breathing|respiratory arrest|respiratory failure|blocked nose|stuffy nose|runny nose|pain in the chest|thoracic discomfort|chest ache|thoracic ache|achy chest|chest pain|thoracic pain|pneumonia|bronchitis|chronic obstructive pulmonary disease (COPD)|COPD|asthma|cold symptom|flu|h1n1|swine"

Resp1 = Resp.split("|")
Hash = {}

def main():
    fin = open(sys.argv[1],"r")
    for line in fin.readlines():
        #print line
	sent = line.split('\t')[3]
        # --------------------
        # Check emoticon
        # --------------------                        
      	emo_flu = 0
	if sent.find('flu')>=0:
		#print sent
       		emo=['lol',':-)',':d','t_t',':-D','=D', '=3', '<=3', '<=8',': )',':)',':D']
       		sentL1 = sent.split()
       		for item in sentL1:
               		for e1 in emo:
                  		if item.find(e1) >=0: 
                            		emo_flu = 1
					break
        # --------------------
	# Check joking
        # --------------------
	joke = 0
	if sent.find('hihi')>=0  or sent.find('haha')>=0:
		joke = 1

        # --------------------
	# Check negation
        # --------------------
	neg = 0
	sent1 = sent.split('.')
	for sent in sent1:
		if sent.find('flu') >=0:
			negList = ['not', 'don\'t', 'didn\'t', 'never', 'none']
			sent2 = sent.split()
			for item in sent2:
				for n1 in negList:
                  			if item.find(n1) >=0: 
                            			neg = 1
						break
	if joke==0 and emo_flu==0 and neg ==0:
		print line.strip()

if __name__=="__main__":
    main()


