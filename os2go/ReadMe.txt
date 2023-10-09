1. run backup_offline
	a) mount backup drive
	b) copy data
	c) do NOT run gaming vm
2. UEFI setup
	a) disable secure boot
	b) setup mode and reset to deploy custom keys
3. run script.sh
	a) ENV var backup_dir
	b) ENV var target_disk
4. minor manuell configuration
	a) Keyboard Layout
	b) wireless signals
		- disable bluetooth
		- enable wifi
	c) Advandced Power Settings
		- Battery Loading Start/Stop
		- Low/Critical Percentage
	d) run ~/scripts/os2go/pass.sh
		- first parameter "tpm2"
		- delete all other keys
