#! /bin/bash
 
#This script will generate the user settings portion of mythicalLibrarian
test -f "./mythicalSetup" && echo "" "../mythicalSetup/mythicalSetup"
if [ "$(id -u)" != "0" ]; then
	echo "You do not have sufficient privlidges to run this script. Try again with sudo configure"
	exit 1
fi
test "$SUDO_USER" = "" && SUDO_USER=`whoami`
echo $SUDO_USER
test "`uname`" != "Darwin" && LinuxDep=1 || LinuxDep=0
test "$LinuxDep" = "0" && read -n1 -p " I see you have a Apple Macintosh! While mythicalLibrarian is still primarily Linux based, it is striving to become a cross-platform utility.  Please report any bugs in the mythicalLibrarian thread on forum.XBMC.org.  Press any key to continue..." arbitraryVariable 


if which dialog >/dev/null; then
	echo "Verified dialog exists"
else
	test "$LinuxDep" = "1" && echo "Please install package 'dialog' on your system" || echo "Please obtain MacPorts and install package dialog"
 	a="dialog " 
fi


if which curl >/dev/null; then
	echo "Verified curl exists"
else
	test "$LinuxDep" = "1" && echo "Please install 'curl' on your system" || echo "Please obtain MacPorts and install package curl"
 	c="curl "
fi
if which agrep >/dev/null; then
	echo "Verified agrep exists"
else
	test "$LinuxDep" = "1" && echo "Please install 'agrep' on your system" || echo "Please obtain MacPorts and install package agrep"
 	d="agrep "
fi
if which notify-send >/dev/null; then
	echo "Verified libnotify-bin exists"
else
	echo "'libnotify-bin' is a non essential missing package on your system"
 	test "$LinuxDep" = "1" && e="libnotify-bin "|| echo "This platform does not support Pop-up notifications.-OK"
fi


if which agrep>/dev/null && which curl>/dev/null && which dialog>/dev/null; then
	echo "All checks complete!!!"
else
	echo "the proper dependencies must be installed..." 
 	echo "The missing dependencies are $a$b$c$d$e"
 	test "$LinuxDep" = "1" && echo "Debian based users run 'apt-get install $a$b$c$d$e" || echo "Please obtain MacPorts and install $a$b$c"
	if [ "$LinuxDep" = "0" ]; then
 		read -n1 -p " Would you like some help on installing MacPorts? Select: (y)/n" MacPortsHelp
 		if [ "$MacPortsHelp" != "n" ]; then
 			clear
 			echo "Please select"
			echo "1. Snow Leopard"
			echo "2. Leopard"
			echo "3. Tiger"
			read -n1 -p "Select (1), 2, or 3" OSXVER
			clear
			echo "Step 1. Please download the MacPorts dmg file in Safari from:"
			test "$OSXVER" = "1" && echo "http://distfiles.macports.org/MacPorts/MacPorts-1.8.2-10.6-SnowLeopard.dmg"
			test "$OSXVER" = "2" && echo "http://distfiles.macports.org/MacPorts/MacPorts-1.8.2-10.5-Leopard.dmg"
			test "$OSXVER" = "3" && echo "http://distfiles.macports.org/MacPorts/MacPorts-1.8.2-10.4-Tiger.dmg"
			echo "Step 2. Double-click on the file to mount it"
			echo "Step 3. Double-click on the MacPorts pkg file"
			echo "Step 4. click continue, agree, install, and finally close when the Install Suceeded"
			read -n1 -p "Press any key when finished..." arbitraryVariable
			clear
			echo "Step 5. Verify X11 is installed on your system.  It can be found in the finder under"
			echo " Applications->Utilities->X11"
			echo "If it is not there, you have two options:"
			echo "Step 6a. from Mac OSX install DVD"
			echo "Step 6a-1. Insert your mac OS X DVD  and select X11. This should not harm any of your documents or programs unless you select reinstallation instead of upgrade."
			echo "Step 6a-2. Navigate to 'Optional Installs' and run 'Optional Installs.pkg'"
			echo "step 6a-3. run through the easy setup and select X11"
			echo "Step 6B. Obtain a copy of xorg-server and build it on your Mac"
			read -n1 -p "Press any key to continue..." arbitraryVariable
			clear
			echo "Step 7. install Xcode"
 			echo "step 7a.from DVD"
 			echo "step 7a-1. insert your mac OS X install DVD"
			echo "Step 7a-2. navigate to 'Optional Installs/Xcode Tools' and run 'XcodeTools.pkg'"
			echo "Step 7a-3. Run through the easy setup."
 			echo "-----OR-----"						
 			echo "Step 7b. from Mac Dev Center"
 			echo "Step 7b-1. Log into the Mac Dev Center here:"
			echo " http://developer.apple.com/technologies/xcode.html"  
			echo "If you are not registered as a developer, it is free with your AppleID and takes 5 minutes"
			test "$OSXVER" = "1" && echo "You will need to Download Xcode 3.2.1 or later to work with your version of OSX "
			test "$OSXVER" = "2" && echo "You will need to Download Xcode 3.1.4 or later to work with your version of OSX "
			test "$OSXVER" = "3" && echo "You will need to Download Xcode 2.5 or later to work with your version of OSX "
			echo "Step 7b-2. Once you have registered, you can open the following link in safari:"
			echo "https://developer.apple.com/mac/scripts/downloader.php?path=/iphone/iphone_sdk_3.2__final/xcode_3.2.2_and_iphone_sdk_3.2_final.dmg"
			echo "Step 7b-3. Double-click to Mount the Xcode dmg file"
 			echo "Step 7b-4. Double-click to run the Xcode pkg file and run through the easy installer"
			read -n1 -p "Press any key to continue..." arbitraryVariable
			echo "step 10. Open the terminal and type the following"
			echo "sudo port install tre"
			echo "step 11. type the following"
			echo "sudo port install dialog"
					
		fi 
	fi
	exit 1
