#!/bin/bash
# https://wiki.ith.intel.com/pages/viewpage.action?pageId=2544209826

wget  http://certificates.intel.com/repository/certificates/Intel%20Root%20Certificate%20Chain%20Base64.zip
wget  http://certs.intel.com/crt/IntelSHA2RootChain-Base64.zip

mkdir -p  /usr/local/share/ca-certificates
unzip ~/"Intel Root Certificate Chain Base64.zip" -d /usr/local/share/ca-certificates
unzip ~/"IntelSHA2RootChain-Base64.zip" -d /usr/local/share/ca-certificates

update-ca-certificates
c_rehash

wget -4 -e use_proxy=no   https://isscorp.intel.com/IntelSM_BigFix/21074/All_BigFix_Client_Installers/Non_Windows/bigfix_non_windows-BESClient_Labs_Prod-TLS.sh

chmod 744 bigfix_non_windows-BESClient_Labs_Prod-TLS.sh
./bigfix_non_windows-BESClient_Labs_Prod-TLS.sh

sleep 5

grep -i regist /var/opt/BESClient/__BESData/__Global/Logs/`date +%Y%m%d`.log

