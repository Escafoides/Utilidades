#!/bin/bash

# $1 = destinatario
# $2 = remitente
# $3 = Asunto
# $4 = Cuerpo del mensaje
# $5 = adjunto


from=$2
to=$1
subject=$3
boundary="ZZ_/afg6432dfgkl.94531q"
body=$4
declare -a attachments

#Recorremos cada uno de los ficheros pasados en el parametro 5
for paramFile in $5
do
   attachments+=($paramFile)
done

# Build headers
{

printf '%s\n' "From: $from
To: $to
Subject: $subject
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=\"$boundary\"

--${boundary}
Content-Type: text/plain; charset=\"US-ASCII\"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Content-Type: text/html
"
if [ -s $body ]
then
	while read p; do
	  echo $p
	done <$body
else 
	echo $body
fi

for file in "${attachments[@]}"; do
  [ ! -f "$file" ] && echo "Warning: attachment $file not found, skipping" >&2 && continue

  mimetype=`file --mime-type -b $file`
  if [ "$mimetype" == "message/rfc822" ]; then
	mimetype="text/plain"
  fi
  printf '%s\n' "--${boundary}
Content-Type: $mimetype
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=\"$file\"
"

  base64 "$file"
  echo
done

# print last boundary with closing --
printf '%s\n' "--${boundary}--"

} | sendmail -t -oi
