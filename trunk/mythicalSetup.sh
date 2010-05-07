#! /bin/bash
 
#This script will generate the user settings portion of mythicalLibrarian
test -f "./mythicalSetup.build" && echo "" "../mythicalSetup.build/mythicalSetup"
if [ "$(id -u)" != "0" ]; then
	echo "You do not have sufficient privlidges to run this script. Try again with sudo configure"
	exit 1
fi
test "$SUDO_USER" = "" && SUDO_USER=`whoami`
echo $SUDO_USER

if which dialog >/dev/null; then
	echo "Verified dialog exists"
else
	echo "install package 'dialog' on your system"
 	a="dialog " 
fi


if which curl >/dev/null; then
	echo "Verified curl exists"
else
	echo "Please install 'curl' on your system"
 	c="curl "
fi
if which agrep >/dev/null; then
	echo "Verified agrep exists"
else
	echo "Please install 'agrep' on your system"
 	d="agrep "
fi
if which notify-send >/dev/null; then
	echo "Verified libnotify-bin exists"
else
	echo "'libnotify-bin' is a non essential missing package on your system"
 	e="libnotify-bin "
fi


if which notify-send>/dev/null && which agrep>/dev/null && which curl>/dev/null && which dialog>/dev/null; then
	echo "All checks complete!!!"
else
	echo "the proper dependencies must be installed..." 
 	echo "Debian based users run 'apt-get install $a$b$c$d$e"
	exit 1
fi
 svnrev=`curl -s -m10  mythicallibrarian.googlecode.com/svn/trunk/| grep -m1 Revision |  sed s/"<html><head><title>mythicallibrarian - "/""/g|  sed s/": \/trunk<\/title><\/head>"/""/g`

if ! which librarian-notify-send>/dev/null; then
 	dialog --title "librarian-notify-send" --yesno "install librarian-notify-send script for Desktop notifications?" 8 25
  	test $? = 0 && DownloadLNS=1 || DownloadLNS=0
 	if [ "$DownloadLNS" = "1" ]; then
 		curl "http://mythicallibrarian.googlecode.com/files/librarian-notify-send">"/usr/local/bin/librarian-notify-send"
 		sudo chmod +x /usr/local/bin/librarian-notify-send
 	fi
fi

if [ ! -f "./librarian" ]; then
 	DownloadML=Stable
 	echo "Stable `date`">./lastupdated
else

 lastupdated="`cat ./lastupdated`"
 DownloadML=$(dialog --title "Version and Build options" --menu "Download an update first then Build mythicalLibrarian" 10 70 15 "Latest" "Download and switch to SVN $svnrev" "Stable" "Download and switch to last stable version"  "Build"  "using: $lastupdated" 2>&1 >/dev/tty)	
if [ "$?" = "1" ]; then
 	clear
 	echo "mythicalLibrarian was not updated"
 	echo "please re-run mythicalSetup"
 	exit 1
fi
fi

if [ "$DownloadML" = "Stable" ]; then
 	echo "Stable "`date`>"./lastupdated"
 	test -f ./mythicalLibrarian.sh && rm -f mythicalLibrarian.sh
 	curl "http://mythicallibrarian.googlecode.com/files/mythicalLibrarian">"./mythicalLibrarian.sh"
 	cat "./mythicalLibrarian.sh" |  sed s/"\\"/"\\\\"/g |  sed s/"\t"/"\\\t "/g >"./mythicalLibrarian1"
 	rm ./mythicalLibrarian.sh
	mv ./mythicalLibrarian1 ./mythicalLibrarian.sh
 	parsing="Stand-by Parsing mythicalLibrarian"
  	startwrite=0
	test -f ./librarian && rm -f ./librarian	
 	echo -e 'mythicalVersion="'"`cat ./lastupdated`"'"'>>./librarian
 	while read line
 	do

		test "$line" = "########################## USER JOBS############################" && let startwrite=$startwrite+1
 		if [ $startwrite = 2 ]; then
 			clear
			parsing="$parsing""."
			echo "$parsing"
 			echo -e "$line" >> ./librarian
 			echo $startwrite
 		fi
  	done <./mythicalLibrarian.sh

 	clear
	echo "Parsing mythicalLibrarian completed"
 	test -f ./mythicalSetup.sh && rm -f ./mythicalSetup.sh
 	curl "http://mythicallibrarian.googlecode.com/files/mythicalSetup.sh">"./mythicalSetup.sh"
 	chmod +x "./mythicalSetup.sh"
 	./mythicalSetup.sh
	exit 0

