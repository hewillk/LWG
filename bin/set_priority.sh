#!/bin/bash
# Set the <priority> of an issue, for use after reflector prioritization polls.

if [[ $1 == --help ]]
then
cat <<EOT
Usage: $0 ISSUE PRIORITY
    ISSUE    - the number of the issue to change.
    PRIORITY - a single digit from 1 to 4.
Set priority of ISSUE to PRIORITY and add a <note>.

Usage: $0 ISSUE 0 [VOTES [--commit]]
    ISSUE    - the number of the issue to change.
    VOTES    - number of P0 votes to record in the <note> (default: five).
When PRIORITY is 0 change the <status> to Tentatively Ready instead.
If --commit is given, do 'git commit' as well.
EOT
  exit
fi

issue=${1:?}
priority=${2:?}
votes=${3:-five}
do_commit=$([[ $4 == --commit ]] && echo yes)
date=$(date +%Y-%m-%d)

xml=xml/issue$issue.xml

die()
{
  echo "Issue $issue: $*" >&2
  exit 1
}

grep -q -E '^<issue .* status="(New|Open)"' $xml || die "Status not New or Open"

if [[ $priority = 0 ]]
then

  sed -i -e '/^<issue /s/ status=".*">$/ status="Tentatively Ready">/' \
         -e '/<\/discussion>$/i\
\
<note>'$date'; Reflector poll</note>\
<p>\
Set status to Tentatively Ready after '$votes' votes in favour during reflector poll.\
</p>\
' $xml

  if [[ $do_commit == yes ]]
  then
    git commit -m "Set $issue to Tentatively Ready" $xml
  fi
else

  grep -q '<priority>99</priority>' $xml || die "Priority already set"

  sed -i -e '/^<priority>99</s/<priority>99</<priority>'$priority'</' \
         -e '/<\/discussion>$/i\
\
<note>'$date'; Reflector poll</note>\
<p>\
Set priority to '$priority' after reflector poll.\
</p>\
' $xml

fi
