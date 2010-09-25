#! /bin/bash
mythicalLibrarian=~/.mythicalLibrarian/
test ! -d "$mythicalLibrarian" && mkdir $mythicalLibrarian

#This script will generate the user settings portion of mythicalLibrarian
test -f "./mythicalPrep" && rm ./mythicalPrep
if [ "$(id -u)" != "0" ]; then
	echo "You do not have sufficient privlidges to run this script. Try again with sudo configure"
	exit 1
fi
test "$SUDO_USER" = "" && SUDO_USER=`whoami`
echo "This package is being set-up as: $SUDO_USER."
echo "The operating system is `uname` based."
echo "Please note these items if reporting bugs"
test "`uname`" != "Darwin" && LinuxDep=1 || LinuxDep=0

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
			echo "Step 6A. from Mac OSX install DVD"
			echo "Step 6A-1. Insert your mac OS X DVD  and select X11. This should not harm any of your documents or programs unless you select reinstallation instead of upgrade."
			echo "Step 6A-2. Navigate to 'Optional Installs' and run 'Optional Installs.pkg'"
			echo "step 6A-3. Run through the easy setup and select X11"
                        echo "-----OR-----"
			echo "Step 6B. Obtain a copy of xorg-server and build it on your Mac"
			read -n1 -p "Press any key to continue..." arbitraryVariable
			clear
			echo "Step 7. install Xcode"
 			echo "step 7a. From DVD:"
 			echo "step 7a-1. Insert your mac OS X install DVD"
			echo "Step 7a-2. Navigate to 'Optional Installs/Xcode Tools' and run 'XcodeTools.pkg'"
			echo "Step 7a-3. Run through the easy setup."
 			echo "-----OR-----"						
 			echo "Step 7b. From Mac Dev Center:"
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
			clear
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

test -f ./bypassDownload && bypassDownload=1 || bypassDownload=0
test -f ./bypassDownload && rm ./bypassDownload

test -f ./lastupdated && lastupdated="`cat ./lastupdated`" || lastupdated=invalidbuild
test $bypassDownload = 0 && DownloadML=$(dialog --title "Welcome to mythicalSetup!" --menu "Welcome to mythicalLibrarian's mythicalSetup.\n\nPlease select the version, Latest(SVN), Stable to be downloaded, or choose Build to continue with previously downloaded version." 13 70 10 "Latest" "Download and switch to SVN $svnrev" "Stable" "Download and switch to last stable version"  "Build"  "using: $lastupdated" 2>&1 >/dev/tty)

if [ "$?" = "1" ] && [ $bypassDownload = 0 ] ; then
 	clear
 	echo "mythicalLibrarian was not updated."
 	echo "Please re-run mythicalSetup."
        echo "Done."
 	exit 1
fi
fi
clear
if [ "$DownloadML" = "Stable" ]; then
 	touch ./bypassDownload
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
			test "$parsing" = "Stand-by Parsing mythicalLibrarian......." && parsing="Stand-by Parsing mythicalLibrarian"
			echo $parsing
 			echo -e "$line" >> ./librarian
 		fi
  	done <./mythicalLibrarian.sh

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
 	touch ./bypassDownload
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
			test "$parsing" = "Stand-by Parsing mythicalLibrarian......." && parsing="Stand-by Parsing mythicalLibrarian"
			echo $parsing
 			echo -e "$line" >> ./librarian
 		fi
  	done <./mythicalLibrarian.sh

 	clear
	echo "Parsing mythicalLibrarian completed!"
 	echo "Removing old and downloading new version of mythicalSetup..."
 	test -f ./mythicalSetup.sh && rm -f ./mythicalSetup.sh
 	curl "http://mythicallibrarian.googlecode.com/svn/trunk/mythicalSetup.sh">"./mythicalSetup.sh"
 	chmod +x "./mythicalSetup.sh"
 	./mythicalSetup.sh
	exit 0

fi

test -f ./mythicalPrep && rm -f ./mythicalPrep
echo "#! /bin/bash">./mythicalPrep
echo " #######################USER SETTINGS##########################">>./mythicalPrep
echo " ###Stand-alone mode values###">>./mythicalPrep
dialog --title "MythTv" --yesno "Will you be using mythicalLibrarian with MythTV?" 8 25
  	  test $? = 0 && mythtv=1 || mythtv=0


if [ "$mythtv" = "1" ]; then
 dialog --title "File Handling" --yes-label "Use Original" --no-label "Choose Folder" --yesno "Using the original folder will let mythtv choose and create a /Episodes /Movies and /Showings in the default recordings folder(s). This allows for better balance across multiple filesystems. \n\nWould you like to use your MythTV recordings folder or would you like to choose a custom folder to place recordings?"  16 60
else 
 dialog --title "File Handling" --yes-label "Use Original" --no-label "Choose Folder" --yesno "Using the original folder will create a /Episodes /Movies and /Showings in the default recordings folder(s). This allows for better balance across multiple filesystems. \n\nWould you like to use your original recordings folder or would you like to choose a custom folder to place recordings?"  16 
fi

test $? = 0 && UserChoosesFolder=1 || UserChoosesFolder=0


