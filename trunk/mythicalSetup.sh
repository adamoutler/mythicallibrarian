#! /bin/bash

#This script will generate the user settings portion of mythicalLibrarian
echo "" > ./mythicalSetup 
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

if which replace >/dev/null; then
 	echo "Verified  mysql-server-5.0 exists"
else
 	echo "install package ' mysql-server-5.0' on your system"
 	b="mysql-server-5.0 "
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
	echo "Please install 'libnotify-bin' on your system"
 	e="libnotify-bin "
fi


if which notify-send>/dev/null && which agrep>/dev/null && which curl>/dev/null && which dialog>/dev/null; then
	echo "All checks complete!!!"
else
	echo "the proper dependencies must be installed..." 
 	echo "Debian based users run 'apt-get install $a$b$c$d$e"
	exit 1
fi


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
 DownloadML=$(dialog --menu "Which version would you like to use?" 10 65 15 "Continue"  "using: $lastupdated" "Stable" "Download and switch to stable version" "Latest" "Download and switch to SVN revision" 2>&1 >/dev/tty)	
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
 	cat "./mythicalLibrarian.sh" | replace "\t" "\\\t " \\ \\\\ >"./mythicalLibrarian.sh"
  	startwrite=0
	test -f ./librarian && rm -f ./librarian
 	while read line
 	do
		test "$line" = "########################## USER JOBS############################" && let startwrite=$startwrite+1
 		if [ $startwrite = 2 ]; then
 			echo -e "$line" >> ./librarian
  	echo $startwrite
 		fi
  	done <./mythicalLibrarian.sh
 	test -f ./mythicalSetup.sh && rm -f ./mythicalSetup.sh
 	curl "http://mythicallibrarian.googlecode.com/files/mythicalSetup.sh">"./mythicalSetup.sh"
 	chmod +x "./mythicalSetup.sh"
 	./mythicalSetup.sh
	exit 0

fi
if [ "$DownloadML" = "Latest" ]; then
  	svnrev=`curl -s  mythicallibrarian.googlecode.com/svn/trunk/| grep -m1 Revision | replace "<html><head><title>mythicallibrarian - " ""| replace ": /trunk</title></head>" ""`
	echo "$svnrev "`date`>"./lastupdated"
 	test -f ./mythicalLibrarian.sh && rm -f mythicalLibrarian.sh
 	curl "http://mythicallibrarian.googlecode.com/svn/trunk/mythicalLibrarian">"./mythicalLibrarian.sh"
 	cat "./mythicalLibrarian.sh" | replace "\t" "\\\t " \\ \\\\ >"./mythicalLibrarian.sh"
  	startwrite=0
	test -f ./librarian && rm -f ./librarian
 	while read line
 	do
		test "$line" = "########################## USER JOBS############################" && let startwrite=$startwrite+1
 		if [ $startwrite = 2 ]; then
 			echo -e "$line" >> ./librarian
  	echo $startwrite
 		fi
  	done <./mythicalLibrarian.sh
 	test -f ./mythicalSetup.sh && rm -f ./mythicalSetup.sh
 	curl "http://mythicallibrarian.googlecode.com/svn/trunk/mythicalSetup.sh">"./mythicalSetup.sh"
 	chmod +x "./mythicalSetup.sh"
 	./mythicalSetup.sh
	exit 0

fi

test -f ./mythicalSetup && rm -f ./mythicalSetup
echo "#! /bin/bash">./mythicalSetup
echo " #######################USER SETTINGS##########################">>./mythicalSetup
echo " ###Stand-alone mode values###">>./mythicalSetup
dialog --title "MythTv" --yesno "Will you be using mythicalLibrarian with MythTV?" 8 25
  	  test $? = 0 && mythtv=1 || mythtv=0

dialog --title "File Handling" --yes-label "Use Original" --no-label "Choose Folder" --yesno "would you like to use your/recording/directory/Episodes and your/recording/directory/Movies?
Or would you like to choose your own directory to separate Episodes from Movies?" 10 50
	test $? = 0 && UserChoosesFolder=1 || UserChoosesFolder=0

test -f ./movedir && movedir1=`cat ./movedir`
test "$movedir1" = "" && movedir1="/home/mythtv/Episodes"
echo " #MoveDir is the folder which mythicalLibrarian will move the file.  No trailing / is accepted eg. "~/videos"">> ./mythicalSetup

