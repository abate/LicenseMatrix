#!/usr/bin/python

import csv
import spdx_lookup as lookup
import spdx
from fuzzywuzzy import process
import json

lincensesIDS = [e['id'] for e in spdx._licenses]
lincensesNAMES = [e['name'] for e in spdx._licenses]
YES = ["yes","YES","Yes"]
NO = ["no","No","NO"]

exceptions = ["Affero General Public License 3.0"]

def yesorno (s):
    (ly,c) = process.extractOne(s,YES)
    b = None
    if c == 100 :
        b = True
    else :
        (ln,c) = process.extractOne(s,NO)
        if c == 100 :
            b = False
    return b

#https://fedoraproject.org/wiki/Licensing:Main
with open('fedora-goodlicenses-table.csv', 'rb') as csvfile:
    spamreader = csv.reader(csvfile, delimiter=',', quotechar='"')
    j = []
    begin = True
    for row in spamreader:
        if begin :
            begin = False
            continue
        spdxid = row[1].strip()
        name = row[0].strip()
        fsf = row[2].strip()
        gpl2 = row[3].strip()
        gpl3 = row[4].strip()
        url = row[5].strip()
        name_norm = None
        spdxid_norm = None
        matchLicense = 0
        print "Examining ID %s" % spdxid
        print "Examining NAME %s" % name
        lname = lookup.by_name(name)
        if lname :
            print "Match %s" % lname
            name_norm = lname.name
            spdxid_norm = lname.id
            matchLicense = 100
        else :
            lid = lookup.by_id(spdxid)
            if lid :
                print "Match %s" % lid
                spdxid_norm = lid.id
                name_norm = lid.name
                matchLicense = 100
            else :
                match = lookup.match(name)
                if match :
                    print "Match Lookup %s" % match.license
                    name_norm = match.license
                    print match
                    matchLicense = match.confidence
                (fuzzyid,c) = process.extractOne(spdxid,lincensesIDS)
                if c >= 95 :
                    print "Fuzzy IDS: ",fuzzyid
                    lid = lookup.by_id(fuzzyid)
                    if lid: 
                        spdxid_norm = lid.id
                        name_norm = lid.name
                    matchLicense = c

                (fuzzyname,c) = process.extractOne(name,lincensesNAMES)
                if c >= 95 : 
                    print "Fuzzy NAME: ", fuzzyname
                    lname = lookup.by_name(fuzzyname)
                    if lname : 
                        spdxid_norm = lname.id
                        name_norm = lname.name
                    matchLicense = c

        print "Confidence Match: %d" % matchLicense
        if matchLicense >= 95 and name not in exceptions :
            print "NAME: %s" % name_norm
            print "ID: %s" % spdxid_norm
            print "FSF: (%s) %s" % (fsf,yesorno(fsf))
            print "GPL2: (%s) %s" % (gpl2,yesorno(gpl2))
            print "GPL3: (%s) %s" % (gpl3,yesorno(gpl3))
        else :
            print "Discarded"

        print "------------"

        if matchLicense >= 95 and name not in exceptions :
            a = { "name" : name_norm, "spdx" : spdxid_norm, "confidence" : matchLicense}
            if matchLicense != 100 :
                a['origname'] = name
                a['origid'] = spdxid
            if yesorno(fsf) :
                a["fsf"] = yesorno(fsf)
            if yesorno(gpl2) :
                a["gpl2"] =  yesorno(gpl2)
            if yesorno(gpl3) :
                a["gpl3"] =  yesorno(gpl3)

            j.append(a)
    
    print "Total Licences Match: %d" , len(j)
    with open('fedora.json', 'w') as outfile:
        json.dump(j, outfile, indent=2, separators=(',', ': '))
