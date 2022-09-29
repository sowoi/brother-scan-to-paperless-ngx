#!/bin/bash
# Developer: Massoud Ahmed
# You need Imagemagick 
# apt install imagemagick
# set policy:
# <policy domain="coder" rights="read | write" pattern="PDF" />
# <policy domain="coder" rights="read|write" pattern="{GIF,JPEG,PNG,WEBP}" />


# create temp Dir
DIR=`mktemp -d`
CUR=$PWD
cd $DIR
# Output directory of scan
OUTPUT="/srv/scanslocal"
FILENAME=scan_"$(date +%Y-%m-%d-%H-%M-%S)".pdf

# get scanner info 
scanner=`scanimage -L | cut -d " " -f 2 | sed 's/\`//'  | sed "s/'//" ` 
scanimage -b --format png  -d "$scanner"  --source "Automatic Document Feeder(center aligned,Duplex"  --resolution 200 --AutoDocumentSize="yes" -v


# check for blanks
echo "$?"
if [ $? -eq 0 ]
   then

COUNTER=0
for f in *.png;
do
    
    if [[ `identify -verbose $f | grep "skewness" | tail -n 1 | cut -d ":" -f 2 | cut -d "." -f 1` -lt -6 ]]; then
        #check if png is blank and remove it
	if [[ $COUNTER -eq 1 ]]; then
	    # save the first page
	    echo "$f will not be removed"
	    continue
        else
   	 echo "$f will be removed"
         rm $f
	fi
    else
        #else keep the png
	echo "$f will not be removed"
        continue
    fi;
    COUNTER=$((COUNTER+1))
	   
	   
done


# reverse order of png and convert to pdf with rotation
filesInFolder=`ls -rv`
echo "$filesInFolder"
convert $filesInFolder -rotate 180 $CUR/$FILENAME

cd $CUR

# move them to scans folder
mv $FILENAME "$OUTPUT"
if [ $? -eq 1 ]; then
   exit 1
fi
echo "$OUTPUT/$FILENAME"
exit 0

else
    exit 1
fi
#EOF