fi
if [ "$DownloadML" = "Latest" ]; then
  	svnrev=`curl -s  mythicallibrarian.googlecode.com/svn/trunk/| grep -m1 Revision |  sed s/"<html><head><title>mythicallibrarian - "/""/g| sed s/": \/trunk<\/title><\/head>"/""/g`
	echo "$svnrev "`date`>"./lastupdated"
 	test -f ./mythicalLibrarian.sh && rm -f mythicalLibrarian.sh
 	curl "http://mythicallibrarian.googlecode.com/svn/trunk/mythicalLibrarian">"./mythicalLibrarian.sh"
 	cat "./mythicalLibrarian.sh"| sed s/'\\'/'\\\\'/g | sed s/"\t"/"	"/g  >"./mythicalLibrarian1" #sed s/"\\"/"\\\\"/g |
 	rm ./mythicalLibrarian.sh
	mv ./mythicalLibrarian1 ./mythicalLibrarian.sh
 	parsing="Stand-by Parsing mythicalLibrarian"
  	startwrite=0
	test -f ./librarian && rm -f ./librarian
 	echo -e 'mythicalVersion="'"`cat ./lastupdated`"'"'>>./librarian
	while read line
 	do

		test "$line" = "########################## USER JOBS############################" && let startwrite=$startwrite+1

 		if [ $startwrite = 2 ]; then
 			clear
			parsing="$parsing""."
			echo $parsing
 			echo -e "$line" >> ./librarian
 		fi
  	done <./mythicalLibrarian.sh
n
 	clear
	echo "Parsing mythicalLibrarian completed"
 	test -f ./mythicalSetup.sh && rm -f ./mythicalSetup.sh
 	curl "http://mythicallibrarian.googlecode.com/svn/trunk/mythicalSetup.sh">"./mythicalSetup.sh"
 	chmod +x "./mythicalSetup.sh"
 	./mythicalSetup.sh
	exit 0

fi

test -f ./mythicalSetup.build && rm -f ./mythicalSetup.build
echo "#! /bin/bash">./mythicalSetup.build
echo " #######################USER SETTINGS##########################">>./mythicalSetup.build
echo " ###Stand-alone mode values###">>./mythicalSetup.build
dialog --title "MythTv" --yesno "Will you be using mythicalLibrarian with MythTV?" 8 25
  	  test $? = 0 && mythtv=1 || mythtv=0

dialog --title "File Handling" --yes-label "Use Original" --no-label "Choose Folder" --yesno "Would you like to use your original recordings folder or would you like to choose your own folder to place recordings?" 10 50
	test $? = 0 && UserChoosesFolder=1 || UserChoosesFolder=0

test -f ./movedir && movedir1=`cat ./movedir`
test "$movedir1" = "" && movedir1="/home/mythtv/Episodes"
echo " #MoveDir is the folder which mythicalLibrarian will move the file.  No trailing / is accepted eg. "~/videos"">> ./mythicalSetup.build

if [ "$UserChoosesFolder" = "0" ]; then 
 dialog --inputbox "Enter the name of the folder you would like to move episodes. Default:$movedir1" 10 50 "$movedir1" 2>./movedir
 movedir=`cat ./movedir`
fi
 test "$movedir" = "" && movedir=$movedir1
 echo $movedir > ./movedir
 echo "MoveDir=$movedir">>./mythicalSetup.build
 movedir="/home/mythtv/Episodes"


dialog --infobox "If your primary folder fails, your files will be moved to /home/mythtv/Episodes by default" 10 30 
echo " #AlternateMoveDir will act as a seccondary MoveDir if the primary MoveDir fails.  No trailing / is accepted eg. "~/videos"">> ./mythicalSetup.build
AlternateMoveDir=/home/mythtv/Episodes
echo "AlternateMoveDir=$AlternateMoveDir">> ./mythicalSetup.build

echo " #If UseOriginalDir is Enabled, original dir will override MoveDir.  Useful for multiple recording dirs.">> ./mythicalSetup.build
echo " #UseOriginalDir will separate episodes from movies and shows. Enabled|Disabled">> ./mythicalSetup.build

test "$UserChoosesFolder" = "0" && echo "UseOriginalDir=Disabled">>./mythicalSetup.build || echo "UseOriginalDir=Enabled">>./mythicalSetup.build
echo " #When Enabled, mythicalLibrarian will move the file to a folder of the same name as the show. This is not affected by UseOriginalDir. Enabled|Disabled">> ./mythicalSetup.build

