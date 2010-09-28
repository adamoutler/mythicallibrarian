#!/usr/bin/python

import sys, os
filename = sys.argv[1]
#filename = "2151_20100923200000.mpg"

#Read database settings from ~/.mythtv/mysql.txt
mysqlTXT = os.path.expanduser('~') + "/.mythtv/mysql.txt"

with open(mysqlTXT,'r') as f:
	mysqlData = f.read()

lines = mysqlData.split('\n')

for line in lines:
    line = line.replace(' ','') #strip spaces
    if line.startswith('DBHostName'):
        DBHostName = line.split('=')[1]
    if line.startswith('DBUserName'):
        DBUserName = line.split('=')[1]
    if line.startswith('DBPassword'):
        DBPassword = line.split('=')[1]
    if line.startswith('DBName'):
        DBName = line.split('=')[1]


#Get data from mythtv database
from MythTV import MythDB
db = MythDB(DBHostName=DBHostName, DBName=DBName, DBUserName=DBUserName, DBPassword=DBPassword)
test = db.getRecorded(chanid=filename[:4],starttime=filename[5:-4])



#Import all information from database regarding file

#print out data (just for testing)
for x in test.items():
    print x[0] + " = " + str(x[1])

#write data to a text file
with open("showData.txt", 'w') as f:
    for x in test.items():
        f.write(x[0] + " = " + str(x[1]) + "\n")

#TODO: Commercial skip information
#markup = test.markup
#for data in markup


