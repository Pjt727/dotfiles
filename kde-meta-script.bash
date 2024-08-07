#!/usr/bin/env bash

kdialog --yesno "Would you like to set KRunner to open with Meta?\nYes enables it, No or closing this window disables it." --title "KRunner as meta"
ISMETA=$?

reconfigureKWin () {
    if [ -x "$(command -v qdbus)" ]
    then
        qdbus org.kde.KWin /KWin reconfigure
    elif [ -x "$(command -v qdbus-qt5)" ]
    then
        qdbus-qt5 org.kde.KWin /KWin reconfigure
    elif [ -x "$(command -v qdbus6)" ]
    then
        qdbus6 org.kde.KWin /KWin reconfigure
    else
        kdialog --error "You don't have any qdbus utility!\nThe changes were written to the configuration file, but were NOT applied automatically.\nIt should work once you log out."
        exit 1
    fi
}

if [ "$ISMETA" == 0 ]
then
    kwriteconfig${KDE_SESSION_VERSION} --file kwinrc --group ModifierOnlyShortcuts --key Meta "org.kde.krunner,/App,,toggleDisplay";
    reconfigureKWin
else
    kwriteconfig${KDE_SESSION_VERSION} --file kwinrc --group ModifierOnlyShortcuts --key Meta --delete;
    reconfigureKWin
fi
