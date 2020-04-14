#! /bin/bash
###
# @Author         : yanyongyu
# @Date           : 2020-04-13 15:26:13
# @LastEditors    : yanyongyu
# @LastEditTime   : 2020-04-14 13:52:56
# @Description    : None
# @GitHub         : https://github.com/yanyongyu
###

DATATAR="deepin.com.qq.office_2.0.0deepin4_i386.deb"
WINEID="Deepin-TIM"
DESKTOP="deepin.com.qq.office.desktop"
ICON="deepin.com.qq.office.svg"

echo "Installing $DATATAR"

mkdir /app/data
ar x $DATATAR
tar xf data.tar.xz
cp ./opt/deepinwine/apps/$WINEID/files.7z /app/data/

mkdir /app/bin
cp ./run.sh /app/bin/
chmod a+x /app/bin/run.sh

mkdir -p /app/share/applications /app/share/icons
cp ./$DESKTOP /app/share/applications
cp ./usr/share/icons /app/share/ -r

mkdir /app/ext

echo "Done"

exit 0