fi
 svnrev=`curl -s -m10  mythicallibrarian.googlecode.com/svn/trunk/| grep -m1 Revision |  sed s/"<html><head><title>mythicallibrarian - "/""/g|  sed s/": \/trunk<\/title><\/head>"/""/g`

if ! which librarian-notify-send>/dev/null && test "$LinuxDep" = "1"; then
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
clear
if [ "$DownloadML" = "Stable" ]; then
 	echo "Stable "`date`>"./lastupdated"
 	test -f ./mythicalLibrarian.sh && rm -f mythicalLibrarian.sh
 	curl "http://mythicallibrarian.googlecode.com/files/mythicalLibrarian">"./mythicalLibrarian.sh"
 	cat "./mythicalLibrarian.sh"| sed s/'	'/'\\t'/g |sed s/'\\'/'\\\\'/g   >"./mythicalLibrarian1" #sed s/"\\"/"\\\\"/g |
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
	echo "Parsing mythicalLibrarian completed!"
 	echo "Removing old and downloading new version of mythicalSetup..."
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
 	cat "./mythicalLibrarian.sh"| sed s/'	'/'\\t'/g |sed s/'\\'/'\\\\'/g   >"./mythicalLibrarian1" #sed s/"\\"/"\\\\"/g |
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
			test "$parsing" = "......." && parsing=""
			echo $parsing
 			echo -e "$line" >> ./librarian
 		fi
  	done <./mythicalLibrarian.sh
n
 	clear
	echo "Parsing mythicalLibrarian completed!"
 	echo "Removing old and downloading new version of mythicalSetup..."
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

dialog --title "File Handling" --yes-label "Use Original" --no-label "Choose Folder" --yesno "Would you like to use your original recordings folder or would you like to choose your own folder to place recordings?" 10 50
	test $? = 0 && UserChoosesFolder=1 || UserChoosesFolder=0

test -f ./movedir && movedir1=`cat ./movedir`
test "$movedir1" = "" && movedir1="~/Episodes"
echo " #MoveDir is the folder which mythicalLibrarian will move the file.  No trailing / is accepted eg. "~/videos"">> ./mythicalSetup

if [ "$UserChoosesFolder" = "0" ]; then 
 dialog --inputbox "Enter the name of the folder you would like to move episodes. Default:$movedir1" 10 50 "$movedir1" 2>./movedir
 movedir=`cat ./movedir`
fi
 test "$movedir" = "" && movedir=$movedir1
 echo $movedir > ./movedir
 echo "MoveDir=$movedir">>./mythicalSetup
 test !-d "$movedir" && sudo -u $SUDO_USER mkdir "$movedir"



test -f ./AlternateMoveDir && AlternateMoveDir1=`cat ./AlternateMoveDir`
test "$AlternateMoveDir1" = "" && AlternateMoveDir1="~/Episodes"
echo " #MoveDir is the folder which mythicalLibrarian will move the file.  No trailing / is accepted eg. "~/videos"">> ./mythicalSetup
dialog --infobox "If your primary folder fails, your files will be moved to /home/mythtv/Episodes by default" 10 30 
echo " #AlternateMoveDir will act as a seccondary MoveDir if the primary MoveDir fails.  No trailing / is accepted eg. "~/videos"">> ./mythicalSetup
AlternateMoveDir=~/Episodes
if [ "$UserChoosesFolder" = "0" ]; then 
 dialog --inputbox "Enter the name of the alternate folder you would like to move episodes. Default:$AlternateMoveDir1" 10 50 "$AlternateMoveDir1" 2>./movedir
 AlternateMoveDir=`cat ./AlternateMoveDir`
