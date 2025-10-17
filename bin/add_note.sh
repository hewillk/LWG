#!/bin/sh
# Add a <note> to an issue

issue=${1:?}

xml=xml/issue$issue.xml

if ! [ -w $xml ]
then
  echo "$0: $xml: No such issue" >&2
  exit 1
fi

prefix=''

case "$2" in
  --prefix=*) prefix="${2:9} " ; shift 1 ;;
  --prefix) prefix="$3 " ; shift 2 ;;
esac

note=${2:?}
if [[ ${note: -1} != . ]]
then
  note="${note}."
fi

text=''
if [ "$3" = "-" ]
then
  echo "Enter additional discussion (followed by EOF, i.e. Ctrl-D)."
  echo "This will be enclosed in <p> after the new <note>."
  while read line
  do
    text="$(printf "%s%s\\\n" "$text" "$line")"
  done
  if [ -n "$text" ]
  then
    text=$(printf "\\\n<p>\\\n%s</p>" "$text")
  fi
fi

date=$(date +%Y-%m-%d)
note=$(printf "<note>%s%s; %s</note>" "$prefix" "$date" "$note")

sed -i "/<\/discussion/i\
${note}${text}
" $xml
