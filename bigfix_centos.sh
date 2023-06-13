#!/usr/bin/env bash
#Jose Julian Marchena Segura
#
# Usage:
#   ./bigfix_non_windows-BESClient_Labs_Prod-TLS.sh
#
# BigFix Agent v10.0.4
#

SERVICE="BESClient"
BESROOT="BES-LABS"

IS_CENT9=""
CHECK_INITSCRIPT=""
IS_CENT9=$(cat /etc/redhat-release  | grep "CentOS Stream release 9")

if [[ -z "$IS_CENT9" ]]; then
  echo "It's not CentOS 9"
else
  echo "It's CentOS9"
  CHECK_INITSCRIPT=$(rpm -qa | grep initscripts)
  [[ -z ""$CHECK_INITSCRIPT ]] && {
    yum install -y initscripts.x86_64
  }
  echo "It's done: yum install -y initscripts.x86_64"
fi

if [[ -f /etc/opt/BESClient/actionsite.afxm ]]; then
   BESMAST=`grep -i $BESROOT /etc/opt/BESClient/actionsite.afxm`
fi

#Check if BES Client is already installed and running
is_besinstalled () {
   if [[ -f /etc/init.d/besclient ]]; then
      if [[ $BESMAST && $BESVER != "" && $BESVER == $URLVERSION && $(ps --no-headers -C $SERVICE) ]]; then
         printf "\t$SERVICE is already installed for Labs, at current version, and running\n\nExiting...\n\n"
         exit 1
      elif [[ $BESMAST && $BESVER != "" && $BESVER == $URLVERSION && ! $(ps --no-headers -C $SERVICE) ]]; then
         /etc/init.d/besclient restart > /dev/null 2>&1
         sleep 5
         if [[ $(ps --no-headers -C $SERVICE) ]]; then
            printf "\t$SERVICE is already installed for Labs, at current version, and running\n\nExiting...\n\n"
            exit 1
         fi
      fi
   fi
}

# FUNCTION: check if command exists
#
command_exists () {
  type "$1" &> /dev/null ;
}

clean_up () {
   if [[ -d /opt/BESClient ]]; then
      rm -fr /opt/BESClient
   fi
   if [[ -d /var/opt/BESClient ]]; then
      rm -fr /var/opt/BESClient
   fi
   if [[ -d /var/opt/BESCommon ]]; then
      rm -fr /var/opt/BESCommon
   fi
}

fw_rule () {
   if [[ $LNXDISTRO == Debian || $LNXDISTRO == Ubuntu ]]; then
      if [[ ! $(ufw status verbose |grep "63422/udp" |grep ALLOW) ]]; then
	 printf "\n******************************************************************************************************\n* There is no UDP rule for BESClient.                                                                *\n* The UDP rule is not required but will improve responsiveness of the agent you have just installed. *\n* This rule will allow UDP notifications from BigFix to reach the agent.                             *\n*                                                                                                    *\n* Note! Added UDP (port 63422) rule for the BigFix agent.                                            *\n*                                                                                                    *\n* The UDP rule for the BigFix agent can be removed with 'ufw delete <number>'                        *\n*                                                                                                    *\n*\tWhere the rule for UDP port 63422 is listed with 'ufw status numbered'                       *\n*                                                                                                    *\n******************************************************************************************************\n\n"
         ufw allow 63422/udp
      fi
   elif [[ $LNXDISTRO == Rhel && `type firewall-cmd &> /dev/null` ]]; then
      if [[ ! $(firewall-cmd --list-ports |grep "63422/udp") ]]; then
	 printf "\n******************************************************************************************************\n* There is no UDP rule for BESClient.                                                                *\n* The UDP rule is not required but will improve responsiveness of the agent you have just installed. *\n* This rule will allow UDP notifications from BigFix to reach the agent.                             *\n*                                                                                                    *\n* Note! Added UDP (port 63422) rule for the BigFix agent.                                            *\n*                                                                                                    *\n* The UDP rule for the BigFix agent can be removed with 'firewall-cmd --delete-port=63422/udp'       *\n*                                                                                                    *\n******************************************************************************************************\n\n"
         firewall-cmd --add-port=63422/udp
      fi
   elif [[ $LNXDISTRO == Suse ]]; then
      if [[ $(grep 15-SP /etc/os-release) ]]; then
         if [[ ! $(firewall-cmd --list-ports |grep "63422/udp") ]]; then
            printf "\n******************************************************************************************************\n* There is no UDP rule for BESClient.                                                                *\n* The UDP rule is not required but will improve responsiveness of the agent you have just installed. *\n* This rule will allow UDP notifications from BigFix to reach the agent.                             *\n*                                                                                                    *\n* Note! Added UDP (port 63422) rule for the BigFix agent.                                            *\n*                                                                                                    *\n* The UDP rule for the BigFix agent can be removed with 'firewall-cmd --delete-port=63422/udp'       *\n*                                                                                                    *\n******************************************************************************************************\n\n"
            firewall-cmd --add-port=63422/udp
         fi
      elif [[ $(grep 12-SP /etc/os-release) ]]; then
         if [[ ! $(grep "63422" /etc/sysconfig/SuSEfirewall2) ]]; then
            printf "\nThere is no UDP rule for BESClient.\n\nThe UDP rule is not required but will improve responsiveness of the agent you have just installed.\nThis rule will allow UDP notifications from BigFix to reach the agent.\n\nPlease consider adding a custom firewall rule to allow in UDP packets to port 63422\n\n"
         fi
      fi
   fi
}

