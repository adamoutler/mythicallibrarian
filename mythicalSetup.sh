#! /bin/bash

#This script will configure mythicalLibrarian
echo "" > ./mythicalSetup 
if [ "$(id -u)" != "0" ]; then
	echo "You do not have sufficient privlidges to run this script. Try again with sudo configure"
	exit 1
fi

if which dialog >/dev/null; then
	echo "Verified dialog exists"
else
	echo "install package 'dialog' on your system"
 	a="dialog " 
fi

if which wget >/dev/null; then
	echo "Verified wget exists"
else
	echo "install package 'wget' on your system"
 	b="wget "
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

echo "Press any key to continue into setup..."; read X

if ! which librarian-notify-send>/dev/null; then
 	dialog --title "librarian-notify-send" --yesno "install librarian-notify-send script for Desktop notifications?" 8 25
  	test $? = 0 && DownloadLNS=1 || DownloadLNS=0
 	if [ "$DownloadLNS" = "1" ]; then
 		wget "http://mythicallibrarian.googlecode.com/files/librarian-notify-send" -O "/usr/local/bin/librarian-notify-send"
 		sudo chmod +x /usr/local/bin/librarian-notify-send
 	fi
fi

dialog --title "Update Core?" --yesno "Have you updated recently?" 8 25
 	test $? = 0 && DownloadML=1 || DownloadML=0
if [ "$DownloadML" = "0" ]; then
 	test -f ./mythicalLibrarian.sh && rm -f mythicalLibrarian.sh
 	wget "http://mythicallibrarian.googlecode.com/svn/trunk/mythicalLibrarian" -O "./mythicalLibrarian.sh"
 	cat "./mythicalLibrarian.sh" | replace \\ \\\\ >"./mythicalLibrarian.sh"
  	startwrite=0
 	while read line
 	do
		test "$line" = "########################## USER JOBS############################" && let startwrite=$startwrite+1
 		if [ $startwrite = 2 ]; then
 			echo -E ${line} >> ./librarian
  	echo $startwrite
 		fi
  	done <./mythicalLibrarian.sh
 	test -f ./mythicalSetup.sh && rm -f ./mythicalSetup.sh
 	wget "http://mythicallibrarian.googlecode.com/svn/trunk/mythicalSetup.sh" -O "./mythicalSetup.sh"
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



test -f ./movedir && movedir1=`cat ./movedir`
test "$movedir1" = "" && movedir1="/home/mythtv/Episodes"
echo " #MoveDir is the folder which mythicalLibrarian will move the file.  No trailing / is accepted eg. "~/videos"">> ./mythicalSetup
dialog --inputbox "Enter the name of the folder you would like to move episodes. Default:$movedir1" 10 50 2>./movedir
movedir=`cat ./movedir`
test "$movedir" = "" && movedir=$movedir1
echo $movedir > ./movedir
echo "MoveDir=$movedir">>./mythicalSetup

dialog --infobox "If your primary folder fails, your files will be moved to /home/mythtv/Episodes by default" 10 30 
echo " #AlternateMoveDir will act as a seccondary MoveDir if the primary MoveDir fails.  No trailing / is accepted eg. "~/videos"">> ./mythicalSetup
AlternateMoveDir=/home/mythtv/Episodes
echo "AlternateMoveDir=$AlternateMoveDir">> ./mythicalSetup

echo " #If UseOriginalDir is Enabled, original dir will override MoveDir.  Useful for multiple recording dirs.">> ./mythicalSetup
echo " #UseOriginalDir will not separate episodes from movies. Enabled|Disabled">> ./mythicalSetup

echo "UseOriginalDir=Disabled">>./mythicalSetup
echo " #When Enabled, mythicalLibrarian will move the file to a folder of the same name as the show. This is not affected by UseOriginalDir. Enabled|Disabled">> ./mythicalSetup

echo "UseShowNameAsDir=Enabled">>./mythicalSetup
echo " #Internet access Timeout in seconds: Default Timeout=50 (seconds)">> ./mythicalSetup

echo "Timeout=50">>./mythicalSetup
echo " #Update database time in secconds, Longer duration means faster processing time and less strain on TheTvDb. Default='84000' (1 day)">> ./mythicalSetup

echo "UpdateDatabase=86000">>./mythicalSetup
echo " #mythicalLibrarian working file dir: Default=~/mythicalLibrarian (home/username/mythicalLibraian)">> ./mythicalSetup

echo "mythicalLibrarian=~/mythicalLibrarian">>./mythicalSetup
echo " #FailSafe mode will enable symlinks to be formed in FailSafeDir if the move or symlink operation fails. Enabled|Disabled">> ./mythicalSetup

