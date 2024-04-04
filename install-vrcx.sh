#!/usr/bin/env bash

# change me
steamapps=$HOME/.local/share/Steam/steamapps

export WINEPREFIX=$HOME/.local/share/vrcx

release_zip_url=https://github.com/vrcx-team/VRCX/releases/download/v2024.03.23/VRCX_20240323.zip

set -e

# Ensure Wine version >= 9.0
wine_version=$(wine64 --version | grep -Po '(?<=wine-)([0-9.]+)')
if [ "$1" != "force" ] && [[ $wine_version < 9.0 ]]; then
	echo "Please upgrade your Wine version to 9.0 or higher."
	echo "If you want to try anyway, run: install-vrcx.sh force"
	exit 1
fi

if [[ ! -d $WINEPREFIX ]]; then
	echo "Creating Wine prefix."
	logs=$(winecfg /v win10 2>&1)
	if [ "$?" -ne "0" ]; then
		echo "*********** Error while creating Wine prefix ***********"
		echo "$logs"
		echo "*********** Error while creating Wine prefix ***********"
		exit 1
	fi
fi

if [[ ! -d $steamapps ]] && [[ -d $HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps ]]; then
	echo "Flatpak Steam detected."
	steamapps=$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps
fi

vrc_appdata=$steamapps/438100/pfx/drive_c/users/steamuser/AppData/LocalLow/VRChat/VRChat
vrc_dst=$WINEPREFIX/drive_c/users/$USER/AppData/LocalLow/VRChat/VRChat

if [[ -d $vrc_appdata ]]; then
	echo "No VRC installation detected."
	echo "If you want to use VRC on this computer, please install it now and start it once."
	echo "Otherwise, your Game Log tab will not function!"
	read -p "Press enter to continue"
fi

if [[ -d $vrc_appdata ]] && [[ ! -d $vrc_dst ]]; then
	echo "Link VRChat AppData into Wine Prefix"
	mkdir -p $(dirname $vrc_dst)
	ln -s $vrc_appdata $vrc_dst
fi

echo "Download VRCX"

mkdir -p $WINEPREFIX/drive_c/vrcx
cd $WINEPREFIX/drive_c/vrcx

while ! wget -qO vrcx.zip --show-progress $release_zip_url; do
        echo "Failed to download release, waiting 5s before retry."
        sleep 5
done
unzip -uq vrcx.zip
rm vrcx.zip

echo '#!/usr/bin/env bash 
export WINEPREFIX=$HOME/.local/share/vrcx
wine64 $WINEPREFIX/drive_c/vrcx/VRCX.exe -no-cef-sandbox' >~/.local/share/vrcx/drive_c/vrcx/vrcx
chmod +x ~/.local/share/vrcx/drive_c/vrcx/vrcx

if command -V winetricks; then
        echo "Install corefonts"
	winetricks corefonts
else
        echo "Download winetricks"
        while ! wget -qO winetricks --show-progress https://github.com/Winetricks/winetricks/blob/20240105/src/winetricks; do
		echo "Failed to download winetricks, waiting 5s before retry."
		sleep 5
        done
        chmod +x ./winetricks
        echo "Install corefonts"
        ./winetricks corefonts
        rm ./winetricks
fi

if [[ -d ~/.local/bin ]]; then
	echo "Install vrcx to ~/.local/bin"
	ln -s ~/.local/share/vrcx/drive_c/vrcx/vrcx ~/.local/bin/vrcx || true
fi

if [[ -d $HOME/.local/share/applications ]]; then
	if [[ -d $HOME/.local/share/icons ]]; then
		echo "Install VRCX.png to ~/.local/share/icons"
		while ! wget -qO ~/.local/share/icons/VRCX.png --show-progress https://github.com/vrcx-team/VRCX/blob/master/VRCX.png; do
			echo "Failed to download icon, waiting 5s before retry."
			sleep 5
		done
	fi

	echo "Install vrcx.desktop to ~/.local/share/applications"
	echo "[Desktop Entry]
Type=Application
Name=VRCX
Categories=Utility;
Exec=$HOME/.local/share/vrcx/drive_c/vrcx/vrcx
Icon=VRCX
" >~/.local/share/applications/vrcx.desktop
fi

echo "Done! Check your menu for VRCX."