test -f ./movedir && movedir1=`cat ./movedir`
test "$movedir1" = "" && movedir1="./Episodes"
echo " #MoveDir is the folder which mythicalLibrarian will move the file.  No trailing / is accepted eg. "~/videos"">> ./mythicalPrep
if [ "$UserChoosesFolder" = "0" ]; then 
 dialog --inputbox "Enter the name of the folder you would like to move episodes. Default:$movedir1" 10 50 "$movedir1" 2>./movedir
 movedir=`cat ./movedir`
fi
 test "$movedir" = "" && movedir=$movedir1
 echo $movedir > ./movedir
 echo "MoveDir=$movedir">>./mythicalPrep
 test "$UserChoosesFolder" = "0" && test ! -d "$movedir" && sudo -u $SUDO_USER mkdir "$movedir"



test -f ./AlternateMoveDir && AlternateMoveDir1=`cat ./AlternateMoveDir`
test "$AlternateMoveDir1" = "" && AlternateMoveDir1="./Episodes"
dialog --infobox "If your primary folder fails, your files will be moved to $AternateMoveDir1 default" 10 30 
echo " #AlternateMoveDir will act as a seccondary MoveDir if the primary MoveDir fails.  No trailing / is accepted eg. "~/videos"">> ./mythicalPrep
if [ "$UserChoosesFolder" = "0" ]; then 
 dialog --inputbox "Enter the name of the alternate folder you would like to move episodes. Default:$AlternateMoveDir1" 10 50 "$AlternateMoveDir1" 2>./AlternateMoveDir
 AlternateMoveDir=`cat ./AlternateMoveDir`
fi
 test "$AlternateMoveDir" = "" && AlternateMoveDir=$AlternateMoveDir1
 echo $AlternateMoveDir > ./AlternateMoveDir
 echo "AlternateMoveDir=$AlternateMoveDir">> ./mythicalPrep
 test "$UserChoosesFolder" = "0" && test ! -d "$AlternateMoveDir" && sudo -u $SUDO_USER mkdir "$AlternateMoveDir"
echo " #If UseOriginalDir is Enabled, original dir will override MoveDir.  Useful for multiple recording dirs.">> ./mythicalPrep
echo " #UseOriginalDir will separate episodes from movies and shows. Enabled|Disabled">> ./mythicalPrep

test "$UserChoosesFolder" = "0" && echo "UseOriginalDir=Disabled">>./mythicalPrep || echo "UseOriginalDir=Enabled">>./mythicalPrep
echo " #When Enabled, mythicalLibrarian will move the file to a folder of the same name as the show. This is not affected by UseOriginalDir. Enabled|Disabled">> ./mythicalPrep

echo "UseShowNameAsDir=Enabled">>./mythicalPrep
echo " #Internet access Timeout in seconds: Default Timeout=50 (seconds)">> ./mythicalPrep

echo "Timeout=50">>./mythicalPrep
echo " #Update database time in secconds, Longer duration means faster processing time and less strain on TheTvDb. Default='70000' (almost a day)">> ./mythicalPrep

echo "UpdateDatabase=70000">>./mythicalPrep
echo " #mythicalLibrarian working file dir: Default=~/.mythicalLibrarian (home/username/mythicalLibraian)">> ./mythicalPrep

echo "mythicalLibrarian=~/.mythicalLibrarian">>./mythicalPrep
echo " #FailSafe mode will enable symlinks to be formed in FailSafeDir if the move or symlink operation fails. Enabled|Disabled">> ./mythicalPrep

echo "FailSafeMode=Enabled">>./mythicalPrep
echo " #FailSafeDir is used when the file cannot be moved to the MoveDir. FailSafe will not create folders. eg. /home/username">> ./mythicalPrep
echo "FailSafeDir='/home/mythtv/FailSafe'">>./mythicalPrep
echo " #DirTracking will check for and remove the folders created by mythicalLibrarian">> ./mythicalPrep

echo "DirTracking=Enabled">>./mythicalPrep

echo " #the following line contains the API key from www.TheTvDb.Com. Default project code: 6DF511BB2A64E0E9">> ./mythicalPrep
echo "APIkey=6DF511BB2A64E0E9">>./mythicalPrep
echo " #Language setting">>./mythicalPrep
echo "Language=en">>./mythicalPrep

if [ "$mythtv" = "1" ]; then

	echo " #SYMLINK has 3 modes.  MOVE|LINK|Disabled: Default=MOVE">> ./mythicalPrep
	echo " #Create symlink in original dir from file after 'MOVE' | Do not move, just create a sym'LINK' | move the file, symlinking is 'Disabled'">> ./mythicalPrep
	dialog --title "SYMLINK" --yesno "Keep files under control of MythTv? Note: 'No' will delete all database entries after moving files" 8 40
		test $? = 0 && echo "SYMLINK=MOVE" >> ./mythicalPrep || echo "SYMLINK=Disabled" >> ./mythicalPrep
