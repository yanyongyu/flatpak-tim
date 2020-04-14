#! /bin/bash
###
# @Author         : yanyongyu
# @Date           : 2020-04-13 15:37:46
# @LastEditors    : yanyongyu
# @LastEditTime   : 2020-04-14 13:45:56
# @Description    : None
# @GitHub         : https://github.com/yanyongyu
###

#!/bin/bash

#   Copyright (C) 2016 Deepin, Inc.
#
#   Author:     Li LongYu <lilongyu@linuxdeepin.com>
#               Peng Hao <penghao@linuxdeepin.com>

BOTTLENAME="Deepin-TIM"
WINEPREFIX="$HOME/.deepinwine/$BOTTLENAME"
APPDIR="/app/data"
APPTAR="files.7z"
APPVER="2.0.0"
EXTDIR="/app/ext"
WINE_CMD="deepin-wine"

_DeleteRegistry() {
    env WINEPREFIX="$WINEPREFIX" $WINE_CMD reg DELETE "$1" /f &>/dev/null
}

HelpApp() {
    echo " Extra Commands:"
    echo " -r/--reset     Reset app to fix errors"
    echo " -e/--remove    Remove deployed app files"
    echo " -h/--help      Show program help info"
}

FixLink() {
    if [ -d ${WINEPREFIX} ]; then
        CUR_DIR=$PWD
        cd "${WINEPREFIX}/dosdevices"
        rm c: z:
        ln -s -f ../drive_c c:
        ln -s -f / z:
        cd $CUR_DIR
        ls -l "${WINEPREFIX}/dosdevices"
    fi
}

CallTIM() {
    export LC_ALL="en_US.UTF-8"
    export GTK_IM_MODULE=ibus
    export QT_IM_MODULE=ibus

    for _dir in $(ls $EXTDIR -F | grep "/$"); do
        if [ -f $EXTDIR/$_dir/script.sh ]; then
            source $EXTDIR/$_dir/script.sh
        fi
    done

    if [ ! -f "$WINEPREFIX/../.QQ_run" ]; then
        echo "First run time"
        # /usr/share/deepin-wine/tools/add_hotkeys
        /usr/share/deepin-wine/tools/fontconfig
        env WINEPREFIX="$WINEPREFIX" $WINE_CMD uninstaller --list
        touch $WINEPREFIX/../.QQ_run
    fi

    #Auto kill block process
    /usr/share/deepin-wine/tools/kill.sh TIM.exe block

    #Support use native file dialog
    export ATTACH_FILE_DIALOG=1

    echo "Start running..."
    env WINEPREFIX="$WINEPREFIX" $WINE_CMD "c:\\Program Files\\Tencent\\TIM\\Bin\\TIM.exe" &

    #disable Tencent MiniBrowser
    _DeleteRegistry "HKCU\\Software\\Tencent\\MiniBrowser"
}

CallApp() {
    FixLink
    echo "CallApp $BOTTLENAME"
    CallTIM
}
ExtractApp() {
    echo "Extract App..."
    mkdir -p "$1"
    7zr x "$APPDIR/$APPTAR" -o"$1"
    mv "$1/drive_c/users/@current_user@" "$1/drive_c/users/$USER"
    sed -i "s#@current_user@#$USER#" $1/*.reg
    cp /usr/share/deepin-wine/wine/fonts/* "$1/drive_c/windows/Fonts"
    echo "Done"
}
DeployApp() {
    ExtractApp "$WINEPREFIX"
    echo "$APPVER" >"$WINEPREFIX/PACKAGE_VERSION"
}
RemoveApp() {
    rm -rf "$WINEPREFIX"
    rm -f "$WINEPREFIX/../.QQ_run"
}
ResetApp() {
    echo "Reset $PACKAGENAME....."
    read -p "*	Are you sure?(Y/N)" ANSWER
    if [ "$ANSWER" = "Y" -o "$ANSWER" = "y" -o -z "$ANSWER" ]; then
        RemoveApp
        DeployApp
        CallApp
    fi
}
UpdateApp() {
    if [ -f "$WINEPREFIX/PACKAGE_VERSION" ] && [ "$(cat "$WINEPREFIX/PACKAGE_VERSION")" = "$APPVER" ]; then
        return
    fi
    if [ -d "${WINEPREFIX}.tmpdir" ]; then
        rm -rf "${WINEPREFIX}.tmpdir"
    fi
    ExtractApp "${WINEPREFIX}.tmpdir"
    /usr/share/deepin-wine/tools/updater -s "${WINEPREFIX}.tmpdir" -c "${WINEPREFIX}" -v
    rm -rf "${WINEPREFIX}.tmpdir"
    echo "$APPVER" >"$WINEPREFIX/PACKAGE_VERSION"
}
RunApp() {
    progpid=$(ps -ef | grep "zenity --progress --title=${BOTTLENAME}" | grep -v grep)
    if [ -n "$progpid" ]; then
        echo "$BOTTLENAME is running. Pid $progpid"
        exit 0
    fi
    if [ -d "$WINEPREFIX" ]; then
        UpdateApp | progressbar "$BOTTLENAME" "更新$BOTTLENAME中..."
    else
        DeployApp | progressbar "$BOTTLENAME" "初始化$BOTTLENAME中..."
    fi
    CallApp
}

CreateBottle() {
    if [ -d "$WINEPREFIX" ]; then
        UpdateApp
    else
        DeployApp
    fi
}

# Check if some visual feedback is possible
if command -v zenity >/dev/null 2>&1; then
    progressbar() {
        WINDOWID="" zenity --progress --title="$1" --text="$2" --pulsate --width=400 --auto-close --no-cancel ||
            WINDOWID="" zenity --progress --title="$1" --text="$2" --pulsate --width=400 --auto-close
    }

else
    progressbar() {
        cat -
    }
fi

if [ -z "$1" ]; then
    echo "Run $BOTTLENAME $APPVER"
    RunApp
    exit 0
fi

case $1 in
"-r" | "--reset")
    ResetApp
    ;;
"-c" | "--create")
    CreateBottle
    ;;
"-e" | "--remove")
    RemoveApp
    ;;
"-h" | "--help")
    HelpApp
    ;;
*)
    echo "Invalid option: $1"
    echo "Use -h|--help to get help"
    exit 1
    ;;
esac

exit 0
