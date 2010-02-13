#! /bin/bash

# ***** WELCOME! Scroll further down to set the user settings. *****

 #mythicalLibrarian by Adam Outler
 #Wed, 30Jan2010 1023
 #email: outleradam@hotmail.com
 #Software the way it should be: Free and Open Source
 #Please contact me with any bug reports 
 #Tech Support: http://xbmc.org/forum/showthread.php?p=470402#post470402
 #Feature Request: http://xbmc.org/forum/showthread.php?t=65769
 
 #Intention:
 # This program was designed to be a user job in MythTV.  It can be called by creating a user job. It must have access to your MythTV recordings
 # This file should be placed in /home/mythtv/mythicalLibrarian
 # The user job can be called as follows:
 # /home/mythtv/mythicalLibrarian/mythicalLibrarian.sh  "%TITLE%" "%SUBTITLE%" "%DIR%/%FILE%"
 #
 #Usage:
 #  mythicalLibrarian.sh "show name" "episode name" "Target Folder"
 #  eg. mythicalLibrarian.sh "South Park" "Here Comes the Neighborhood" "/home/mythrecordings/2308320472023429837.mpg"
 #  
 #Output-target
 # If an error occurs and the file cannot be moved, then no change will occur to the original file. If the Movedir
 # is full or not available, such as when running a NAS and the computer is disconnected from the network, the 
 # AlternateMoveDir will be used. If both of these dirs fail, the show will be SymLinked in the FailSafeDir.
 # You may elect to run the user job at a later time when the issue has been resolved.  Output dir and link type 
 # will depend  on user settings. The file name however, is preset to the most acceptable standard:
 #   Show Title - SxxExx (Episode Title).ext
 #
 #Symlinking:
 # When Symlinking is enabled, mythicalLibrarian will follow its normal mode of operation.  In MOVE mode, 
 # mythicalLibrarian will create a symlink from the new file in the same name and location of the old file.  In 
 # LINK mode, mythicalLibrarian will not move the file, LINK mode creates a new symlink to the original file. 
 # 
 #Output-Files
 # mythicalLibrarian will create several files in it's working folder.  This is a list of the files and their functions.
 # -created.tracking-keeps track of created comskip.txt and NFO files so they can be deleted in the future if their video file
 # is deleted.
 # -doover.sh is designed to keep track of failed jobs.  It is designed to be executable.  #Commented commands are 
 # those which are determined to be questionable.  This file can be made executable and ran after a problem is corrected
 # which caused the problem. Questionable commands are those which will require you to add a episode title and set the
 # mythicalLibrarian.sh Database=Disabled setting.  Questionable files do not have sufficient guide data.
 # -markupstart.txt and markupstop.txt are files which contain information from the last comskip generation.
 # Deletion will cause no adverse effects.
 # -output.log keeps track of operations and can be used to determine problems.
 # -shn.txt, sid.txt, and working.xml are used each time to determine the name and show id of the last show identified.
 # -The DailyReport folder is used to log the files which were moved that day.  It can be used as a "program guide" of sorts
 # to keep track of what has been added to your library.
 #
 #Logging:
 # Log file will show information for troubleshooting. You can find the log file in the working folder
 # Log file default location: /home/mythtv/mythicalLibrarian/output.log
 #
 #Database-external:
 # This program will make 3 calls to TheTvDb for every episode.  The first one is to obtain the series ID and verify the show
 # name is correct.  The seccond is to check if the internally managed database is up-to-date.  The third call will only be
 # made if the internal database is not up-to-date.  The third call will download a larger file which contains all information
 # about the show which is known on TheTvDb.
 #
 #Database-internal:
 # While mythicalLibrarian maintains and requires it's own external file/folder database in the working directory, there is 
 # also support for integration with MythTV's internal database.  MythTV Database is required for movies to be recognized and 
 # handled by mythicalLibrarian. Also, in the event that the integrated fuzzy logic cannot make a determination of the 
 # correct show name, mythicalLibrarian will pull the original air date from the MythTV database and attempt to make an 
 # exact match to theTvDb.com supplied data. In addition, the type of program is extracted from the mythtv database and a 
 # determination is made weather or not there is sufficient information available to identify the show based upon guide data
 # In order to make mythicalLibrarian work to it's full potential, all settings must be filled out correctly under the 
 # database section of the user settings. Currently, the only guide data supported is schedulesdirect through mythtv. When
 # updating mythicalLibrarian it is best to delte all database folders to ensure proper data formatting.
 #
 #Dependencies: depends on "curl", "agrep", "libnotify-bin" and Mythtv Backend for database access.
 # install curl with "apt-get install curl"  -curl downloads webpages and sends commands to XBMC 
 # install agrep with "apt-get install agrep"  -agrep provides fuzzy logic
 # optional: install libnotify-bin with "apt-get install libnotify-bin" -allows GNOME desktop notifications
 #
 #Ubuntu Notifications:
 # In order for mythicalLibrarian to send notifications to the GNOME desktop, it must have no-password sudo access.  It uses
 # this access strictly to send complete, moving and failure status notifications.  Because this program is launched by the
 # user mythtv under normal circumstances, mythtv must temporarily become your user name in order to send a notification to
 # your desktop. This requires the use of a separate script, and for mythtv to have a sudoers group with no password option.
 # Notifications are an optional feature and will only work on the MythTV backend computer.  The librarian-notify-send script
 # should be located in /usr/local/bin.  You can get this script here:
 # https://sourceforge.net/projects/mythicallibrari/files/mythicalLibrarianBeta/librarian-notify-send/download
 #
 #XBMC Notifications:
 # If options are enabled, mythicalLibrarian will send a http requests to a specified XBMC Server to display library updates,
 # to update the library and to clean out the library.  In order for this to work XBMC you must ensure that the setting in 
 # XBMC under System->Network->Services->Allow control of XBMC via HTTP and Allow programs on other systems to control XBMC
 # are enabled.  

 
 #Show Name Translation
 # The user may elect to create a file in the mythicalLibrarian/ working folder which will then translate any recorded
 # show name into the desired show name.  This is useful for adding a year to distinguish between a new series
 # and an older series and/or typos in your guide data.  By default it should be called "showtranslations" and
 # it will be in your home/username/mythicalLibrarian folder.  showtranslations is not needed by most users and the file 
 # should only be created if it is needed. Under most circumstances, the integrated fuzzy logic will be 
 # sufficient to translate the guide name to the TvDb name, however showtranslations is available to improve 
 # accuracy to 100%. The format of showtranslations is as follows:
 #Filename: /home/mythtv/mythicalLibrarian/showtranslations
 ##############################################################
 #My Guide Show Title = www.TheTvDb.com Show Title            #
 #Battlestar Gallactica = Battlestar Gallactica (2003)        #
 #The Office = The Office (US)                                # 
 #Millionaire = Who Wants To Be A Millionaire                 #
 #Aqua teen Hungerforce = Aqua Teen Hunger Force              #
 ##############################################################
 
 #######################USER SETTINGS##########################
 ###Stand-alone mode values###
 #SYMLINK has 3 modes.  MOVE|LINK|Disabled: Default=MOVE
 #Create symlink in original dir from file after 'MOVE' | Do not move, just create a sym'LINK' | move the file, symlinking is 'Disabled'
 SYMLINK=MOVE
 #MoveDir is the folder which mythicalLibrarian will move the file.  No trailing / is accepted eg. "~/videos"
 MoveDir="/home/mythtv/NAS/Video/Episodes"  #<------THIS VALUE MUST BE SET-------
 #AlternateMoveDir will act as a seccondary MoveDir if the primary MoveDir fails.  No trailing / is accepted eg. "~/videos"
 AlternateMoveDir=/home/mythtv/Episodes
 #If UseOriginalDir is Enabled, original dir will override MoveDir.  Useful for multiple recording dirs.
 #UseOriginalDir will not separate episodes from movies. Enabled|Disabled
 UseOriginalDir=Disabled
 #When Enabled, mythicalLibrarian will move the file to a folder of the same name as the show. This is not affected by UseOriginalDir. Enabled|Disabled
 UseShowNameAsDir=Enabled
 #Internet access Timeout in seconds: Default Timeout=50 (seconds)
 Timeout=50
 #Update database time in secconds, Longer duration means faster processing time and less strain on TheTvDb. Default='84000' (1 day)
 UpdateDatabase=1
 #mythicalLibrarian working file dir: Default=~/mythicalLibrarian (home/username/mythicalLibraian)
 mythicalLibrarian=~/mythicalLibrarian
 #FailSafe mode will enable symlinks to be formed in FailSafeDir if the move or symlink operation fails. Enabled|Disabled
 FailSafeMode=Enabled
 #FailSafeDir is used when the file cannot be moved to the MoveDir. FailSafe will not create folders. eg. /home/username
 FailSafeDir="/home/mythtv/FailSafe"  #<------THIS VALUE MUST BE SET-------
 #DirTracking will check for and remove the folders created by mythicalLibrarian
 DirTracking=Enabled
 #the following line contains the API key from www.TheTvDb.Com. Default project code: 6DF511BB2A64E0E9
 APIkey=6DF511BB2A64E0E9
  
 ###Database settings### 
 #MythTV MYSQL access allows addition of movies, comskip data, and improves accuracy of episode recognition.
 #Database access Enabled|Disabled
 Database=Enabled
 #Database Type Default=MythTV
 DatabaseType=MythTV
 #Guide data type
 GuideDataType=SchedulesDirect
 #MySQL User name: Default="mythtv"
 MySQLuser="mythtv" #<------THIS VALUE MUST BE SET-------
 #MySQL Password: Default="mythtv"
 MySQLpass="mythtv" #<------THIS VALUE MUST BE SET-------
 #MySQL Myth Database: Default="mythconverg"
 MySQLMythDb=mythconverg
 #Primary Movie Dir. mythicalLibrarian will attempt to move to this dir first. No trailing / is accepted eg. "~/videos"
 PrimaryMovieDir="/home/mythtv/NAS/Video/Movies" #<------THIS VALUE MUST BE SET-------
 #AlternateMoveDir will act as a Seccondary move dir if the primary moive dir fails
 AlternateMovieDir="/home/mythtv/Movies"
 #CommercialMarkup will generate comskip files for recordings when they are moved. Enabled|Disabled
 CommercialMarkup=Enabled
 #CommercialMarkupCleanup will execute a maintenance routine which will remove comskip files if they are not needed
 CommercialMarkupCleanup=Enabled

 ###Reporting/Communications###
 #Enables debug mode.  This is a verbose mode of logging which should be used for troubleshooting.  Enabled|Disabled
 DEBUGMODE=Enabled
 #DailyReport provides a local log of shows added to your library per day. Enabled|Disabled
 DailyReport=Enabled
 #Notify tells mythicalLibrarian to send a notification to GNOME Desktop upon completion. Enabled|Disabled
 Notify=Enabled
 #If notifications are enabled, NotifyUserName should be the same as the user logged into the GNOME Session. (your username)
 NotifyUserName="adam" #<------THIS VALUE MUST BE SET-------
 #Send a notification to XBMC to Update library upon sucessful move job Enabled|Disabled
 XBMCUpdate=Enabled
 #Send a notification to XBMC to cleanup the library upon sucessful move job Enabled|Disabled
 XBMCClean=Enabled
 #Send Notifications to XBMC UI when library is updated Enabled|Disabled
 XBMCNotify=Enabled
 #Ip Address and port for XBMC Notifications Eg.XBMCIPs=( "192.168.1.110:8080" "192.168.1.111:8080" "XBOX:8080" )
 XBMCIPs=( "192.168.1.110:8080" "XBOX:8080" ) #<------THIS VALUE MUST BE SET-------
 #Commands to be run on sucessful job
 FailedJob () {
 	echo FAILED
 }
 #Command to be run on Failed job
 SucessfulJob () {
 	echo SUCESS
 }
 #########################USER SETTINGS########################## 
 
 ################################################################
 ############Adept personel only beyond this point###############
 ################################################################
 echo "@@@@@@@@@@@NEW SEARCH INITIATED AT `date`@@@@@@@@@@@@@">>"$mythicalLibrarian"/output.log 
  
 #####DEFINE ENVIRONMENT AND VARIABLES#####
 MyUserName=`whoami`
 #make our working dir if it does not exist
 if [ ! -d "$mythicalLibrarian" ]; then 
 	mkdir $mythicalLibrarian
 	echo "creating home/mythicalLibrarian and log file">>"$mythicalLibrarian"/output.log
 fi

 #Set episode name, dir, extension, and showname from the input parameters.
 ShowName=$1
 epn=`echo $2|sed 's/;.*//'|tr -d [:punct:]`
 originalext=`echo "${3#*.}"`
 originaldirname=`dirname "$3"`
 FileBaseName=${3##*/}  
 FileName="$3"
 #Check for show translations relating to the show in question.
 if [ -f $mythicalLibrarian/showtranslations ]; then 
 	showtranslation=`grep "$ShowName = " "$mythicalLibrarian/showtranslations"|replace "$ShowName = " ""|replace "$mythicalLibrarian/showtranslations" ""`		 
 	if [ "$showtranslation" != "$null" ];then 
 		ShowName=$showtranslation
 		echo "USER TRANSLATION: $1 = $ShowName">>"$mythicalLibrarian"/output.log
 	elif [ "$showtranslation" = "$null" ];then
 		showtranslation="Inactive"
 	fi
 fi
 
 #Check for Use Original Dir Parameter
 test "$UseOriginalDir" = "Enabled" && MoveDir="$originaldirname"
 
 #Check and make doover.sh if it does not exist
 test ! -f "$mythicalLibrarian/doover.sh" && echo 'rm "'$mythicalLibrarian'"/doover.sh'>$mythicalLibrarian/doover.sh
  

 ######DAILY REPORT#####
 dailyreport() {
 	if [ $DailyReport = Enabled ]; then
 		test ! -d "$mythicalLibrarian/DailyReport" && mkdir "$mythicalLibrarian/DailyReport" 
 		reportfilename=`date +%Y-%m-%d`
 		reporttime=`date +%T`
     		echo "$reporttime "$1>>"$mythicalLibrarian/DailyReport/$reportfilename"
 	fi
 }
  
 #####CHECK PERMISSIONS#####
 #CheckPermissions by writing a small file then deleting it, checking along the way.
 #CheckPermissions takes file size, free space on dir, and the dir, then it performs
 #tests.  the result will be $TMoveDirWritable as a 1 or a 0 for writable or not.
 checkpermissions () { 
 TMoveDirWritable=0
 if [ "$2" != "" ] && [ "$1" != "" ] && [ $1 -lt $2 ]; then
 	echo "Testing write permission on $3">$3/arbitraryfile.ext 
 	if [ -f "$3/arbitraryfile.ext" -a -s "$3/arbitraryfile.ext" ]; then
 		rm -f "$3/arbitraryfile.ext"
 		test ! -f "$3/arbitraryfile.ext" && TMoveDirWritable=1 || TMoveDirWritable=0
 	else
 		TMoveDirWritable=0
 		echo "CHECK PERMISSIONS ON $MoveDir"
 	fi
 elif [ -z "$2" ] || [ $1 -ge $2 ]; then
 	TMoveDirWritable=0
 	echo "UNUSABLE SPACE-CHECK:$3"
 fi
 }
 
 #####FUZZY LOGIC RECOGNITION OF SERIES#####
 FuzzySeriesMatch () {


 	showname=`echo "$ShowName"|replace "&amp;" "&"`
echo $showname
 	serieslinenumber=`agrep -Byn "${showname:0:27}" "$mythicalLibrarian/shn.txt"|sed 's/:.*//'|grep -m1 ^`
 
 #Get the seriesid based on the showname
  	seriesid=`sed -n $serieslinenumber'p' "$mythicalLibrarian"/sid.txt| grep -m1 ^`
 	NewShowName=`sed -n $serieslinenumber'p' "$mythicalLibrarian"/shn.txt|replace "&amp" "&"| tr -d '"<>:!\|/'|grep -m1 ^`
 }

 #####COMSKIP FILES#####
 #Function GenComSkip creates a comskip.txt file for use with the show upon moving, created from data from library
 GenComSkip () {
 		mythicalLibrarianCounter=1
 #Set up comskip file
 		test -f "$mythicalLibrarian/markupframes.txt" && rm -f "$mythicalLibrarian/markupframes.txt"
 		echo "FILE PROCESSING COMPLETE">"$mythicalLibrarian"/markupframes.txt
 		echo "------------------------">>"$mythicalLibrarian"/markupframes.txt	
 		while read line
 			do
 			mythicalLibrarianCounter=`expr $mythicalLibrarianCounter + 1`;
 			StartData=`sed -n "$mythicalLibrarianCounter"p "$mythicalLibrarian/markupstart.txt"`
 			StopData=`sed -n "$mythicalLibrarianCounter"p "$mythicalLibrarian/markupstop.txt"`
 			if [ ! -z "$StopData" ]; then
 				echo "$StartData $StopData">>"$mythicalLibrarian"/markupframes.txt
 				CommercialMarkup="Created"
 				echo "COMMERCIAL DATA START:$StartData STOP:$StopData"
 			fi
 		done <"$mythicalLibrarian/markupstop.txt"
 }
 
 

 
 
 #####XBMC COMMUNICATIONS#####
 #Function XBMC Automate handles all communication with XBMC  
 XBMCAutomate () {
 #Send notification to XBMC, Update Library, Clean Library
 
 if [ "$XBMCNotify" = "Enabled" ] || [ "$XBMCUpdate" = "Enabled" ] || [ "$XBMCClean" = "Enabled" ]; then
 
 	for XBMCIP in ${XBMCIPs[@]}
 	do
 		echo "SENDING REQUESTED COMMANDS TO:$XBMCIP"
 		test "$XBMCNotify" = "Enabled" && curl -s -m1 "http://"$XBMCIP"/xbmcCmds/xbmcHttp?command=ExecBuiltIn(Notification(mythical%20Librarian%2Cadding%20show%20$tvdbshowname%20to%20library))" > /dev/null 2>&1
 		test "$XBMCUpdate" = "Enabled" && curl -s -m1 "http://"$XBMCIP"/xbmcCmds/xbmcHttp?command=ExecBuiltIn(UpdateLibrary(video))" > /dev/null 2>&1
 		test "$XBMCClean" = "Enabled" && curl -s -m1 "http://"$XBMCIP"/xbmcCmds/xbmcHttp?command=ExecBuiltIn(CleanLibrary)" > /dev/null 2>&1
 	done
 fi
 }


 #####MYTHTV DATABASE#####
 #This function gathers information from the mythtv database for use in the program
 GetMythTVDatabase () {

 #Obtain MythTV Database Information
 	echo "Accessing MythTV DataBase:"

 #get chanid for recordings to identify program table
 	ChanID=`mysql -u$MySQLuser -p$MySQLpass -e "use '$MySQLMythDb' ; select chanid from recorded where basename like '$FileBaseName';"|sed -n 2p|replace "chanid" ""|replace " " ""`
  
 #get ProgramID from recorded to identify program
 	ProgramID=`mysql -u$MySQLuser -p$MySQLpass -e "use '$MySQLMythDb' ; select programid from recorded where basename like '$FileBaseName' ; " |sed -n "2p"|replace "starttime" ""`
 
 #Get zap2it series id from basename to identify program
 	Zap2itSeriesID=`mysql -u$MySQLuser -p$MySQLpass -e "use '$MySQLMythDb' ; select seriesid from recorded where basename like '$FileBaseName' ; " |sed -n "2p"|replace "seriesid" ""`
 
 #Get plot from basename to identify program
  	plot=`mysql -u$MySQLuser -p$MySQLpass -e "use '$MySQLMythDb' ; select description from recorded where basename like '$FileBaseName' ; " |sed -n "2p"|replace "description" ""`
 
 #Get rating from basename to identify program
 	stars=`mysql -u$MySQLuser -p$MySQLpass -e "use '$MySQLMythDb' ; select stars from recorded where basename like '$FileBaseName' ; " |sed -n "2p"|replace "stars" ""`

 #get show start time to identify program ----future development
 	ShowStartTime=`mysql -u$MySQLuser -p$MySQLpass -e "use '$MySQLMythDb' ; select starttime from recorded where basename like '$FileBaseName' ; " |sed -n "2p"|replace "starttime" ""`
 
 #get category from recorded to identify program table -----future development
 	ShowCategory=`mysql -u$MySQLuser -p$MySQLpass -e "use '$MySQLMythDb' ; select category from recorded where basename like '$FileBaseName' ; " |sed -n "2p"|replace "category" ""`
 
 #get original air date for tv shows
 	OriginalAirDate=`mysql -u$MySQLuser -p$MySQLpass -e "use '$MySQLMythDb' ; select originalairdate from recorded where basename like '$FileBaseName' ; "|sed -n "2p"|replace "originalairdate" ""`
 	test "$OriginalAirDate" = "0000-00-00" && OriginalAirDate="$null"
 
 #get DataType
   	XMLTVGrabber=`mysql -u$MySQLuser -p$MySQLpass -e "use '$MySQLMythDb' ; select xmltvgrabber from videosource ; "|replace "xmltvgrabber" ""|sed -n "2p"|replace " " ""`
 
 #get year for movies 
 	MovieAirDate=`mysql -u$MySQLuser -p$MySQLpass -e "use '$MySQLMythDb' ; select airdate from recordedprogram where programid like '$ProgramID' and chanid like '$ChanID' ; "|replace "airdate" ""|sed -n "2p"|replace " " ""`
 
 #Blank year if it is invalid
 	if [ ! -z "$MovieAirDate" ] && [ $MovieAirDate -lt 1900 ]; then
 		MovieAirDate=$null
 	fi

 #####COMSKIP DATA#####
 
 #Set up counter, remove old markup data and generate new markup file from markupstart and stop
 	if [ "$CommercialMarkup" = "Enabled" ]; then	
 #Remove old and generate a comskip Start list
 		echo $null >$mythicalLibrarian/markupstart.txt
	 	mysql -u$MySQLuser -p$MySQLpass -e "use '$MySQLMythDb' ; select mark from recordedmarkup where starttime like '$ShowStartTime' and chanid like '$ChanID' and type like "4" ; " |replace "mark" ""|replace " " "">>$mythicalLibrarian/markupstart.txt
 
 #Remove old and generate comskip Stop list
 		echo $null >$mythicalLibrarian/markupstop.txt
 		mysql -u$MySQLuser -p$MySQLpass -e "use '$MySQLMythDb' ; select mark from recordedmarkup where starttime like '$ShowStartTime' and chanid like '$ChanID' and type like "5" ; " |replace "mark" ""|replace " " "">>$mythicalLibrarian/markupstop.txt

 		GenComSkip
 	fi

 }
 
 #####REMOVE ENTRIES FROM LIBRARY#####
 #remove mythtv recording's pictures and database entries.  Thanks to barney_1.
 SYMLINKDisabled () {
 
 #Make sure we got input arguments and file is valid
 	if [ ! -f "$3" ]; then
 	
 #Remove recording entry from mysql database
 		echo "REMOVING - $FileBaseName - THUMBNAILS - DATABASE ENTRIES">>"$mythicalLibrarian"/output.log
  		echo "REMOVING - $FileBaseName - THUMBNAILS - DATABASE ENTRIES"
		mysql -u$MySQLuser -p$MySQLpass -e "use '$MySQLMythDb' ; delete from recorded where basename like '$FileBaseName'; "
 
 #Remove thumbnails
 		rm -f "$originaldirname/$FileBaseName".*	
 	fi 
 }
 
 
 #####PROCESS DATABASE INFORMATION#####
 #Function ProcessSchedulesDirect processes Zap2it/SchedulesDirect/Tribune data for use in the program
 ProcessSchedulesDirect () {
 
 #Check for database permissions
 	test "$ChanID" = "" && echo "%%%NO DATABASE INFORMATION. CHECK LOGIN/PASS OR FILE %%%%%">>$mythicalLibrarian/output.log
 
 #Get rating from Stars
  	rating=`printf "%0.f\n" $stars`
  	test $rating != "" && let rating=$rating*2
 	test $rating = "" && rating=1
 
 #Create MV/EP/SH Identification Type from ProgramID
	mythicalLibrarianProgramIDCheck=${ProgramID:0:2}
 
 #Extrapolate data from Programid
	test "$mythicalLibrarianProgramIDCheck" = "SH" && ProgramIDType="Generic Episode With No Data"
	test "$mythicalLibrarianProgramIDCheck" = "MV" && ProgramIDType="Movie"
	test "$mythicalLibrarianProgramIDCheck" = "EP" && ProgramIDType="Series With Episode Data"
 
 #if the ProgramID does not meet criteria, then end the program
 	if [ "$ProgramIDType" = "Generic Episode With No Data" ]; then
 		echo "GENERIC GUIDE DATA WAS SUPPLIED TYPE: $ProgramIDType- $1, $2">>"$mythicalLibrarian"/output.log
 		echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%">>"$mythicalLibrarian"/output.log
 		echo "%%%%%%%%%%%%%%%%%%%PROGRAM GUIDE DATA IS NOT COMPLETE%%%%%%%%%%%%%%%%%%%%">>"$mythicalLibrarian"/output.log
 		echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%">>"$mythicalLibrarian"/output.log
 		echo "%%%%%%%%%%%%%%OPERATION FAILED" `date` "%%%%%%%%%%%%%%%%%">>"$mythicalLibrarian"/output.log 
 		test $Notify = "Enabled" &&	sudo -u "$NotifyUserName" /usr/local/bin/librarian-notify-send "mythicalLibrarian Guide error" "Could not obtain enough information for library: $1 $ProgramIDType" utilities-system-monitor
  		echo $mythicalLibrarian'/mythicalLibrarian.sh "'$1'" "'$2'" "'$3'"'>>$mythicalLibrarian/doover.sh
 		SucessfulJob	
 		echo $runjob	
 		exit 0
 	fi
 	
 	Zap2itSeriesID=`echo $ProgramID| tr -d MVSHEP | sed 's/0*//' | sed 's/.\{4\}$//' `
 }

 #####DOWNLOAD AND PARSE INFORMATION FROM THETVDB#####
 DownloadAndParse () {
 #Get the seriesid based on the showname
 	 seriesid=`sed -n $serieslinenumber'p' "$mythicalLibrarian"/sid.txt|grep -m1 ^`
 	 NewShowName=`sed -n $serieslinenumber'p' "$mythicalLibrarian"/shn.txt|grep -m1 ^|replace "&amp;" "&"`
 #Create folder for database if it does not exist
 if [ ! -d "$mythicalLibrarian/$NewShowName" ]; then
 	mkdir $mythicalLibrarian/"$NewShowName"
 	echo "Creating MythicalLibrarian Database Folder">>"$mythicalLibrarian"/output.log
 fi
 echo "SEARCH FOUND:""$NewShowName" "ID#:" $seriesid >>"$mythicalLibrarian"/output.log
 
 #If series ID is obtained, then get show information.
 if [ "$seriesid" != "" ] ; then
 
 #####GET SERIES INFORMATION#####
 #Get current server time
 	curl -s -m"$Timeout" "http://www.thetvdb.com/api/Updates.php?type=none">"$mythicalLibrarian/$NewShowName/current.time"
 
 #Parse file into usable data only
 	test -f "$mythicalLibrarian/$NewShowName/current.time" && cat "$mythicalLibrarian/$NewShowName/current.time"|grep "<Time>"|replace "<Time>" ""|replace "</Time>" "">"$mythicalLibrarian/$NewShowName/current.time"
  	test -f "$mythicalLibrarian/$NewShowName/current.time" && TvDbTime=`cat "$mythicalLibrarian/$NewShowName/current.time"` 
 	test -f "$mythicalLibrarian/$NewShowName/lastupdated.time" && LastUpdated=`cat "$mythicalLibrarian/$NewShowName/lastupdated.time"`
 
 #If file exist for last updated time, then get value 
 	if [ -f "$mythicalLibrarian/$NewShowName/lastupdated.time" ]; then
 		LastUpdated=`cat "$mythicalLibrarian/$NewShowName/lastupdated.time"`
 
 #If no last updated time, then assign a never updated value
  	elif [ ! -f "$mythicalLibrarian/$NewShowName/lastupdated.time" ]; then
 		LastUpdated=0
 	fi	 
 
 #Check for valid time, if blank, then assign 0 value
 	test "$LastUpdated" = "" && LastUpdated="0"
 
 #Apply Database Update interval to last update time  LastUpdated = NextUpdated
 	let LastUpdated=$LastUpdated+$UpdateDatabase
 
 
 #if episode information is out of date or not created
 	if [ "$TvDbTime" -gt "$LastUpdated" ]; then
 
 #####GET EPISODE INFORMATION#####
 #Strip XML tags
 		seriesid=`echo $seriesid|tr -d "<seriesid>"|tr -d "</seriesid>"`
 
 #Download information from server
 		curl -s -m"$Timeout" "http://www.thetvdb.com/api/$APIkey/series/$seriesid/all/en.xml">$mythicalLibrarian"/$NewShowName/$NewShowName.xml"
 
 #create a folder/file "database" Strip XML tags.  Series, Exx and Sxx are separated into different files
 		if [ -f "$mythicalLibrarian/$NewShowName/$NewShowName.xml" ]; then 
 #Get Zap2it ID
			cat "$mythicalLibrarian/$NewShowName/$NewShowName.xml" | grep "<zap2it_id>"|replace "  <zap2it_id>" ""|replace "</zap2it_id>" ""| tr -d MVSHEP | sed 's/0*//'>"$mythicalLibrarian/$NewShowName/$NewShowName.zap2it.txt"

 #Get Fuzzy logic show name
 			cat "$mythicalLibrarian/$NewShowName/$NewShowName.xml" | grep "<EpisodeName>"|replace "  <EpisodeName>" ""|replace "</EpisodeName>" ""|sed 's/;.*//'|replace "&amp;" "&"|tr -d '`"<>:!\|/"'"'">"$mythicalLibrarian"/"$NewShowName"/"$NewShowName".Ename.txt

 #Get actual show name
 			cat "$mythicalLibrarian/$NewShowName/$NewShowName.xml" | grep "<EpisodeName>"|replace "&amp;" "and"|replace "  <EpisodeName>" ""|replace "</EpisodeName>" ""|tr -d [:punct:]>"$mythicalLibrarian"/"$NewShowName"/"$NewShowName".actualEname.txt

 #Get OriginalAirDate
 			cat "$mythicalLibrarian/$NewShowName/$NewShowName.xml" | grep "<FirstAired>"|replace "  <FirstAired>" ""|replace "</FirstAired>" ""|replace "/" "">"$mythicalLibrarian/$NewShowName/$NewShowName".FAired.txt

 #Get Season number
 			cat "$mythicalLibrarian/$NewShowName/$NewShowName".xml | grep "<SeasonNumber>"|replace "<SeasonNumber>" ""|replace "</SeasonNumber>" ""|replace " " "">"$mythicalLibrarian"/"$NewShowName"/"$NewShowName".S.txt
 
 #Get Episode number
 			cat "$mythicalLibrarian/$NewShowName/$NewShowName".xml | grep "<EpisodeNumber>"|replace "<EpisodeNumber>" ""|replace "</EpisodeNumber>" ""|replace " " "">"$mythicalLibrarian/$NewShowName/$NewShowName".E.txt
 
 
 		elif [ ! -f "$mythicalLibrarian/$NewShowName/$NewShowName.xml" ]; then
 			echo "COULD NOT DOWNLOAD:www.thetvdb.com/api/$APIkey/series/$seriesid/all/en.xml">>"$mythicalLibrarian"/output.log
 		fi
 	 
 #check if files were created and generate message
 		if [ -f $mythicalLibrarian/"$NewShowName"/"$NewShowName".Ename.txt ]; then
 	 		echo $TvDbTime>"$mythicalLibrarian/$NewShowName/lastupdated.time"
 			echo "LOCAL DATABASE UPDATED:$mythicalLibrarian/$NewShowName">>"$mythicalLibrarian"/output.log
 		elif [ ! -f "$mythicalLibrarian/$NewShowName/$NewShowName.Ename.txt" ]; then
 			echo "*** PERMISSION ERROR $mythicalLibrarian/$NewShowName/">>"$mythicalLibrarian"/output.log
 		fi
 #Send report to the log if database was not updated.
 	elif [ "$TvDbTime" -le "$LastUpdated" ]; then
 		echo "DATABASE IS MAINTAINED. TIME IS:$TvDbTime NEXT UPDATE IS:$LastUpdated"
 	fi
 fi
 }
 
 #####GENERATE tvshow.nfo#####
 TVShowNFO () {
 	echo"<tvshow>">"$MoveDir"/tvshow.nfo
 	echo"	<title>$NewShowName</title>">>"$MoveDir"/tvshow.nfo
 	echo"	<rating>$rating/rating>">>"$MoveDir"/tvshow.nfo
 	echo"	<season>-1</season>">>"$MoveDir"/tvshow.nfo
 	echo"	<episode>0</episode>">>"$MoveDir"/tvshow.nfo
 	echo"	<displayseason>-1</displayseason>">>"$MoveDir"/tvshow.nfo
 	echo"	<displayepisode>-1</displayepisode>">>"$MoveDir"/tvshow.nfo
 	echo"	<genre>$category<genre>">>"$MoveDir"/tvshow.nfo
 	echo"</tvshow>">>"$MoveDir"/tvshow.nfo
 } 
 
 
 
 #####MAINTENANCE#####
 #Loop through the list of created comskip files from comskip.tracking and remove orphans.
 if [ "$CommercialMarkupCleanup" = "Enabled" -a -f "$mythicalLibrarian/created.tracking" ]; then
 	mythicalLibrarianCounter=0
 	echo "PERFORMING MAINTENANCE ROUTINE">>"$mythicalLibrarian"/output.log
 	while read line
 	do
 		(( ++$mythicalLibrarianCounter ))
 		SupportFile=`echo $line|cut -d"'" -f2`
 	 	MainFile=`echo $line|cut -d"'" -f4`
 		ls "$MainFile" > /dev/null 2>&1
 		if [ "$?" != "0" ]; then
  			if [ -d "`dirname $SupportFile`" ]; then
 				echo "REMOVING ORPHAN $SupportFile"
 				echo "REMOVING ORPHAN $SupportFile">>"$mythicalLibrarian"/output.log
 				rm -f "$SupportFile"
 			else
 				echo "FOLDER DISCONNECTED:"`dirname $SupportFile`
 				echo "FOLDER DISCONNECTED:"`dirname $SupportFile`>>"$mythicalLibrarian"/output.log
 			 	echo "$line" >> "$mythicalLibrarian/created.tracking2"	
 			fi
 		else 
 			echo "$line" >> "$mythicalLibrarian/created.tracking2"
  		fi
 	done <"$mythicalLibrarian/created.tracking"
  	test -f "$mythicalLibrarian/created.tracking" && rm -f "$mythicalLibrarian/created.tracking"
  	mv "$mythicalLibrarian/created.tracking2" "$mythicalLibrarian/created.tracking"

 fi

 #Check if folders are empty and remove dir if needed and it was created by mythicalLibrarian
 if [ "$DirTracking" = "Enabled" -a -f "$mythicalLibrarian/dir.tracking" ]; then
 	while read line
 	do
 		DirToCheck=$line
 		if [ -d "$DirToCheck" ]; then
  			DirToCheckCheck=`ls "$line"|grep -m1 ^`
		 	if [ "$DirToCheckCheck" = "" ]; then
 				echo "REMOVING ORPHAN FOLDER:$line">>"$mythicalLibrarian"/output.log
  				echo "REMOVING ORPHAN FOLDER:$line"
 				rmdir "$line"
			elif [ "$DirToCheckCheck" != "" ]; then
  				echo "$DirToCheck" >> "$mythicalLibrarian/dir.tracking2"
			fi
 		elif [ ! -d "$DirToCheck" ]; then
 			echo $DirToCheck >> "$mythicalLibrarian/dir.tracking2"
 		fi

 	done < "$mythicalLibrarian"/dir.tracking
  	rm -f "$mythicalLibrarian/dir.tracking"
  	mv "$mythicalLibrarian/dir.tracking2" "$mythicalLibrarian/dir.tracking"
 fi 	 
  
 
 #####GATHER INFORMATION FROM  DATABASE#####
  #Get information if database is enabled
 if [ "$Database" = "Enabled" ]; then 
  	test "$DatabaseType" = "MythTV" && GetMythTVDatabase
	test "$GuideDataType" = "SchedulesDirect" && ProcessSchedulesDirect
 
  fi
  #Report found data
 echo "RECSTART:$ShowStartTime MOVIEYEAR:$MovieAirDate SERIESDATE:$OriginalAirDate"
 echo "PROGRAMID:$ProgramID ShowCategory:$ShowCategory STARS:$stars RATING:$rating"
 echo "PLOT: $plot"
  
 
 #####SEARCH FOR SHOW NAME#####
 if [ "$2" != "" ] || [ "$mythicalLibrarianProgramIDCheck" = "EP" ] ; then
 	echo "SEARCHING: www.TheTvDb.com SHOW NAME: $ShowName EPISODE: $epn">>"$mythicalLibrarian"/output.log
 	echo "FILE NAME: $3">>"$mythicalLibrarian"/output.log
 
 #Format Show name for Sending to www.TheTvDb.com
 	tvdbshowname=`echo $ShowName|replace " " "%20"`
 
 #download series info for show, parse into temporary text db- sid.txt shn.txt
 	curl -s -m"$Timeout" www.thetvdb.com/api/GetSeries.php?seriesname=$tvdbshowname>"$mythicalLibrarian/working.xml"
 	cat $mythicalLibrarian/working.xml | grep "<seriesid>"|replace "<seriesid>" ""|replace "</seriesid>" "">"$mythicalLibrarian/sid.txt"
 	cat $mythicalLibrarian/working.xml | grep "<SeriesName>"|replace "<SeriesName>" ""|replace "</SeriesName>" "">$mythicalLibrarian/shn.txt
 
 elif [ -z "$MovieAirDate" ]; then
 	NewShowName=$1
 fi
 
 
 ######DOWNLOAD/PARSE/IDENTIFICATION OF SHOW NAME######
 if [ "Zap2itSeriesID" != "" ] && [ "$mythicalLibrarianProgramIDCheck" = "EP" ] ; then
 	mythicalLibrarianCounter=0
 
 #loop through all show names received by TheTvDb and match Zap2it ID.
 	while read line 
 	do
 		(( ++ mythicalLibrarianCounter ))
 		serieslinenumber=$mythicalLibrarianCounter
 		echo "TESTING FOR ZAP2IT SERIES ID MATCH:$line"
 		DownloadAndParse
 		ParsedZap2itSeriesID=`cat "$mythicalLibrarian/$NewShowName/$NewShowName.zap2it.txt"`
       	if [ "$ParsedZap2itSeriesID" = "$Zap2itSeriesID" ]; then
 
 #Mark matched Zap2it ID
  			echo "MATCH FOUND BASED ON Zap2itID:$NewShowName ID:$seriesid"
 			MatchedShowName=$NewShowName
 			MatchedSeriesID=$seriesid
 			MatchedSeriesLineNumber=$serieslinenumber
 		fi
 	done < "$mythicalLibrarian"/shn.txt
 	if [ -n "$MatchedShowName" ]; then
 
 #Use matched Zap2it ID
 		NewShowName=$MatchedShowName
 		seriesid=$MatchedSeriesID
 		serieslinenumber=$MatchedSeriesLineNumber
 	else
 
 #when no match is found:
 		echo "USING FUZZY LOGIC FOR EPISODE RECOGNITION Please update TheTvDb.com">>"$mythicalLibrarian"/output.log
 		echo "USING FUZZY LOGIC FOR EPISODE RECOGNITION Please update TheTvDb.com"

 #Use fuzzy logic to make the best match of the show name as a last resort
 	 	FuzzySeriesMatch
 		echo "FUZZY LOGIC SHOW NAME: $NewShowName ID: $seriesid"
 		DownloadAndParse
 	fi
 elif [ "Zap2itSeriesID" != "" ] && [ "$mythicalLibrarianProgramIDCheck" = "EP" ] || [ "$2" != "" ]; then
 
 #If no zap2it ID is present, then use fuzzy logic to do show tranlation
  	FuzzySeriesMatch
 	echo "FUZZY LOGIC SHOW NAME: $NewShowName ID: $seriesid"
 	DownloadAndParse
 fi
 
 if [ "$seriesid" != "" ] ; then 
 
 
 #####PROCESS SHOW INFORMATION##### 	
 #If info was pulled from database, then plug name into newshowname	
 	test -z "$NewShowName" && NewShowName=$ShowName
 
 #use fuzzy logic to find the closest show name from the locally created database and return absolute episode number
 	absolouteEpisodeNumber=`agrep -Byn "${epn:0:29}" "$mythicalLibrarian/$NewShowName/$NewShowName.Ename.txt"|sed 's/:.*//'|grep -m1 ^`
 	echo FUZZY Exx NUMBER:$absolouteEpisodeNumber 
 
 #if no fuzzy match, then use database to match.
 	if [ "$Database" = "Enabled" ]; then
 		if [ "$absolouteEpisodeNumber" = "" -a "$OriginalAirDate" != "" ]; then
 			absolouteEpisodeNumber=0
 			absolouteEpisodeNumber=`grep -n "$OriginalAirDate" "$mythicalLibrarian""/""$NewShowName""/""$NewShowName"".FAired.txt"|grep -m1 ^|sed 's/:.*//'`
 			absolouteEpisodeNumber=`grep -n "$OriginalAirDate" "$mythicalLibrarian""/""$NewShowName""/""$NewShowName"".FAired.txt"|grep -m1 ^|sed 's/:.*//'`
 #Subtract 1 to compensate for original series airdate
  			if [ "$absolouteEpisodeNumber" != "" ]; then
  				let absolouteEpisodeNumber=$absolouteEpisodeNumber-1
  				echo DB ABSOLOUTE Exx NR:$absolouteEpisodeNumber BASED ON ORIG AIR DATE:$OriginalAirDate 
  			fi
 		fi
 
 #Remove no match found, "-1" = ""
 		test "$absolouteEpisodeNumber" = "-1" && absolouteEpisodeNumber=$null
 	fi
 	echo "DEFINED ABSOLOUTE EPISODE NUMBER: $absolouteEpisodeNumber">>"$mythicalLibrarian"/output.log
  
 #if line match is obtained, then gather new episode name, Sxx and Exx
 	if [ "$absolouteEpisodeNumber" !=  ""  ]; then
 		epn=`sed -n $absolouteEpisodeNumber'p' $mythicalLibrarian/"$NewShowName"/"$NewShowName".actualEname.txt`
 
 #gather series and episode names from files created earlier.
 		exx=`sed -n $absolouteEpisodeNumber'p' $mythicalLibrarian/"$NewShowName"/"$NewShowName".E.txt`
 		sxx=`sed -n $absolouteEpisodeNumber'p' $mythicalLibrarian/"$NewShowName"/"$NewShowName".S.txt`
 
 #Single digit episode and show names are not allowed Ex and Sx replaced with Exx Sxx
 		test $exx -lt 10  && exx="E0$exx" || exx="E$exx"
 		test $sxx -lt 10  && sxx="S0$sxx" || sxx="S$sxx"
 	fi
 	echo "EPISODE:$epn ABSOLUTE NUMBER:$absolouteEpisodeNumber" $sxx$exx
 
 #if series id is not obtained send failure message
 elif [ -z "$seriesid" ]; then 
 	echo "series was not found the tvdb or this is a movie may be down try renaming $1">>"$mythicalLibrarian"/output.log
  	if [ "$Database" = "Enabled" ]; then
 		echo "DB ENTIRES- RECSTART:$ShowStartTime- MOVIE:$MovieAirDate- ORIGAIRDATE:$OriginalAirDate- CHID:$ChanID- CAT:$ShowCategory-">>"$mythicalLibrarian"/output.log
 		exx=$null
 	fi
 fi
 
 #If it's a movie, give it a name.
 test "$mythicalLibrarianProgramIDCheck" = "MV" && NewShowName="$1"
 
 ######SANITY CHECKS#####
 #If file is a link then activate link mode so the original link is not screwed up.
 if [ -L "$3" ]; then
 	echo "FILE IS A LINK ACTIVATING SYMLINK LINK MODE">>"$mythicalLibrarian"/output.log
 	SYMLINK=LINK
 fi
 
 #Get file size and free space
 MoveFileSize=`stat -c %s "$3"`
 MoveFileSize=$((MoveFileSize/1024))
 MoveDirFreeSpace=`df -P "$MoveDir"|sed -n 2p|awk '{print $4}'`  
 AlternateMoveDirFreeSpace=`df -P "$AlternateMoveDir"|sed -n 2p|awk '{print $4}'`
 test "$Database" = "Enabled" && "$PrimaryMovieDir" != "" && PrimaryMovieDirFreeSpace=`df -P "$PrimaryMovieDir"|sed -n 2p|awk '{print $4}'` || PrimaryMovieDirFreeSpace=0
 test "$Database" = "Enabled" && "$AlternateMovieDir" != "" && AlternateMovieDirFreeSpace=`df -P "$AlternateMovieDir"|sed -n 2p|awk '{print $4}'`|| AlternateMovieDirFreeSpace=0
 OriginaldirFreeSpace=`df -P "$originaldirname"|sed -n 2p|awk '{print $4}'` 
 WorkingDirFreeSpace=`df -P "$mythicalLibrarian"|sed -n 2p|awk '{print $4}'` 
 
 #Call permissions check from function.  Write small file, delete, get results
 checkpermissions "$MoveFileSize" "$MoveDirFreeSpace" "$MoveDir" 
 MoveDirWritable=$TMoveDirWritable
 checkpermissions "$MoveFileSize" "$AlternateMoveDirFreeSpace" "$AlternateMoveDir" 
 AlternateMoveDirWritable=$TMoveDirWritable
 test "$Database" = "Enabled" && "$PrimaryMovieDir" != "" && checkpermissions "$MoveFileSize" "$PrimaryMovieDirFreeSpace" "$PrimaryMovieDir"
 test "$Database" = "Enabled" && "$PrimaryMovieDir" != "" && PrimaryMovieDirWritable=$TMoveDirWritable
 test "$Database" = "Enabled" && "$AlternateMovieDir" != "" && checkpermissions "$MoveFileSize" "$AlternateMovieDirFreeSpace" "$AlternateMovieDir"
 test "$Database" = "Enabled" && "$AlternateMovieDir" != "" && AlternateMovieDirWritable=$TMoveDirWritable
 checkpermissions "1" "$OriginaldirFreeSpace" "$originaldirname"
 OriginalDirWritable=$TMoveDirWritable
 checkpermissions "5000" "$WorkingDirFreeSpace" "$mythicalLibrarian"
 WorkingDirWritable=$TMoveDirWritable
  
 #report to terminal
 echo "FILE SIZE:$MoveFileSize""kB"
 echo "MOVEDIR FREE SPACE: $MoveDirFreeSpace"kB"- WRITABLE:$MoveDirWritable"
 echo "ALTMOVEDIR FREE SPACE: $AlternateMoveDirFreeSpace"kB"- WRITABLE:$AlternateMoveDirWritable"
 echo "MOVIEDIR FREE SPACE: $PrimaryMovieDirFreeSpace"kB"- WRITABLE:$PrimaryMovieDirWritable"
 echo "ALTMOVIEDIR FREE SPACE: $AlternateMovieDirFreeSpace"kB"- WRITABLE:$AlternateMovieDirWritable"
 
 #####DEBUG MODE OUTPUT BLOCK#####
 if [ $DEBUGMODE = "Enabled" ]; then
 	echo "###################DEBUG MODE ENABLED####################">>"$mythicalLibrarian"/output.log
 	echo "MY USER NAME:$MyUserName-">>"$mythicalLibrarian"/output.log
 	echo "LISTING INTERNAL VARIABLES USED BY mythicalLibrarian.">>"$mythicalLibrarian"/output.log
 	echo "INTERNET TIMEOUT:$Timeout- TVDB API KEY:$APIkey- mythicalLibrarian WORKING DIR:$mythicalLibrarian-">>"$mythicalLibrarian"/output.log
 	echo "MOVE DIR:$MoveDir- USING SHOWNAME AS FOLDER:$UseShowNameAsDir-">>"$mythicalLibrarian"/output.log
 	echo "FAILSAFE MODE:$FailSafeMode- FAILSAFE DIR:$FailSafeDir- ALTERNATE MOVE DIR:$AlternateMoveDir-">>"$mythicalLibrarian"/output.log
 	echo "USE ORIGINAL DIR:$UseOriginalDir NOTIFICATIONS:$Notify DEBUG MODE:$DEBUGMODE-">>"$mythicalLibrarian"/output.log
 	echo "INPUT SHOW NAME:$1- LOCAL SHOW NAME TRANSLATION:$showtranslation- ShowName:$ShowName">>"$mythicalLibrarian"/output.log
 	echo "RESOLVED SERIES ID:$seriesid- RESOVED SHOW NAME:$NewShowName-">>"$mythicalLibrarian"/output.log
 	echo "INPUT EPISODE NAME:$2- ABSOLOUTE EPISODE NUMBER:$absolouteEpisodeNumber- RESOLVED EPISODE NAME:$epn-">>"$mythicalLibrarian"/output.log
 	echo "SEASON:$sxx- EPISODE:$exx- SYMLINK MODE:$SYMLINK- FILESIZE: $MoveFileSize'kB'">>"$mythicalLibrarian"/output.log 
 	echo "CREATE AND DELETE FLAGS: ORIGINALDIR:$OriginalDirWritable- FREE:$OriginaldirFreeSpace""kB""- WORKINGDIR:$WorkingDirWritable Free:$WorkingDirFreeSpace""kB""-">>"$mythicalLibrarian"/output.log
 	echo "MOVEDIR:$MoveDirWritable- FREE:$MoveDirFreeSpace""kB""- ALTERNATEMOVEDIR:$AlternateMoveDirWritable- FREE:$AlternateMoveDirFreeSpace""kB""-">>"$mythicalLibrarian"/output.log
 	echo "PRIMARYMOVIEDIRWRITABLE:$PrimaryMovieDirWritable- FREE:$PrimaryMovieDirFreeSpace""kB""- ALTERNATEMOVIEDIR:$AlternateMoveDirWritable- FREE:$AlternateMovieDirFreeSpace""kB""-">>"$mythicalLibrarian"/output.log
 	if [ "$Database" = "Enabled"	]; then
 		echo "DATABASE TYPE:$XMLTVGrabber-">>"$mythicalLibrarian"/output.log
		echo " RECSTART:$ShowStartTime- MOVIE YEAR:$MovieAirDate- ORIGINAL SERIES DATE:$OriginalAirDate-">>"$mythicalLibrarian"/output.log
 		echo " PROGRAMID:$ProgramID- CHANNEL ID:$ChanID- CATEGORY:$ShowCategory-">>"$mythicalLibrarian"/output.log
 		echo " EXTRAPOLATED DATA DETERMINED THIS RECORDING AS A:$ProgramIDType- STARS:$stars RATING:$rating">> "$mythicalLibrarian"/output.log
 		echo " ZAP2IT SERIES ID:$Zap2itSeriesID- MATCHED TVDB SERIES ID:$MatchedSeriesID-" >>"$mythicalLibrarian"/output.log
              echo PLOT: "$plot"
 	fi
 	echo "####################END OF DEBUG LOG#####################">>"$mythicalLibrarian"/output.log
  fi
 
 
 #####FILE HANDLING AND ID TYPE DECISSION#####
 #If file to be moved does not exist, then report
 if [ ! -f "$3" ]; then
 	echo "INPUT FILE NAME NON EXISTANT -CHECK FILE NAME AND READ PERMISSIONS"
 	echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%">>"$mythicalLibrarian"/output.log
 	echo "%%%%%INPUT FILE NAME NON EXISTANT CHECK FILE NAME AND PERMISSIONS%%%%%%%%">>"$mythicalLibrarian"/output.log
 	echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%">>"$mythicalLibrarian"/output.log
	echo "%%%%%%%%%%%%%%OPERATION FAILED" `date` "%%%%%%%%%%%%%%%%%">>"$mythicalLibrarian"/output.log
 	echo $mythicalLibrarian'/mythicalLibrarian.sh "'$1'" "'$2'" "'$3'"'>>$mythicalLibrarian/doover.sh
 	if [ $Notify = Enabled ]; then
 	sudo -u "$NotifyUserName" /usr/local/bin/librarian-notify-send "mythicalLibrarian Error" "Invalid File supplied" error
 	fi
 	FailedJob
 	echo $runjob
  	exit 1 
 fi
 
 FailSafeState=0
 test "$MoveDirWritable" != "1" && MoveDir="$AlternateMoveDir"
 test "$MoveDirWritable" != "1" -a "$AlternateMoveDirWritable" != "1" && FailSafeState=1
 
 #Movie handling: Determine where file will fit
 test "$mythicalLibrarianProgramIDCheck" = "MV" -a "$PrimaryMovieDirWritable" != "1" && PrimaryMovieDir="$AlternateMoveDir"
 test "$mythicalLibrarianProgramIDCheck" = "MV" -a "$PrimaryMovieDirWritable" != "1" -a "$AlternateMovieDirWritable" != "1" && FailSafeState=1
 

 #####OUTPUT FILE NAME FORMATTING#####
 #format names for file system
 epn=`echo $epn| tr -d [:punct:]`
 NewShowName=`echo $NewShowName|tr -d [:punct:]`
 #output Series format  showname=show name sxx=season number exx=episode number epn=episode name
 if [ ! -z "$exx" ]; then
 	 ShowFileName=`echo "$NewShowName.$sxx$exx ($epn)"`

 #output Movie Format
 elif [ "$mythicalLibrarianProgramIDCheck" = "MV" ]; then
  	ShowFileName=`echo "$NewShowName ($MovieAirDate)"` 
 	MoveDir="$PrimaryMovieDir"
 	exx="Movie"
 fi
 
 #####FAILSAFE HANDLING#####
 #If failsafe state is set then create link in FailSafeMode
 if [ $FailSafeState = "1" ]; then
  	echo "FAILSAFE FLAG WAS SET CHECK PERMISSIONS AND FOLDERS">>"$mythicalLibrarian"/output.log
 	echo "FAILSAFE FLAG WAS SET"
 	if [ $FailSafeMode = "Enabled" ]; then
 		echo "PERMISSION ERROR OR DRIVE FULL">>"$mythicalLibrarian"/output.log	
 		echo "ATTEMPTING SYMLINK TO FAILSAFE DIR: $FailSafeDir">>"$mythicalLibrarian"/output.log
 		echo "ATTEPMTING SYMLINK TO FAILSAFE DIR"
 		ln -s "$3" "$FailSafeDir/$ShowFileName.$originalext"
 		test -f "$FailSafeDir/$ShowFileName.$originalext";echo "FAILSAFE MODE COMPLETE: SYMLINK CREATED">>"$mythicalLibrarian"/output.log
 		test ! -f "$FailSafeDir/$ShowFileName.$originalext"; echo "FAILSAFE MODE FAILURE CHECK PERMISSIONS AND FREE SPACE IN $FailSafeDir">>"$mythicalLibrarian"/output.log
 	fi
 
 	test $Notify = Enabled && sudo -u "$NotifyUserName" /usr/local/bin/librarian-notify-send "mythicalLibrarian FAILSAFE" "FAILSAFE mode active See "$mythicalLibrarian"/output.log for more information" error
 	echo $mythicalLibrarian'/mythicalLibrarian.sh "'$1'" "'$2'" "'$3'"'>>$mythicalLibrarian/doover.sh
  	FailedJob
	echo $runjob
 	exit 1 
 fi
 
 ######PRE-NAMING CHECKS#####
 if [ "$exx" = "" ]; then
 	test "$Notify" = "Enabled" && sudo -u "$NotifyUserName" /usr/local/bin/librarian-notify-send "mythicalLibrarian Error" "Could not obtain information from server about: $1. TheTvDb is incomplete" web-browser
 	echo "%%%%%%%%%%www.TheTvDB.com information is incomplete $1, $2">>"$mythicalLibrarian"/output.log
 	echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%">>"$mythicalLibrarian"/output.log
  	echo "%%%%%%%%%%%%Please consider helping out and adding to thetvdb%%%%%%%%%%%%">>"$mythicalLibrarian"/output.log
 	echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%">>"$mythicalLibrarian"/output.log
 	echo "%%%%%%%%%%%%%%OPERATION FAILED" `date` "%%%%%%%%%%%%%%%%%">>"$mythicalLibrarian"/output.log
 	echo $mythicalLibrarian'/mythicalLibrarian.sh "'$1'" "'$2'" "'$3'"'>>$mythicalLibrarian/doover.sh
 	echo "ERROR: INFORMATION COULD NOT BE OBTAINED"
 	FailedJob
	echo $runjob		
 	exit 0
 fi
  
 #check to see if output folder exists
 test -d "$MoveDir" && echo "SET TARGET DIR AS: $MoveDir"
 
 #If specified, make $movedir = $movedir/show name
 test "$UseShowNameAsDir" = "Enabled" && MoveDir=`echo "$MoveDir"/"$NewShowName"`
 
 
 #####MAKE FOLDER#####
 #Make the folder if it does not exist
 if [ ! -d "$MoveDir" ]; then
 	echo "CREATING FOLDER: $MoveDir">>"$mythicalLibrarian"/output.log
	echo "$MoveDir">>"$mythicalLibrarian"/dir.tracking
 	mkdir "$MoveDir"
 #Error message if folder was not created
 	if [ ! -d "$MoveDir" ];then
 		echo "COULD NOT CREATE $MoveDir/$NewShowName">>"$mythicalLibrarian"/output.log
 		echo "##########################################################">>"$mythicalLibrarian"/output.log
 		echo "#############FAILSAFE MODE HAS BEEN ACTIVATED#############">>"$mythicalLibrarian"/output.log
 		echo "##########################################################">>"$mythicalLibrarian"/output.log
 		if [ $Notify = "Enabled" ]; then
 			sudo -u "$NotifyUserName" /usr/local/bin/librarian-notify-send "mythicalLibrarian error" "failsafe mode activated."  error
 		fi
 		SYMLINK=LINK
 		MoveDir=$FailSafeDir
 	fi
 fi
 	
 
 #####ANTI-CLOBBER#####	
 #If file exists then make a new name for it
 if [ -f "$MoveDir/$ShowFileName.$originalext" ]; then
 
 	mythicalLibrarianCounter=0
 	NameCheck=0
 	while [ $NameCheck = '0' ]; do
 		let mythicalLibrarianCounter=$mythicalLibrarianCounter+1
 	 
 #If file does not exist, then it is a valid target
 		if [ ! -f "$MoveDir/$ShowFileName-$mythicalLibrarianCounter.$originalext" ]; then 
 			NameCheck="1"
 			ShowFileName=`echo "$ShowFileName"-"$mythicalLibrarianCounter"`
 			echo "FILE NAME EXISTS.  FILE WILL BE KNOWN AS: $ShowFileName"
 		fi
 	done
  
 fi
 
 #####MOVE MODE HANDLING#####
 #If symlink is not in LINK mode, Move and rename the file.
 if [ "$SYMLINK" != "LINK" ]; then
 
 #Send notifications, Move the file and rename
 	echo "MOVING FILE: $3 to $MoveDir/$ShowFileName.$originalext">>"$mythicalLibrarian"/output.log
 	test "$Notify" = "Enabled" && sudo -u "$NotifyUserName" /usr/local/bin/librarian-notify-send "mythicalLibrarian Moving" "Moving and renaming $ShowFileName" drive-harddisk
 	mv "$3" "$MoveDir/$ShowFileName.$originalext"
 
 #Check and report if file was moved
 	if [ -f "$MoveDir/$ShowFileName.$originalext" ]; then
 		if [ -s "$MoveDir/$ShowFileName.$originalext" ];then
 
 #Send notification to XBMC, Update Library, Clean Library
  			XBMCAutomate 		
 
 #Create Commercial skip data with file
 			if [ "$CommercialMarkup" = "Created" ]; then
 				mv "$mythicalLibrarian/markupframes.txt" "$MoveDir/$ShowFileName.txt"
 				echo "'$MoveDir/$ShowFileName.txt'" "'$MoveDir/$ShowFileName.$originalext'">>"$mythicalLibrarian"/created.tracking
 			fi
 
 #Make symlink back to original file
 			if [ "$SYMLINK" = "MOVE" ]; then
 				echo CREATING SYMLINK IN MOVE MODE
 				ln -s  "$MoveDir/$ShowFileName.$originalext" "$3"
  			fi
  			 test "$SYMLINK" = "Disabled" && SYMLINKDisabled 
 #Send notification of completion and exit
 			test $Notify = "Enabled" && sudo -u "$NotifyUserName" /usr/local/bin/librarian-notify-send "mythicalLibrarian Sucess" "$ShowFileName moved to $MoveDir" info
 	
 #Send notification to daily report log
 			dailyreport "$ShowFileName"
 		 	echo "@@@@@@@@@@@@@OPERATION COMPLETE" `date` "@@@@@@@@@@@@@@@@">>"$mythicalLibrarian"/output.log
 			SucessfulJob
 			echo $runjob	
   			exit 0
 #if file was not moved, then fail  
 		elif [ ! -s "$MoveDir/$ShowFileName.$originalext" ]; then
 			rm -f "$MoveDir/$ShowFileName.$originalext"
 			test $Notify = "Enabled" && sudo -u "$NotifyUserName" /usr/local/bin/librarian-notify-send "mythicalLibrarian Failure" "$ShowFileName could not be moved to $MoveDir" stop
 			echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%">>"$mythicalLibrarian"/output.log
 			echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%WROTE 0 LENGTH FILE%%%%%%%%%%%%%%%%%%%%%%%%%">>"$mythicalLibrarian"/output.log
 			echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%">>"$mythicalLibrarian"/output.log
 			echo "%%%%%%%%%%%%%%OPERATION FAILED" `date` "%%%%%%%%%%%%%%%%%">>"$mythicalLibrarian"/output.log
 			FailedJob
			echo $runjob
 			exit 0
 		fi
 	elif [ ! -f "$MoveDir/$ShowFileName.$originalext" ]; then
  		echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%">>"$mythicalLibrarian"/output.log
 		echo "%%%%%%%%%%%%%%%%%%%%PERMISSION ERROR WHILE MOVING%%%%%%%%%%%%%%%%%%%%%%%%">>"$mythicalLibrarian"/output.log
 		echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%">>"$mythicalLibrarian"/output.log
 		echo "%%%%%%%%%%%%%%OPERATION FAILED" `date` "%%%%%%%%%%%%%%%%%">>"$mythicalLibrarian"/output.log
 		test $Notify = "Enabled" && sudo -u "$NotifyUserName" /usr/local/bin/librarian-notify-send "mythicalLibrarian Failure" "$ShowFileName could not be moved to $MoveDir" stop
 	fi
 
 
 #####LINK MODE HANDLING#####
 #If symlink is in LINK mode then create symlink
 elif [ "$SYMLINK" = "LINK" ]; then
 	echo "CREATING LINK IN LINK MODE"
 
 	ln -s "$3" "$MoveDir/$ShowFileName.$originalext"     
 
 #if file was created
 	if [ -L "$MoveDir/$ShowFileName.$originalext" ]; then	
 		echo "Symlink created $MoveDir/$ShowFileName.$originalext">>"$mythicalLibrarian"/output.log
 		echo "@@@@@@@@@@@@@OPERATION COMPLETE" `date` "@@@@@@@@@@@@@@@@">>"$mythicalLibrarian"/output.log	
 		if [ "$Notify" = "Enabled" ]; then
 			sudo -u "$NotifyUserName" /usr/local/bin/librarian-notify-send "mythicalLibrarian Sucess" "$ShowFileName linked to $MoveDir" info
 		fi
 
  #Send notification to XBMC, Update Library, Clean Library
 		XBMCAutomate 		
 
 #Move comskip data
  	 	if [ "$CommercialMarkup" = "Created" ]; then
 			mv "$mythicalLibrarian"/markupframes.txt "$MoveDir/$ShowFileName.txt"
 			echo "$MoveDir/$ShowFileName.txt">>"$mythicalLibrarian"/created.tracking
 		fi
 		echo "#"$mythicalLibrarian'/mythicalLibrarian.sh "'$1'" "'$2'" "'$3'"'>>$mythicalLibrarian/doover.sh
 		dailyreport "$ShowFileName"
 		SucessfulJob
		echo $runjob
 		exit 0
 
 #If link failure, send notification and fail
 	elif [ ! -L "$MoveDir/$ShowFileName.$originalext" ]; then
 		echo "PERMISSION ERROR OR FILE SYSTEM DOES NOT SUPPORT SYMLINKS:$MoveDir"
 		echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%">>"$mythicalLibrarian"/output.log
 		echo "%%%%%%%%%%%%%%LINK PERMISSION ERROR OR FILE DOES NOT EXIST%%%%%%%%%%%%%%%">>"$mythicalLibrarian"/output.log
 		echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%">>"$mythicalLibrarian"/output.log
 		echo "%%%%%%%%%%%%%%OPERATION FAILED" `date` "%%%%%%%%%%%%%%%%%">>"$mythicalLibrarian"/output.log
 		test $Notify = "Enabled" &&	sudo -u "$NotifyUserName" /usr/local/bin/librarian-notify-send "mythicalLibrarian error" "Failure while creating link. Check permissions" error
 		echo $mythicalLibrarian'/mythicalLibrarian.sh "'$1'" "'$2'" "'$3'"'>>$mythicalLibrarian/doover.sh
 	fi
 	FailedJob
	echo $runjob
 	exit 1
 fi 
 
 #####GENERIC UNSPECIFIED ERROR#####
 #if no match is found then send error messages
 if [ "$exx" = "" ]; then 
 	echo "NO MATCH FOUND.  TROUBLESHOOTING: Check www.TheTvDb TO SEE IF $1 EXISTS. ">>"$mythicalLibrarian"/output.log
 	echo "CHECK EPISODE NAME $2. CHECK INTERNET CONNECTION. CHECK API KEY.">>"$mythicalLibrarian"/output.log
 	echo "NOT ENOUGH INFORMATION PULLED FROM DATABASE TO IDENTIFY FILE AS MOVIE OR EPISODE">>"$mythicalLibrarian"/output.log
 	echo "CHECK www.TheTvDb.com  RUN mythicalLibrarian LINK COMMAND PROMPT.">>"$mythicalLibrarian"/output.log
 	echo "FOR MORE INFORMATION SEE http://xbmc.org/wiki/index.php?title=mythicalLibrarian">>"$mythicalLibrarian"/output.log
 	echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%">>"$mythicalLibrarian"/output.log
 	echo "%%%%%%%%%%%%%%OPERATION FAILED" `date` "%%%%%%%%%%%%%%%%%">>"$mythicalLibrarian/output.log">>"$mythicalLibrarian"/output.log
 fi
 
 
 #send notification if enabled
 test $Notify = "Enabled" && sudo -u "$NotifyUserName" /usr/local/bin/librarian-notify-send "mythicalLibrarian error" "mythicalLibrarian operation failed See "$mythicalLibrarian"/output.log for more information" error
 echo $mythicalLibrarian'/mythicalLibrarian.sh "'$1'" "'$2'" "'$3'"'>>$mythicalLibrarian/doover.sh
 FailedJob
 echo $runjob
 exit 1