echo "">>./mythicalPrep
echo " ###Database Settings###">>./mythicalPrep
	echo " #Guide data type">> ./mythicalPrep
 	dialog --title "Database Type" --yesno "Do you have one of the following guide data types?  SchedulesDirect, TiVo, Tribune, Zap2it?  note: No will bypass TVDB lookups" 12 25
	test $? = 0 && database=1 || database=0

	if [ "$database" = "1" ] || [ "$database" = "0" ]; then
 
		echo " #Database access Enabled|Disabled">> ./mythicalPrep
		echo "Database=Enabled">>./mythicalPrep	

 		echo " #Database Type Default=MythTV">> ./mythicalPrep
		echo "DatabaseType=MythTV">>./mythicalPrep

 		echo " #Guide data type">> ./mythicalPrep
		test "$database" = 1 && echo "GuideDataType=SchedulesDirect">>./mythicalPrep || echo "GuideDataType=NoLookup">>./mythicalPrep

 		echo " #MySQL User name: Default="mythtv"">> ./mythicalPrep
 		test -f "/home/mythtv/.mythtv/mysql.txt" && MySQLuser1=`grep "DBUserName" "/home/mythtv/.mythtv/mysql.txt" |  sed s/"DBUserName="/""/g`||mythtvusername="mythtv"
 		echo "$MySQLuser1" >./MySQLuser
	    	dialog --inputbox "Enter your MYSQL Username. Default=$MySQLuser1" 9 40 "$MySQLuser1" 2>./MySQLuser
		MySQLuser=`cat ./MySQLuser`
 		test "$MySQLuser" = "" && MySQLuser="$MySQLuser1"
 		echo "$MySQLuser">./MySQLuser
		echo "MySQLuser=$MySQLuser">>./mythicalPrep


 		echo " #MySQL Password: Default="mythtv"">> ./mythicalPrep	
 		
 		test -f "/home/mythtv/.mythtv/mysql.txt" && MySQLpass1=`grep "DBPassword=" "/home/mythtv/.mythtv/mysql.txt" |  sed s/"DBPassword="/""/g`||mythtvusername="mythtv"
 		test ! -f "./MySQLpass" && echo "$MySQLpass1">./MySQLpass
	    	dialog --inputbox "Enter your MYSQL password. Default=$MySQLpass1" 9 40 "$MySQLpass1" 2>./MySQLpass
 		MySQLpass=`cat ./MySQLpass`
 		test "$MySQLpass" = "" && MySQLpass="$MySQLpass1"
 		echo "$MySQLpass">./MySQLpass
		echo "MySQLpass=$MySQLpass">>./mythicalPrep

 		echo "#MySQL Myth Database: Default="mythconverg"">> ./mythicalPrep
 		echo "MySQLMythDb=mythconverg">>./mythicalPrep



 		echo " #Primary Movie Dir. mythicalLibrarian will attempt to move to this dir first. No trailing / is accepted eg. '~/videos'">> ./mythicalPrep 		
 		test -f ./PrimaryMovieDir && PrimaryMovieDir1=`cat ./PrimaryMovieDir`
 		test "$PrimaryMovieDir1" = "" && PrimaryMovieDir1="~/Movies"
 		if [ "$UserChoosesFolder" = "0" ]; then 
		 dialog --inputbox "Enter the name of the folder you would like to move Movies Default=$PrimaryMovieDir1" 12 50 "$PrimaryMovieDir1" 2>./PrimaryMovieDir
 		 PrimaryMovieDir=`cat ./PrimaryMovieDir`
		fi
 		test "$PrimaryMovieDir" = "" && PrimaryMovieDir=$PrimaryMovieDir1
 		echo "$PrimaryMovieDir">./PrimaryMovieDir
 		echo "PrimaryMovieDir=$PrimaryMovieDir">>./mythicalPrep
 	 	test "$UserChoosesFolder" = "0" && test ! -d "$PrimaryMovieDir" && sudo -u $SUDO_USER mkdir "$PrimaryMovieDir"


 		echo " #AlternateMoveDir will act as a Seccondary move dir if the primary moive dir fails">> ./mythicalPrep
 		test -f ./AlternateMovieDir && AlternateMovieDir1=`cat ./AlternateMovieDir`
 		test "$AlternateMovieDir1" = "" && AlternateMovieDir1="~/Movies"
 		if [ "$UserChoosesFolder" = "0" ]; then 
		 dialog --inputbox "Enter the name of the Alternate folder you would like to move Movies Default=$AlternateMovieDir1" 12 50 "$AlternateMovieDir1" 2>./AlternateMovieDir
 		 AlternateMovieDir=`cat ./AlternateMovieDir`
		fi
 		test "$AlternateMovieDir" = "" && AlternateMovieDir=$AlternateMovieDir1
 		echo "$AlternateMovieDir">./AlternateMovieDir
 		echo "AlternateMovieDir=$AlternateMovieDir">>./mythicalPrep
 	 	test "$UserChoosesFolder" = "0" && test ! -d "$AlternateMovieDir" && sudo -u $SUDO_USER mkdir "$AlternateMovieDir" 


 		echo " #ShowStopper = Enabled prevents generic shows and unrecognized episodes from being processed">> ./mythicalPrep
 		dialog --title "Unrecognizable programming" --yesno "Do you want mythicalLibrarian to process shows when it cannot obtain TVDB information?" 8 40
  		test "$?" = "0" && echo " ShowStopper=Disabled">> ./mythicalPrep || echo " ShowStopper=Enabled">> ./mythicalPrep
 		


		test -f ./PrimaryShowDir && PrimaryShowDir1=`cat ./PrimaryShowDir`
 		test "$PrimaryShowDir1" = "" && PrimaryShowDir1="~/Showings"
 		if [ "$UserChoosesFolder" = "0" ]; then 
		 dialog --inputbox "Enter the name of the folder you would like to move Shows Default=$PrimaryShowDir1" 12 50 "$PrimaryShowDir1" 2>./PrimaryShowDir
 		 PrimaryShowDir=`cat ./PrimaryShowDir`
		fi
 		test "$PrimaryShowDir" = "" && PrimaryShowDir=$PrimaryShowDir1
 		echo "$PrimaryShowDir">./AlternateShowDir
 		echo "PrimaryShowDir=$PrimaryShowDir">>./mythicalPrep
 	 	test "$UserChoosesFolder" = "0" && test ! -d "$PrimaryShowDir" && sudo -u $SUDO_USER mkdir "$PrimaryShowDir"




 		echo " #AlternateShowDir will act as a Seccondary move dir if the primary Show dir fails">> ./mythicalPrep
		test -f ./AlternateShowDir && AlternateShowDir1=`cat ./AlternateShowDir`
 		test "$AlternateShowDir1" = "" && AlternateShowDir1="~/Showings"
 		if [ "$UserChoosesFolder" = "0" ]; then 
		 dialog --inputbox "Enter the name of the Alternate folder you would like to move Shows Default=$AlternateShowDir1" 12 50 "$AlternateShowDir1" 2>./AlternateShowDir
 		 AlternateShowDir=`cat ./AlternateShowDir`
		fi
 		test "$AlternateShowDir" = "" && AlternateShowDir=$AlternateShowDir1
 		echo "$AlternateShowDir">./AlternateShowDir
 		echo "AlternateShowDir=$AlternateShowDir">>./mythicalPrep
  	 	test "$UserChoosesFolder" = "0" && test ! -d "$AlternateShowDir" && sudo -u $SUDO_USER mkdir "$AlternateShowDir"


 		echo " #CommercialMarkup will generate comskip files for recordings when they are moved. Enabled|Disabled">> ./mythicalPrep
 		echo "CommercialMarkup=Enabled" >> ./mythicalPrep

 		echo " #CommercialMarkupCleanup will execute a maintenance routine which will remove comskip files if they are not needed">> ./mythicalPrep
 		echo "CommercialMarkupCleanup=Enabled" >> ./mythicalPrep

	fi