echo "FailSafeMode=Enabled">>./mythicalSetup
echo " #FailSafeDir is used when the file cannot be moved to the MoveDir. FailSafe will not create folders. eg. /home/username">> ./mythicalSetup
echo "FailSafeDir='/home/mythtv/FailSafe'">>./mythicalSetup
echo " #DirTracking will check for and remove the folders created by mythicalLibrarian">> ./mythicalSetup

echo "DirTracking=Enabled">>./mythicalSetup

echo " #the following line contains the API key from www.TheTvDb.Com. Default project code: 6DF511BB2A64E0E9">> ./mythicalSetup
echo "APIkey=6DF511BB2A64E0E9">>./mythicalSetup


echo " ###Database Settings###">>./mythicalSetup
if [ "$mythtv" = "1" ]; then

	echo " #SYMLINK has 3 modes.  MOVE|LINK|Disabled: Default=MOVE">> ./mythicalSetup
	echo " #Create symlink in original dir from file after 'MOVE' | Do not move, just create a sym'LINK' | move the file, symlinking is 'Disabled'"
	dialog --title "SYMLINK" --yesno "Keep files under control of MythTv? Note: 'No' will delete all database entries after moving files" 8 40
		test $? = 0 && echo "SYMLINK=MOVE" >> ./mythicalSetup || echo "SYMLINK=Disabled" >> ./mythicalSetup

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
 		test -f ./MySQLuser && MySQLuser1=`cat ./MySQLuser`
 		test "$MySQLuser1" = "" && MySQLuser1=mythtv
	    	dialog --inputbox "Enter your MYSQL Username. Default=$MySQLuser1" 9 40 2>./MySQLuser
		MySQLuser=`cat ./MySQLuser`
 		test "$MySQLuser" = "" && MySQLuser="$MySQLuser1"
 		echo "$MySQLuser">./MySQLuser
		echo "MySQLuser=$MySQLuser">>./mythicalSetup

 		echo " #MySQL Password: Default="mythtv" 	">> ./mythicalSetup	
 		test -f ./MySQLpass && MySQLpass1=`cat ./MySQLpass`
 		test "$MySQLpass1" = "" && MySQLpass1=mythtv
	    	dialog --inputbox "Enter your MYSQL password. Default=$MySQLpass1" 9 40 2>./MySQLpass
 		MySQLpass=`cat ./MySQLpass`
 		test "$MySQLpass" = "" && MySQLpass="$MySQLpass1"
 		echo "$MySQLpass">./MySQLpass
		echo "MySQLpass=$MySQLpass">>./mythicalSetup

 		echo "#MySQL Myth Database: Default="mythconverg"">> ./mythicalSetup
 		echo "MySQLMythDb=mythconverg">>./mythicalSetup

 		echo " #Primary Movie Dir. mythicalLibrarian will attempt to move to this dir first. No trailing / is accepted eg. "~/videos"">> ./mythicalSetup 		
 		test -f ./PrimaryMovieDir && PrimaryMovieDir1=`cat ./PrimaryMovieDir`
 		test "$PrimaryMovieDir1" = "" && PrimaryMovieDir1="/home/mythtv/Movies"
		dialog --inputbox "Enter the name of the folder you would like to move Movies Default=$PrimaryMovieDir1" 12 50 2>./PrimaryMovieDir
 		PrimaryMovieDir=`cat ./PrimaryMovieDir`
 		test "$PrimaryMovieDir" = "" && PrimaryMovieDir=$PrimaryMovieDir1
 		echo "$PrimaryMovieDir">./PrimaryMovieDir
 		echo "PrimaryMovieDir='$PrimaryMovieDir'">>./mythicalSetup
 		AlternateMovieDir="/home/mythtv/Movies"
 		echo " #AlternateMoveDir will act as a Seccondary move dir if the primary moive dir fails">> ./mythicalSetup
 		echo "AlternateMovieDir='$AlternateMovieDir'" >> ./mythicalSetup

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

	echo " #MySQL User name: Default="mythtv"">> ./mythicalSetup
 	echo "MySQLuser=''" >> ./mythicalSetup

	echo " #MySQL Password: Default="mythtv"">> ./mythicalSetup
 	echo "MySQLpass=''" >> ./mythicalSetup

	echo " #MySQL Myth Database: Default="mythconverg"">> ./mythicalSetup
 	echo "MySQLMythDb=''" >> ./mythicalSetup

	echo " #Primary Movie Dir. mythicalLibrarian will attempt to move to this dir first. No trailing / is accepted eg. "~/videos"">> ./mythicalSetup
 	echo "PrimaryMovieDir=''" >> ./mythicalSetup

	echo " #AlternateMoveDir will act as a Seccondary move dir if the primary moive dir fails">> ./mythicalSetup
 	echo "AlternateMovieDir=''" >> ./mythicalSetup

	echo " #CommercialMarkup will generate comskip files for recordings when they are moved. Enabled|Disabled">> ./mythicalSetup
 	echo "CommercialMarkup=Disabled" >> ./mythicalSetup

	echo " #CommercialMarkupCleanup will execute a maintenance routine which will remove comskip files if they are not needed">> ./mythicalSetup
 	echo "CommercialMarkupCleanup=Disabled" >> ./mythicalSetup

