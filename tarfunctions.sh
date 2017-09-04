#!/bin/bash
# Title: spm
# Description: Downloads and installs AppImages and precompiled tar archives.  Can also upgrade and remove installed packages.
# Dependencies: GNU coreutils, tar, wget
# Author: simonizor
# Website: http://www.simonizor.gq
# License: GPL v2.0 only

X="0.3.8"
# Set spm version
TAR_LIST="$(echo -e $(grep '"available"' "$CONFDIR"/tar-pkgs.json | cut -f7 -d" " | tr -d ',"'))"

tarfunctionsexistfunc () {
    sleep 0
}

tarsaveconffunc () {
    if [ -z "$NEW_TARFILE" ]; then
        NEW_TARFILE="$TARFILE"
    fi
    SAVEDIR="$1"
    echo "INSTDIR="\"$INSTDIR\""" > "$CONFDIR"/"$SAVEDIR"
    if [ "$TAR_DOWNLOAD_SOURCE" != "LOCAL" ]; then
        echo "TAR_DOWNLOAD_SOURCE="\"$TAR_DOWNLOAD_SOURCE\""" >> "$CONFDIR"/"$SAVEDIR"
        echo "TARURI="\"$TARURI\""" >> "$CONFDIR"/"$SAVEDIR"
        echo "TARFILE="\"$NEW_TARFILE\""" >> "$CONFDIR"/"$SAVEDIR"
    fi
    if [ "$TAR_DOWNLOAD_SOURCE" = "GITHUB" ]; then
        echo "TAR_GITHUB_COMMIT="\"$TAR_GITHUB_NEW_COMMIT\""" >> "$CONFDIR"/"$SAVEDIR"
        echo "TAR_GITHUB_VERSION="\"$TAR_GITHUB_NEW_VERSION\""" >> "$CONFDIR"/"$SAVEDIR"
    fi
    echo "DESKTOP_FILE_PATH="\"$DESKTOP_FILE_PATH\""" >> "$CONFDIR"/"$SAVEDIR"
    echo "ICON_FILE_PATH="\"$ICON_FILE_PATH\""" >> "$CONFDIR"/"$SAVEDIR"
    echo "EXECUTABLE_FILE_PATH="\"$EXECUTABLE_FILE_PATH\""" >> "$CONFDIR"/"$SAVEDIR"
    echo "BIN_PATH="\"$BIN_PATH\""" >> "$CONFDIR"/"$SAVEDIR"
    echo "CONFIG_PATH="\"$CONFIG_PATH\""" >> "$CONFDIR"/"$SAVEDIR"
    echo "TAR_DESCRIPTION="\"$TAR_DESCRIPTION\""" >> "$CONFDIR"/"$SAVEDIR"
    echo "DEPENDENCIES="\"$DEPENDENCIES\""" >> "$CONFDIR"/"$SAVEDIR"
}