is_lnxdistro () {
  if [[ "$1" == "red" ]]; then
    return 0
  fi
  grep -i "$1" /proc/version &> /dev/null ;
}

is_besrunning () {
   if [[ ! $(ps --no-headers -C BESClient) ]]; then
      printf "\nFATAL: BESClient process is not running after upgrade!!!\n\n"
      exit 1
   fi
}

printf "\nBegin BigFix Agent installation... \n\n"

MASTHEADURL="https://isscorp.intel.com/IntelSM_BigFix/21074/All_BigFix_Client_Installers/Labs_Prod/masthead.afxm"

if [ -n "$1" ]; then
  RELAYFQDN=$1
else
  RELAYFQDN="BES-LABS.INTEL.COM"
fi

# these variables are used to determine which version of the BigFix agent should be downloaded
URLVERSION=10.0.4.32
URLMAJORMINOR=`echo $URLVERSION | awk '/./ {gsub(/\./, " "); print $1 $2}'`

# check for x32bit or x64bit OS
MACHINETYPE=`uname -m`

# set OS_BIT variable based upon MACHINE_TYPE (this currently assumes either Intel 32bit or AMD 64bit)
# if machine_type does not contain 64 then 32bit else 64bit (assume 64 unless otherwise noted)
if [[ $MACHINETYPE != *"64"* ]]; then
  OSBIT=x32
else
  OSBIT=x64
  # KNOWN ISSUE: this will incorrectly assume AMD64 compatible processor in the case of PowerPC64
fi

#Check *nix distro
if is_lnxdistro debian && command_exists dpkg; then
   LNXDISTRO=Debian
   BESVER=`dpkg -s besagent 2>/dev/null |grep Version |awk '{print $2}'`
elif is_lnxdistro ubuntu && command_exists dpkg; then
   LNXDISTRO=Ubuntu
   BESVER=`dpkg -s besagent 2>/dev/null |grep Version |awk '{print $2}'`
elif is_lnxdistro red && command_exists rpm; then
   LNXDISTRO=Rhel
   BESVER=`rpm -qi BESAgent 2>/dev/null |grep Version |awk '{print $3}'`
elif is_lnxdistro suse && command_exists rpm; then
   LNXDISTRO=Suse
   BESVER=`rpm -qi BESAgent 2>/dev/null |grep Version |awk '{print $3}'`
fi

printf "Check if BESClient v$URLVERSION is already installed for Labs, and running\n\n"
is_besinstalled

if [[ -f /etc/init.d/besclient && -f /etc/opt/BESClient/actionsite.afxm && -z $BESMAST && ! -z $BESVER ]]; then
   printf "\nNOTE:\tBESAgent is installed with non-Labs masthead!!!\n\n"
   printf "\tUninstall the existing BESAgent and reinstall for Labs\n\n"
   /etc/init.d/besclient stop >/dev/null
   if [[ $LNXDISTRO == Debian || $LNXDISTRO == Ubuntu ]]; then
      if [[ `dpkg -s labsbesinst >/dev/null 2>&1` ]]; then
         dpkg -P labsbesinst >/dev/null 2>&1
      fi
      dpkg -P besagent >/dev/null 2>&1
   elif [[ $LNXDISTRO == Rhel || $LNXDISTRO == SuSE ]]; then
      rpm -e BESAgent >/dev/null 2>&1
   fi
   rm -f /etc/opt/BESClient/actionsite.afxm 2>/dev/null
   unset BESVER
