#!/bin/bash

FILE=$1
# It's from Idisd token: https://ubit-artifactory-sh.intel.com/ui/repos/tree/General/clkv-infra-sh-local
# Choose Idisd -> Set me up -> Generic -> Generate API Key
PASSWD=""

if [[ "$FILE" == *"gz" ]]; then
  echo "scp $FILE root@haydn.sh.intel.com:/root/Data/DDT/packages/weekly/centos/9/"
  scp "$FILE" root@haydn.sh.intel.com:/root/Data/DDT/packages/weekly/centos/9/
else
  echo "FILE:$FILE is not a gz file, will not upload into haydn.sh.intel.com:/root/Data/DDT/packages/weekly/centos/9/"

fi

  # Remove -O for download
  echo "curl -uxupengfe:$PASSWD -T $FILE https://ubit-artifactory-sh.intel.com/artifactory/clkv-infra-sh-local/builds/weekly/centos/9/$FILE"
  curl -uxupengfe:"$PASSWD" -T "$FILE" "https://ubit-artifactory-sh.intel.com/artifactory/clkv-infra-sh-local/builds/weekly/centos/9/$FILE"
