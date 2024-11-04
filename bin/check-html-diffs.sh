#!/bin/sh
old=$(mktemp -d ./mailing.old.XXXXXX)
new=$(mktemp -d ./mailing.new.XXXXXX)
echo Building lists at HEAD
make clean
make lists -j4
sed -i 's/Revised ....-..-.. at ..:..:.. UTC/Revised .../' mailing/*.html
mv mailing $new
git checkout ${1-origin/master} -- src
echo Building lists with code from `git rev-parse origin/master`
make clean
make lists -j4
git checkout HEAD -- src
sed -i 's/Revised ....-..-.. at ..:..:.. UTC/Revised .../' mailing/*.html
mv mailing $old
diff -u -r --color=${2:-auto} $old $new || exit
rm -r $old $new
echo No changes to HTML files