fi

function version_lt() { test "$(echo "$@" | tr " " "n" | sort -rV | head -n 1)" != "$1"; }
if version_lt $BESVER $URLVERSION; then
   if [[ -f /etc/opt/BESClient/actionsite.afxm && ! -z $BESMAST ]]; then
      BESUPG=Y
   fi
fi

############################################################9
# TODO: add more linux cases, not all are handled

# set INSTALLDIR for OS X - other OS options will change this variable
#   This will also be used to create the default clientsettings.cfg file
TMPDIR="/tmp"

# if clientsettings.cfg exists in CWD copy it
if [ -f clientsettings.cfg ] && [ ! -f $TMPDIR/clientsettings.cfg ] ; then
  cp clientsettings.cfg $TMPDIR/clientsettings.cfg
fi

if [ ! -f $TMPDIR/clientsettings.cfg ] ; then
  # create clientsettings.cfg file
  printf "__RelayServer1=http://$RELAYFQDN:63422/bfmirror/downloads/\n" > $TMPDIR/clientsettings.cfg
  printf "__RelayServer2=http://$RELAYFQDN:63422/bfmirror/downloads/\n" >> $TMPDIR/clientsettings.cfg
  printf "__RelaySelect_Automatic=0" >> $TMPDIR/clientsettings.cfg
  printf "\tRelay configured for Labs environment: $RELAYFQDN\n\n"
fi

if [[ $OSTYPE == darwin* ]]; then
  # Mac OS X
  INSTALLERURL="https://software.bigfix.com/download/bes/$URLMAJORMINOR/BESAgent-$URLVERSION-BigFix_MacOSX10.7.pkg"
  INSTALLER="/tmp/BESAgent.pkg"
else
  # For most Linux:
  ETCDIR="/etc/opt/BESClient"
fi

# if Debian
if is_lnxdistro debian && command_exists dpkg; then
   if [[ $OSBIT == x64 ]]; then
      URLBITS=amd64
   else
      URLBITS=i386
	  URLVERSION=9.5.14.73 #GBL - lastest client version for Ubuntu 12/14/16 32-bit, and Debian 7/8/9 32-bit
   fi
   INSTALLER="BESAgent.deb"
   INSTALLERURL="https://isscorp.intel.com/IntelSM_BIgFix/21074/All_BigFix_Client_Installers/Non_Windows/Debian/BESAgent-$URLVERSION-debian6.$URLBITS.deb"
fi

# if Ubuntu
if is_lnxdistro ubuntu && command_exists dpkg; then
   if [[ $OSBIT == x64 ]]; then
      URLBITS=amd64
   else
      URLBITS=i386
	  URLVERSION=9.5.14.73 #GBL - lastest client version for Ubuntu 12/14/16 32-bit, and Debian 7/8/9 32-bit
   fi
   INSTALLER="BESAgent.deb"
   INSTALLERURL="https://isscorp.intel.com/IntelSM_BIgFix/21074/All_BigFix_Client_Installers/Non_Windows/Ubuntu/BESAgent-$URLVERSION-ubuntu10.$URLBITS.deb"
fi # END_IF Debian (dpkg)

# if Red Hat or CentOS or OEL or Amazon Linux
if is_lnxdistro red && command_exists rpm; then
   if [[ $OSBIT == x64 ]]; then
      URLBITS=x86_64
   else
      URLBITS=i686
      URLVERSION=9.5.14.73 #GBL - lastest client version for RHEL5 32-bit, and RHEL6 32-bit
   fi
   INSTALLER="BESAgent.rpm"
   INSTALLERURL="https://isscorp.intel.com/IntelSM_BIgFix/21074/All_BigFix_Client_Installers/Non_Windows/RHEL_OEL_CentOS_Amazon/BESAgent-$URLVERSION-rhe6.$URLBITS.rpm"
fi