echo "UseShowNameAsDir=Enabled">>./mythicalSetup.build
echo " #Internet access Timeout in seconds: Default Timeout=50 (seconds)">> ./mythicalSetup.build

echo "Timeout=50">>./mythicalSetup.build
echo " #Update database time in secconds, Longer duration means faster processing time and less strain on TheTvDb. Default='70000' (almost a day)">> ./mythicalSetup.build

echo "UpdateDatabase=70000">>./mythicalSetup.build
echo " #mythicalLibrarian working file dir: Default=~/.mythicalLibrarian (home/username/mythicalLibraian)">> ./mythicalSetup.build

echo "mythicalLibrarian=~/.mythicalLibrarian">>./mythicalSetup.build
echo " #FailSafe mode will enable symlinks to be formed in FailSafeDir if the move or symlink operation fails. Enabled|Disabled">> ./mythicalSetup.build

echo "FailSafeMode=Enabled">>./mythicalSetup.build
echo " #FailSafeDir is used when the file cannot be moved to the MoveDir. FailSafe will not create folders. eg. /home/username">> ./mythicalSetup.build
echo "FailSafeDir='/home/mythtv/FailSafe'">>./mythicalSetup.build
echo " #DirTracking will check for and remove the folders created by mythicalLibrarian">> ./mythicalSetup.build

echo "DirTracking=Enabled">>./mythicalSetup.build

echo " #the following line contains the API key from www.TheTvDb.Com. Default project code: 6DF511BB2A64E0E9">> ./mythicalSetup.build
echo "APIkey=6DF511BB2A64E0E9">>./mythicalSetup.build
echo " #Language setting">>./mythicalSetup.build
echo "Language=en">>./mythicalSetup.build

if [ "$mythtv" = "1" ]; then

	echo " #SYMLINK has 3 modes.  MOVE|LINK|Disabled: Default=MOVE">> ./mythicalSetup.build
	echo " #Create symlink in original dir from file after 'MOVE' | Do not move, just create a sym'LINK' | move the file, symlinking is 'Disabled'"
	dialog --title "SYMLINK" --yesno "Keep files under control of MythTv? Note: 'No' will delete all database entries after moving files" 8 40
		test $? = 0 && echo "SYMLINK=MOVE" >> ./mythicalSetup.build || echo "SYMLINK=Disabled" >> ./mythicalSetup.build