fi


echo " ###Reporting/Communications###">>./mythicalSetup

	echo " #If notifications are enabled, NotifyUserName should be the same as the user logged into the GNOME Session. (your username)">> ./mythicalSetup
	test ! -f ./DesktopUserName && echo "$SUDO_USER">>./DesktopUserName
 	test -f ./DesktopUserName && DesktopUserName1=`cat ./DesktopUserName`
	dialog --inputbox "Enter your Desktop Username Default=$DesktopUserName1" 8 40 2>./DesktopUserName
 	DesktopUserName=`cat ./DesktopUserName`
 	test "$DesktopUserName" = "" && DesktopUserName=$DesktopUserName1
 	echo "$DesktopUserName">./DesktopUserName
  	echo "NotifyUserName=$DesktopUserName" >>./mythicalSetup

 	echo " #Notify tells mythicalLibrarian to send a notification to GNOME Desktop upon completion. Enabled|Disabled">> ./mythicalSetup
	dialog --title "Desktop Notifications" --yesno "Would you like mythicalLibrarian to send desktop notifications? (requires further configuration)" 9 30
	test $? = 0 && notifications=1 || notifications=0
 	if [ "$notifications" = "1" ]; then
 	echo "Notify=Enabled" >> ./mythicalSetup
	dialog --infobox "See this link for setting up Desktop Notifications.  http://www.xbmc.org/wiki/?title=MythicalLibrarian#GNOME_Desktop_Notifications" 10 30 

else

 	echo " #Notify tells mythicalLibrarian to send a notification to GNOME Desktop upon completion. Enabled|Disabled">> ./mythicalSetup
 	echo "Notify=Disabled" >> ./mythicalSetup

	echo " #If notifications are enabled, NotifyUserName should be the same as the user logged into the GNOME Session. (your username)">> ./mythicalSetup
 	echo "NotifyUserName='$DesktopUserName'" >> ./mythicalSetup
fi


dialog --title "XBMC Notifications" --yesno "Would you like mythicalLibrarian to interface XBMC?" 9 30
	test $? = 0 && notifications=1 || notifications=0


if [ "$notifications" = "1" ]; then

 		
	echo " #Ip Address and port for XBMC Notifications Eg.XBMCIPs=( "192.168.1.110:8080" "192.168.1.111:8080" "XBOX:8080" )">> ./mythicalSetup
		  xbmcips1=`cat ./xbmcips` 
 		  test "$xbmcips1" = "" && xbmcips1="'192.168.1.100:8080'"
   	dialog --inputbox "Enter your XBMC IP Addresses and port in single quotes. eg. '192.168.1.110:8080' 'XBOX:8080' Default=$xbmcips1" 10 50 2>./xbmcips
                xbmcips=`cat ./xbmcips`
 		  test "$xbmcips" = "" && xbmcips=$xbmcips1
 		  echo "$xbmcips">./xbmcips
 		  echo "XBMCIPs=( $xbmcips )">>./mythicalSetup
		  
	dialog --title "XBMC Notifications" --yesno "Would you like mythicalLibrarian to update your library?" 9 30
		  if [ $? = 0 ]; then
 			echo " #Send a notification to XBMC to Update library upon sucessful move job Enabled|Disabled">> ./mythicalSetup
 			 echo "XBMCUpdate=Enabled">>./mythicalSetup
 			 echo " #Send Notifications to XBMC UI when library is updated Enabled|Disabled">> ./mythicalSetup
 			 echo "XBMCNotify=Enabled">>./mythicalSetup

		  else

		 	 echo " #Send a notification to XBMC to Update library upon sucessful move job Enabled|Disabled">> ./mythicalSetup
 			 echo "XBMCUpdate=Disabled">>./mythicalSetup
 			 echo " #Send Notifications to XBMC UI when library is updated Enabled|Disabled">> ./mythicalSetup
 			 echo "XBMCNotify=Disabled"
 		  fi

	echo " #Send Notifications to XBMC UI when library is updated Enabled|Disabled">> ./mythicalSetup
	dialog --title "XBMC Popups Notifications" --yesno "Would you like mythicalLibrarian to send XBMC popup notifications?" 9 30
		  test $? = 0 && echo "XBMCNotify=Enabled">>./mythicalSetup || echo "XBMCNotify=Disabled">>./mythicalSetup

	echo " #Send a notification to XBMC to cleanup the library upon sucessful move job Enabled|Disabled">> ./mythicalSetup
	echo "XBMCClean=Disabled">>./mythicalSetup