elif [ $mythtv = 0 ]; then

 	
    	dialog --title "SYMLINK" --yesno "Do you want mythicalLibrarian to symlink to the original file after move?" 8 35
 	test $? = 0 && echo "SYMLINK=MOVE" >> ./mythicalPrep || echo "SYMLINK=Disabled" >> ./mythicalPrep

 	echo " #SYMLINK has 3 modes.  MOVE|LINK|Disabled: Default=MOVE">> ./mythicalPrep
 	echo " #Create symlink in original dir from file after 'MOVE' | Do not move, just create a sym'LINK' | move the file, symlinking is 'Disabled'">> ./mythicalPrep
	echo "Database=Disabled" >> ./mythicalPrep

	echo " #Database Type Default=MythTV">> ./mythicalPrep
	echo "DatabaseType=none" >> ./mythicalPrep

	echo " #Guide data type">> ./mythicalPrep
 	echo "GuideDataType=none" >> ./mythicalPrep

 	test -f "/home/mythtv/.mythtv/mysql.txt" && mythtvusername=`grep "DBUserName" "/etc/mythtv/.mythtv/mysql.txt" |  sed s/"DBUserName="/""/g`||mythtvusername="mythtv"
	echo " #MySQL User name: Default="$mythtvusername"">> ./mythicalPrep
 	echo "MySQLuser=''" >> ./mythicalPrep

 	test -f "/home/mythtv/.mythtv/mysql.txt" && mythtvpassword=`grep "DBPassword=" "/etc/mythtv/.mythtv/mysql.txt" |  sed s/"DBPassword="/""/g`||mythtvusername="mythtv"
	echo " #MySQL Password: Default="$mythtvpassword"">> ./mythicalPrep
 	echo "MySQLpass=''" >> ./mythicalPrep

	echo " #MySQL Myth Database: Default="mythconverg"">> ./mythicalPrep
 	echo "MySQLMythDb=''" >> ./mythicalPrep

	echo " #Primary Movie Dir. mythicalLibrarian will attempt to move to this dir first. No trailing / is accepted eg. "~/videos"">> ./mythicalPrep
 	echo "PrimaryMovieDir=''" >> ./mythicalPrep

	echo " #AlternateMoveDir will act as a Seccondary move dir if the primary moive dir fails">> ./mythicalPrep
 	echo "AlternateMovieDir=''" >> ./mythicalPrep
 
 	echo " #ShowStopper = Enabled prevents generic shows and unrecognized episodes from being processed">> ./mythicalPrep
 	echo " ShowStopper=Disabled">> ./mythicalPrep

 	echo " #CommercialMarkup will generate comskip files for recordings when they are moved. Enabled|Disabled">> ./mythicalPrep
 	echo "CommercialMarkup=Disabled" >> ./mythicalPrep

	echo " #CommercialMarkupCleanup will execute a maintenance routine which will remove comskip files if they are not needed">> ./mythicalPrep
 	echo "CommercialMarkupCleanup=Disabled" >> ./mythicalPrep

