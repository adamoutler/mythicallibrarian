#!/usr/bin/python

def version():
    #Displays author and version information.
    #This file may be used for any purpose, however the credits should never be changed. 
    print ' Written by Mike Szczys'
    print ' Maintained by Adam Outler (outleradam at hotmail.com'
    print ' for support, please visit: http://forum.xbmc.org/showthread.php?t=65644'
    print ' This file was written for the mythicalLibrarian project,'
    print ' and is licensed under INSERT LICENSE HERE which allows adaptation.'
    print ' ------------------------------------------------------------------'
    print 'Beta'
    print '  ' + __file__ + ' utilizes mythtv python bindings to obtain information'
    print '  about a recording and will print the information to a file.'
    print ''
    return 0


def help():
    #Displays usage information
    print ' ' + __file__ + ' is designed to pull data from MythTV python bindings.'
    print ''
    print ''
    print 'Usage:'
    print ' ' + __file__ + ' --filename=file.ext : returns information to showData.txt'
    print '       --DBHostName        : sets the DB Host, default: localhost'
    print '       --DBName            : sets the DB Name, default: mythconverg'
    print '       --DBUserName        : sets the User Name, default: mythtv'
    print '       --DBPassword        : sets the Password, default, mythtv'
    print '       --output=file.txt   : sets the output, default: ./showData.txt'
    print '       --version|-v|-ver   : displays version information'
    print '       -auto               : attempts to pull databse login info from mysql.txt'
    print ' example:'
    print ' $ ' + __file__ + ' --filename=1000_20101010101010.mpg --DBHostName=localhost --DBName=mythconverg --DBUserName=mythtv --DBPassword=mythtv --output=/home/myfile.txt'
    print ''
    return 0

def invalidFile():
    print 'target is not valid.  Please choose a valid target.'
    print 'usage: ' + __file__ + ' --filename='
    help()

    return 0

filename = '1006_20100823173000.mpg'
#requires libmyth-python python-lxml
import sys, os

#Setup default database information
dbInfo = {
    "DBHostName" : "localhost",
    "DBName"     : "mythconverg",
    "DBUserName" : "mythtv",
    "DBPassword" : "mythtv"
    }
#Setup other default option information
options = {
    "auto"       : "False" ,
    "output"     : "./showData.txt",
    "filename"   : "" }

#A list of valid command line options (anything with an = sign) and flags
validOptions = ['--DBHostName','--DBName','--DBUserName','--DBPassword', '--filename', '--output']
validFlags = ['-auto'] #auto flag looks up login from mysql.txt
validVersionFlags = ['-v','--version','-ver']
validHelpFlags = ['-?','--help','-h']

                
####
#Handle Command Line Arguments
####

#If there were no arguments
if len(sys.argv) < 2:
    print "ERROR: Filename must be passed as an argument"
    print
    help()
    print sys.argv[0]
    print __file__
    sys.exit(1)


print 'woot'
#parse through the arguments
if len(sys.argv) >= 2:
    #create an argument list without scriptname and filename
    myArgs = sys.argv[1:]
    for arg in myArgs:
        #Test to see if this is an option flag
        if '=' in arg and arg.split('=')[0] in validOptions:
            #This is a valid option, do something with it

            #Testing to see if it's database login info
            if arg.split('=')[0][2:] in dbInfo:
                #It's a DB login item, save it in dbInfo
                dbInfo[arg.split('=')[0][2:]] = arg.split('=')[1].replace('"','')

            #If it's not, it must be a misc option
            elif arg.split('=')[0][2:] in options:
                #It is in the options dictionary, save it
                options[arg.split('=')[0][2:]] = arg.split('=')[1].replace('"','')

            #If it wasn't either, then we've got problems
            else:
                print "ERROR: Option flag was valid but something went wrong trying to use that data"
                sys.exit(1)

        #Test to see if this is a version flag
        elif arg in validVersionFlags:
            version()
 	    sys.exit(0)

        #Test to see if this is a help flag
        elif arg in validHelpFlags:
            help()
            sys.exit(0)

        #Test for the rest of the valid flags
        elif arg in validFlags:
            #TODO: do something here
            print "A valid flag was detected but there's no code to do anything with it yet"                       

         	 	
        else:
            #this is an unacceptable argument, raise an exception
            print "ERROR: Invalid command line argument: " + arg
            sys.exit(1)


#TODO Set the filename here 

#TODO if flags[filename] = "" then  flags[filename] = sys.argv[1]

#TODO test validitiy of filename and spit out invalidFile() help

###############################
#Function: readMysqlTxt
#Arguments: None
#Returns: list of five values:
#  0 or 1 for success or error
#  DBHostName
#  DBName
#  DBUserName
#  DBPassword
#
#Note: Need to add error catching in case file read problems
###############################
def readMysqlTxt():
    #Read database settings from ~/.mythtv/mysql.txt
    mysqlTXT = os.path.expanduser('~') + "/.mythtv/mysql.txt"

    with open(mysqlTXT,'r') as f:
	mysqlData = f.read()
	#Add error handling here... return [1] if error

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
    return [0,'DBHostName=\''+DBHostName+'\'','DBName=\''+DBName+'\'','\'DBUserName=\''+DBUserName+'\'','\'DBPassword=\''+DBPassword+'\'']


#Get data from mythtv database
from MythTV import MythDB

print 'Establishing database connection'
try:
        #Defaults or args
 	db = MythDB(DBHostName=dbInfo['DBHostName'], DBName=dbInfo['DBName'], DBUserName=dbInfo['DBUserName'], DBPassword=dbInfo['DBPassword']) 
except: 
	try:
            #mythtv preconfigured options
            print 'Failed: attempting to use system default configuration'
 	    db = MythDB() 
        except:
            try:
                #read from the mysql.txt
 	        print 'Failed: attempting to read from default mythtv file'
 	        db = MythDB(readMysqlTxt()) 
            except: 
                print 'Failed: Please specify database information manually'
 		sys.exit(' See --help for more information.')

#Insert statement if db could not be accessed.



try:
    rec = db.searchRecorded(basename=flags['filename']).next()
except StopIteration:
    raise Exception('Recording Not Found')


####
#Commercial skip information
####
# gathers all markup into two lists:
# markupstart
# markupstop
####
markup = rec.markup
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
with open(flags['output'], 'w') as f:
    #iterate through each Recorded() data item and write it to the file
    for x in rec.items():
        f.write(x[0] + " = " + str(x[1]) + "\n")
    f.write("------COMMERCIAL SKIP------\n")
    f.write("--------FRAME START--------\n")
    for data in markupstart: f.write(str(data) + "\n")
    f.write("--------FRAME STOP---------\n")
    for data in markupstop: f.write(str(data) + "\n")
    f.write("--------END FRAMES---------\n")

if rec.chanid != '':
    print "Operation complete"


