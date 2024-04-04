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

while pidof "VRCX.exe"; do
    echo "Please close VRCX. The installation will continue afterwards."
    sleep 5
done

if [[ ! -d $WINEPREFIX ]]; then
	echo "Creating Wine prefix..."
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
	echo "No VRC installation detected!"
	echo "If you want to use VRC on this computer, please install it now and start it once."
	echo "Otherwise, your Game Log tab will not function!"
	read -p "Press enter to continue"
fi

if [[ -d $vrc_appdata ]] && [[ ! -d $vrc_dst ]]; then
	echo "Linking VRChat AppData into Wine Prefix..."
	mkdir -p $(dirname $vrc_dst)
	ln -s $vrc_appdata $vrc_dst
fi

echo "Downloading VRCX..."

vrcx_home=$WINEPREFIX/drive_c/vrcx
mkdir -p $vrcx_home
cd $vrcx_home

while ! wget -qO vrcx.zip --show-progress $release_zip_url; do
        echo "Failed to download release, waiting 5s before retry."
        sleep 5
done

echo "Extracting VRCX..."
unzip -uq vrcx.zip
rm vrcx.zip

echo '#!/usr/bin/env bash 
export WINEPREFIX=$HOME/.local/share/vrcx
wine64 $WINEPREFIX/drive_c/vrcx/VRCX.exe -no-cef-sandbox' > $vrcx_home/vrcx
chmod +x $vrcx_home/vrcx

if command -V winetricks; then
        echo "Installing corefonts... (this will take a minute)"
 	logs=$(winetricks corefonts 2>&1)
        winetricks_exit_code="$?"
else
        echo "Downloading winetricks..."
        while ! wget -qO winetricks --show-progress https://github.com/Winetricks/winetricks/blob/20240105/src/winetricks; do
		echo "Failed to download winetricks, waiting 5s before retry."
		sleep 5
        done
        chmod +x ./winetricks
        echo "Installing corefonts... (this will take a minute)"
 	logs=$(./winetricks corefonts 2>&1)
        winetricks_exit_code="$?"
        rm ./winetricks
fi

if [ "$winetricks_exit_code" -ne "0" ]; then
	echo "*********** Error while installing corefonts ***********"
	echo "$logs"
	echo "*********** Error while installing corefonts ***********"
	exit 1
fi

if [[ -d "$HOME/.local/bin" ]]; then
	echo "Installing vrcx to ~/.local/bin"
	ln -s "$vrcx_home/vrcx" "$HOME/.local/bin/vrcx" || true
fi

if [[ -d "$HOME/.local/share/applications" ]]; then
	if [[ -d "$HOME/.local/share/icons" ]]; then
		echo "Installing VRCX.png to ~/.local/share/icons"
                cp "$vrcx_home/VRCX.png" "$HOME/.local/share/icons/VRCX.png"
	fi

	echo "Installing vrcx.desktop to ~/.local/share/applications"
	echo "[Desktop Entry]
Type=Application
Name=VRCX
Categories=Utility;
Exec=$vrcx_home/vrcx
Icon=VRCX
" >"$HOME/.local/share/applications/vrcx.desktop"
fi

echo "Done! Check your menu for VRCX."