fi


echo " ###Reporting/Communications###">>./mythicalPrep
 
	echo " #If notifications are enabled, NotifyUserName should be the same as the user logged into the GNOME Session. (your username)">> ./mythicalPrep
	test ! -f ./DesktopUserName && echo "$SUDO_USER">>./DesktopUserName
 	test -f ./DesktopUserName && DesktopUserName1=`cat ./DesktopUserName`
	dialog --inputbox "Enter your Desktop Username Default=$DesktopUserName1" 10 40 "$DesktopUserName1" 2>./DesktopUserName
 	DesktopUserName=`cat ./DesktopUserName`
 	test "$DesktopUserName" = "" && DesktopUserName=$DesktopUserName1
 	echo "$DesktopUserName">./DesktopUserName
  	echo "NotifyUserName=$DesktopUserName" >>./mythicalPrep

 	echo " #Notify tells mythicalLibrarian to send a notification to GNOME Desktop upon completion. Enabled|Disabled">> ./mythicalPrep
	dialog --title "Desktop Notifications" --yesno "Would you like mythicalLibrarian to send desktop notifications?
if Yes, the user must have no password sudo access." 10 45
	test $? = 0 && notifications=1 || notifications=0
 	if [ "$notifications" = "1" ]; then
 	echo "Notify=Enabled" >> ./mythicalPrep


else

 	echo " #Notify tells mythicalLibrarian to send a notification to GNOME Desktop upon completion. Enabled|Disabled">> ./mythicalPrep
 	echo "Notify=Disabled" >> ./mythicalPrep

	echo " #If notifications are enabled, NotifyUserName should be the same as the user logged into the GNOME Session. (your username)">> ./mythicalPrep
 	echo "NotifyUserName='$DesktopUserName'" >> ./mythicalPrep
fi


dialog --title "XBMC Notifications" --yesno "Would you like mythicalLibrarian to interface XBMC?" 9 30
	test $? = 0 && notifications=1 || notifications=0


if [ "$notifications" = "1" ]; then

 		
	echo " #Ip Address and port for XBMC Notifications Eg.XBMCIPs=( '192.168.1.110:8080' '192.168.1.111:8080' 'XBOX:8080' )">> ./mythicalPrep
		  xbmcips1=`cat ./xbmcips` 
 		  test "$xbmcips1" = "" && xbmcips1="'192.168.1.100:8080'"
   	dialog --inputbox "Enter your XBMC IP Addresses and port in single quotes. eg. '192.168.1.110:8080' 'XBOX:8080' Default=$xbmcips1" 10 50 "$xbmcips1" 2>./xbmcips
                xbmcips=`cat ./xbmcips`
  		  echo "$xbmcips">./xbmcips
 		  echo "XBMCIPs=( $xbmcips )">>./mythicalPrep
		  
	dialog --title "XBMC Notifications" --yesno "Would you like mythicalLibrarian to update your library?" 9 30
		  if [ $? = 0 ]; then
 			echo " #Send a notification to XBMC to Update library upon successful move job Enabled|Disabled">> ./mythicalPrep
 			 echo "XBMCUpdate=Enabled">>./mythicalPrep
 			 echo " #Send Notifications to XBMC UI when library is updated Enabled|Disabled">> ./mythicalPrep
 			 echo "XBMCNotify=Enabled">>./mythicalPrep

		  else

		 	 echo " #Send a notification to XBMC to Update library upon successful move job Enabled|Disabled">> ./mythicalPrep
 			 echo "XBMCUpdate=Disabled">>./mythicalPrep
 			 echo " #Send Nrotifications to XBMC UI when library is updated Enabled|Disabled">> ./mythicalPrep
 			 echo "XBMCNotify=Disabled"
 		  fi

	echo " #Send a notification to XBMC to cleanup the library upon successful move job Enabled|Disabled">> ./mythicalPrep
	echo "XBMCClean=Disabled">>./mythicalPrep
else

	echo " #Ip Address and port for XBMC Notifications Eg.XBMCIPs=( "192.168.1.110:8080" "192.168.1.111:8080" "XBOX:8080" )">> ./mythicalPrep
	echo "XBMCIPs=''">>./mythicalPrep

	echo " #Send a notification to XBMC to Update library upon successful move job Enabled|Disabled">> ./mythicalPrep
	echo "XBMCUpdate=Disabled">>./mythicalPrep

	echo " #Send Notifications to XBMC UI when library is updated Enabled|Disabled">> ./mythicalPrep
	echo "XBMCNotify=Disabled">>./mythicalPrep

 	echo " #Send a notification to XBMC to cleanup the library upon successful move job Enabled|Disabled">> ./mythicalPrep
	echo "XBMCClean=Disabled">>./mythicalPrep

