<h2>appSync: Java SE Runtime Environment</h2>

<b>IDEA:</b> Checks for the latest Java SE Runtime Environment installers; downloads when appliciable and backs up older versions
<br>
<b>Actual:</b> Checks the the lastest version and downloads all (check the TODO section)

Finished Dev-Part1 approx at 2013-07-24.20.31
Finished Dev-Part2 approx at 2013-07-25.22.21

<b>TODO: </b>
<br>
-per-OS build/patch/update check and download only upon new versions
<br>
-maintain "older" verions; know current version in repository
<br>
-add email notifications
<br>
-restructure md5 and bin_downloaded checks such that:
<br>
--download only if file does not exist OR if file exists AND md5 does not match

<b>Done TODOs: </b>
+add optional OS exclusions
<br>
+md5 checks downloaded binaries (in the download-temp path); if md5 fails on any file, that file is removed
<br>
