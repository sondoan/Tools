# Post processing program: filter by semantic features
# Input: Parsed file 
# Output: Filter by semantic
# Example,
# python semantic-post-processing.py filter-by-SUBJ-nagation-SEM1

import sys,os

Resp="asthmatic|cough|sore throat|tonsillitis|sinusitis|rales|rhonchi|rales on auscultation|lung sounds|breathing difficulties|shortness of breath|dyspnoea|dyspnea|apnea|short of breath|respiratory distress|breathing trouble|gasping for air|stop breathing|respiratory arrest|respiratory failure|blocked nose|stuffy nose|runny nose|pain in the chest|thoracic discomfort|chest ache|thoracic ache|achy chest|chest pain|thoracic pain|pneumonia|bronchitis|chronic obstructive pulmonary disease (COPD)|COPD|asthma|cold symptom|flu|h1n1|swine"

Resp1 = Resp.split("|")

Hash = {}

def main():

    fin = open(sys.argv[1],"r")
    content = ""
    for line in fin.readlines():
        content = content + line.strip()

    SentDict1 = {}
    doclist = content.split("</text>")
    for item in doclist:
        #print item
        if len(item)>0:
            idx = item.split("<raw>")[0].split("\"")[1]
            #print id
            remain1 = item.split("<raw>")[1]
            text = remain1.split("</raw>")[0]
            #print text

            SentDict1[idx] = text

            remain2 = remain1.split("</raw>")[1]
            #print remain2
            sentences = remain2.split("<tokens id=")
            #============================================
            # Read parsed information into SentDict
            #============================================

            SentDict = {}
            for sent in sentences[1:]:
                #print sent
                id = sent.split('\'')[1]
                
                token = sent.split("</tokens>")[0]
                token1 = token.split('</tok>')
                text1 = ''
                tag1 = ''
                id1 = ''
                for item in token1:
                    ttemp = item.split('\'>')
                    text1 = text1 + ' '+ttemp[-1]
                    #ttemp1 = ttemp[0].split('\'')[-1]

                    #print ttemp
                    t1 = len(ttemp)-2
                    ttemp1 = ttemp[t1].split('\'')[-1]
                    tag1 = tag1 + ' ' + ttemp1
                    
                    if t1>=0:
                        tid1 = ttemp[t1].split('\'')[1]
                        id1 = id1 + ' '+tid1

                # For each sentence it has one set of relation
                # A relation define a binary relation between two args.
                relation = sent.split("</tokens>")[1]
                #print relation
                rels = relation.split("</rels>")[0]
                #print rels
                subrel = rels.split("</gr>")
                #print subrel

                Rel1=[]
                for item in subrel:

                    if item.find('<arg')>=0:
                        reltemp = item.split('<arg')
                        #print reltemp
                        relName = reltemp[0].split('rel=')[1].split('\'')[1]
                        #print relName
                        if relName == 'ncsubj':
                            
                            relVerbID = reltemp[1].split('\'')[1]
                            relNNID= reltemp[2].split('\'')[1]
                            relOptional = reltemp[3].split('<')[0].split('>')[1]

                            #print relVerbID
                            #print relNNID
                            #print relOptional

                            Rel1.append((relVerbID,relNNID,relOptional))
                        else:                            
                            # process other relations
                            1
                            
                #print Rel1
                SentDict[id] = (text,text1,tag1,id1,Rel1)

            #print SentDict
            # =========================================================
            # Analyze each sentence.
            # =========================================================

            # Global variable for polarity (combination of all sentences)
            Opinion = []
            
            for key in SentDict.iterkeys():
                #print key
                #print SentDict[key]
                sent_orig = SentDict[key][0]
                sent = SentDict[key][1]
                sent_morph = SentDict[key][1]
                tag1 = SentDict[key][2]
                id1 = SentDict[key][3]
                SUBRel = SentDict[key][4]

                # Determine subject of sentences, only for self-reporting                
                Subject = 1 
                # based on keyword "flu"
                
                if sent.find("flu")>=0:
                    #print "+++++++++++++++++++++++++++++++++++++++++++++++"
                    #print "ORIG: " + sent_orig
                    #print "MORPH: " + sent_morph
                    sent_list = sent_morph.split()
                    tag_list = tag1.split()
                    #print "POS: " + tag1
                    #print id1
                    id1_list = id1.split()
                    #print SUBRel
                    Opi = []
                    Subj_flu = 1

                    # Check for each relation
                    for item in SUBRel:
                        idx1 = id1_list.index(item[0])
                        idx2 = id1_list.index(item[1])
                        # Print out string
                        V1= sent_list[idx1]
                        N1= sent_list[idx2]
                        V1Tag= tag_list[idx1]
                        N1Tag= tag_list[idx2]

                        Optional1= item[2]

                        #print "<NCSUB, " + V1 + ", " + N1 + ", "+Optional1 + ">"
                        #print "<NCSUB, " + V1Tag + ", " + N1Tag + ", "+Optional1 + ">"

                        # --------------------
                        # Check subject is they/them/he/she/him/her
                        # --------------------
                        if N1Tag.find("PPHS")>=0:
                            #print key
                            #print "<NCSUB, " + V1 + ", " + N1 + ", "+Optional1 + ">"
                            Subj_flu = 0
                        ## --------------------
                        ## Check subject is you/us/we
                        ## --------------------
                        #if N1Tag.find("PPIO2")>=0 or N1Tag.find("PPS2")>=0 or N1Tag.find("PPY")>=0:
                        #    #print key
                        #    #print "<NCSUB, " + V1 + ", " + N1 + ", "+Optional1 + ">"
                        #    Subj_flu = 0
                        # --------------------
                        # Check subject is you/us/we
                        # --------------------
                        #if N1Tag.find("PPHS1")>=0 or N1Tag.find("PPHS2")>=0:
                        #    #print key
                        #    #print "<NCSUB, " + V1 + ", " + N1 + ", "+Optional1 + ">"
                        #    Subj_flu = 1

                    Opi.append(Subj_flu)
                    # --------------------
                    # Check negation
                    # --------------------
                    # NO FLU or NOT BE FLU 
                    if "XX" in tag_list:
                        Subj_flu =0
                        neg_flu = 0
                    else:
                        neg_flu = 1
                    
                    Opi.append(neg_flu)

                    # --------------------
                    # Check POS with other people
                    # --------------------
                    if tag1.find("PPHS") >=0:
                        Subj1_flu =0
                    else:
                        Subj1_flu =1

                    Opi.append(Subj1_flu)

                    #print sent_orig
                    #print sent
                    #print tag_list

                    # --------------------
                    # Check joking
                    # --------------------                        
                    joke_flu = 0
                    if sent_orig.find("\*cough")>=0 or sent_orig.find("haha")>=0 :
                        joke_flu = 1
                    Opi.append(joke_flu)

                    # --------------------
                    # Check emoticon
                    # --------------------                        
                    emo_flu = 0
                    emo=['lol',':-)',':d','t_t',':-D','=D', '=3', '<=3', '<=8',': )']
                    #emo=['lol',':-)',':d','t_t',':-D']
                    
                    sentL1 = sent_orig.split()
                    for item in sentL1:
                        for e1 in emo:
                            if item.find(e1) >=0: 
                                emo_flu = 1

                    Opi.append(emo_flu)
                    ## --------------------
                    ## Check hashtag - no good results
                    ## --------------------   
                    hashTag_flu = 0
                    
                    #hash_idx = []
                    #for item in sent_list:
                    #    tag = 1
                    #    if item.find('#')==0:
                    #        idx1 = sent_list.index(item)
                    #        hash_idx.append(idx1)                        
                    #
                    #tag1_flu = -1
                    #if len(hash_idx) >0:
                    #    #print sent_list
                    #    #print hash_idx
                    #    for tag in hash_idx:
                    #        hashTag = sent_list[tag]
                    #        #print hashTag
                    #        tag1_flu = 0
                    #        for item in Resp1:
                    #            if hashTag.lower().find(item)>=0:
                    #                tag1_flu = 1
                    #                break                                            
                    #    #print tag1_flu
                    #
                    #hashTag_flu = tag1_flu

                    Opi.append(hashTag_flu)

                    # --------------------
                    # Check Tamiflu or Meds
                    # --------------------                        
                    Tami_flu = 0
                    if sent.lower().find('tamiflu')>=0:
                        Tami_flu=1

                    Opi.append(Tami_flu)

                    # --------------------
                    # Check "flu" + gone
                    # --------------------                                            
                    #gone_flu =1
                    ## # Look at word after
                    #if (idx+1)<len(tags):
                    #    afterTag = tags[idx+1].split('\'')[1]
                    #    if (idx-1)>=1:
                    #        previousTag = tags[idx-1].split('\'')[1]
                    #        # Check for flu shot, "flu shot" but not "fever, cough, flu"
                    #        if afterTag.find("N")== 0 and previousTag.find("N") ==-1 and previousTag != "AT": 
                    #            gone_flu = 0
                    #Opi.append(gone_flu)

                    #==============================================================
                    # Determine subjects of sentences by combination among sentences
                    #==============================================================
                    #print sent
                    #print Opi
                    Subject = Opi[1] # Check for negation -- the best result for now
                    #print Subject
                    # --------------------------------------
                    
                    # For SUBJECT
                    #if Opi[0] == 0 and Opi[1] == 0:
                    #    Subject = 0
                    #else:
                    #    Subject =1                    

                    #if Opi[0] == 0:
                    #    Subject = 0

                    # For Jokes
                    #if Opi[3]==1:
                    #    Subject = 0

                    # For Emoticon
                    #if Opi[4]==1:
                    #    Subject = 0            
                    #else:
                    #    Subject = 1

                    #For hashTag
                    #if Opi[5]==0:
                    #    Subject = 0
                    #else:
                    #    Subject = 1

                    # For tamiflu
                    #if Opi[6]==1:
                    #    Subject = 0

                    # =======================
                    # DEBUG
                    # =======================
                    #if Subject ==0:
                    #    print sent
                    #    print Opi

                # In cases of other sentences
                else:
                    #print sent
                    1

                #print key
                #print SentDict[key][1]
                Opinion.append((key,Subject))
                
            # Opinion aggregation            
            #print Opinion
            #print "=========================="
            polarity = 1
            for item in Opinion:
                opinion1 = item[1]
                if opinion1 == 0:
                    polarity = 0
            # -------------------------------
            # Print out the aggregation
            # -------------------------------
            #print polarity

            ## Print out the screen
            if polarity == 1:
                id = Opinion[0][0].split('.')[0]
                print id
                #print SentDict1[id]
                                                                
if __name__=="__main__":
    main()
