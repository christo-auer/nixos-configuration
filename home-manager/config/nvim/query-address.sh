#!/usr/bin/env zsh

abook --mutt-query "$@" | grep -v "Not found" | grep -v "Cannot open database" | \
  while read entry; do
    if [ "$entry" != "" ]; then
      name=$(echo ${entry} | cut -f2)
      mail=$(echo ${entry} | cut -f1)
      echo "${name} <${mail}>, "
    fi
  done

ldapsearch \
  -H 'ldap://localhost:1389/'  \
  -D $(pass haw/xmail.mwn.de | tail -n1 | cut -d: -f2) \
  -w $(pass haw/xmail.mwn.de | head -n1) \
  -b "ou=people" "(&(objectClass=person)(|(cn=*$@*)(mail=*$@*)(givenName=*$@*)(sn=*$@*)))" 2> /dev/null | \
  gawk -v RS="\n\n" -v ORS="\n" '{gsub("\n","§",$0); print $0}' | \

while read line; do
  entry=$(echo "$line" | tr '§' '\n')

  mail=$(echo "$entry" | grep -E '^mail: ' | sed 's/mail: //g' )
  name=$(echo "$entry" | grep -E '^cn: ' | sed 's/cn: //g' )

  if [ ! -z "$mail" -a ! -z "$name" ]; then
    echo "${name} <${mail}>, "
  fi
done 
