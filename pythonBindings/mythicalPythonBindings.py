#!/usr/bin/python




#requires libmyth-pythonsudo 
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
'''
from MythTV import MythDB
filename = '1004_20100823003000.mpg'
db = MythDB()
# do some error handling here so we can return a better failure on error
try:
    rec = db.searchRecorded(basename=filename).next()
except StopIteration:
    # thrown when pulling data from an empty iterator
    raise Exception('Recording Not Found')
chanid, starttime = rec.chanid, rec.starttime
print chanid
print starttime
'''


from MythTV import MythDB
db = MythDB(DBHostName=DBHostName, DBName=DBName, DBUserName=DBUserName, DBPassword=DBPassword)
test = db.getRecorded(basename=filename)



#Import all information from database regarding file

'''
#print out data (just for testing)
for x in test.items():
    print x[0] + " = " + str(x[1])
'''

####
#Commercial skip information
####
# gathers all markup into two lists:
# markupstart
# markupstop
####
markup = test.markup
markupstart = []
markupstop = []


for data in markup:
    if data.type == 4:
        markupstart.append(data.mark)
    if data.type == 5:
        markupstop.append(data.mark)

####
#write data to a text file
####
with open("showData.txt", 'w') as f:
    #iterate through each Recorded() data item and write it to the file
    for x in test.items():
        f.write(x[0] + " = " + str(x[1]) + "\n")
    f.write("--------FRAME START--------\n")
    for data in markupstart: f.write(str(data) + "\n")
    f.write("--------FRAME STOP---------\n")
    for data in markupstop: f.write(str(data) + "\n")
    f.write("--------END FRAMES---------\n")