fi 

echo " #DailyReport provides a local log of shows added to your library per day. Enabled|Disabled">> ./mythicalPrep
echo "DailyReport=Enabled">> ./mythicalPrep
echo "#Enables debug mode.  This is a verbose mode of logging which should be used for troubleshooting.  Enabled|Disabled" >> ./mythicalPrep 

OldOutputLog=`eval echo "~/.mythicalLibrarian/output.log.old"`
test -f "$OldOutputLog" && OldOutputLog=$OldOutputLog || OldOutputLog="" 
echo "DEBUGMODE=Enabled" >> ./mythicalPrep


	
echo "#maxItems controls the number of items in the RSS. RSS Can be activated by creating a folder in /var/www/mythical-rss." >> ./mythicalPrep 
echo "maxItems=8">> ./mythicalPrep
echo "#########################USER SETTINGS########################## ">> ./mythicalPrep
echo '########################## USER JOBS############################'>> ./mythicalPrep
echo ' #The RunJob function is a place where you can put your custom script to be run at the end of execution'>> ./mythicalPrep
echo ' #Though it may be at the top, this is actually the end of the program.  '>> ./mythicalPrep

echo ' RunJob () {'>> ./mythicalPrep
echo ' 	case $jobtype in'>> ./mythicalPrep
echo ' #Successful Completion of mythicalLibrarian'>> ./mythicalPrep
echo ' 		LinkModeSuccessful|MoveModeSuccessful)'>> ./mythicalPrep
echo ' 			echo "SUCCESSFUL COMPLETEION TYPE: $jobtype"'>> ./mythicalPrep
echo ' 			#Insert Custom User Job here '>> ./mythicalPrep
test -f /etc/mythicalLibrarian/JobSucessful && cat -A /etc/mythicalLibrarian/JobSucessful >> ./mythicalPrep
echo ' 			'>> ./mythicalPrep
echo ' 			#'>> ./mythicalPrep
echo ' 			exit 0'>> ./mythicalPrep
echo ' 			;;'>> ./mythicalPrep
echo ' #File system error occoured'>> ./mythicalPrep
echo ' 		PermissionError0Length|NoFileNameSupplied|PermissionErrorWhileMoving|FailSafeModeComplete|LinkModeFailed)'>> ./mythicalPrep
echo ' 			echo "FILE SYSTEM ERROR:$jobtype"'>> ./mythicalPrep
echo ' 			#Insert Custom User Job here '>> ./mythicalPrep
test -f /etc/mythicalLibrarian/JobFilesystemError && cat -A  /etc/mythicalLibrarian/JobFilesystemError >> ./mythicalPrep
echo ' 			'>> ./mythicalPrep
echo ' 			#'>> ./mythicalPrep
echo '   			exit 1'>> ./mythicalPrep
echo ' 			;;'>> ./mythicalPrep
echo ' '>> ./mythicalPrep
echo ' #Information error occoured'>> ./mythicalPrep
echo ' 		TvDbIsIncomplete|GenericShow)'>> ./mythicalPrep
echo ' 			echo "INSUFFICIENT INFORMATION WAS SUPPLIED:$jobtype"'>> ./mythicalPrep
echo '  			#Insert Custom User Job here '>> ./mythicalPrep
test -f /etc/mythicalLibrarian/JobInformationNotComplete && cat -A /etc/mythicalLibrarian/JobInformationNotComplete >> ./mythicalPrep
echo ' 			'>> ./mythicalPrep
echo ' 			#'>> ./mythicalPrep
echo '  			exit 0'>> ./mythicalPrep
echo ' 			;;'>> ./mythicalPrep
echo ' #Generic error occoured'>> ./mythicalPrep
echo '  		GenericUnspecifiedError)'>> ./mythicalPrep
test -f /etc/mythicalLibrarian/JobGenericError && cat -A /etc/mythicalLibrarian/JobGenericError >> ./mythicalPre
echo '  			echo "UNKNOWN ERROR OCCOURED:$jobtype"'>> ./mythicalPrep
echo '  			#Insert Custom User Job here  '>> ./mythicalPrep
echo ' 			'>> ./mythicalPrep
echo ' 			#'>> ./mythicalPrep
echo '  			exit 3 '>> ./mythicalPrep
echo ' 			;;'>> ./mythicalPrep
echo ' #Insufficent data error occoured'>> ./mythicalPrep
echo ' 	 		NameCouldNotBeAssigned)'>> ./mythicalPrep
echo ' 	 		 	echo "NAME COULD NOT BE ASSIGNED BASED UPON DATA SUPPLIED"'>> ./mythicalPrep
echo ' 	 			#Insert Custom User Job here'>> ./mythicalPrep
test -f /etc/mythicalLibrarian/JobInsufficientData && cat -A /etc/mythicalLibrarian/JobInsufficientData  >> ./mythicalPrep
echo ' 	 			'>> ./mythicalPrep
echo ' 				#'>> ./mythicalPrep
echo ' 				exit 3'>> ./mythicalPrep
echo ' 				;;'>> ./mythicalPrep
echo ' #Job was ignored by title or category'>> ./mythicalPrep
echo ' 			titleIgnore|categoricIgnore)'>> ./mythicalPrep
echo ' 			echo "Show Was ignored based on $jobtype"'>> ./mythicalPrep
echo ' 				#Insert Custom User Job Here'>> ./mythicalPrep
test -f /etc/mythicalLibrarian/JobIgnoreList && cat -A /etc/mythicalLibrarian/JobIgnoreList >> ./mythicalPrep
echo ' 				'>> ./mythicalPrep
echo ' 				#'>> ./mythicalPrep
echo ' 				exit 0'>> ./mythicalPrep
echo ' 				;;'>> ./mythicalPrep