echo "">>./mythicalSetup.build
echo " ###Database Settings###">>./mythicalSetup.build
	echo " #Guide data type">> ./mythicalSetup.build
 	dialog --title "Database Type" --yesno "Do you have one of the following guide data types?  SchedulesDirect, TiVo, Tribune, Zap2it" 10 25
	test $? = 0 && database=1 || database=0

	if [ "$database" = "1" ] || [ "$database" = "0" ]; then
 
		echo " #Database access Enabled|Disabled">> ./mythicalSetup.build
		echo "Database=Enabled">>./mythicalSetup.build	

 		echo " #Database Type Default=MythTV">> ./mythicalSetup.build
		echo "DatabaseType=MythTV">>./mythicalSetup.build

 		echo " #Guide data type">> ./mythicalSetup.build
		test "$database" = 1 && echo "GuideDataType=SchedulesDirect">>./mythicalSetup.build || echo "GuideDataType=NoLookup">>./mythicalSetup.build

 		echo " #MySQL User name: Default="mythtv"">> ./mythicalSetup.build
 		test -f "/home/mythtv/.mythtv/mysql.txt" && MySQLuser1=`grep "DBUserName" "/home/mythtv/.mythtv/mysql.txt" |  sed s/"DBUserName="/""/g`||mythtvusername="mythtv"
 		echo "$MySQLuser1" >./MySQLuser
	    	dialog --inputbox "Enter your MYSQL Username. Default=$MySQLuser1" 9 40 "$MySQLuser1" 2>./MySQLuser
		MySQLuser=`cat ./MySQLuser`
 		test "$MySQLuser" = "" && MySQLuser="$MySQLuser1"
 		echo "$MySQLuser">./MySQLuser
		echo "MySQLuser=$MySQLuser">>./mythicalSetup.build


 		echo " #MySQL Password: Default="mythtv"">> ./mythicalSetup.build	
 		
 		test -f "/home/mythtv/.mythtv/mysql.txt" && MySQLpass1=`grep "DBPassword=" "/home/mythtv/.mythtv/mysql.txt" |  sed s/"DBPassword="/""/g`||mythtvusername="mythtv"
 		test ! -f "./MySQLpass" && echo "$MySQLpass1">./MySQLpass
	    	dialog --inputbox "Enter your MYSQL password. Default=$MySQLpass1" 9 40 "$MySQLpass1" 2>./MySQLpass
 		MySQLpass=`cat ./MySQLpass`
 		test "$MySQLpass" = "" && MySQLpass="$MySQLpass1"
 		echo "$MySQLpass">./MySQLpass
		echo "MySQLpass=$MySQLpass">>./mythicalSetup.build

 		echo "#MySQL Myth Database: Default="mythconverg"">> ./mythicalSetup.build
 		echo "MySQLMythDb=mythconverg">>./mythicalSetup.build

 		echo " #Primary Movie Dir. mythicalLibrarian will attempt to move to this dir first. No trailing / is accepted eg. '~/videos'">> ./mythicalSetup.build 		
 		test -f ./PrimaryMovieDir && PrimaryMovieDir1=`cat ./PrimaryMovieDir`
 		test "$PrimaryMovieDir1" = "" && PrimaryMovieDir1="/home/mythtv/Movies"


 		if [ "$UserChoosesFolder" = "0" ]; then 
		 dialog --inputbox "Enter the name of the folder you would like to move Movies Default=$PrimaryMovieDir1" 12 50 "$PrimaryMovieDir1" 2>./PrimaryMovieDir
 		 PrimaryMovieDir=`cat ./PrimaryMovieDir`
		fi
 		test "$PrimaryMovieDir" = "" && PrimaryMovieDir=$PrimaryMovieDir1
 		echo "$PrimaryMovieDir">./PrimaryMovieDir
 		echo "PrimaryMovieDir='$PrimaryMovieDir'">>./mythicalSetup.build
 		AlternateMovieDir="/home/mythtv/Movies"
 		echo " #AlternateMoveDir will act as a Seccondary move dir if the primary moive dir fails">> ./mythicalSetup.build
 		echo "AlternateMovieDir='$AlternateMovieDir'" >> ./mythicalSetup.build

 		echo " #ShowStopper = Enabled prevents generic shows and unrecognized episodes from being processed">> ./mythicalSetup.build
 		dialog --title "Unrecognizable programming" --yesno "Do you want mythicalLibrarian to process shows when it cannot obtain TVDB information?" 8 40
  		test "$?" = "0" && echo " ShowStopper=Disabled">> ./mythicalSetup.build || echo " ShowStopper=Enabled">> ./mythicalSetup.build
 		


		test -f ./PrimaryShowDir && PrimaryShowDir1=`cat ./PrimaryShowDir`
 		test "$PrimaryShowDir1" = "" && PrimaryShowDir1="/home/mythtv/Showings" ||


 		if [ "$UserChoosesFolder" = "0" ]; then 
		 dialog --inputbox "Enter the name of the folder you would like to move Shows Default=$PrimaryShowDir1" 12 50 "$PrimaryShowDir1" 2>./PrimaryShowDir
 		 PrimaryShowDir=`cat ./PrimaryShowDir`
		fi
 		test "$PrimaryShowDir" = "" && PrimaryShowDir=$PrimaryShowDir1
 		echo "$PrimaryShowDir">./PrimaryShowDir
 		echo "PrimaryShowDir='$PrimaryShowDir'">>./mythicalSetup.build
 		AlternateShowDir="/home/mythtv/Showings"
 		echo " #AlternateShowDir will act as a Seccondary move dir if the primary Show dir fails">> ./mythicalSetup.build
 		echo "AlternateShowDir='$AlternateShowDir'" >> ./mythicalSetup.build

 		echo " #CommercialMarkup will generate comskip files for recordings when they are moved. Enabled|Disabled">> ./mythicalSetup.build
 		echo "CommercialMarkup=Enabled" >> ./mythicalSetup.build

 		echo " #CommercialMarkupCleanup will execute a maintenance routine which will remove comskip files if they are not needed">> ./mythicalSetup.build
 		echo "CommercialMarkupCleanup=Enabled" >> ./mythicalSetup.build

	fi

