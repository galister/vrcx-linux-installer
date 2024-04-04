This is an easy-to-use installer for Linux. It installs a known working release from [VRCX Official Releases](https://github.com/vrcx-team/VRCX/releases) under Wine 9+.

**Wine 9** is now required!

## Install script

Script can be found [here](install-vrcx.sh).

What the script does:
1. Create a prefix at `~/.local/share/vrcx`
1. Run `winetricks corefonts` \
   (Downloads a known good version of `winetricks` if not available locally)
1. (Optional) Link VRChat AppData folder into prefix to enable the "Game Log" tab
1. Install VRCX into `~/.local/share/vrcx/drive_c/vrcx`
1. Create launcher script, desktop entry and icon.

Before running the script:
- Have Wine 9 installed
- If you plan on running VRChat on this computer, make sure it's installed and have been ran at least once.



Here's the one-liner. Please review the contents before executing.
```bash
curl -sSf https://github.com/galister/vrcx-linux-installer/blob/master/install-vrcx.sh | bash
```

## Join the Linux VR Community

- Discord: [Link](https://discord.gg/dCJhT8eEUG)
- Matrix: [#linux-vr-adventures:matrix.org](https://matrix.to/#/#linux-vr-adventures:matrix.org)
