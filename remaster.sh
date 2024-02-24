#!/bin/sh

# remaster.sh - Copyright 2010 Brian Smith
# Licensed under GPLv2 License
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# Modified for speed.

alias grep="busybox grep"
alias sed="busybox sed"
alias awk="busybox awk"
alias wget="busybox wget"
alias mount="busybox mount"

cd_type=""

checkmountimage(){
	echo "cd location:  $cd_location"
	
	if [ -f $cd_location/boot/corepure64.gz ]; then
		cd_type="cd"
	fi
	
	if [ -f $cd_location ]; then
		sudo mount $cd_location $temp_dir/mnt || exit 16
		if [ -f $temp_dir/mnt/boot/corepure64.gz ]; then
			cd_type="iso"	
		else 
			sudo umount $temp_dir/mnt
		fi
	fi	

	if [ ! -n "$cd_type" ]; then
		echo "Unable to find CD or mount ISO"
		exit 5;	
	fi
}

extractimage(){
	checkmountimage

	sudo rm -rf $temp_dir/image
	mkdir -p $temp_dir/image


	if [ $cd_type == "iso" ]; then
		sudo cp -a $temp_dir/mnt/?* $temp_dir/image || exit 17
		sudo umount $temp_dir/mnt
	else
		sudo cp -a $cd_location/?* $temp_dir/image || exit 18
	fi
}

bootcode(){
	if [ ! -f $temp_dir/image/boot/isolinux/isolinux.cfg ]; then
		echo "$temp_dir/image/boot/isolinux/isolinux.cfg not found"
		exit 9
	fi
	
	sudo busybox sed -i s/APPEND/append/ $temp_dir/image/boot/isolinux/isolinux.cfg
	
	for bootcode in `cat $input | grep "^cc = " | awk '{ $1=""; $2=""; print }'`; do
	        sudo busybox sed -i "/append/s|$| $bootcode|" $temp_dir/image/boot/isolinux/isolinux.cfg
	done
	
	if [ -n "`grep ^app_outside_initrd $input`" ]; then 
	        sudo busybox sed -i "/append/s|$| cde|" $temp_dir/image/boot/isolinux/isolinux.cfg
	fi
	
}

package(){	
	cdlabel="Tinycore"

	cd "$HOME/hometemp/image"
	sudo mkisofs -quiet -l -J -R -V $cdlabel -no-emul-boot -boot-load-size 4 -boot-info-table -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat -o /home/tc/ezremaster.iso . || exit 24
	echo "Saved in /home/tc/hometemp"
}

if [ $# -ne 2 ]; then
	set +x
	echo ""
	echo "You must supply 2 arguments:  config-file and function"
	echo ""
	echo "Example:  remaster.sh /tmp/ezremaster/ezremaster.cfg rebuild"
	echo ""
	echo "Valid Functions are:"
	echo ""
	echo "   checkimage"
	echo "   extractimage"
	echo "   bootcode"
	echo "   package"
	echo "   rebuild (does all of the above steps)"
	echo ""
	exit 1
fi

input=$1

if [ ! -r $input ]; then
	echo "Unable to open config file $input"
	exit 2
fi

function=$2

cd_location=`grep "^cd_location = " $input | awk '{print $3}'`
temp_dir=`grep "^temp_dir = " $input | awk '{print $3}'`

mkdir -p $temp_dir/image
mkdir -p $temp_dir/extract
mkdir -p $temp_dir/mnt
mkdir -p $temp_dir/app_dep

if [ ! -d $temp_dir/image ]; then
	echo "Error creating tmp dir:  $temp_dir/image"
	exit 7
fi

case $function in
	checkimage) 
		checkmountimage
		if [ $cd_type == "iso" ]; then
			sudo umount $temp_dir/mnt	
		fi
		;;
	extractimage) extractimage ;;
	bootcode) bootcode ;;
	package) package ;;
	rebuild)
		extractimage
		bootcode
		package
		;;
	*) echo "Invalid function: $function"; exit 3 ;;
esac