elif [ $mythtv = 0 ]; then

 	
    	dialog --title "SYMLINK" --yesno "Do you want mythicalLibrarian to symlink to the original file after move?" 8 35
 	test $? = 0 && echo "SYMLINK=MOVE" >> ./mythicalSetup.build || echo "SYMLINK=Disabled" >> ./mythicalSetup.build

 	echo " #SYMLINK has 3 modes.  MOVE|LINK|Disabled: Default=MOVE">> ./mythicalSetup.build
 	echo " #Create symlink in original dir from file after 'MOVE' | Do not move, just create a sym'LINK' | move the file, symlinking is 'Disabled'">> ./mythicalSetup.build
	echo "Database=Disabled" >> ./mythicalSetup.build

	echo " #Database Type Default=MythTV">> ./mythicalSetup.build
	echo "DatabaseType=none" >> ./mythicalSetup.build

	echo " #Guide data type">> ./mythicalSetup.build
 	echo "GuideDataType=none" >> ./mythicalSetup.build

 	test -f "/home/mythtv/.mythtv/mysql.txt" && mythtvusername=`grep "DBUserName" "/etc/mythtv/.mythtv/mysql.txt" |  sed s/"DBUserName="/""/g`||mythtvusername="mythtv"
	echo " #MySQL User name: Default="$mythtvusername"">> ./mythicalSetup.build
 	echo "MySQLuser=''" >> ./mythicalSetup.build

 	test -f "/home/mythtv/.mythtv/mysql.txt" && mythtvpassword=`grep "DBPassword=" "/etc/mythtv/.mythtv/mysql.txt" |  sed s/"DBPassword="/""/g`||mythtvusername="mythtv"
	echo " #MySQL Password: Default="$mythtvpassword"">> ./mythicalSetup.build
 	echo "MySQLpass=''" >> ./mythicalSetup.build

	echo " #MySQL Myth Database: Default="mythconverg"">> ./mythicalSetup.build
 	echo "MySQLMythDb=''" >> ./mythicalSetup.build

	echo " #Primary Movie Dir. mythicalLibrarian will attempt to move to this dir first. No trailing / is accepted eg. "~/videos"">> ./mythicalSetup.build
 	echo "PrimaryMovieDir=''" >> ./mythicalSetup.build

	echo " #AlternateMoveDir will act as a Seccondary move dir if the primary moive dir fails">> ./mythicalSetup.build
 	echo "AlternateMovieDir=''" >> ./mythicalSetup.build
 
 	echo " #ShowStopper = Enabled prevents generic shows and unrecognized episodes from being processed">> ./mythicalSetup.build
 	echo " ShowStopper=Disabled">> ./mythicalSetup.build

 	echo " #CommercialMarkup will generate comskip files for recordings when they are moved. Enabled|Disabled">> ./mythicalSetup.build
 	echo "CommercialMarkup=Disabled" >> ./mythicalSetup.build

	echo " #CommercialMarkupCleanup will execute a maintenance routine which will remove comskip files if they are not needed">> ./mythicalSetup.build
 	echo "CommercialMarkupCleanup=Disabled" >> ./mythicalSetup.build

fi


echo " ###Reporting/Communications###">>./mythicalSetup.build

	echo " #If notifications are enabled, NotifyUserName should be the same as the user logged into the GNOME Session. (your username)">> ./mythicalSetup.build
	test ! -f ./DesktopUserName && echo "$SUDO_USER">>./DesktopUserName
 	test -f ./DesktopUserName && DesktopUserName1=`cat ./DesktopUserName`
	dialog --inputbox "Enter your Desktop Username Default=$DesktopUserName1" 10 40 "$DesktopUserName1" 2>./DesktopUserName
 	DesktopUserName=`cat ./DesktopUserName`
 	test "$DesktopUserName" = "" && DesktopUserName=$DesktopUserName1
 	echo "$DesktopUserName">./DesktopUserName
  	echo "NotifyUserName=$DesktopUserName" >>./mythicalSetup.build

 	echo " #Notify tells mythicalLibrarian to send a notification to GNOME Desktop upon completion. Enabled|Disabled">> ./mythicalSetup.build
	dialog --title "Desktop Notifications" --yesno "Would you like mythicalLibrarian to send desktop notifications?
if Yes, the user must have no password sudo access." 10 45
	test $? = 0 && notifications=1 || notifications=0
 	if [ "$notifications" = "1" ]; then
 	echo "Notify=Enabled" >> ./mythicalSetup.build