targithubinfofunc () {
    if [ -z "$GITHUB_TOKEN" ]; then
        wget --quiet "$TAR_API_URI" -O "$CONFDIR"/cache/"$TARPKG"-release || { echo "wget $TAR_API_URI failed; has the repo been renamed or deleted?"; rm -rf "$CONFDIR"/cache/*; exit 1; }
    else
        wget --quiet --auth-no-challenge --header="Authorization: token "$GITHUB_TOKEN"" "$TAR_API_URI" -O "$CONFDIR"/cache/"$TARPKG"-release || { echo "wget $TAR_API_URI failed; is your token valid?"; rm -rf "$CONFDIR"/cache/*; exit 1; }
    fi
    NEW_TARFILE="$(grep -iv '.*ia32*.\|.*i686*.\|.*i386*.' $CONFDIR/cache/$TARPKG-release | grep -i "$TARPKG" | grep -im 1 '"name":*..*linux*..*.tar.*.' | cut -f4 -d'"')"
    TAR_GITHUB_NEW_COMMIT="$(grep -iv '.*ia32*.\|.*i686*.\|.*i386*.' $CONFDIR/cache/$TARPKG-release  | grep -B 1 -im 1 '"browser_download_url":*..*linux*..*.tar.*.' | cut -f4 -d'"' | head -n 1)"
    TAR_GITHUB_NEW_DOWNLOAD="$(grep -iv '.*ia32*.\|.*i686*.\|.*i386*.' $CONFDIR/cache/$TARPKG-release | grep -i "$TARPKG" | grep -im 1 '"browser_download_url":*..*linux*..*.tar.*.' | cut -f4 -d'"')"
    if [ -z "$NEW_TARFILE" ]; then
        NEW_TARFILE="$(grep -iv '.*ia32*.\|.*i686*.\|.*i386*.' $CONFDIR/cache/$TARPKG-release  | grep -im 1 '"name":*..*linux*..*.tar.*.' | cut -f4 -d'"')"
        TAR_GITHUB_NEW_COMMIT="$(grep -iv '.*ia32*.\|.*i686*.\|.*i386*.' $CONFDIR/cache/$TARPKG-release | grep -B 1 -im 1 '"browser_download_url":*..*linux*..*.tar.*.' | cut -f4 -d'"' | head -n 1)"
        TAR_GITHUB_NEW_DOWNLOAD="$(grep -iv '.*ia32*.\|.*i686*.\|.*i386*.' $CONFDIR/cache/$TARPKG-release | grep -im 1 '"browser_download_url":*..*linux*..*.tar.*."' | cut -f4 -d'"')"
    fi
    if [ -z "$NEW_TARFILE" ]; then
        NEW_TARFILE="$(grep -iv '.*ia32*.\|.*i686*.\|.*i386*.' $CONFDIR/cache/$TARPKG-release | grep -i "$TARPKG" | grep -im 1 '"name":*..*.tar.*.' | cut -f4 -d'"')"
        TAR_GITHUB_NEW_COMMIT="$(grep -iv '.*ia32*.\|.*i686*.\|.*i386*.' $CONFDIR/cache/$TARPKG-release  | grep -B 1 -im 1 '"browser_download_url":*..*.tar.*.' | cut -f4 -d'"' | head -n 1)"
        TAR_GITHUB_NEW_DOWNLOAD="$(grep -iv '.*ia32*.\|.*i686*.\|.*i386*.' $CONFDIR/cache/$TARPKG-release | grep -i "$TARPKG" | grep -im 1 '"browser_download_url":*..*.tar.*.' | cut -f4 -d'"')"
    fi
    if [ -z "$NEW_TARFILE" ]; then
        NEW_TARFILE="$(grep -iv '.*ia32*.\|.*i686*.\|.*i386*.' $CONFDIR/cache/$TARPKG-release | grep -im 1 '"name":*..*.tar.*.' | cut -f4 -d'"')"
        TAR_GITHUB_NEW_COMMIT="$(grep -iv '.*ia32*.\|.*i686*.\|.*i386*.' $CONFDIR/cache/$TARPKG-release | grep -B 1 -im 1 '"browser_download_url":*..*.tar.*.' | cut -f4 -d'"' | head -n 1)"
        TAR_GITHUB_NEW_DOWNLOAD="$(grep -iv '.*ia32*.\|.*i686*.\|.*i386*.' $CONFDIR/cache/$TARPKG-release | grep -im 1 '"browser_download_url":*..*.tar.*.' | cut -f4 -d'"')"
    fi
    TAR_DOWNLOAD_SOURCE="GITHUB"
    TAR_GITHUB_NEW_VERSION="$(echo "$TAR_GITHUB_NEW_DOWNLOAD" | cut -f8 -d"/")"
    tarsaveconffunc "cache/$TARPKG.conf"
    . "$CONFDIR"/cache/"$TARPKG".conf
    if [ -z "$NEW_TARFILE" ]; then
        echo "$(tput setaf 1)Error finding latest tar for $TARPKG!$(tput sgr0)"
        GITHUB_DOWNLOAD_ERROR="TRUE"
    fi
}

tarappcheckfunc () { # check user input against list of known apps here
    echo "$TAR_LIST" | grep -qwm 1 "$1"
    TAR_STATUS="$?"
    if [ "$(echo "$TAR_LIST" | grep -wm 1 "$1")" != "$1" ]; then
        TAR_STATUS="1"
    fi
    case $TAR_STATUS in
        0)
            TARPKG_NAME="$(cat $CONFDIR/tar-pkgs.json | tr '\\' '\n' | grep -iowm 1 "$1" | cut -f2 -d'"')"
            if [ ! -z "$DOWNLOAD_SOURCE" ]; then
                TAR_DOWNLOAD_SOURCE="$DOWNLOAD_SOURCE"
            fi
            KNOWN_TAR="TRUE"
            INSTDIR="$(grep -w -A 11 "\"$TARPKG_NAME\"" "$CONFDIR"/tar-pkgs.json | grep -w '"instdir"' | cut -f4 -d'"')"
            TAR_DOWNLOAD_SOURCE="$(grep -w -A 11 "\"$TARPKG_NAME\"" "$CONFDIR"/tar-pkgs.json | grep -w '"download_source"' | cut -f4 -d'"')"
            TARURI="$(grep -w -A 11 "\"$TARPKG_NAME\"" "$CONFDIR"/tar-pkgs.json | grep -w '"taruri"' | cut -f4 -d'"')"
            TAR_API_URI="$(grep -w -A 11 "\"$TARPKG_NAME\"" "$CONFDIR"/tar-pkgs.json | grep -w '"apiuri"' | cut -f4 -d'"')"
            DESKTOP_FILE_PATH="$(grep -w -A 11 "\"$TARPKG_NAME\"" "$CONFDIR"/tar-pkgs.json | grep -w '"desktop_file_path"' | cut -f4 -d'"')"
            ICON_FILE_PATH="$(grep -w -A 11 "\"$TARPKG_NAME\"" "$CONFDIR"/tar-pkgs.json | grep -w '"icon_file_path"' | cut -f4 -d'"')"
            EXECUTABLE_FILE_PATH="$(grep -w -A 11 "\"$TARPKG_NAME\"" "$CONFDIR"/tar-pkgs.json | grep -w '"executable_file_path"' | cut -f4 -d'"')"
            BIN_PATH="$(grep -w -A 11 "\"$TARPKG_NAME\"" "$CONFDIR"/tar-pkgs.json | grep -w '"bin_path"' | cut -f4 -d'"')"
            CONFIG_PATH="$(grep -w -A 11 "\"$TARPKG_NAME\"" "$CONFDIR"/tar-pkgs.json | grep -w '"config_path"' | cut -f4 -d'"')"
            TAR_DESCRIPTION="$(grep -w -A 11 "\"$TARPKG_NAME\"" "$CONFDIR"/tar-pkgs.json | grep -w '"description"' | cut -f4 -d'"')"
            DEPENDENCIES="$(grep -w -A 11 "\"$TARPKG_NAME\"" "$CONFDIR"/tar-pkgs.json | grep -w '"dependencies"' | cut -f4 -d'"')"
            if [ "$TAR_DOWNLOAD_SOURCE" = "GITHUB" ]; then
                targithubinfofunc
            else
                tarsaveconffunc "cache/$TARPKG_NAME.conf"
            fi
            ;;
        *)
            if [ -f "$CONFDIR"/tarinstalled/$1 ]; then
                . "$CONFDIR"/tarinstalled/$1
            fi
            KNOWN_TAR="FALSE"
            ;;
    esac
}

tarlistfunc () {
    if [ -z "$TARPKG" ]; then
        echo "$(tput bold)$(echo "$TAR_LIST" | wc -l) tar packages for install$(tput sgr0):"
        echo
        echo "$TAR_LIST" | pr -tTw 125 -3
    else
        if [ -f "$CONFDIR"/tarinstalled/"$TARPKG" ]; then
            echo "$(tput bold)$TARPKG tar installed information$(tput sgr0):"
            . "$CONFDIR"/tarinstalled/"$TARPKG"
            echo "$(tput bold)Info$(tput sgr0):  $TAR_DESCRIPTION"
            echo "$(tput bold)Deps$(tput sgr0):  $DEPENDENCIES"
            if [ -z "$TAR_GITHUB_COMMIT" ]; then
                echo "$(tput bold)Version$(tput sgr0):  $TARFILE"
            else
                echo "$(tput bold)Version$(tput sgr0):  $TAR_GITHUB_COMMIT"
            fi
            echo "$(tput bold)Source$(tput sgr0):  $TAR_DOWNLOAD_SOURCE"
            echo "$(tput bold)URL$(tput sgr0):  $TARURI"
            echo "$(tput bold)Install dir$(tput sgr0):  $INSTDIR"
            echo "$(tput bold)Bin path$(tput sgr0):  $BIN_PATH"
            echo
        else
            tarappcheckfunc "$TARPKG"
            if [ "$KNOWN_TAR" = "TRUE" ]; then
                echo "$(tput bold)$TARPKG tar package information$(tput sgr0):"
                tarsaveconffunc "cache/$TARPKG.conf"
                . "$CONFDIR"/cache/"$TARPKG".conf
                echo "$(tput bold)Info$(tput sgr0):  $TAR_DESCRIPTION"
                echo "$(tput bold)Deps$(tput sgr0):  $DEPENDENCIES"
                if [ -z "$TAR_GITHUB_COMMIT" ]; then
                    echo "$(tput bold)Version$(tput sgr0):  $TARFILE"
                else
                    echo "$(tput bold)Version$(tput sgr0):  $TAR_GITHUB_COMMIT"
                fi
                echo "$(tput bold)Source$(tput sgr0):  $TAR_DOWNLOAD_SOURCE"
                echo "$(tput bold)URL$(tput sgr0):  $TARURI"
                echo "$(tput bold)Install dir$(tput sgr0):  $INSTDIR"
                echo "$(tput bold)Bin path$(tput sgr0):  $BIN_PATH"
                echo
            else
                TARPKG_NOT_FOUND="TRUE"
            fi
        fi
    fi
}

tarlistinstalledfunc () {
    for tarpkg in $(dir -C -w 1 "$CONFDIR"/tarinstalled); do
        echo "$(tput bold)$tarpkg installed information$(tput sgr0):"
        . "$CONFDIR"/tarinstalled/"$tarpkg"
        echo "$(tput bold)Info$(tput sgr0):  $TAR_DESCRIPTION"
        echo "$(tput bold)Deps$(tput sgr0):  $DEPENDENCIES"
        if [ -z "$TAR_GITHUB_COMMIT" ]; then
            echo "$(tput bold)Version$(tput sgr0):  $TARFILE"
        else
            echo "$(tput bold)Version$(tput sgr0):  $TAR_GITHUB_COMMIT"
        fi
        echo "$(tput bold)Source$(tput sgr0):  $TAR_DOWNLOAD_SOURCE"
        echo "$(tput bold)URL$(tput sgr0):  $TARURI"
        echo "$(tput bold)Install dir$(tput sgr0):  $INSTDIR"
        echo "$(tput bold)Bin path$(tput sgr0):  $BIN_PATH"
        echo
    done
}

tardlfunc () {
    case $TAR_DOWNLOAD_SOURCE in
        GITHUB)
            cd "$CONFDIR"/cache
            wget --read-timeout=30 "$TAR_GITHUB_NEW_DOWNLOAD" || { echo "wget $TARURI_DL failed; exiting..."; rm -rf "$CONFDIR"/cache/*; exit 1; }
            ;;
        DIRECT)
            cd "$CONFDIR"/cache
            wget --read-timeout=30 --trust-server-names "$TARURI" || { echo "wget $TARURI failed; exiting..."; rm -rf "$CONFDIR"/cache/*; exit 1; }
            ;;
    esac
    TARFILE="$(dir "$CONFDIR"/cache/*.tar*)"
    TARFILE="${TARFILE##*/}"
    NEW_TARFILE="$TARFILE"
}