if [ "$UserChoosesFolder" = "0" ]; then 
 dialog --inputbox "Enter the name of the folder you would like to move episodes. Default:$movedir1" 10 50 "$movedir1" 2>./movedir
 movedir=`cat ./movedir`
fi
 test "$movedir" = "" && movedir=$movedir1
 echo $movedir > ./movedir
 echo "MoveDir=$movedir">>./mythicalSetup
 movedir="/home/mythtv/Episodes"


dialog --infobox "If your primary folder fails, your files will be moved to /home/mythtv/Episodes by default" 10 30 
echo " #AlternateMoveDir will act as a seccondary MoveDir if the primary MoveDir fails.  No trailing / is accepted eg. "~/videos"">> ./mythicalSetup
AlternateMoveDir=/home/mythtv/Episodes
echo "AlternateMoveDir=$AlternateMoveDir">> ./mythicalSetup

echo " #If UseOriginalDir is Enabled, original dir will override MoveDir.  Useful for multiple recording dirs.">> ./mythicalSetup
echo " #UseOriginalDir will separate episodes from movies and shows. Enabled|Disabled">> ./mythicalSetup

test "$UserChoosesFolder" = "0" && echo "UseOriginalDir=Disabled">>./mythicalSetup || echo "UseOriginalDir=Enabled">>./mythicalSetup
echo " #When Enabled, mythicalLibrarian will move the file to a folder of the same name as the show. This is not affected by UseOriginalDir. Enabled|Disabled">> ./mythicalSetup

echo "UseShowNameAsDir=Enabled">>./mythicalSetup
echo " #Internet access Timeout in seconds: Default Timeout=50 (seconds)">> ./mythicalSetup

echo "Timeout=50">>./mythicalSetup
echo " #Update database time in secconds, Longer duration means faster processing time and less strain on TheTvDb. Default='70000' (almost a day)">> ./mythicalSetup

echo "UpdateDatabase=70000">>./mythicalSetup
echo " #mythicalLibrarian working file dir: Default=~/.mythicalLibrarian (home/username/mythicalLibraian)">> ./mythicalSetup

echo "mythicalLibrarian=~/.mythicalLibrarian">>./mythicalSetup
echo " #FailSafe mode will enable symlinks to be formed in FailSafeDir if the move or symlink operation fails. Enabled|Disabled">> ./mythicalSetup

echo "FailSafeMode=Enabled">>./mythicalSetup
echo " #FailSafeDir is used when the file cannot be moved to the MoveDir. FailSafe will not create folders. eg. /home/username">> ./mythicalSetup
echo "FailSafeDir='/home/mythtv/FailSafe'">>./mythicalSetup
echo " #DirTracking will check for and remove the folders created by mythicalLibrarian">> ./mythicalSetup

echo "DirTracking=Enabled">>./mythicalSetup

echo " #the following line contains the API key from www.TheTvDb.Com. Default project code: 6DF511BB2A64E0E9">> ./mythicalSetup
echo "APIkey=6DF511BB2A64E0E9">>./mythicalSetup
echo " #Language setting">>./mythicalSetup
echo "Language=en">>./mythicalSetup

if [ "$mythtv" = "1" ]; then

	echo " #SYMLINK has 3 modes.  MOVE|LINK|Disabled: Default=MOVE">> ./mythicalSetup
	echo " #Create symlink in original dir from file after 'MOVE' | Do not move, just create a sym'LINK' | move the file, symlinking is 'Disabled'"
	dialog --title "SYMLINK" --yesno "Keep files under control of MythTv? Note: 'No' will delete all database entries after moving files" 8 40
		test $? = 0 && echo "SYMLINK=MOVE" >> ./mythicalSetup || echo "SYMLINK=Disabled" >> ./mythicalSetup
