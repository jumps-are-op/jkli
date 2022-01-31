#!/bin/bash

#############################################
## jkli ## Jumps Keyboard Layout Installer ##
#############################################

# 
# Made By jumps-are-op
# All software Made By jumps-are-op is under GPL
#

# Some script vars
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
SCRIPT_NAME="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"

# This scripts should only be runned as root
if [ "$UID" != "0" ];then
	echo "This script should be runned as root"
	echo "Try running 'sudo $SCRIPT_NAME'"
	exit 1
fi

# List of layouts
layouts=($(ls "$SCRIPT_DIR"|grep -o ".*"|grep -v "$SCRIPT_NAME"))
cancel(){
	clear;echo "Canceld By user.";exit 1
}

ask(){
	local i num
	echo "NOTE: at any time press ctrl+d to exit"
	echo
	echo "What layout You want to install"
	echo ""
	echo "0: see what layout look like"
	echo "$(for i in "${layouts[@]}";do ((num++));echo "$num: $i";done)"
	echo ""
	read -p "layout: " i || cancel
	case "$i" in
		1)layout="${layouts[0]}";;
		2)layout="${layouts[1]}";;
		0)
		clear
		echo '+========[ workman ]=========+'
		echo '|` 1 2 3 4 5 6 7 8 9 0 - = <<|'
		echo '|>>>q d r w b j f u p ; [ ] \|'
		echo "|>>>a s h t g y n e o i ; <<<|"
		echo '|>>>>z x m c v k l , . / <<<<|'
		echo '+============================+'
		echo ''
		echo '+=======[ workman-j ]========+'
		echo '|` 1 2 3 4 5 6 7 8 9 0 - = <<|'
		echo "|>>>q d r w b f i u p ' [ ] \\|"
		echo '|>>>a s h t g y j n e o ; <<<|'
		echo '|>>>>z x m c v k l , . / <<<<|'
		echo '+============================+'
		echo 
		read -n 1 -s -p "press anykey to cotinue " null
		clear;ask;return;;
	*)clear;echo "Invalide input";exit 1;;
	esac
}

askinstall(){
	local i
	echo "Do you want to install it"
	echo ""
	echo "1: Permanently"
	echo "2: Only for this session"
	read -p "[1/2] " i || cancel
	case "$i" in 
		1)install="permanently";;
		2)install="only in this session";;
		*)echo "Invalide option '$option', exiting.";return 1;;
	esac
}

asksure(){
	local i
	echo "install $layout layout $install"
	read -p "[y/N] " i
	case "$i" in
		y|Y)return;;
		*)cancel;;
	esac
}

install(){
	echo "installing $layout layout..."
	if [ "$install" == "permanently" ];then
	cp "$SCRIPT_DIR/$layout/$layout.iso15.kmap" /etc/keyboard/layout.iso15.kmap
	cp "$SCRIPT_DIR/$layout/xmodmap.$layout" /etc/keyboard/xmodmap.layout
	echo "[Unit]
Description=Keyboard layout
After=getty.target

[Service]
ExecStart=
ExecStart=/usr/bin/loadkeys /etc/keyboard/layout.iso15.kmap

[Install]
WantedBy=getty.target" >/etc/systemd/system/keyboard.service
	echo "[Unit]
Description=Keyboard layout for X
After=graphical.target

[Service]
Type=oneshot
ExecStart=
ExecStart=setxkbmap us
ExecStart=xmodmap /etc/keyboard/xmodmap.layout
ExecStart=set -r 66

[Install]
WantedBy=graphical.target" >/etc/systemd/system/keyboard-gui.service
	systemctl enable keyboard.service
	systemctl enable keyboard-gui.service
	fi
	/usr/bin/loadkeys "$SCRIPT_DIR/$layout/$layout.iso15.kmap"
	setxkbmap us
	xmodmap "$SCRIPT_DIR/$layout/xmodmap.$layout"
	sleep 1
	set -r 66
}

main(){
	clear
	ask
	clear
	askinstall
	clear
	asksure
	clear
	install
	clear 
	echo "Done Installing $layout layout."
}
main && exit 0 || exit 1
