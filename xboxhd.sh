#!/bin/bash
hdd_path=""
lockhdd() { ./smartctl -g security $1; ./smartctl -s security-eeprom-setpass,eeprom.bin $1; }
unlockhdd() { ./smartctl -g security $1; ./smartctl -s security-eeprom-unlock,eeprom.bin $1; ./smartctl -s security-eeprom-disable,eeprom.bin $1; }
qemu_run() { qemu-system-i386 -kernel kernel -initrd initrd.gz -drive file=fat:rw:hdm/,index=1,format=raw -drive file=$1,index=0,media=disk,format=raw -append "load_ramdisk=1 prompt_ramdisk=0 ramdisk_size=24000 rw root=/dev/ram pci=biosirq vga=0x317"; }
select_hdd() { ( readarray -t lines < <(lsblk -I 8 -dno NAME,SIZE,MODEL); select choice in "${lines[@]}"; do [[ -n $choice ]] || { echo "Invalid choice. Please try again." >&2; continue; }; break; done; read -r hdd_path size unused <<<"$choice"; echo $hdd_path; ) }

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

while(true); do
	PS3='Please enter your choice: '
	options=("List drives connected" "Launch xboxhdm" "Lock hard drive" "Unlock hard drive" "Quit")
	select opt in "${options[@]}"
	do
		case $opt in
			"List drives connected")
				hdd_path=/dev/`select_hdd`
				break
				;;
			"Launch xboxhdm")
				qemu_run $hdd_path
				break
				;;
			"Lock hard drive")
				lockhdd $hdd_path
				break
				;;
			"Unlock hard drive")
				unlockhdd $hdd_path
				break
				;;
			"Quit")
				exit
				;;
			*) echo invalid option;;
		esac
	done
done


