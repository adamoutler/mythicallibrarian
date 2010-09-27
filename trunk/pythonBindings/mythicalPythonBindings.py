#!/usr/bin/python



#import as command line option
filename = "2151_20100923200000.mpg"


#Possible to add this as a command line option for remote hosts?
#This data can be obtained from /home/mythtv/.mythtv/mysql.txt but how to get to it?  
#chgrp mythtv /etc/mythtv/mysql.txt in mythicalSetup.  This script could be run with sudo.
#sudo grep DBHostName= /home/mythtv/.mythtv/mysql.txt| sed s/'DBHostName='//g
backendIP = "192.168.1.105"
#sudo grep DBName= /home/mythtv/.mythtv/mysql.txt| sed s/'DBName='//g
databaseName = "mythconverg"
#sudo grep DBUserName= /home/mythtv/.mythtv/mysql.txt| sed s/'DBUserName='//g
username = "mythtv"
#sudo grep DBPassword= /home/mythtv/.mythtv/mysql.txt| sed s/'DBPassword='//g
password = "mythtv"
#The problem is that this data cannot be brought in from the file without a reduction in system permissions.

from MythTV import MythDB
db = MythDB(DBHostName=backendIP, DBName=databaseName, DBUserName=username, DBPassword=password)
test = db.getRecorded(chanid=filename[:4],starttime=filename[5:-4])



#Import all information from database regarding file

#print out data (just for testing)
for x in test.items():
    print x[0] + " = " + str(x[1])

#write data to a text file
with open("showData.txt", 'w') as f:
    for x in test.items():
        f.write(x[0] + " = " + str(x[1]) + "\n")

        

'''
print "Title = " + test.title
print "Episode = " + test.subtitle
print "ChanID = " + str(test.chanid)
print "ProgramID = " + test.programid
print "Zap2ItSeriesID = " + test.seriesid
print "Plot = " + test.description
print "ShowStartTime = " + str(test.progstart)
print "ShowCategory = " + test.category
print "OriginalAirDate = " + str(test.originalairdate)
#print "XMLTVGrabber = " + ????
#print "MovieAirDate = " + ????
print "--- COMSKIP DATA ---"
print "markup start"
print test.markup
'''


