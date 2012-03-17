#!/bin/bash
#
# Fanboy Adblock list grabber script v1.6 (16/03/2012)
# Dual License CCby3.0/GPLv2
# http://creativecommons.org/licenses/by/3.0/
# http://www.gnu.org/licenses/gpl-2.0.html
#
# Variables for directorys
#
MAINDIR="/var/www/adblock"
GOOGLEDIR="/home/fanboy/google/fanboy-adblock-list"
TESTDIR="/tmp/ramdisk"
ZIP="nice -n 19 /usr/local/bin/7za"
NICE="nice -n 19"
SHRED="nice -n 19 /usr/bin/shred"
LOGFILE="/etc/crons/log-listgrabber.txt"
DATE="`date`"
ECHORESPONSE="List Changed: $LS2"
BADUPDATE="Bad Update: $LS2"
LS2="`ls -al $FILE`"
# OPENSSL=/usr/bin/openssl
OPENSSL=/usr/local/openssl/bin/openssl
ENCRYPT=sha256

# Make Ramdisk.
#
$GOOGLEDIR/scripts/ramdisk.sh
# Fallback if ramdisk.sh isn't excuted.
#
if [ ! -d "/tmp/ramdisk/" ]; then
  rm -rf /tmp/ramdisk/
  mkdir /tmp/ramdisk; chmod 777 /tmp/ramdisk
  mount -t tmpfs -o size=30M tmpfs /tmp/ramdisk/
  mkdir /tmp/ramdisk/opera/
fi

