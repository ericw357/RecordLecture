#!/usr/bin/env bash

FILENAME=$(date +"%Y%m%d_%H%M")
LENGTH=10

echo "Press Ctl+C to start recording once level is set"
arecord -D plughw:1 -q -f cd -d 0 -V mono /dev/null
[ $? -eq 0 -o 137 ] || exit $?

#record with sudo since arecord seems to want root privledges
arecord -d $1 -D plughw:1 -f S16_LE -c1 -r44100  /home/pi/record/${FILENAME}.wav
#arecord -d $1 -D plughw:1 -f cd | lame --preset 64 -a - /home/pi/upload/${FILENAME}.mp3
[ $? -eq 0 -o 137 ] || exit $?

#change ownership to pi
sudo chown pi /home/pi/record/${FILENAME}.wav
[ $? -eq 0 ] || exit $?

echo "Record Stopped"

#copy to process directory
echo "Copy file in process"
cp /home/pi/record/${FILENAME}.wav /home/pi/process/${FILENAME}.wav
echo "Copy file complete"

#stereo > mono
#sox /home/pi/process/${FILENAME}.wav -c 1 /home/pi/process/${FILENAME}-mono.wav
#echo "Stereo to Mono complete"

#convert to mp3 (64Kpbs)
echo "MP3 Conversion in process"
lame --preset 64 -a /home/pi/process/${FILENAME}.wav /home/pi/upload/${FILENAME}.mp3
[ $? -eq 0 ] || exit $?
echo "Mp3 Conversion complete"

#remove process files
echo "Removing process files"
rm /home/pi/record/${FILENAME}.wav
rm /home/pi/process/${FILENAME}.wav
#rm /home/pi/process/${FILENAME}-mono.wav
echo "Process files removed"