echo ' esac'>> ./mythicalPrep
echo ' #Custom exit point may be set anywhere in program by typing RunJob on any new line'>> ./mythicalPrep
echo ' #Insert Custom User Job here '>> ./mythicalPrep
test -f /etc/mythicalLibrarian/JobUnspecified && cat -A /etc/mythicalLibrarian/JobUnspecified >> ./mythicalPrep
echo ' '>> ./mythicalPrep
echo ' #'>> ./mythicalPrep
echo ' exit 4'>> ./mythicalPrep
echo ''>> ./mythicalPrep
echo ' }'>> ./mythicalPrep
echo ''>> ./mythicalPrep

test -f ./mythicalLibrarian && rm ./mythicalLibrarian
cat ./mythicalPrep >./mythicalLibrarian
cat ./librarian >>./mythicalLibrarian

AlternateMoveDir=`echo $AlternateMoveDir`
AlternateMovieDir=`echo $AlternateMovieDir`
AlternateShowDir=`echo $AlternateShowDir`



test "$mythtv" = "1" && dialog --inputbox "Enter The Username of the person who will run mythicalLibrarian.  Note, this will generally be mythtv." 10 40 "mythtv" 2>./UserName || dialog --inputbox "Enter The Username of the person who will run mythicalLibrarian." 10 40 "$SUDO_USER" 2>./UserName || echo $SUDO_USER>./UserName
 	UserName=`cat ./UserName`
if sudo grep "mythtv " /etc/sudoers>/dev/null && [ "$mythtv" = "1" ] ; then 
 echo "mythtv group was maintained" 
else 
 echo "Adding sudoers entry for mythtv"
 sudo useradd -g $SUDO_USER mythtv
 sudo useradd -g mythtv $SUDO_USER
 echo "%mythtv ALL=(ALL) ALL" | sudo tee -a /etc/sudoers
 echo " Please set a password for mythtv account access"
 sudo passwd mythtv
 useradd -g $SUDO_USER mythtv
fi


#basic linux setup checks for POSIX compliance
test ! -d "/usr" && sudo -U mkdir "/usr"
test ! -d "/usr/local" && mkdir "/usr/local"
test ! -d "/usr/local/bin" && mkdir "/usr/local/bin" && PATH=$PATH:/usr/local/bin && export PATH && echo "PATH=$PATH:/usr/local/bin">~/.profile


#basic mythtv username check
test "$mythtv" = "1" && test ! -d "/home/mythtv" && mkdir "/home/mythtv"

if [ "$UserChoosesFolder" = "0" ]; then
 	test ! -d "$AlternateMoveDir" && mkdir "$AlternateMoveDir" 
 	test ! -d "$AlternateMovieDir" && mkdir "$AlternateMovieDir"
 	test ! -d ~/.mythicalLibrarian && mkdir ~/.mythicalLibrarian
 	test ! -d "$AlternateShowDir" && mkdir "$AlternateShowDir"
 	test ! -d /home/mythtv/Episodes && mkdir /home/mythtv/Episodes
fi

test ! -d "/home/mythtv/Failsafe" && mkdir "/home/mythtv/Failsafe"
test -d "/var/www" && test ! -d "/var/www/mythical-rss" &&  mkdir /var/www/mythical-rss 
test -d "/var/www/mythical-rss" && RssEnabled=1
test -d ~/.mythicalLibrarian && chmod 775 ~/.mythicalLibrarian
chmod 711 ~/.mythicalLibrarian/mythicalSetup




#Change ownership
chown -R $SUDO_USER ~/.mythicalLibrarian
chmod -R 775 ~/.mythicalLibrarian

chown -hR "$UserName" /var/www/mythical-rss



test "$mythtv" = "1" && useradd -G mythtv $UserName>/dev/null 2>&1 
test "$mythtv" = "1" && useradd -G $UserName mythtv >/dev/null 2>&1 
clear

echo "mythicalLibrarian will now conduct mythicalDiagnostics"
read -n1 -p "Press any key to continue to online testing...."
echo ""
echo "Testing mythicalLibrarian">./testfile.ext
chmod 1755 "./mythicalLibrarian"
cp ./mythicalLibrarian /usr/local/bin/mythicalLibrarian