fi
 test "$AlternateMovedir" = "" && movedir=$AlternateMoveDir1
 echo $AlternateMovedir > ./AlternateMoveDir
 echo "AlternateMoveDir=$AlternateMoveDir">> ./mythicalSetup
  test !-d "$AlternateMoveDir" && sudo -u $SUDO_USER mkdir "$AlternateMoveDir"
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
		test "$database" = 1 && echo "GuideDataType=SchedulesDirect">>./mythicalSetup || echo "GuideDataType=NoLookup">>./mythicalSetup

 		echo " #MySQL User name: Default="mythtv"">> ./mythicalSetup
 		test -f "/home/mythtv/.mythtv/mysql.txt" && MySQLuser1=`grep "DBUserName" "/home/mythtv/.mythtv/mysql.txt" |  sed s/"DBUserName="/""/g`||mythtvusername="mythtv"
 		echo "$MySQLuser1" >./MySQLuser
	    	dialog --inputbox "Enter your MYSQL Username. Default=$MySQLuser1" 9 40 "$MySQLuser1" 2>./MySQLuser
		MySQLuser=`cat ./MySQLuser`
 		test "$MySQLuser" = "" && MySQLuser="$MySQLuser1"
 		echo "$MySQLuser">./MySQLuser
		echo "MySQLuser=$MySQLuser">>./mythicalSetup


 		echo " #MySQL Password: Default="mythtv"">> ./mythicalSetup	
 		
 		test -f "/home/mythtv/.mythtv/mysql.txt" && MySQLpass1=`grep "DBPassword=" "/home/mythtv/.mythtv/mysql.txt" |  sed s/"DBPassword="/""/g`||mythtvusername="mythtv"
 		test ! -f "./MySQLpass" && echo "$MySQLpass1">./MySQLpass
	    	dialog --inputbox "Enter your MYSQL password. Default=$MySQLpass1" 9 40 "$MySQLpass1" 2>./MySQLpass
 		MySQLpass=`cat ./MySQLpass`
 		test "$MySQLpass" = "" && MySQLpass="$MySQLpass1"
 		echo "$MySQLpass">./MySQLpass
		echo "MySQLpass=$MySQLpass">>./mythicalSetup

 		echo "#MySQL Myth Database: Default="mythconverg"">> ./mythicalSetup
 		echo "MySQLMythDb=mythconverg">>./mythicalSetup



 		echo " #Primary Movie Dir. mythicalLibrarian will attempt to move to this dir first. No trailing / is accepted eg. '~/videos'">> ./mythicalSetup 		
 		test -f ./PrimaryMovieDir && PrimaryMovieDir1=`cat ./PrimaryMovieDir`
 		test "$PrimaryMovieDir1" = "" && PrimaryMovieDir1="~/Movies"
 		if [ "$UserChoosesFolder" = "0" ]; then 
		 dialog --inputbox "Enter the name of the folder you would like to move Movies Default=$PrimaryMovieDir1" 12 50 "$PrimaryMovieDir1" 2>./PrimaryMovieDir
 		 PrimaryMovieDir=`cat ./PrimaryMovieDir`
		fi
 		test "$PrimaryMovieDir" = "" && PrimaryMovieDir=$PrimaryMovieDir1
 		echo "$PrimaryMovieDir">./PrimaryMovieDir
 		echo "PrimaryMovieDir='$PrimaryMovieDir'">>./mythicalSetup
 	 	test !-d "$PrimaryMovieDir" && sudo -u $SUDO_USER mkdir "$PrimaryMovieDir"


 		echo " #AlternateMoveDir will act as a Seccondary move dir if the primary moive dir fails">> ./mythicalSetup
 		test -f ./AlternateMovieDir && AlternateMovieDir1=`cat ./AlternateMovieDir`
 		test "$AlternateMovieDir1" = "" && AlternateMovieDir1="~/Movies"
 		if [ "$UserChoosesFolder" = "0" ]; then 
		 dialog --inputbox "Enter the name of the folder you would like to move Movies Default=$AlternateMovieDir1" 12 50 "$AlternateMovieDir1" 2>./PrimaryMovieDir
 		 AlternateMovieDir=`cat ./AlternateMovieDir`
		fi
 		test "$AlternateMovieDir" = "" && AlternateMovieDir=$AlternateMovieDir1
 		echo "$AlternateMovieDir">./AlternateMovieDir
 		echo "AlternateMovieDir='$AlternateMovieDir'">>./mythicalSetup
 	 	test !-d "$AlternateMovieDir" && sudo -u $SUDO_USER mkdir "$AlternateMovieDir"


 		echo " #ShowStopper = Enabled prevents generic shows and unrecognized episodes from being processed">> ./mythicalSetup
 		dialog --title "Unrecognizable programming" --yesno "Do you want mythicalLibrarian to process shows when it cannot obtain TVDB information?" 8 40
  		test "$?" = "0" && echo " ShowStopper=Disabled">> ./mythicalSetup || echo " ShowStopper=Enabled">> ./mythicalSetup
 		


		test -f ./PrimaryShowDir && PrimaryShowDir1=`cat ./PrimaryShowDir`
 		test "$PrimaryShowDir1" = "" && PrimaryShowDir1="~/Showings"
 		if [ "$UserChoosesFolder" = "0" ]; then 
		 dialog --inputbox "Enter the name of the folder you would like to move Shows Default=$PrimaryShowDir1" 12 50 "$PrimaryShowDir1" 2>./PrimaryShowDir
 		 PrimaryShowDir=`cat ./PrimaryShowDir`
		fi
 		test "$PrimaryShowDir" = "" && PrimaryShowDir=$PrimaryShowDir1
 		echo "$PrimaryShowDir">./AlternateShowDir
 		echo "PrimaryShowDir='$PrimaryShowDir'">>./mythicalSetup
 	 	test !-d "$PrimaryShowDir" && sudo -u $SUDO_USER mkdir "$PrimaryShowDir"




 		echo " #AlternateShowDir will act as a Seccondary move dir if the primary Show dir fails">> ./mythicalSetup
		test -f ./AlternateShowDir && AlternateShowDir1=`cat ./AlternateShowDir`
 		test "$AlternateShowDir1" = "" && AlternateShowDir1="~/Showings"
 		if [ "$UserChoosesFolder" = "0" ]; then 
		 dialog --inputbox "Enter the name of the folder you would like to move Shows Default=$AlternateShowDir1" 12 50 "$AlternateShowDir1" 2>./PrimaryShowDir
 		 AlternateShowDir=`cat ./AlternateShowDir`
		fi
 		test "$AlternateShowDir" = "" && AlternateShowDir=$AlternateShowDir1
 		echo "$AlternateShowDir">./AlternateShowDir
 		echo "AlternateShowDir='$AlternateShowDir'">>./mythicalSetup
 		AlternateShowDir="/home/mythtv/Showings"
 	 	test !-d "$AlternateShowDir" && sudo -u $SUDO_USER mkdir "$AlternateShowDir"



 		echo "AlternateShowDir='$AlternateShowDir'" >> ./mythicalSetup

 		echo " #CommercialMarkup will generate comskip files for recordings when they are moved. Enabled|Disabled">> ./mythicalSetup
 		echo "CommercialMarkup=Enabled" >> ./mythicalSetup

 		echo " #CommercialMarkupCleanup will execute a maintenance routine which will remove comskip files if they are not needed">> ./mythicalSetup
 		echo "CommercialMarkupCleanup=Enabled" >> ./mythicalSetup

	fi