echo "">>./mythicalSetup
echo " ###Database Settings###">>./mythicalSetup
	echo " #Guide data type">> ./mythicalSetup
 	dialog --title "Database Type" --yesno "Do you have one of the following guide data types?  SchedulesDirect, TiVo, Tribune, Zap2it" 10 25
	test $? = 0 && database=1 || database=0

	if [ "$database" = "1" ] || [ "$database" = "0" ]; then
 
		echo " #Database access Enabled|Disabled">> ./mythicalSetup
		echo "Database=Enabled">>./mythicalSetup	

 		echo " #Database Type Default=MythTV">> ./mythicalSetup
		echo "DatabaseType=MythTV">>./mythicalSetup

 		echo " #Guide data type">> ./mythicalSetup
		echo "GuideDataType=SchedulesDirect">>./mythicalSetup

 		echo " #MySQL User name: Default="mythtv"">> ./mythicalSetup
 		test -f "/home/mythtv/.mythtv/mysql.txt" && MySQLuser1=`grep "DBUserName" "/home/mythtv/.mythtv/mysql.txt" | replace "DBUserName=" ""`||mythtvusername="mythtv"
 		echo "$MySQLuser1" >./MySQLuser
	    	dialog --inputbox "Enter your MYSQL Username. Default=$MySQLuser1" 9 40 "$MySQLuser1" 2>./MySQLuser
		MySQLuser=`cat ./MySQLuser`
 		test "$MySQLuser" = "" && MySQLuser="$MySQLuser1"
 		echo "$MySQLuser">./MySQLuser
		echo "MySQLuser=$MySQLuser">>./mythicalSetup


 		echo " #MySQL Password: Default="mythtv"">> ./mythicalSetup	
 		
 		test -f "/home/mythtv/.mythtv/mysql.txt" && MySQLpass1=`grep "DBPassword=" "/home/mythtv/.mythtv/mysql.txt" | replace "DBPassword=" ""`||mythtvusername="mythtv"
 		test ! -f "./MySQLpass" && echo "$MySQLpass1">./MySQLpass
	    	dialog --inputbox "Enter your MYSQL password. Default=$MySQLpass1" 9 40 "$MySQLpass1" 2>./MySQLpass
 		MySQLpass=`cat ./MySQLpass`
 		test "$MySQLpass" = "" && MySQLpass="$MySQLpass1"
 		echo "$MySQLpass">./MySQLpass
		echo "MySQLpass=$MySQLpass">>./mythicalSetup

 		echo "#MySQL Myth Database: Default="mythconverg"">> ./mythicalSetup
 		echo "MySQLMythDb=mythconverg">>./mythicalSetup

 		echo " #Primary Movie Dir. mythicalLibrarian will attempt to move to this dir first. No trailing / is accepted eg. '~/videos'">> ./mythicalSetup 		

 		test "$PrimaryMovieDir1" = "" && PrimaryMovieDir1="/home/mythtv/Movies"


 		if [ "$UserChoosesFolder" = "0" ]; then 
		 dialog --inputbox "Enter the name of the folder you would like to move Movies Default=$PrimaryMovieDir1" 12 50 "$PrimaryMovieDir1" 2>./PrimaryMovieDir
 		 PrimaryMovieDir=`cat ./PrimaryMovieDir`
		fi
 		test "$PrimaryMovieDir" = "" && PrimaryMovieDir=$PrimaryMovieDir1
 		echo "$PrimaryMovieDir">./PrimaryMovieDir
 		echo "PrimaryMovieDir='$PrimaryMovieDir'">>./mythicalSetup
 		AlternateMovieDir="/home/mythtv/Movies"
 		echo " #AlternateMoveDir will act as a Seccondary move dir if the primary moive dir fails">> ./mythicalSetup
 		echo "AlternateMovieDir='$AlternateMovieDir'" >> ./mythicalSetup

 		echo " #ShowStopper = Enabled prevents generic shows and unrecognized episodes from being processed">> ./mythicalSetup
 		dialog --title "Unrecognizable programming" --yesno "Process unrecognized Episodes and Shows?" 8 40
  		test "$?" = "0" && echo " ShowStopper=Disabled">> ./mythicalSetup || echo " ShowStopper=Enabled">> ./mythicalSetup
 		
 		echo " #CommercialMarkup will generate comskip files for recordings when they are moved. Enabled|Disabled">> ./mythicalSetup
 		echo "CommercialMarkup=Enabled" >> ./mythicalSetup

 		echo " #CommercialMarkupCleanup will execute a maintenance routine which will remove comskip files if they are not needed">> ./mythicalSetup
 		echo "CommercialMarkupCleanup=Enabled" >> ./mythicalSetup

	fi

