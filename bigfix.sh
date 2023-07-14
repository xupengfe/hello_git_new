#!/bin/bash

bigfix="bigfix_non_windows-BESClient_Labs_Prod-TLS.sh"
bigfix_exist=""

bigfix_exist=$(ls ${bigfix}* 2>/dev/null)
[[ -z "$bigfix_exist" ]] || {
  echo "rm -rf ${bigfix}*"
  rm -rf ${bigfix}*
}

echo "wget http://xenvgt.sh.intel.com/download/iterp/bigfix_non_windows-BESClient_Labs_Prod-TLS.sh"
wget http://xenvgt.sh.intel.com/download/iterp/bigfix_non_windows-BESClient_Labs_Prod-TLS.sh

echo "wget http://xpf.sh.intel.com/tools/bigfix_centos.sh"
wget http://xpf.sh.intel.com/tools/bigfix_centos.sh

echo "chmod +x bigfix_non_windows-BESClient_Labs_Prod-TLS.sh"
chmod +x bigfix_non_windows-BESClient_Labs_Prod-TLS.sh
chmod +x bigfix_centos.sh
sleep 1

echo "./bigfix_centos.sh"
./bigfix_centos.sh
echo "If not centOS please execute ./bigfix_centos.sh Ubuntu"