tarcheckfunc () {
    case $TARFILE in
        *tar.gz)
            tar -xvzf "$CONFDIR"/cache/"$TARFILE" || { echo "tar $TARFILE failed; exiting..."; rm -rf "$CONFDIR"/cache/*; exit 1; }
            ;;
        *tar.bz2|*tar.tbz|*tar.tb2|*tar)
            tar -xvf "$CONFDIR"/cache/"$TARFILE" || { echo "tar $TARFILE failed; exiting..."; rm -rf "$CONFDIR"/cache/*; exit 1; }
            ;;
        *)
            echo "Unknown file type!"
            rm -rf "$CONFDIR"/cache/*
            exit 1
            ;;
    esac
}

checktarversionfunc () {
    . "$CONFDIR"/tarinstalled/"$TARPKG"
    if [ "$TAR_DOWNLOAD_SOURCE" = "GITHUB" ]; then
        if [ "$GITHUB_DOWNLOAD_ERROR" = "TRUE" ]; then
            TAR_NEW_UPGRADE="FALSE"
            GITHUB_DOWNLOAD_ERROR="FALSE"
        elif [ "$TAR_FORCE_UPGRADE" = "TRUE" ]; then
            TAR_NEW_UPGRADE="TRUE"
            TAR_FORCE_UPGRADE="FALSE"
        elif [ $TAR_GITHUB_COMMIT != $TAR_GITHUB_NEW_COMMIT ]; then
            TAR_NEW_UPGRADE="TRUE"
        else
            TAR_NEW_UPGRADE="FALSE"
        fi
    else
        wget -S --read-timeout=30 --spider "$TARURI" -o "$CONFDIR"/cache/"$TARPKG".latest
        NEW_TARURI="$(grep -o "Location:.*" "$CONFDIR"/cache/"$TARPKG".latest | cut -f2 -d" ")"
        NEW_TARFILE="${NEW_TARURI##*/}"
        if [ "$TAR_FORCE_UPGRADE" = "TRUE" ]; then
            TAR_NEW_UPGRADE="TRUE"
            TAR_FORCE_UPGRADE="FALSE"
        elif [[ "$NEW_TARFILE" != "$TARFILE" ]]; then
            TAR_NEW_UPGRADE="TRUE"
        elif [ "$RENAMED" = "TRUE" ] && [ -d /opt/"$OLD_NAME" ]; then
            TAR_NEW_UPGRADE="TRUE"
            RENAMED=""
        else
            TAR_NEW_UPGRADE="FALSE"
        fi
    fi
    if [ -z "$NEW_TARFILE" ] && [ -z "$NEW_COMMIT" ] && [ "$TAR_FORCE_UPGRADE" = "FALSE" ]; then
        echo "$(tput setaf 1)Error checking new version for $TARPKG!$(tput sgr0)"
        TAR_NEW_UPGRADE="FALSE"
    fi
}