elif [ $mythtv = 0 ]; then

 	
    	dialog --title "SYMLINK" --yesno "Do you want a symlink to the original file after move?" 6 25
 	test $? = 0 && echo "SYMLINK=MOVE" >> ./mythicalSetup || echo "SYMLINK=Disabled" >> ./mythicalSetup

 	echo " #SYMLINK has 3 modes.  MOVE|LINK|Disabled: Default=MOVE">> ./mythicalSetup
 	echo " #Create symlink in original dir from file after 'MOVE' | Do not move, just create a sym'LINK' | move the file, symlinking is 'Disabled'">> ./mythicalSetup
	echo "Database=Disabled" >> ./mythicalSetup

	echo " #Database Type Default=MythTV">> ./mythicalSetup
	echo "DatabaseType=none" >> ./mythicalSetup

	echo " #Guide data type">> ./mythicalSetup
 	echo "GuideDataType=none" >> ./mythicalSetup

 	test -f "/home/mythtv/.mythtv/mysql.txt" && mythtvusername=`grep "DBUserName" "/etc/mythtv/.mythtv/mysql.txt" | replace "DBUserName=" ""`||mythtvusername="mythtv"
	echo " #MySQL User name: Default="$mythtvusername"">> ./mythicalSetup
 	echo "MySQLuser=''" >> ./mythicalSetup

 	test -f "/home/mythtv/.mythtv/mysql.txt" && mythtvpassword=`grep "DBPassword=" "/etc/mythtv/.mythtv/mysql.txt" | replace "DBPassword=" ""`||mythtvusername="mythtv"
	echo " #MySQL Password: Default="$mythtvpassword"">> ./mythicalSetup
 	echo "MySQLpass=''" >> ./mythicalSetup

	echo " #MySQL Myth Database: Default="mythconverg"">> ./mythicalSetup
 	echo "MySQLMythDb=''" >> ./mythicalSetup

	echo " #Primary Movie Dir. mythicalLibrarian will attempt to move to this dir first. No trailing / is accepted eg. "~/videos"">> ./mythicalSetup
 	echo "PrimaryMovieDir=''" >> ./mythicalSetup

	echo " #AlternateMoveDir will act as a Seccondary move dir if the primary moive dir fails">> ./mythicalSetup
 	echo "AlternateMovieDir=''" >> ./mythicalSetup
 
 	echo " #ShowStopper = Enabled prevents generic shows and unrecognized episodes from being processed">> ./mythicalSetup
 	echo " ShowStopper=Disabled">> ./mythicalSetup

 	echo " #CommercialMarkup will generate comskip files for recordings when they are moved. Enabled|Disabled">> ./mythicalSetup
 	echo "CommercialMarkup=Disabled" >> ./mythicalSetup

	echo " #CommercialMarkupCleanup will execute a maintenance routine which will remove comskip files if they are not needed">> ./mythicalSetup
 	echo "CommercialMarkupCleanup=Disabled" >> ./mythicalSetup

fi


echo " ###Reporting/Communications###">>./mythicalSetup

	echo " #If notifications are enabled, NotifyUserName should be the same as the user logged into the GNOME Session. (your username)">> ./mythicalSetup
	test ! -f ./DesktopUserName && echo "$SUDO_USER">>./DesktopUserName
 	test -f ./DesktopUserName && DesktopUserName1=`cat ./DesktopUserName`
	dialog --inputbox "Enter your Desktop Username Default=$DesktopUserName1" 10 40 "$DesktopUserName1" 2>./DesktopUserName
 	DesktopUserName=`cat ./DesktopUserName`
 	test "$DesktopUserName" = "" && DesktopUserName=$DesktopUserName1
 	echo "$DesktopUserName">./DesktopUserName
  	echo "NotifyUserName=$DesktopUserName" >>./mythicalSetup

 	echo " #Notify tells mythicalLibrarian to send a notification to GNOME Desktop upon completion. Enabled|Disabled">> ./mythicalSetup
	dialog --title "Desktop Notifications" --yesno "Would you like mythicalLibrarian to send desktop notifications?
if Yes, the user must have no password sudo access." 10 45
	test $? = 0 && notifications=1 || notifications=0
 	if [ "$notifications" = "1" ]; then
 	echo "Notify=Enabled" >> ./mythicalSetup


else

 	echo " #Notify tells mythicalLibrarian to send a notification to GNOME Desktop upon completion. Enabled|Disabled">> ./mythicalSetup
 	echo "Notify=Disabled" >> ./mythicalSetup

	echo " #If notifications are enabled, NotifyUserName should be the same as the user logged into the GNOME Session. (your username)">> ./mythicalSetup
 	echo "NotifyUserName='$DesktopUserName'" >> ./mythicalSetup
