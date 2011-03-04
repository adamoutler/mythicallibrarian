#! /bin/bash

#Credits for this script go to kvandesteeg for locating this
#information. 


easy_install pip
export VERSIONER_PYTHON_PREFER_32_BIT=yes
defaults write com.apple.versioner.python Prefer-32-Bit -bool yes
sudo pip install MySQL-python
sudo pip install lxml
git clone -b fixes/0.24 git://github.com/MythTV/mythtv.git
cd mythtv/bindings/python
sudo python setup.py install

echo 
echo "Now testing python bindings installation"  
python -c "import MythDB.MythTV"
if [ "$?" = "0" ]; then
  echo "Python Bindings are sucessfully installed"
else
 echo "Python bindings installation FAILED!!!
here are some resources which you can check for more information
Gossamer-Threads Mac MythTV Python:
 http://www.gossamer-threads.com/lists/mythtv/dev/389569
mythicalLibrarian Thread:
 http://forum.xbmc.org/showpost.php?p=741780&postcount=773"
fi