tarupdateforcefunc () {
    if [ -f "$CONFDIR"/tarinstalled/"$TARPKG" ]; then
        . "$CONFDIR"/tarinstalled/"$TARPKG"
        echo "$(tput bold)Info$(tput sgr0):  $TAR_DESCRIPTION"
        echo "$(tput bold)Deps$(tput sgr0):  $DEPENDENCIES"
        if [ -z "$TAR_GITHUB_COMMIT" ]; then
            echo "$(tput bold)Version$(tput sgr0):  $TARFILE"
        else
            echo "$(tput bold)Version$(tput sgr0):  $TAR_GITHUB_COMMIT"
        fi
        echo "$(tput bold)Source$(tput sgr0):  $TAR_DOWNLOAD_SOURCE"
        echo "$(tput bold)URL$(tput sgr0):  $TARURI"
        echo "$(tput bold)Install dir$(tput sgr0):  $INSTDIR"
        echo "$(tput bold)Bin path$(tput sgr0):  $BIN_PATH"
        echo
    else
        echo "Package not found!"
        rm -rf "$CONFDIR"/cache/*
        exit 1
    fi
    . "$CONFDIR"/tarinstalled/"$TARPKG"
    if [ ! -z "$DOWNLOAD_SOURCE" ]; then
        TAR_DOWNLOAD_SOURCE="$DOWNLOAD_SOURCE"
    fi
    NEW_TARFILE="$TARFILE"
    TAR_GITHUB_NEW_COMMIT="$TAR_GITHUB_COMMIT"
    TAR_GITHUB_NEW_DOWNLOAD="$TAR_GITHUB_DOWNLOAD"
    TAR_GITHUB_NEW_VERSION="$TAR_GITHUB_VERSION"
    echo "Marking $TARPKG for upgrade by force..."
    echo "$(tput setaf 2)New upgrade available for $TARPKG!$(tput sgr0)"
    tarsaveconffunc "tarupgrades/$TARPKG"
}

tarupgradecheckallfunc () {
    for package in $(dir -C -w 1 "$CONFDIR"/tarinstalled); do
        TARPKG="$package"
        echo "Checking $package version..."
        tarappcheckfunc "$package"
        checktarversionfunc
        if [ "$TAR_NEW_UPGRADE" = "TRUE" ]; then
            echo "$(tput setaf 2)New upgrade available for $package -- $NEW_TARFILE !$(tput sgr0)"
            tarsaveconffunc "tarupgrades/$package"
        fi
    done
    echo
    if [ "$(dir "$CONFDIR"/tarupgrades | wc -l)" = "1" ]; then
        echo "$(tput setaf 2)$(dir -C -w 1 "$CONFDIR"/tarupgrades | wc -l) new tar package upgrade available.$(tput sgr0)"
    elif [ "$(dir "$CONFDIR"/tarupgrades | wc -l)" = "0" ]; then
        echo "No new tar package upgrades."
    else
        echo "$(tput setaf 2)$(dir -C -w 1 "$CONFDIR"/tarupgrades | wc -l) new tar package upgrades available.$(tput sgr0)"
    fi
}

tarupgradecheckfunc () {
    if ! echo "$TAR_LIST" | grep -qow "$1"; then
        echo "$1 is not in tar-pkgs.json; try running 'spm update'."
    else
        TARPKG="$1"
        echo "Checking $TARPKG version..."
        tarappcheckfunc "$TARPKG"
        checktarversionfunc
        if [ "$TAR_NEW_UPGRADE" = "TRUE" ]; then
            echo "$(tput setaf 2)New upgrade available for $TARPKG -- $NEW_TARFILE !$(tput sgr0)"
            tarsaveconffunc "tarupgrades/$TARPKG"
        else
            echo "No new upgrade for $TARPKG"
        fi
    fi
}

tarupdatelistfunc () {
    echo "Downloading tar-pkgs.json from spm github repo..."
    rm "$CONFDIR"/tar-pkgs.json
    wget "https://raw.githubusercontent.com/simoniz0r/spm/master/tar-pkgs.json" -qO "$CONFDIR"/tar-pkgs.json
    echo "tar-pkgs.json updated!"
    if [ -z "$1" ]; then
        tarupgradecheckallfunc
    else
        tarupgradecheckfunc "$1"
    fi
}

tardesktopfilefunc () {
    echo "Downloading $TARPKG.desktop from spm github repo..."
    wget --quiet "https://raw.githubusercontent.com/simoniz0r/spm/master/apps/$TARPKG/$TARPKG.desktop" -O "$CONFDIR"/cache/"$TARPKG".desktop  || { echo "wget $TARURI failed; exiting..."; rm -rf "$CONFDIR"/cache/*; exit 1; }
    echo "Moving $TARPKG.desktop to $INSTDIR ..."
    sudo mv "$CONFDIR"/cache/"$TARPKG".desktop "$INSTDIR"/"$TARPKG".desktop
    DESKTOP_FILE_PATH="$INSTDIR/$TARPKG.desktop"
    DESKTOP_FILE_NAME="$TARPKG.desktop"
}

tarinstallfunc () {
    echo "Moving files to $INSTDIR..."
    EXTRACTED_DIR_NAME="$(ls -d "$CONFDIR"/cache/*/)"
    sudo mv "$EXTRACTED_DIR_NAME" "$INSTDIR" || { echo "Failed!"; rm -rf "$CONFDIR"/cache/*; exit 1; }
    DESKTOP_FILE_NAME="$(basename "$DESKTOP_FILE_PATH")"
    ICON_FILE_NAME="$(basename "$ICON_FILE_PATH")"
    EXECUTABLE_FILE_NAME="$(basename "$EXECUTABLE_FILE_PATH")"
    echo "Creating symlink for $EXECUTABLE_FILE_PATH to /usr/local/bin/$TARPKG ..."
    sudo ln -s "$EXECUTABLE_FILE_PATH" /usr/local/bin/"$TARPKG"
    echo "Creating symlink for $TARPKG.desktop to /usr/share/applications/ ..."
    case $DESKTOP_FILE_PATH in
        DOWNLOAD)
            tardesktopfilefunc "$TARPKG"
            sudo ln -s "$DESKTOP_FILE_PATH" /usr/share/applications/"$DESKTOP_FILE_NAME"
            ;;
        *NONE*)
            echo "Skipping .desktop file..."
            ;;
        *)
            sudo sed -i "s:Exec=.*:Exec="$EXECUTABLE_FILE_PATH":g" "$DESKTOP_FILE_PATH"
            sudo sed -i "s:Icon=.*:Icon="$ICON_FILE_PATH":g" "$DESKTOP_FILE_PATH"
            sudo ln -s "$DESKTOP_FILE_PATH" /usr/share/applications/"$DESKTOP_FILE_NAME"
            ;;
    esac
    echo "Creating config file for $TARPKG..."
    tarsaveconffunc "tarinstalled/$TARPKG"
    echo "$TARPKG has been installed to $INSTDIR !"
}

tarinstallstartfunc () {
    if [ -f "$CONFDIR"/tarinstalled/"$TARPKG" ] || [ -f "$CONFDIR"/appimginstalled/"$TARPKG" ]; then # Exit if already installed by spm
        echo "$TARPKG is already installed."
        echo "Use 'spm upgrade' to install the latest version of $TARPKG."
        rm -rf "$CONFDIR"/cache/*
        exit 1
    fi
    if type >/dev/null 2>&1 "$TARPKG"; then
        echo "$TARPKG is already installed and not managed by spm; exiting..."
        rm -rf "$CONFDIR"/cache/*
        exit 1
    fi
    if [ -d "/opt/$TARPKG" ]; then
        echo "/opt/$TARPKG exists; spm cannot install to existing directories!"
        rm -rf "$CONFDIR"/cache/*
        exit 1
    fi
    tarappcheckfunc "$TARPKG"
    if [ "$KNOWN_TAR" = "FALSE" ];then
        echo "$TARPKG is not in tar-pkgs.json; try running 'spm update' to update tar-pkgs.json."
        rm -rf "$CONFDIR"/cache/*
        exit 1
    else
        echo "Tar for $TARPKG will be installed."
        read -p "Continue? Y/N " INSTANSWER
        case $INSTANSWER in
            N*|n*)
                echo "$TARPKG was not installed."
                rm -rf "$CONFDIR"/cache/*
                exit 0
                ;;
        esac
    fi
}

tarupgradefunc () {
    echo "Would you like to do a clean upgrade (remove all files in /opt/$TARPKG before installing) or an overwrite upgrade?"
    echo "Note: If you are using Discord with client modifications, it is recommended that you do a clean upgrade."
    read -p "Choice? Clean/Overwrite " PKGUPGDMETHODANSWER
    case $PKGUPGDMETHODANSWER in
        Clean|clean)
            echo "$TARPKG will be upgraded to $TARFILE."
            echo "Removing files in $INSTDIR..."
            sudo rm -rf "$INSTDIR" || { echo "Failed!"; rm -rf "$CONFDIR"/cache/*; exit 1; }
            echo "Moving files to $INSTDIR..."
            EXTRACTED_DIR_NAME="$(ls -d "$CONFDIR"/cache/*/)"
            sudo mv "$EXTRACTED_DIR_NAME" "$INSTDIR"
            ;;
        Overwrite|overwrite)
            echo "$TARPKG will be upgraded to $TARFILE."
            echo "Copying files to $INSTDIR..."
            EXTRACTED_DIR_NAME="$(ls -d "$CONFDIR"/cache/*/)"
            sudo cp -r "$EXTRACTED_DIR_NAME"/* "$INSTDIR"/ || { echo "Failed!"; rm -rf "$CONFDIR"/cache/*; exit 1; }
            ;;
        *)
            echo "Invalid choice; $TARPKG was not upgraded."
            rm -rf "$CONFDIR"/cache/*
            exit 1
            ;;
    esac
    case $DESKTOP_FILE_PATH in
        DOWNLOAD)
            tardesktopfilefunc "$TARPKG"
            sudo ln -sf "$DESKTOP_FILE_PATH" /usr/share/applications/"$DESKTOP_FILE_NAME"
            ;;
        *NONE*)
            echo "Skipping .desktop file..."
            ;;
        *)
            sudo sed -i "s:Exec=.*:Exec="$EXECUTABLE_FILE_PATH":g" "$DESKTOP_FILE_PATH"
            sudo sed -i "s:Icon=.*:Icon="$ICON_FILE_PATH":g" "$DESKTOP_FILE_PATH"
            sudo ln -sf "$DESKTOP_FILE_PATH" /usr/share/applications/"$DESKTOP_FILE_NAME"
            ;;
    esac
    echo "Creating config file for $TARPKG..."
    tarsaveconffunc "tarinstalled/$TARPKG"
    echo "$TARPKG has been upgraded to $TARFILE!"
}

tarupgradestartallfunc () {
    if [ "$TARUPGRADES" = "FALSE" ]; then
        sleep 0
    else
        if [ "$(dir "$CONFDIR"/tarupgrades | wc -l)" = "1" ]; then
            echo "$(tput setaf 2)$(dir -C -w 1 "$CONFDIR"/tarupgrades | wc -l) new tar package upgrade available.$(tput sgr0)"
        else
            echo "$(tput setaf 2)$(dir -C -w 1 "$CONFDIR"/tarupgrades | wc -l) new tar package upgrades available.$(tput sgr0)"
        fi
        dir -C -w 1 "$CONFDIR"/tarupgrades | pr -tT --column=3 -w 125
        echo
        read -p "Continue? Y/N " UPGRADEALLANSWER
        case $UPGRADEALLANSWER in
            Y*|y*)
                for UPGRADE_PKG in $(dir -C -w 1 "$CONFDIR"/tarupgrades); do
                    TARPKG="$UPGRADE_PKG"
                    echo "Downloading $TARPKG..."
                    tarappcheckfunc "$TARPKG"
                    if [ "$TAR_DOWNLOAD_SOURCE" = "GITHUB" ]; then
                        targithubinfofunc
                    fi
                    tardlfunc "$TARPKG"
                    tarcheckfunc
                    tarupgradefunc
                    rm "$CONFDIR"/tarupgrades/"$TARPKG"
                    rm -rf "$CONFDIR"/cache/*
                    echo
                done
                ;;
            N*|n*)
                echo "No packages were upgraded; exiting..."
                rm -rf "$CONFDIR"/cache/*
                exit 0
                ;;
        esac
    fi
}

tarupgradestartfunc () {
    echo "$TARPKG will be upgraded to the latest version."
    read -p "Continue? Y/N " UPGRADEANSWER
    case $UPGRADEANSWER in
        Y*|y*)
            tarappcheckfunc "$TARPKG"
            if [ "$TAR_DOWNLOAD_SOURCE" = "GITHUB" ]; then
                targithubinfofunc
            fi
            tardlfunc "$TARPKG"
            tarcheckfunc
            tarupgradefunc
            rm "$CONFDIR"/tarupgrades/"$TARPKG"
            ;;
        N*|n*)
            echo "$TARPKG was not upgraded."
            ;;
    esac
}

tarremovefunc () {
    . "$CONFDIR"/tarinstalled/"$REMPKG"
    echo "Removing $REMPKG..."
    echo "All files in $INSTDIR will be removed!"
    read -p "Continue? Y/N " PKGREMANSWER
    case $PKGREMANSWER in
        N*|n*)
            echo "$REMPKG was not removed."
            rm -rf "$CONFDIR"/cache/*
            exit 0
            ;;
    esac
    if [ -f "$CONFDIR"/tarupgrades/$REMPKG ]; then
        rm "$CONFDIR"/tarupgrades/"$REMPKG"
    fi
    DESKTOP_FILE_NAME="$(basename "$DESKTOP_FILE_PATH")"
    ICON_FILE_NAME="$(basename "$ICON_FILE_PATH")"
    EXECUTABLE_FILE_NAME="$(basename "$EXECUTABLE_FILE_PATH")"
    echo "Removing $INSTDIR..."
    sudo rm -rf "$INSTDIR" || { echo "Failed!"; rm -rf "$CONFDIR"/cache/*; exit 1; }
    echo "Removing symlinks..."
    case $DESKTOP_FILE_PATH in
        NONE)
            echo "Skipping .desktop file..."
            ;;
        *)
            sudo rm /usr/share/applications/"$DESKTOP_FILE_NAME"
            ;;
    esac
    sudo rm /usr/local/bin/"$REMPKG"
    rm "$CONFDIR"/tarinstalled/"$REMPKG"
    echo "$REMPKG has been removed!"
}

tarremovepurgefunc () {
    . "$CONFDIR"/tarinstalled/"$PURGEPKG"
    echo "Removing $PURGEPKG..."
    echo "All files in $INSTDIR and $CONFIG_PATH will be removed!"
    read -p "Continue? Y/N " PKGREMANSWER
    case $PKGREMANSWER in
        N*|n*)
            echo "$PURGEPKG was not removed."
            rm -rf "$CONFDIR"/cache/*
            exit 0
            ;;
    esac
    if [ -f "$CONFDIR"/tarupgrades/$PURGEPKG ]; then
        rm "$CONFDIR"/tarupgrades/"$PURGEPKG"
    fi
    DESKTOP_FILE_NAME="$(basename "$DESKTOP_FILE_PATH")"
    ICON_FILE_NAME="$(basename "$ICON_FILE_PATH")"
    EXECUTABLE_FILE_NAME="$(basename "$EXECUTABLE_FILE_PATH")"
    echo "Removing $INSTDIR..."
    sudo rm -rf "$INSTDIR" || { echo "Failed!"; rm -rf "$CONFDIR"/cache/*; exit 1; }
    echo "Removing symlinks..."
    case $DESKTOP_FILE_PATH in
        NONE)
            echo "Skipping .desktop file..."
            ;;
        *)
            sudo rm /usr/share/applications/"$DESKTOP_FILE_NAME"
            ;;
    esac
    sudo rm /usr/local/bin/"$PURGEPKG"
    echo "Removing $CONFIG_PATH..."
    if [ ! -z "$CONFIG_PATH" ]; then
        rm -rf "$CONFIG_PATH"
    else
        echo "No config path specified; skipping..."
    fi
    rm "$CONFDIR"/tarinstalled/"$PURGEPKG"
    echo "$PURGEPKG has been removed!"
}