fi


dialog --title "XBMC Notifications" --yesno "Would you like mythicalLibrarian to interface XBMC?" 9 30
	test $? = 0 && notifications=1 || notifications=0


if [ "$notifications" = "1" ]; then

 		
	echo " #Ip Address and port for XBMC Notifications Eg.XBMCIPs=( '192.168.1.110:8080' '192.168.1.111:8080' 'XBOX:8080' )">> ./mythicalSetup
		  xbmcips1=`cat ./xbmcips` 
 		  test "$xbmcips1" = "" && xbmcips1="'192.168.1.100:8080'"
   	dialog --inputbox "Enter your XBMC IP Addresses and port in single quotes. eg. '192.168.1.110:8080' 'XBOX:8080' Default=$xbmcips1" 10 50 "$xbmcips1" 2>./xbmcips
                xbmcips=`cat ./xbmcips`
  		  echo "$xbmcips">./xbmcips
 		  echo "XBMCIPs=( $xbmcips )">>./mythicalSetup
		  
	dialog --title "XBMC Notifications" --yesno "Would you like mythicalLibrarian to update your library?" 9 30
		  if [ $? = 0 ]; then
 			echo " #Send a notification to XBMC to Update library upon successful move job Enabled|Disabled">> ./mythicalSetup
 			 echo "XBMCUpdate=Enabled">>./mythicalSetup
 			 echo " #Send Notifications to XBMC UI when library is updated Enabled|Disabled">> ./mythicalSetup
 			 echo "XBMCNotify=Enabled">>./mythicalSetup

		  else

		 	 echo " #Send a notification to XBMC to Update library upon successful move job Enabled|Disabled">> ./mythicalSetup
 			 echo "XBMCUpdate=Disabled">>./mythicalSetup
 			 echo " #Send Nrotifications to XBMC UI when library is updated Enabled|Disabled">> ./mythicalSetup
 			 echo "XBMCNotify=Disabled"
 		  fi

	echo " #Send a notification to XBMC to cleanup the library upon successful move job Enabled|Disabled">> ./mythicalSetup
	echo "XBMCClean=Disabled">>./mythicalSetup
else

	echo " #Ip Address and port for XBMC Notifications Eg.XBMCIPs=( "192.168.1.110:8080" "192.168.1.111:8080" "XBOX:8080" )">> ./mythicalSetup
	echo "XBMCIPs=''">>./mythicalSetup

	echo " #Send a notification to XBMC to Update library upon successful move job Enabled|Disabled">> ./mythicalSetup
	echo "XBMCUpdate=Disabled">>./mythicalSetup

	echo " #Send Notifications to XBMC UI when library is updated Enabled|Disabled">> ./mythicalSetup
	echo "XBMCNotify=Disabled">>./mythicalSetup

 	echo " #Send a notification to XBMC to cleanup the library upon successful move job Enabled|Disabled">> ./mythicalSetup
	echo "XBMCClean=Disabled">>./mythicalSetup

fi 

echo " #DailyReport provides a local log of shows added to your library per day. Enabled|Disabled">> ./mythicalSetup
echo "DailyReport=Enabled">> ./mythicalSetup
echo "#Enables debug mode.  This is a verbose mode of logging which should be used for troubleshooting.  Enabled|Disabled" >> ./mythicalSetup 
echo "DEBUGMODE=Enabled" >> ./mythicalSetup
echo "#maxItems controls the number of items in the RSS. RSS Can be activated by creating a folder in /var/www/mythical-rss." >> ./mythicalSetup 
echo "maxItems=8">> ./mythicalSetup
echo "#########################USER SETTINGS########################## ">> ./mythicalSetup
echo '########################## USER JOBS############################'>> ./mythicalSetup
echo ' #The RunJob function is a place where you can put your custom script to be run at the end of execution'>> ./mythicalSetup
echo ' #Though it may be at the top, this is actually the end of the program.  '>> ./mythicalSetup

