#!/bin/bash
PROJECTNAME="GB2Twitter"
BGB="/home/dan/Documents/GBDev/Emu/bgb.exe" #RUN WITH WINE

rgbasm -o ${PROJECTNAME}.obj main.asm
if [[$? -ne 0]]
then
  exit 1
fi
rgblink -o ${PROJECTNAME}.gb ${PROJECTNAME}.obj
if [[$? -ne 0]]
then
  exit 1
fi
rgbfix -p0 -v ${PROJECTNAME}.gb
if [[$? -ne 0]]
then
    exit 1
fi
rm LinkTest.obj
echo "Assembly success!"
wine ${BGB} ${PROJECTNAME}.gb