test "$mythtv" = "1" && chmod -R 775 "$AlternateMoveDir" "$AlternateMovieDir" $AlternateShowDir "/home/mythtv/Failsafe" "/var/www/mythical-rss">/dev/null 2>&1 
test "$mythtv" = "1" && chown -hR "mythtv"  "$AlternateMoveDir" "$AlternateMovieDir" $AlternateShowDir "/home/mythtv/Failsafe" "/var/www/mythical-rss">/dev/null 2>&1 
test "$mythtv" != "1" && chown -hR "$UserName" "$AlternateMoveDir" "$AlternateMovieDir" "/home/mythtv/Failsafe" "/var/www/mythical-rss">/dev/null 2>&1 


sudo -u $SUDO_USER /usr/local/bin/mythicalLibrarian -m
test $? = "0" && passed="0" || passed="1"

test -d ~/.mythicalLibrarian && sudo chown -hR "$UserName" ~/.mythicalLibrarian
test -d "~/.mythicalLibrarian/Mister Rogers' Neighborhood/" && chown -hR "$UserName" "~/.mythicalLibrarian/Mister Rogers' Neighborhood/"
test "$passed" = "0" && echo "Installation and tests completed successfully."  || echo "Please try again.  If problem persists, please post here: http://forum.xbmc.org/showthread.php?t=65644"


if [ "$mythtv" = "1" ]; then
 test `which mysql >/dev/null` && foundMysql=0||foundMysql=1
 if [ "$foundMysql" = "0" ]; then
  PATH="$PATH:/usr/local/mysql:/usr/local/mysql/bin"
  test `which mysql >/dev/null` && echo PATH="$PATH:/usr/local/mysql:/usr/local/mysql/bin"| tee ~/.profile ~/../mythtv/.profile 
 fi
 
 JobFoundInSlot=0
 counter=0
 SlotToUse=0
 while [ $counter -lt 4 ]
 do
  let counter=$counter+1
  job=`mysql -u$MySQLuser -p$MySQLpass -e "use mythconverg; select data from settings where value like 'UserJob$counter';" | sed s/"data"/""/g |sed -n "2p" ` 
  mysql -u$MySQLuser -p$MySQLpass -e "use mythconverg;"
  test "$?" = "1" && nomythtvdb=1
  test "$job" = '/usr/local/bin/mythicalLibrarian "%DIR%/%FILE%"' && JobFoundInSlot=$counter
  test "$JobFoundInSlot" = "0" && test "$SlotToUse" = "0" && test "$job" = "" && SlotToUse=$counter
 done 
 if [ "$nomythtvdb" != "1" ] && [ "$JobFoundInSlot" != "0" ]; then
  echo "MythTV job not added because mythicalLibrarian already exists in slot $JobFoundInSlot"	
 else
  echo ADDING JOB to slot $SlotToUse
  if [ "$SlotToUse" != "0" ]; then
   CheckForTableEntry=`mysql -u$MySQLuser -p$MySQLpass -e "use mythconverg; select * from settings where value like 'UserJob$SlotToUse';"`
   test "$CheckForTableEntry" = "" && mysql -u$MySQLuser -p$MySQLpass -e "use mythconverg; INSERT into settings SET value = 'UserJob$SlotToUse';"
   mythicalcheck=`mysql -u$MySQLuser -p$MySQLpass -e "use mythconverg; UPDATE settings SET data='/usr/local/bin/mythicalLibrarian \"%DIR%/%FILE%\"' WHERE value='UserJob$SlotToUse'; UPDATE settings SET data='mythicalLibrarian' WHERE value='UserJobDesc$SlotToUse'; UPDATE settings SET data='1' WHERE value='JobAllowUserJob$SlotToUse';"`
     mysql -u$MySQLuser -p$MySQLpass -e "use mythconverg; UPDATE settings SET data='1' WHERE value='DeletesFollowLinks';"



  else
   echo "Could not add mythcialLibrarian MythTV UserJob because no slots were available"
  fi
 fi
fi
test "${mythicalcheck:0:5}" = "ERROR" && echo 'Access denied to update user job.  User job must be added manually.  /usr/local/bin/mythicalLibrarian "%DIR%/%FILE%"'






echo "permissions were set for user: $UserName."
test `which ifconfig` && myip=`ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}'`
test "$RssEnabled" = "1" && test "$myip" != "" && echo "RSS Feed will be located at http://$myip/mythical-rss/rss.xml ." 
test "$RssEnabled" != "1" && echo "No RSS Feeds will be used on this server. Configure /var/www/mythical-rss to link to web server for access by mythicalLibrarian."
echo "mythicalLibrarian is located in /usr/local/bin" 
echo "mythicalLibrarian's log is located in "~/".mythicalLibrarian/output.log"
if [ $UserChoosesFolder = 1 ]; then
 echo "Renamed video files will be placed in new folders within original."
 test "$mythtv" = "1" && echo -e "  ie. /var/lib/mythtv/recordings/Episodes, /Movies and /Showings."
 test "$mythtv" != "1" && echo -e "  ie. /path_to_original_file/Episodes, /Movies and /Showings."
else
 echo "User specified folders are to be used for placement of recordings."
fi
test "$mythtv" = "1" && echo -e "Check the mythicalLibrarian checkbox when setting up recordings."
echo "For more information, type 'mythicalLibrarian --help'"
echo "Done."

exit 0