else

	echo " #Ip Address and port for XBMC Notifications Eg.XBMCIPs=( "192.168.1.110:8080" "192.168.1.111:8080" "XBOX:8080" )">> ./mythicalSetup
	echo "XBMCIPs=0">>./mythicalSetup

	echo " #Send a notification to XBMC to Update library upon sucessful move job Enabled|Disabled">> ./mythicalSetup
	echo "XBMCUpdate=Disabled">>./mythicalSetup

	echo " #Send Notifications to XBMC UI when library is updated Enabled|Disabled">> ./mythicalSetup
	echo "XBMCNotify=Disabled">>./mythicalSetup

 	echo " #Send a notification to XBMC to cleanup the library upon sucessful move job Enabled|Disabled">> ./mythicalSetup
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
echo ' RunJob () {'>> ./mythicalSetup
echo ' 	case $jobtype in'>> ./mythicalSetup
echo ' #Sucessful Completion of mythicalLibrarian'>> ./mythicalSetup
echo ' 		LinkModeSucessful|MoveModeSucessful)'>> ./mythicalSetup
echo ' 			echo "SUCESSFUL COMPLETEION TYPE: $jobtype"'>> ./mythicalSetup
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
echo ' ########################## USER JOBS############################'>> ./mythicalSetup
echo ' '>> ./mythicalSetup
echo ' ################################################################'>> ./mythicalSetup
echo ' ############Adept personel only beyond this point###############'>> ./mythicalSetup
echo ' ################################################################'>> ./mythicalSetup
test -f ./mythicalLibrarian && rm ./mythicalLibrarian
cat ./mythicalSetup >./mythicalLibrarian
cat ./librarian >>./mythicalLibrarian

nuser=`who -m | awk '{print $1;}' | grep -m1 ^`
 echo $nuser
test "$mythtv" = "1" && test ! -d "/home/mythtv" && mkdir "/home/mythtv"
test ! -d "/var/lib/mythicalLibrarian" && mkdir "/var/lib/mythicalLibrarian"
test ! -d "$AlternateMoveDir" && mkdir "$AlternateMoveDir" 
test ! -d "$AlternateMovieDir" && mkdir "$AlternateMovieDir"
test ! -d ~mythicalLibrarian && mkdir ~/mythicalLibrarian
test ! -d /home/mythtv/Episodes && mkdir /home/mythtv/Episodes
test ! -d "/home/mythtv/Failsafe" && mkdir "/home/mythtv/Failsafe"
test -d "/var/www" && test ! -d "/var/www/mythical-rss" && mkdir /var/www/mythical-rss
test "$mythtv" = "1" && chown -R "mythtv:mythtv"  "$AlternateMoveDir" "$AlternateMovieDir" "/home/mythtv/Failsafe" "/var/www/mythical-rss">/dev/null 2>&1 
test "$mythtv" = "1" && chmod -R 775 "$AlternateMoveDir" "$AlternateMovieDir" "/home/mythtv/Failsafe" "/var/www/mythical-rss">/dev/null 2>&1 
test "$mythtv" != "1" && chown -R "$SUDO_USER:$SUDO_USER" "$AlternateMoveDir" "$AlternateMovieDir" "/home/mythtv/Failsafe" "/var/www/mythical-rss">/dev/null 2>&1 
test "$mythtv" = "1" && useradd -G mythtv $SUDO_USER >/dev/null 2>&1 
cp ./mythicalLibrarian /usr/local/bin/mythicalLibrarian
echo "mythicalLibrarian will now conduct fuzzy logic testing"
echo "please note any errors.   All 'DIR' flags should say 'WRITABLE:1'"
read -p "Press any key to continue to online testing...."
echo "Testing mythicalLibrarian">./testfile.ext
chmod 1755 ./mythicalLibrarian
./mythicalLibrarian -m


test -d $movedir && chown -R "$SUDO_USER:$SUDO_USER" ~/mythicalLibrarian

echo $SUDO_USER