else

 	echo " #Notify tells mythicalLibrarian to send a notification to GNOME Desktop upon completion. Enabled|Disabled">> ./mythicalSetup.build
 	echo "Notify=Disabled" >> ./mythicalSetup.build

	echo " #If notifications are enabled, NotifyUserName should be the same as the user logged into the GNOME Session. (your username)">> ./mythicalSetup.build
 	echo "NotifyUserName='$DesktopUserName'" >> ./mythicalSetup.build
fi


dialog --title "XBMC Notifications" --yesno "Would you like mythicalLibrarian to interface XBMC?" 9 30
	test $? = 0 && notifications=1 || notifications=0


if [ "$notifications" = "1" ]; then

 		
	echo " #Ip Address and port for XBMC Notifications Eg.XBMCIPs=( '192.168.1.110:8080' '192.168.1.111:8080' 'XBOX:8080' )">> ./mythicalSetup.build
		  xbmcips1=`cat ./xbmcips` 
 		  test "$xbmcips1" = "" && xbmcips1="'192.168.1.100:8080'"
   	dialog --inputbox "Enter your XBMC IP Addresses and port in single quotes. eg. '192.168.1.110:8080' 'XBOX:8080' Default=$xbmcips1" 10 50 "$xbmcips1" 2>./xbmcips
                xbmcips=`cat ./xbmcips`
  		  echo "$xbmcips">./xbmcips
 		  echo "XBMCIPs=( $xbmcips )">>./mythicalSetup.build
		  
	dialog --title "XBMC Notifications" --yesno "Would you like mythicalLibrarian to update your library?" 9 30
		  if [ $? = 0 ]; then
 			echo " #Send a notification to XBMC to Update library upon successful move job Enabled|Disabled">> ./mythicalSetup.build
 			 echo "XBMCUpdate=Enabled">>./mythicalSetup.build
 			 echo " #Send Notifications to XBMC UI when library is updated Enabled|Disabled">> ./mythicalSetup.build
 			 echo "XBMCNotify=Enabled">>./mythicalSetup.build

		  else

		 	 echo " #Send a notification to XBMC to Update library upon successful move job Enabled|Disabled">> ./mythicalSetup.build
 			 echo "XBMCUpdate=Disabled">>./mythicalSetup.build
 			 echo " #Send Nrotifications to XBMC UI when library is updated Enabled|Disabled">> ./mythicalSetup.build
 			 echo "XBMCNotify=Disabled"
 		  fi

	echo " #Send a notification to XBMC to cleanup the library upon successful move job Enabled|Disabled">> ./mythicalSetup.build
	echo "XBMCClean=Disabled">>./mythicalSetup.build
else

	echo " #Ip Address and port for XBMC Notifications Eg.XBMCIPs=( "192.168.1.110:8080" "192.168.1.111:8080" "XBOX:8080" )">> ./mythicalSetup.build
	echo "XBMCIPs=''">>./mythicalSetup.build

	echo " #Send a notification to XBMC to Update library upon successful move job Enabled|Disabled">> ./mythicalSetup.build
	echo "XBMCUpdate=Disabled">>./mythicalSetup.build

	echo " #Send Notifications to XBMC UI when library is updated Enabled|Disabled">> ./mythicalSetup.build
	echo "XBMCNotify=Disabled">>./mythicalSetup.build

 	echo " #Send a notification to XBMC to cleanup the library upon successful move job Enabled|Disabled">> ./mythicalSetup.build
	echo "XBMCClean=Disabled">>./mythicalSetup.build

fi 

echo " #DailyReport provides a local log of shows added to your library per day. Enabled|Disabled">> ./mythicalSetup.build
echo "DailyReport=Enabled">> ./mythicalSetup.build
echo "#Enables debug mode.  This is a verbose mode of logging which should be used for troubleshooting.  Enabled|Disabled" >> ./mythicalSetup.build 
echo "DEBUGMODE=Enabled" >> ./mythicalSetup.build
echo "#maxItems controls the number of items in the RSS. RSS Can be activated by creating a folder in /var/www/mythical-rss." >> ./mythicalSetup.build 
echo "maxItems=8">> ./mythicalSetup.build
echo "#########################USER SETTINGS########################## ">> ./mythicalSetup.build
echo '########################## USER JOBS############################'>> ./mythicalSetup.build
echo ' #The RunJob function is a place where you can put your custom script to be run at the end of execution'>> ./mythicalSetup.build
echo ' #Though it may be at the top, this is actually the end of the program.  '>> ./mythicalSetup.build