echo ' RunJob () {'>> ./mythicalSetup
echo ' 	case $jobtype in'>> ./mythicalSetup
echo ' #Successful Completion of mythicalLibrarian'>> ./mythicalSetup
echo ' 		LinkModeSuccessful|MoveModeSuccessful)'>> ./mythicalSetup
echo ' 			echo "SUCCESSFUL COMPLETEION TYPE: $jobtype"'>> ./mythicalSetup
echo ' 			#Insert Custom User Job here '>> ./mythicalSetup
echo ' 			'>> ./mythicalSetup
echo ' 			#'>> ./mythicalSetup
echo ' 			exit 0'>> ./mythicalSetup
echo ' 			;;'>> ./mythicalSetup
echo ' #File system error occoured'>> ./mythicalSetup
echo ' 		PermissionError0Length|NoFileNameSupplied|PermissionErrorWhileMoving|FailSafeModeComplete|LinkModeFailed)'>> ./mythicalSetup
echo ' 			echo "FILE SYSTEM ERROR:$jobtype"'>> ./mythicalSetup
echo ' 			#Insert Custom User Job here '>> ./mythicalSetup
echo ' 			'>> ./mythicalSetup
echo ' 			#'>> ./mythicalSetup
echo '   			exit 1'>> ./mythicalSetup
echo ' 			;;'>> ./mythicalSetup
echo ' '>> ./mythicalSetup
echo ' #Information error occoured'>> ./mythicalSetup
echo ' 		TvDbIsIncomplete|GenericShow)'>> ./mythicalSetup
echo ' 			echo "INSUFFICIENT INFORMATION WAS SUPPLIED:$jobtype"'>> ./mythicalSetup
echo '  			#Insert Custom User Job here '>> ./mythicalSetup
echo ' 			'>> ./mythicalSetup
echo ' 			#'>> ./mythicalSetup
echo '  			exit 0'>> ./mythicalSetup
echo ' 			;;'>> ./mythicalSetup
echo ' #Generic error occoured'>> ./mythicalSetup
echo '  		GenericUnspecifiedError)'>> ./mythicalSetup
echo '  			echo "UNKNOWN ERROR OCCOURED:$jobtype"'>> ./mythicalSetup
echo '  			#Insert Custom User Job here  '>> ./mythicalSetup
echo ' 			'>> ./mythicalSetup
echo ' 			#'>> ./mythicalSetup
echo '  			exit 3 '>> ./mythicalSetup
echo ' 			;;'>> ./mythicalSetup
echo ' esac'>> ./mythicalSetup
echo ' #Custom exit point may be set anywhere in program by typing RunJob on any new line'>> ./mythicalSetup
echo ' #Insert Custom User Job here '>> ./mythicalSetup
echo ' '>> ./mythicalSetup
echo ' #'>> ./mythicalSetup
echo ' exit 4'>> ./mythicalSetup
echo ''>> ./mythicalSetup
echo ' }'>> ./mythicalSetup
echo ''>> ./mythicalSetup

test -f ./mythicalLibrarian && rm ./mythicalLibrarian
cat ./mythicalSetup >./mythicalLibrarian
cat ./librarian >>./mythicalLibrarian


test "$mythtv" = "1" && test ! -d "/home/mythtv" && mkdir "/home/mythtv"
test ! -d "$AlternateMoveDir" && mkdir "$AlternateMoveDir" 
test ! -d "$AlternateMovieDir" && mkdir "$AlternateMovieDir"
test ! -d ~/.mythicalLibrarian && mkdir ~/.mythicalLibrarian
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




test "$mythtv" = "1" && chmod -R 775 "$AlternateMoveDir" "$AlternateMovieDir" "/home/mythtv/Failsafe" "/var/www/mythical-rss">/dev/null 2>&1 
test "$mythtv" = "1" && chown -hR "mythtv":"mythtv"  "$AlternateMoveDir" "$AlternateMovieDir" "/home/mythtv/Failsafe" "/var/www/mythical-rss">/dev/null 2>&1 
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
  job=`mysql -u$MySQLuser -p$MySQLpass -e "use mythconverg; select data from settings where value like 'UserJob$counter';" | replace "data" "" |sed -n "2p" ` 
  test "$?" = "1" && nomythtvdb=1
  test "$job" = '/usr/local/bin/mythicalLibrarian "%DIR%/%FILE%"' && JobFoundInSlot=$counter
  test "$JobFoundInSlot" = "0" && test "$SlotToUse" = "0" && test "$job" = "" && SlotToUse=$counter
 done 
 if [ "$nomythtvdb" != "1" ] && [ "$JobFoundInSlot" != "0" ]; then
  echo "mythicalLibrarian MythTV UserJob not added because UserJob already exists in slot $JobFoundInSlot"	
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