# if SuSE
if is_lnxdistro suse && command_exists rpm; then
   if [[ $OSBIT == x64 ]]; then
      URLBITS=x86_64
   else
      URLBITS=i386
      URLVERSION=9.5.14.73 #GBL - lastest client version for SLES11 32-bit
   fi
   INSTALLER="BESAgent.rpm"
   INSTALLERURL="https://isscorp.intel.com/IntelSM_BIgFix/21074/All_BigFix_Client_Installers/Non_Windows/SLES/BESAgent-$URLVERSION-sle11.$URLBITS.rpm"
fi
############################################################


# MUST HAVE ROOT PRIV
if [ "$(id -u)" != "0" ]; then
  # dump out data for debugging
  echo
  echo OSTYPE=$OSTYPE
  echo MACHINETYPE=$MACHINETYPE
  echo OSBIT=$OSBIT
  echo TMPDIR=$TMPDIR
  echo ETCDIR=$ETCDIR
  echo INSTALLER=$INSTALLER
  echo INSTALLERURL=$INSTALLERURL
  echo URLBITS=$URLBITS
  echo URLVERSION=$URLVERSION
  echo URLMAJORMINOR=$URLMAJORMINOR
  echo MASTHEADURL=$MASTHEADURL
  echo DEBDIST=$DEBDIST
  echo
  echo "Sorry, you are not root. Exiting."
  echo
  exit 1
fi

############################################################
###    Start execution:    #################################
############################################################

# Create $ETCDIR folder if missing
if [ ! -d "$ETCDIR" ]; then
  # Control will enter here if $ETCDIR doesn't exist.
  mkdir -p $ETCDIR
fi

#### Downloads #############################################
printf "Downloading packages... \n\n"
DLEXITCODE=0
if command_exists wget ; then
    # this is run if curl doesn't exist, but wget does
    # download using wget
    wget $MASTHEADURL -O $ETCDIR/actionsite.afxm -4 -e use_proxy=no --no-check-certificate
    DLEXITCODE=$(( DLEXITCODE + $? ))

    wget $INSTALLERURL -O $INSTALLER -4 -e use_proxy=no --no-check-certificate
    DLEXITCODE=$(( DLEXITCODE + $? ))
elif command_exists curl ; then
  # Download the BigFix agent (using cURL because it is on most Linux & OS X by default)
  curl --noproxy "*" -4 -k -o $INSTALLER $INSTALLERURL
  DLEXITCODE=$(( DLEXITCODE + $? ))

  # Download the masthead, renamed, into the correct location
  curl --noproxy "*" -4 -k -o $ETCDIR/actionsite.afxm $MASTHEADURL
  DLEXITCODE=$(( DLEXITCODE + $? ))
else
  echo neither wget nor curl is installed.
  echo not able to download required files.
  echo exiting...
  exit 2
fi

# Exit if download failed
if [ $DLEXITCODE -ne 0 ]; then
  (>&2 echo Download Failed. ExitCode=$DLEXITCODE)
  exit $DLEXITCODE
fi

# install BigFix client
echo "Installing BigFix Client"
if [[ $INSTALLER == *.deb ]]; then
   #  debian (DEB) --- Added in Upgrade GBL
   if [[ $BESUPG == Y && $BESVER != $URLVERSION ]]; then
      printf "Version currently installed... $BESVER\n"
      printf "Updating BESAgent to $URLVERSION\n"
      /etc/init.d/besclient stop >/dev/null 2>&1
      #dpkg -r besagent >/dev/null 2>&1
      dpkg -i $INSTALLER >/dev/null 2>/dev/null
      /etc/init.d/besclient start >/dev/null 2>&1
      # pause 5 seconds to wait for bigfix to get going a bit
      sleep 5
      is_besrunning
      printf "\nBESAgent upgrade is complete...\n\n"
      fw_rule
      exit 0
   fi
   # Clean up in case of removed Agent and install
   if [[ $BESVER == "" ]]; then
      clean_up
      dpkg -i $INSTALLER >/dev/null 2>/dev/null
   fi
fi
if [[ $INSTALLER == *.pkg ]]; then
   # PKG type
   #   Could be Mac OS X, Solaris, or AIX
   if command_exists installer ; then
      #  Mac OS X
      installer -pkg $INSTALLER -target /
   elif command_exists pkgadd ; then
      # TODO: test case for Solaris
      pkgadd -d $INSTALLER
   fi # installer