echo ' RunJob () {'>> ./mythicalSetup.build
echo ' 	case $jobtype in'>> ./mythicalSetup.build
echo ' #Successful Completion of mythicalLibrarian'>> ./mythicalSetup.build
echo ' 		LinkModeSuccessful|MoveModeSuccessful)'>> ./mythicalSetup.build
echo ' 			echo "SUCCESSFUL COMPLETEION TYPE: $jobtype"'>> ./mythicalSetup.build
echo ' 			#Insert Custom User Job here '>> ./mythicalSetup.build
echo ' 			'>> ./mythicalSetup.build
echo ' 			#'>> ./mythicalSetup.build
echo ' 			exit 0'>> ./mythicalSetup.build
echo ' 			;;'>> ./mythicalSetup.build
echo ' #File system error occoured'>> ./mythicalSetup.build
echo ' 		PermissionError0Length|NoFileNameSupplied|PermissionErrorWhileMoving|FailSafeModeComplete|LinkModeFailed)'>> ./mythicalSetup.build
echo ' 			echo "FILE SYSTEM ERROR:$jobtype"'>> ./mythicalSetup.build
echo ' 			#Insert Custom User Job here '>> ./mythicalSetup.build
echo ' 			'>> ./mythicalSetup.build
echo ' 			#'>> ./mythicalSetup.build
echo '   			exit 1'>> ./mythicalSetup.build
echo ' 			;;'>> ./mythicalSetup.build
echo ' '>> ./mythicalSetup.build
echo ' #Information error occoured'>> ./mythicalSetup.build
echo ' 		TvDbIsIncomplete|GenericShow)'>> ./mythicalSetup.build
echo ' 			echo "INSUFFICIENT INFORMATION WAS SUPPLIED:$jobtype"'>> ./mythicalSetup.build
echo '  			#Insert Custom User Job here '>> ./mythicalSetup.build
echo ' 			'>> ./mythicalSetup.build
echo ' 			#'>> ./mythicalSetup.build
echo '  			exit 0'>> ./mythicalSetup.build
echo ' 			;;'>> ./mythicalSetup.build
echo ' #Generic error occoured'>> ./mythicalSetup.build
echo '  		GenericUnspecifiedError)'>> ./mythicalSetup.build
echo '  			echo "UNKNOWN ERROR OCCOURED:$jobtype"'>> ./mythicalSetup.build
echo '  			#Insert Custom User Job here  '>> ./mythicalSetup.build
echo ' 			'>> ./mythicalSetup.build
echo ' 			#'>> ./mythicalSetup.build
echo '  			exit 3 '>> ./mythicalSetup.build
echo ' 			;;'>> ./mythicalSetup.build
echo ' esac'>> ./mythicalSetup.build
echo ' #Custom exit point may be set anywhere in program by typing RunJob on any new line'>> ./mythicalSetup.build
echo ' #Insert Custom User Job here '>> ./mythicalSetup.build
echo ' '>> ./mythicalSetup.build
echo ' #'>> ./mythicalSetup.build
echo ' exit 4'>> ./mythicalSetup.build
echo ''>> ./mythicalSetup.build
echo ' }'>> ./mythicalSetup.build
echo ''>> ./mythicalSetup.build

test -f ./mythicalLibrarian && rm ./mythicalLibrarian
cat ./mythicalSetup.build >./mythicalLibrarian
cat ./librarian >>./mythicalLibrarian

test ! -d "/usr" && mkdir "/usr"
test ! -d "/usr/local" && mkdir "/usr/local"
test ! -d "/usr/local/bin" && mkdir "/usr/local/bin" && PATH=$PATH:/usr/local/bin && export PATH && echo "PATH=$PATH:/usr/local/bin">~/.profile
test "$mythtv" = "1" && test ! -d "/home/mythtv" && mkdir "/home/mythtv"
test ! -d "$AlternateMoveDir" && mkdir "$AlternateMoveDir" 
test ! -d "$AlternateMovieDir" && mkdir "$AlternateMovieDir"
test ! -d ~/.mythicalLibrarian && mkdir ~/.mythicalLibrarian
test ! -d "$AlternateShowDir" && mkdir "$AlternateShowDir"
chown $SUDO_USER:$SUDO_USER ~/.mythicalLibrarian
chown -hR "$SUDO_USER":"$SUDO_USER" ~/.mythicalLibrarian
test ! -d /home/mythtv/Episodes && mkdir /home/mythtv/Episodes
test ! -d "/home/mythtv/Failsafe" && mkdir "/home/mythtv/Failsafe"
test -d "/var/www" && test ! -d "/var/www/mythical-rss" && mkdir /var/www/mythical-rss
test "$mythtv" = "1" && useradd -G mythtv $SUDO_USER >/dev/null 2>&1 
clear
echo "mythicalLibrarian will now conduct mythicalDiagnostics"
read -n1 -p "Press any key to continue to online testing...."
echo ""
echo "Testing mythicalLibrarian">./testfile.ext
chmod 1755 "./mythicalLibrarian"
cp ./mythicalLibrarian /usr/local/bin/mythicalLibrarian




