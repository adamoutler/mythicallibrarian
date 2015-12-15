> # mythicalFeatures #

  * Renames Episodes to Title S##E## (Subtitle)
  * Renames Generic Programming to Title S0E0 (Subtitle)
  * Renames Movies to Movie (Year)
  * Generates RSS feeds to keep you up to date
  * Will render your files still human readable in the event you loose your database
  * Maintains consistancy by symlinking back to original file
  * Allows mythtv to serve files
  * Allows mythtv to delete files
  * Provides Ubuntu desktop notifications upon completed jobs
  * Provides episode lookups based upon zap2it ids referenced to thetvdb
  * Provides episode lookup based upon subtitle or original airdate
  * Optional primary and secondary Episodes, Movies, and Shows folders for NAS users
  * Creates COMSKIP files from mythcommflag
  * Creates NFO files for generic programming
  * Tracks and deletes created helper files if main video file is deleted
  * Sends notifications to XBMC
  * Updates XBMC's library
  * Provides detailed logs and daily report in the /daily report folder
  * Showtranslations allows for title renaming if guide data is incorrect

```
Easy installation:

sudo apt-get install curl && mkdir ~/.mythicalLibrarian && mkdir ~/.mythicalLibrarian/mythicalSetup && cd ~/.mythicalLibrarian/mythicalSetup
curl http://mythicallibrarian.googlecode.com/svn/trunk/mythicalSetup.sh>./mythicalSetup.sh
sudo su
chmod +x ./mythicalSetup.sh && ./mythicalSetup.sh
```