fi # *.pkg install file
if [[ $INSTALLER == *.rpm ]]; then
   #  linux (RPM) --- Added in upgrade GBL
   if [[ $BESUPG == Y && $BESVER != $URLVERSION ]]; then
      printf "Version currently installed... $BESVER\n"
      printf "Updating BESAgent to $URLVERSION\n"
      /etc/init.d/besclient stop >/dev/null 2>&1
      rpm -U $INSTALLER >/dev/null 2>&1
      /etc/init.d/besclient start >/dev/null 2>&1
      # pause 5 seconds to wait for bigfix to get going a bit
      sleep 5
      is_besrunning
      printf "\nBESAgent upgrade is complete...\n\n"
      fw_rule
      exit 0
   fi
   # Clean up in case of removed Agent and install
   if [[ $BESVER == "" ]]; then
      clean_up
      rpm -i $INSTALLER >/dev/null 2>&1
      systemctl daemon-reload >/dev/null 2>&1
   fi
fi

### start the BigFix client (required for most linux dist)
# if file /etc/init.d/besclient exists
if [[ -f /etc/init.d/besclient ]]; then
   #if missing, create besclient.config file based upon /tmp/clientsettings.cfg
   if [ ! -f /var/opt/BESClient/besclient.config ]; then
      cat /tmp/clientsettings.cfg | awk 'BEGIN { print "[Software\\BigFix\\EnterpriseClient]"; print "EnterpriseClientFolder = /opt/BESClient"; print; print "[Software\\BigFix\\EnterpriseClient\\GlobalOptions]"; print "StoragePath = /var/opt/BESClient"; print "LibPath = /opt/BESClient/BESLib"; } /=/ {gsub(/=/, " "); print "\n[Software\\BigFix\\EnterpriseClient\\Settings\\Client\\" $1 "]\neffective date = \nvalue = " $2;}' | sed "s/effective\ date\ =\ /effective\ date\ =\ $(date +'%a, %d %b %Y %T %z')/" > /var/opt/BESClient/besclient.config
      chmod 600 /var/opt/BESClient/besclient.config
   fi

   # Do not start bigfix if: StartBigFix=false
   if [ "$StartBigFix" != "false" ]; then
      /etc/init.d/besclient start
   fi
fi
# pause 5 seconds to wait for bigfix to get going a bit
sleep 5
#Verify that BES Client process is running - GBL
is_besrunning

#Logs for support
if [ -f "/var/opt/BESClient/__BESData/__Global/Logs/`date +%Y%m%d`.log" ]; then
  tail --lines=30 --verbose "/var/opt/BESClient/__BESData/__Global/Logs/`date +%Y%m%d`.log"
fi
echo ""
echo Succesfully Installed BES Agent
rm -f /tmp/clientsettings.cfg
echo ""
echo "Saving Linux Client Settings to /var/opt/BESClient/Intel/AdminGroup"
if [ ! -d /var/opt/BESClient/Intel ]; then
   mkdir -p /var/opt/BESClient/Intel
fi
propFile=/var/opt/BESClient/Intel/AdminGroup
inputFile=config.txt
if [[ ! -f $inputFile || $inputFile == "" ]]; then
   echo ""
   read -p "First prompt for input file: example /tmp/config.txt >" inputFile
fi
if [[ ! -f $inputFile || $inputFile == "" ]]; then
   echo ""
   read -p "Last prompt for input file: example /tmp/config.txt >" inputFile
fi
if [[ ! -f $inputFile || $inputFile == "" ]]; then
   printf "\nNo input properties to process\n\n"
   echo "Division: EC" > $propFile
   echo "Group: IT" >> $propFile
   echo "PrimaryPatchContact: scax" >> $propFile
   echo "PnNSchedule: monthly" >> $propFile
   printf "Linux Client Settings processing complete\n"
   printf "Exiting Installer...\n\n"
else
   sed -i 's/\"//g' $inputFile
   sed -i 's/\,/ /g' $inputFile
   sed -i 's/\n//g' $inputFile
   sed -i 's/\r//g' $inputFile
   cp $inputFile $propFile
   if [[ ! `grep ^Division $propFile` ]]; then
      echo "Division:EC" >> $propFile
   fi
   if [[ ! `grep ^Group $propFile` ]]; then
      echo "Group:IT" >> $propFile
   fi
   printf "\nLinux Client Settings processing complete\n\n"
   printf "Exiting Installer...\n\n"
fi
fw_rule
