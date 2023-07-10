#!/bin/bash

EMAIL_FILE=$1
FROM_FORMAT="From: "
TO_FORMAT="To: "
EMAIL_FROM=""
EMAIL_TO=""
RESULT=""

EMAIL_FROM=$(grep "$FROM_FORMAT"  "$EMAIL_FILE" | awk -F "$FROM_FORMAT" '{print $2}' | head -n 1)
EMAIL_TO=$(grep "$TO_FORMAT"  "$EMAIL_FILE" | awk -F "$TO_FORMAT" '{print $2}' | head -n 1)

echo "Will send email file:$EMAIL_FILE from $EMAIL_FROM to $EMAIL_TO"

echo "git send-email --confirm=never --no-signed-off-by-cc --suppress-cc=all --no-chain-reply-to --transfer-encoding=quoted-printable --from=$EMAIL_FROM --to=$EMAIL_TO --smtp-server=smtp.intel.com --smtp-server-port=25 $EMAIL_FILE"
git send-email \
  --confirm=never \
  --no-signed-off-by-cc \
  --suppress-cc=all \
  --no-chain-reply-to \
  --transfer-encoding=quoted-printable \
  --from="$EMAIL_FROM"  \
  --to="$EMAIL_TO" \
  --smtp-server="smtp.intel.com"  \
  --smtp-server-port=25 \
  "$EMAIL_FILE"
# git send-email	-q \
#   --confirm=never \
#   --no-signed-off-by-cc \
#   --suppress-cc=all \
#   --no-chain-reply-to \
#   --to="Pengfei Xu <pengfei.xu@intel.com>" \
#   $EMAIL_FILE
RESULT=$?

if [[ "$RESULT" -eq 0 ]]; then
  echo "Send email from $EMAIL_FROM to $EMAIL_TO with file:$EMAIL_FILE successfully:$RESULT"
else
  echo "Send email from $EMAIL_FROM to $EMAIL_TO with file:$EMAIL_FILE failed:$RESULT"
fi