test "$mythtv" = "1" && chmod -R 775 "$AlternateMoveDir" "$AlternateMovieDir" $AlternateShowDir "/home/mythtv/Failsafe" "/var/www/mythical-rss">/dev/null 2>&1 
test "$mythtv" = "1" && chown -hR "mythtv":"mythtv"  "$AlternateMoveDir" "$AlternateMovieDir" $AlternateShowDir "/home/mythtv/Failsafe" "/var/www/mythical-rss">/dev/null 2>&1 
test "$mythtv" != "1" && chown -hR "$SUDO_USER:$SUDO_USER" "$AlternateMoveDir" "$AlternateMovieDir" "/home/mythtv/Failsafe" "/var/www/mythical-rss">/dev/null 2>&1 


sudo -u $SUDO_USER mythicalLibrarian -m
test $? = "0" && passed="0" || passed="1"
test -d ~/.mythicalLibrarian && sudo chown -hR "$SUDO_USER":"$SUDO_USER" ~/.mythicalLibrarian
test -d "~/.mythicalLibrarian/Mister Rogers' Neighborhood/" && chown -hR "$SUDO_USER":"$SUDO_USER" "~/.mythicalLibrarian/Mister Rogers' Neighborhood/"
test "$passed" = "0" && echo "Installation and tests completed successfully"  || echo "Please try again.  If problem persists, please post here: http://forum.xbmc.org/showthread.php?t=65644"


if [ "$mythtv" = "1" ]; then
 JobFoundInSlot=0
 counter=0
 SlotToUse=0
 while [ $counter -lt 4 ]
 do
  let counter=$counter+1
  job=`mysql -u$MySQLuser -p$MySQLpass -e "use mythconverg; select data from settings where value like 'UserJob$counter';" | sed s/"data"/""/g |sed -n "2p" ` 
  test "$?" = "1" && nomythtvdb=1
  test "$job" = '/usr/local/bin/mythicalLibrarian "%DIR%/%FILE%"' && JobFoundInSlot=$counter
  test "$JobFoundInSlot" = "0" && test "$SlotToUse" = "0" && test "$job" = "" && SlotToUse=$counter
 done 
 if [ "$nomythtvdb" != "1" ] && [ "$JobFoundInSlot" != "0" ]; then
  echo "MythTV job not added because mythicalLibrarian already exists in slot $JobFoundInSlot"	
 else
  echo ADDING JOB to slot $SlotToUse
  if [ "$SlotToUse" != "0" ]; then
   mythicalcheck=`mysql -u$MySQLuser -p$MySQLpass -e "use mythconverg; UPDATE settings SET data='/usr/local/bin/mythicalLibrarian \"%DIR%/%FILE%\"' WHERE value='UserJob$SlotToUse'; UPDATE settings SET data='mythicalLibrarian' WHERE value='UserJobDesc$SlotToUse'; UPDATE settings SET data='1' WHERE value='JobAllowUserJob$SlotToUse';"`
  else
   echo "Could not add mythcialLibrarian MythTV UserJob because no slots were available"
  fi
 fi
fi
test "${mythicalcheck:0:5}" = "ERROR" && echo 'Access denied to update user job.  User job must be added manually.  /usr/local/bin/mythicalLibrarian "%DIR%/%FILE%"'
echo "permissions were set for user: $SUDO_USER"
test `which ifconfig` && myip=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
test "$myip" != "" && echo "RSS Feed will be located at http://$myip/mythical-rss/rss.xml"
echo "mythicalLibrarian is located in /usr/local/bin"
echo "'mythicalLibrarian --help' for more information"
echo "Done."

exit 0