elif [ $mythtv = 0 ]; then

 	
    	dialog --title "SYMLINK" --yesno "Do you want mythicalLibrarian to symlink to the original file after move?" 8 35
 	test $? = 0 && echo "SYMLINK=MOVE" >> ./mythicalSetup || echo "SYMLINK=Disabled" >> ./mythicalSetup

 	echo " #SYMLINK has 3 modes.  MOVE|LINK|Disabled: Default=MOVE">> ./mythicalSetup
 	echo " #Create symlink in original dir from file after 'MOVE' | Do not move, just create a sym'LINK' | move the file, symlinking is 'Disabled'">> ./mythicalSetup
	echo "Database=Disabled" >> ./mythicalSetup

	echo " #Database Type Default=MythTV">> ./mythicalSetup
	echo "DatabaseType=none" >> ./mythicalSetup

	echo " #Guide data type">> ./mythicalSetup
 	echo "GuideDataType=none" >> ./mythicalSetup

 	test -f "/home/mythtv/.mythtv/mysql.txt" && mythtvusername=`grep "DBUserName" "/etc/mythtv/.mythtv/mysql.txt" |  sed s/"DBUserName="/""/g`||mythtvusername="mythtv"
	echo " #MySQL User name: Default="$mythtvusername"">> ./mythicalSetup
 	echo "MySQLuser=''" >> ./mythicalSetup

 	test -f "/home/mythtv/.mythtv/mysql.txt" && mythtvpassword=`grep "DBPassword=" "/etc/mythtv/.mythtv/mysql.txt" |  sed s/"DBPassword="/""/g`||mythtvusername="mythtv"
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
