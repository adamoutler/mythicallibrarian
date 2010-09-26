#!/usr/bin/python

filename = "1004_20100823003000.mpg"

backendIP = "127.0.0.1"
databaseName = "mythconverg"
username = "mythtv"
password = "mythtv"

from MythTV import MythDB

db = MythDB(DBHostName=backendIP, DBName=databaseName, DBUserName=username, DBPassword=password)

test = db.getRecorded(chanid=filename[:4],starttime=filename[5:-4])

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