# Make sure the shell scripts are exexcutable, all the time..
#
chmod a+x $GOOGLEDIR/scripts/ie/*.sh $GOOGLEDIR/scripts/iron/*.sh $GOOGLEDIR/scripts/*.sh $GOOGLEDIR/scripts/firefox/*.sh $GOOGLEDIR/scripts/combine/*.sh

# Grab Mercurial Updates
#
cd /home/fanboy/google/fanboy-adblock-list/
$NICE /usr/local/bin/hg pull
$NICE /usr/local/bin/hg update


# Main List
# Hash googlecode (SSLGOOGLE) and fanboy.co.nz (SSLMAIN), then compare the two.
#
SSLGOOGLE=$($OPENSSL $ENCRYPT $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt)
SSLMAIN=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-adblock.txt)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-adblock.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt $SSLGOOGLE"

#
if [ "$SSLGOOGLE" = "$SSLMAIN" ]
 then
    # Log
    echo "Replacing: fanboy-adblock on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
    ## DEBUG
    ### echo "Updated: fanboy-adblock.txt"
    ### echo "SSLMAIN: $MAINDIR/fanboy-adblock.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt $SSLGOOGLE"
    # Make sure the old copy is cleared before we start
    rm -f $TESTDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-adblock.txt
    # Copy to ram disk first. (quicker)
    cp -f $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt $TESTDIR/fanboy-adblock.txt
    # Re-generate checksum
    perl $TESTDIR/addChecksum.pl $TESTDIR/fanboy-adblock.txt
    cp -f $TESTDIR/fanboy-adblock.txt $MAINDIR/fanboy-adblock.txt
    # Compress file in Ram disk
    $ZIP a -mx=9 -y -tgzip $TESTDIR/fanboy-adblock.txt.gz $TESTDIR/fanboy-adblock.txt > /dev/null
    # Clear Webhost-copy before copying
    rm -f $MAINDIR/fanboy-adblock.txt.gz
    # Now Copy over GZip'd list
    cp -f $TESTDIR/fanboy-adblock.txt.gz $MAINDIR/fanboy-adblock.txt.gz
    # perl $TESTDIR/addChecksum.pl $TESTDIR/firefox-expanded.txt-org2
    # cp -f $TESTDIR/firefox-expanded.txt-org2 $MAINDIR/fanboy-adblock.txt
    # cp -f $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt $MAINDIR/fanboy-adblock.txt
    # cp -f $TESTDIR/fanboy-adblocklist-current-expanded.txt $MAINDIR/fanboy-adblock.txt
    
    # Create a log
    FILE="$TESTDIR/fanboy-adblock.txt"
    echo $ECHORESPONSE >> $LOGFILE

    # The Dimensions List
    ### echo "Updated: fanboy-dimensions.txt"
    $NICE $GOOGLEDIR/scripts/firefox/fanboy-dimensions.sh
    
    # The Adult List
    ### echo "Updated: fanboy-adult.txt"
    $NICE $GOOGLEDIR/scripts/firefox/fanboy-adult.sh

    # The P2P List
    ### echo "Updated: fanboy-p2p.txt"
    $NICE $GOOGLEDIR/scripts/firefox/fanboy-p2p.sh

    # Seperate off CSS elements for Opera CSS
    ### echo "Updated: fanboy-element-opera-generator.sh"
    $NICE $GOOGLEDIR/scripts/firefox/fanboy-element-opera-generator.sh
    
    # Seperate off Elements
    ### echo "Updated: fanboy-noele.sh"
    $NICE $GOOGLEDIR/scripts/firefox/fanboy-noele.sh
    
    # Combine (Czech)
    ### echo "Combine: firefox-adblock-czech.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-czech.sh
    # Combine (Espanol)
    ### echo "Combine: firefox-adblock-esp.sh"
		$NICE $GOOGLEDIR/scripts/combine/firefox-adblock-esp.sh
    # Combine (Russian)
    ### echo "Combine: firefox-adblock-rus.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-rus.sh
    # Combine (Japanese)
    ### echo "Combine: firefox-adblock-jpn.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-jpn.sh
    # Combine (Swedish)
    ### echo "Combine: firefox-adblock-swe.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-swe.sh
    # Combine (Chinese)
    ### echo "Combine: firefox-adblock-chn.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-chn.sh
    # Combine (Vietnam)
    ### echo "Combine: firefox-adblock-vtn.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-vtn.sh
    # Combine (Vietnam)
    ### echo "Combine: firefox-adblock-krn.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-krn.sh
    # Combine (Turkish)
    ### echo "Combine: firefox-adblock-turk.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-turk.sh
    # Combine (Italian)
    ### echo "Combine: firefox-adblock-ita.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-ita.sh
    # Combine (Polish)
    ### echo "Combine: firefox-adblock-pol.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-pol.sh
    # Combine Regional trackers
    ### echo "Combine: firefox-adblock-intl-tracking.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    ### echo "Combine: firefox-adblock-tracking.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-tracking.sh
    ### echo "Combine: firefox-adblock-merged.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-merged.sh
    # Combine (Main+Tracking+Enhanced) and Ultimate (Main+Tracking+Enhanced+Annoyances)
    ### echo "Combine: firefox-adblock-ultimate.sh"
    $NICE $GOOGLEDIR/scripts/combine/firefox-adblock-ultimate.sh
else
    echo "Files are the same: fanboy-adblock.txt" > /dev/null
    ## DEBUG
    ### echo Not Processed
    ### echo "SSLMAIN: $MAINDIR/fanboy-adblock.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt $SSLGOOGLE"
    ### ls -al $MAINDIR/fanboy-adblock.txt $GOOGLEDIR/fanboy-adblocklist-current-expanded.txt
fi

# Tracking List
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE=$($OPENSSL $ENCRYPT $GOOGLEDIR/fanboy-adblocklist-stats.txt)
SSLMAIN=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-tracking.txt)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-tracking.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/fanboy-adblocklist-stats.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-tracking.txt $GOOGLEDIR/fanboy-adblocklist-stats.txt

# Tracking
# Check for 0-sized file first
#
if [ "$SSLGOOGLE" = "$SSLMAIN" ]
 then
    # Log
    echo "Replacing: fanboy-tracking on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
    ## DEBUG
    ### echo "Updated: fanboy-tracking.txt"
    ### echo "SSLMAIN: $MAINDIR/fanboy-tracking.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/fanboy-adblocklist-stats.txt $SSLGOOGLE"
    ### ls -al $MAINDIR/fanboy-tracking.txt $GOOGLEDIR/fanboy-adblocklist-stats.txt
    # Clear old list
    rm -f $TESTDIR/fanboy-tracking.txt.gz $TESTDIR/fanboy-tracking.txt
    # Copy list from repo to RAMDISK
    cp -f $GOOGLEDIR/fanboy-adblocklist-stats.txt $TESTDIR/fanboy-tracking.txt
    # Re-generate checksum
    perl $TESTDIR/addChecksum.pl $TESTDIR/fanboy-tracking.txt
    # GZip
    $ZIP a -mx=9 -y -tgzip $TESTDIR/fanboy-tracking.txt.gz $TESTDIR/fanboy-tracking.txt > /dev/null
    # Create a log
    FILE="$TESTDIR/fanboy-tracking.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Clear Webhost-copy before copying and Copy over GZip'd list
    cp -f $TESTDIR/fanboy-tracking.txt $MAINDIR/fanboy-tracking.txt
    rm -f $MAINDIR/fanboy-tracking.txt.gz
    cp -f $TESTDIR/fanboy-tracking.txt.gz $MAINDIR/fanboy-tracking.txt.gz
    # Now combine with international list
    sh /etc/crons/hg-grab-intl.sh
    # Generate IE script
    $GOOGLEDIR/scripts/ie/tracking-ie-generator.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-tracking.sh
    $GOOGLEDIR/scripts/combine/firefox-adblock-merged.sh
    # Combine (Main+Tracking+Enhanced) and Ultimate (Main+Tracking+Enhanced+Annoyances)
    $GOOGLEDIR/scripts/combine/firefox-adblock-ultimate.sh
else
   echo "Files are the same: fanboy-tracking.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/fanboy-tracking.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/fanboy-adblocklist-stats.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-tracking.txt $GOOGLEDIR/fanboy-adblocklist-stats.txt
fi

# Enhanced Trackers
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE=$($OPENSSL $ENCRYPT $GOOGLEDIR/enhancedstats-addon.txt)
SSLMAIN=$($OPENSSL $ENCRYPT $MAINDIR/enhancedstats.txt)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/enhancedstats.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/enhancedstats-addon.txt $SSLGOOGLE"
### ls -al $MAINDIR/enhancedstats.txt $GOOGLEDIR/enhancedstats-addon.txt

if [ "$SSLGOOGLE" = "$SSLMAIN" ]
then
    # Log
    echo "Replacing: fanboy-enhancedstats on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
    ## DEBUG
    ### echo "Updated: enhancedstats-addon.txt"
    ### echo "SSLMAIN: $MAINDIR/enhancedstats.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/enhancedstats-addon.txt $SSLGOOGLE"
    ### ls -al $MAINDIR/enhancedstats.txt $GOOGLEDIR/enhancedstats-addon.txt
    # Clear old list
    rm -f $TESTDIR/enhancedstats.txt $TESTDIR/enhancedstats.txt.gz
    # Copy list from repo to RAMDISK
    cp -f $GOOGLEDIR/enhancedstats-addon.txt $TESTDIR/enhancedstats.txt
    # GZip
    $ZIP a -mx=9 -y -tgzip $TESTDIR/enhancedstats.txt.gz $TESTDIR/enhancedstats.txt > /dev/null
    # Create a log
    FILE="$TESTDIR/enhancedstats.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Clear Webhost-copy before copying and now Copy over GZip'd list
    cp -f $TESTDIR/enhancedstats.txt $MAINDIR/enhancedstats.txt
    rm -f $MAINDIR/enhancedstats.txt.gz
    cp -f $TESTDIR/enhancedstats.txt.gz $MAINDIR/enhancedstats.txt.gz
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-merged.sh
    # Combine (Main+Tracking+Enhanced) and Ultimate (Main+Tracking+Enhanced+Annoyances)
    $GOOGLEDIR/scripts/combine/firefox-adblock-ultimate.sh
else
   echo "Files are the same: enhancedstats.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/enhancedstats.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/enhancedstats-addon.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/enhancedstats.txt $GOOGLEDIR/enhancedstats-addon.txt

fi

# Addon/Annoyances
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE=$($OPENSSL $ENCRYPT $GOOGLEDIR/fanboy-adblocklist-addon.txt)
SSLMAIN=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-addon.txt)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-addon.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/fanboy-adblocklist-addon.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-addon.txt $GOOGLEDIR/fanboy-adblocklist-addon.txt

if [ "$SSLGOOGLE" = "$SSLMAIN" ]
then
    # Log
    echo "Replacing: fanboy-addon on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
    ## DEBUG
    ### echo "Updated: fanboy-addon.txt"
    ### echo "SSLMAIN: $MAINDIR/fanboy-addon.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/fanboy-adblocklist-addon.txt $SSLGOOGLE"
    ### ls -al $MAINDIR/fanboy-addon.txt $GOOGLEDIR/fanboy-adblocklist-addon.txt
    # Clear old list
    rm -f $TESTDIR/fanboy-addon.txt $TESTDIR/fanboy-addon.txt.gz
    # Copy list from repo to RAMDISK
    cp -f $GOOGLEDIR/fanboy-adblocklist-addon.txt $TESTDIR/fanboy-addon.txt
    # GZip
    $ZIP a -mx=9 -y -tgzip $TESTDIR/fanboy-addon.txt.gz $TESTDIR/fanboy-addon.txt > /dev/null
    # Create a log
    FILE="$TESTDIR/fanboy-addon.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Clear Webhost-copy before copying and now Copy over GZip'd list
    cp -f $TESTDIR/fanboy-addon.txt $MAINDIR/fanboy-addon.txt
    rm -f $MAINDIR/fanboy-addon.txt.gz
    cp -f $TESTDIR/fanboy-addon.txt.gz $MAINDIR/fanboy-addon.txt.gz
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-merged.sh
    # Combine (Main+Tracking+Enhanced) and Ultimate (Main+Tracking+Enhanced+Annoyances)
    $GOOGLEDIR/scripts/combine/firefox-adblock-ultimate.sh
else
   echo "Files are the same: fanboy-addon.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/fanboy-addon.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/fanboy-adblocklist-addon.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-addon.txt $GOOGLEDIR/fanboy-adblocklist-addon.txt
fi

# CZECH
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE=$($OPENSSL $ENCRYPT $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt)
SSLMAIN=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-czech.txt)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-czech.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt $SSLGOOGLE"

if [ "$SSLGOOGLE" = "$SSLMAIN" ]
then
   # Log
   echo "Replacing: fanboy-czech on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
   ## DEBUG
   ### echo "Updated: fanboy-czech.txt"
   ### echo "SSLMAIN: $MAINDIR/fanboy-czech.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-czech.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt
   cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt $MAINDIR/fanboy-czech.txt
   # Properly wipe old file.
   $SHRED -n 3 -z -u $MAINDIR/fanboy-czech.txt.gz
   $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-czech.txt.gz $MAINDIR/fanboy-czech.txt > /dev/null
   # Create a log
   FILE="$MAINDIR/fanboy-czech.txt"
   echo $ECHORESPONSE >> $LOGFILE
   # Combine Regional trackers
   $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
   # Generate IE script
   $GOOGLEDIR/scripts/ie/czech-ie-generator.sh
   # Combine
   $GOOGLEDIR/scripts/combine/firefox-adblock-czech.sh
else
   echo "Files are the same: fanboy-czech.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/fanboy-czech.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-czech.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-cz.txt
fi

# RUSSIAN
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE=$($OPENSSL $ENCRYPT $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt)
SSLMAIN=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-russian.txt)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-russian.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-russian.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt

if [ "$SSLGOOGLE" = "$SSLMAIN" ]
then
   # Log
   echo "Replacing: fanboy-russian on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
   ## DEBUG
   ### echo "Updated: fanboy-russian.txt"
   ### echo "SSLMAIN: $MAINDIR/fanboy-russian.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-russian.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt
   cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt $MAINDIR/fanboy-russian.txt
   # Properly wipe old file.
   $SHRED -n 3 -z -u $MAINDIR/fanboy-russian.txt.gz
   $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-russian.txt.gz $MAINDIR/fanboy-russian.txt > /dev/null
   # Create a log
   FILE="$MAINDIR/fanboy-russian.txt"
   echo $ECHORESPONSE >> $LOGFILE
   # Combine Regional trackers
   $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
   # Generate IE script
   $GOOGLEDIR/scripts/ie/russian-ie-generator.sh
   # Combine
   $GOOGLEDIR/scripts/combine/firefox-adblock-rus.sh
   # Generate Opera RUS script also
   $GOOGLEDIR/scripts/firefox/opera-russian.sh
else
   echo "Files are the same: fanboy-russian.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/fanboy-russian.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-russian.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-rus-v2.txt
fi

# TURK
# Store Encryption data on whats on the server vs googlecode
#
SSLGOOGLE=$($OPENSSL $ENCRYPT $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt)
SSLMAIN=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-turkish.txt)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-turkish.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-turkish.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt

if [ "$SSLGOOGLE" = "$SSLMAIN" ]
then
   # Log
   echo "Replacing: fanboy-turk on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
   ## DEBUG
   ### echo "Updated: fanboy-turkish.txt"
   ### echo "SSLMAIN: $MAINDIR/fanboy-turkish.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-turkish.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt
   cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt $MAINDIR/fanboy-turkish.txt
   # Properly wipe old file.
   $SHRED -n 3 -z -u  $MAINDIR/fanboy-turkish.txt.gz
   $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-turkish.txt.gz $MAINDIR/fanboy-turkish.txt > /dev/null
   # Create a log
   FILE="$MAINDIR/fanboy-turkish.txt"
   echo $ECHORESPONSE >> $LOGFILE
   # Combine Regional trackers
   $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
   # Generate IE script
   $GOOGLEDIR/scripts/ie/turkish-ie-generator.sh
   # Combine
   $GOOGLEDIR/scripts/combine/firefox-adblock-turk.sh
else
   echo "Files are the same: fanboy-turkish.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/fanboy-turkish.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-turkish.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-tky.txt
fi

# JAPANESE
# Hash googlecode (SSLGOOGLE) and fanboy.co.nz (SSLMAIN), then compare the two.
#
SSLGOOGLE=$($OPENSSL $ENCRYPT $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt)
SSLMAIN=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-japanese.txt)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-japanese.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-japanese.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt

if [ "$SSLGOOGLE" = "$SSLMAIN" ]
then
   # Log
   echo "Replacing: fanboy-japanese on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
   ## DEBUG
   ### echo "Updated: fanboy-japanese.txt"
   ### echo "SSLMAIN: $MAINDIR/fanboy-japanese.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-japanese.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt
   cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt $MAINDIR/fanboy-japanese.txt
   # Properly wipe old file.
   $SHRED -n 3 -z -u  $MAINDIR/fanboy-japanese.txt.gz
   $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-japanese.txt.gz $MAINDIR/fanboy-japanese.txt > /dev/null
   # Create a log
   FILE="$MAINDIR/fanboy-japanese.txt"
   echo $ECHORESPONSE >> $LOGFILE
   # Combine Regional trackers
   $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
   # Generate IE script
   $GOOGLEDIR/scripts/ie/italian-ie-generator.sh
   # Combine
   $GOOGLEDIR/scripts/combine/firefox-adblock-jpn.sh
else
   echo "Files are the same: fanboy-japanese.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/fanboy-japanese.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-japanese.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-jpn.txt

fi

# KOREAN
# Hash googlecode (SSLGOOGLE) and fanboy.co.nz (SSLMAIN), then compare the two.
#
SSLGOOGLE=$($OPENSSL $ENCRYPT $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt)
SSLMAIN=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-korean.txt)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-korean.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-korean.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt

if [ "$SSLGOOGLE" = "$SSLMAIN" ]
then
    # Log
    echo "Replacing: fanboy-korean on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
    ## DEBUG
    ### echo "Updated: fanboy-korean.txt"
    ### echo "SSLMAIN: $MAINDIR/fanboy-korean.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt $SSLGOOGLE"
    ### ls -al $MAINDIR/fanboy-korean.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt $MAINDIR/fanboy-korean.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u  $MAINDIR/fanboy-korean.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-korean.txt.gz $MAINDIR/fanboy-korean.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-korean.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-krn.sh
else
   echo "Files are the same: fanboy-korean.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/fanboy-korean.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-korean.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-krn.txt
fi


# ITALIAN
# Hash googlecode (SSLGOOGLE) and fanboy.co.nz (SSLMAIN), then compare the two.
#
SSLGOOGLE=$($OPENSSL $ENCRYPT $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt)
SSLMAIN=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-italian.txt)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-italian.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-italian.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt

if [ "$SSLGOOGLE" = "$SSLMAIN" ]
then
    # Log
    echo "Replacing: fanboy-italian on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
    ## DEBUG
    ### echo "Updated: fanboy-italian.txt"
    ### echo "SSLMAIN: $MAINDIR/fanboy-italian.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt $SSLGOOGLE"
    ### ls -al $MAINDIR/fanboy-italian.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt $MAINDIR/fanboy-italian.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u  $MAINDIR/fanboy-italian.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-italian.txt.gz $MAINDIR/fanboy-italian.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-italian.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Generate IE script
    $GOOGLEDIR/scripts/ie/italian-ie-generator.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-ita.sh
else
   echo "Files are the same: fanboy-italian.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/fanboy-italian.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-italian.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ita.txt
fi

# POLISH
# Hash googlecode (SSLGOOGLE) and fanboy.co.nz (SSLMAIN), then compare the two.
#
SSLGOOGLE=$($OPENSSL $ENCRYPT $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt)
SSLMAIN=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-polish.txt)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-polish.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-polish.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt

if [ "$SSLGOOGLE" = "$SSLMAIN" ]
then
    # Log
    echo "Replacing: fanboy-polish on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
    ## DEBUG
    ### echo "Updated: fanboy-polish.txt"
    ### echo "SSLMAIN: $MAINDIR/fanboy-polish.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt $SSLGOOGLE"
    ### ls -al $MAINDIR/fanboy-polish.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt $MAINDIR/fanboy-polish.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u  $MAINDIR/fanboy-polish.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-polish.txt.gz $MAINDIR/fanboy-polish.txt /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-polish.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-pol.sh
else
   echo "Files are the same: fanboy-polish.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/fanboy-polish.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-polish.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-pol.txt
fi

# INDIAN
# Hash googlecode (SSLGOOGLE) and fanboy.co.nz (SSLMAIN), then compare the two.
#
SSLGOOGLE=$($OPENSSL $ENCRYPT $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt)
SSLMAIN=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-indian.txt)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-indian.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-indian.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt

if [ "$SSLGOOGLE" = "$SSLMAIN" ]
then
    # Log
    echo "Replacing: fanboy-indian on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
    ## DEBUG
    ### echo "Updated: fanboy-indian.txt"
    ### echo "SSLMAIN: $MAINDIR/fanboy-indian.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt $SSLGOOGLE"
    ### ls -al $MAINDIR/fanboy-indian.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt $MAINDIR/fanboy-indian.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u  $MAINDIR/fanboy-indian.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-indian.txt.gz $MAINDIR/fanboy-indian.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-indian.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-ind.sh
else
   echo "Files are the same: fanboy-indian.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/fanboy-indian.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-indian.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-ind.txt
fi

# VIETNAM
# Hash googlecode (SSLGOOGLE) and fanboy.co.nz (SSLMAIN), then compare the two.
#
SSLGOOGLE=$($OPENSSL $ENCRYPT $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt)
SSLMAIN=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-vietnam.txt)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-vietnam.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-vietnam.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt

if [ "$SSLGOOGLE" = "$SSLMAIN" ]
then
    # Log
    echo "Replacing: fanboy-vietnam on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
    ## DEBUG
    ### echo "Updated: fanboy-vietnam.txt"
    ### echo "SSLMAIN: $MAINDIR/fanboy-vietnam.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt $SSLGOOGLE"
    ### ls -al $MAINDIR/fanboy-vietnam.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt $MAINDIR/fanboy-vietnam.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u  $MAINDIR/fanboy-vietnam.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-vietnam.txt.gz $MAINDIR/fanboy-vietnam.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-vietnam.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-vtn.sh
else
   echo "Files are the same: fanboy-vietnam.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/fanboy-vietnam.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-vietnam.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-vtn.txt
fi

# CHINESE
# Hash googlecode (SSLGOOGLE) and fanboy.co.nz (SSLMAIN), then compare the two.
#
SSLGOOGLE=$($OPENSSL $ENCRYPT $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt)
SSLMAIN=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-chinese.txt)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-chinese.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-chinese.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt

if [ "$SSLGOOGLE" = "$SSLMAIN" ]
then
    # Log
    echo "Replacing: fanboy-chinese on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
    ## DEBUG
    ### echo "Updated: fanboy-chinese.txt"
    ### echo "SSLMAIN: $MAINDIR/fanboy-chinese.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt $SSLGOOGLE"
    ### ls -al $MAINDIR/fanboy-chinese.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt $MAINDIR/fanboy-chinese.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u  $MAINDIR/fanboy-chinese.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-chinese.txt.gz $MAINDIR/fanboy-chinese.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-chinese.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-chn.sh
else
   echo "Files are the same: fanboy-chinese.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "SSLMAIN: $MAINDIR/fanboy-chinese.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-chinese.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-chn.txt
fi

# ESPANOL
# Hash googlecode (SSLGOOGLE) and fanboy.co.nz (SSLMAIN), then compare the two.
#
SSLGOOGLE=$($OPENSSL $ENCRYPT $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt)
SSLMAIN=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-espanol.txt)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-espanol.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-espanol.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt

if [ "$SSLGOOGLE" = "$SSLMAIN" ]
then
    # Log
    echo "Replacing: fanboy-espanol on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
    ## DEBUG
    ### echo "Updated: fanboy-espanol.txt"
    ### echo "SSLMAIN: $MAINDIR/fanboy-espanol.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt $SSLGOOGLE"
    ### ls -al $MAINDIR/fanboy-espanol.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt $MAINDIR/fanboy-espanol.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u  $MAINDIR/fanboy-espanol.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-espanol.txt.gz $MAINDIR/fanboy-espanol.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-espanol.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
		# Generate IE script
		$GOOGLEDIR/scripts/ie/espanol-ie-generator.sh
		# Combine
		$GOOGLEDIR/scripts/combine/firefox-adblock-esp.sh
else
   echo "Files are the same: fanboy-espanol.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "Not updated: fanboy-espanol.txt"
   ### echo "SSLMAIN: $MAINDIR/fanboy-espanol.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt $SSLGOOGLE"
   ### ls -al $MAINDIR/fanboy-espanol.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-esp.txt
fi

# SWEDISH
# Hash googlecode (SSLGOOGLE) and fanboy.co.nz (SSLMAIN), then compare the two.
#
SSLGOOGLE=$($OPENSSL $ENCRYPT $GOOGLEDIR/firefox-regional/fanboy-adblocklist-swe.txt)
SSLMAIN=$($OPENSSL $ENCRYPT $MAINDIR/fanboy-swedish.txt)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/fanboy-swedish.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-swe.txt $SSLGOOGLE"
### ls -al $MAINDIR/fanboy-swedish.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-swe.txt

if [ "$SSLGOOGLE" = "$SSLMAIN" ]
then
    ## DEBUG
    ### echo "Updated: fanboy-swedish.txt"
    ### echo "SSLMAIN: $MAINDIR/fanboy-swedish.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-swe.txt $SSLGOOGLE"
    ### ls -al $MAINDIR/fanboy-swedish.txt $GOOGLEDIR/firefox-regional/fanboy-adblocklist-swe.txt
    # Log
    echo "Replacing: fanboy-swedish on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
    cp -f $GOOGLEDIR/firefox-regional/fanboy-adblocklist-swe.txt $MAINDIR/fanboy-swedish.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u  $MAINDIR/fanboy-swedish.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/fanboy-swedish.txt.gz $MAINDIR/fanboy-swedish.txt > /dev/null
    # Create a log
    FILE="$MAINDIR/fanboy-swedish.txt"
    echo $ECHORESPONSE >> $LOGFILE
    # Combine Regional trackers
    $GOOGLEDIR/scripts/combine/firefox-adblock-intl-tracking.sh
    # Combine
    $GOOGLEDIR/scripts/combine/firefox-adblock-swe.sh
else
   echo "Files are the same: fanboy-swedish.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "Not updated: fanboy-swedish.txt"
   ### echo "SSLMAIN: $MAINDIR/fanboy-swedish.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/firefox-regional/fanboy-adblocklist-swe.txt $SSLGOOGLE"
   ### ls -al $GOOGLEDIR/other/adblock-gannett.txt $MAINDIR/adblock-gannett.txt
fi

# Gannett
# Hash googlecode (SSLGOOGLE) and fanboy.co.nz (SSLMAIN), then compare the two.
#
SSLGOOGLE=$($OPENSSL $ENCRYPT $GOOGLEDIR/other/adblock-gannett.txt)
SSLMAIN=$($OPENSSL $ENCRYPT $MAINDIR/adblock-gannett.txt)
## DEBUG
### echo "Before Loop"
### echo "SSLMAIN: $MAINDIR/adblock-gannett.txt $SSLMAIN"
### echo "SSLGOOGLE: $GOOGLEDIR/other/adblock-gannett.txt $SSLGOOGLE"
### ls -al $GOOGLEDIR/other/adblock-gannett.txt $MAINDIR/adblock-gannett.txt

if [ "$SSLGOOGLE" = "$SSLMAIN" ]
then
    ## DEBUG
    ### echo "Updated: fanboy-gannett.txt"
    ### echo "SSLMAIN: $MAINDIR/adblock-gannett.txt $SSLMAIN"
    ### echo "SSLGOOGLE: $GOOGLEDIR/other/adblock-gannett.txt $SSLGOOGLE"
    ### ls -al $GOOGLEDIR/other/adblock-gannett.txt $MAINDIR/adblock-gannett.txt
    # Log
    echo "Replacing: fanboy-gannett on `date +'%Y-%m-%d %H:%M:%S'`" >> /var/log/adblock-log.txt
    cp -f $GOOGLEDIR/other/adblock-gannett.txt $MAINDIR/adblock-gannett.txt
    # Properly wipe old file.
    $SHRED -n 3 -z -u $MAINDIR/adblock-gannett.txt.gz
    $ZIP a -mx=9 -y -tgzip $MAINDIR/adblock-gannett.txt.gz $MAINDIR/adblock-gannett.txt > /dev/null
else
   echo "Files are the same: adblock-gannett.txt" > /dev/null
   ## DEBUG
   ### echo Not Processed
   ### echo "Not updated: fanboy-gannett.txt"
   ### echo "SSLMAIN: $MAINDIR/adblock-gannett.txt $SSLMAIN"
   ### echo "SSLGOOGLE: $GOOGLEDIR/other/adblock-gannett.txt $SSLGOOGLE"
   ### ls -al $GOOGLEDIR/other/adblock-gannett.txt $MAINDIR/adblock-gannett.txt
fi

