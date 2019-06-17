#!/bin/bash

unpack() {
	if [ ! -d /home/x/Desktop/tce/sq ]; then
		mkdir /home/x/Desktop/tce/sq
	fi
	if [ -f $1 ]; then
		echo "Unpacking $1"
		mount -o loop $1 /home/x/Desktop/tce/sq
		cp -rp /home/x/Desktop/tce/sq/* /home/x/Desktop/tce/cpio/.
		umount -f /home/x/Desktop/tce/sq
		sleep 2;
	fi
}

parsedep() {
	if [ -f $1.dep ]; then
		echo "$1.dep found. parsing...."
		while read p; do
			echo "[!] $p required."
			if [ ! -f $p ]; then
				wget http://tinycorelinux.net/9.x/armv7/tcz/$p
			fi

			if [ -f $p ]; then
				unpack $p;
			fi

			if [ ! -f $p.dep ]; then
				wget -q http://tinycorelinux.net/9.x/armv7/tcz/$p.dep
			fi	

			if [ -f $p.dep ]; then
				parsedep $p;
			fi

		done < $1.dep
	fi
}

getOne() {
	if [ ! -f $1 ]; then
		wget http://tinycorelinux.net/9.x/armv7/tcz/$1
	fi

	if [ -f $1 ]; then
		unpack $1;
	fi

	if [ ! -f $1.dep ]; then
		wget -q http://tinycorelinux.net/9.x/armv7/tcz/$1.dep 
	fi	
			
	if [ -f $1.dep ]; then
		parsedep $1;
	fi
}

getAll() {
	while read p; do
		echo "Getting $p + Dependencies and unpacking to ../cpio"
		if [ ! -f $p ]; then
			wget http://tinycorelinux.net/9.x/armv7/tcz/$p
		fi

		if [ -f $p ]; then
			unpack $p;
		fi

		if [ ! -f $p.dep ]; then
			wget -q http://tinycorelinux.net/9.x/armv7/tcz/$p.dep
		fi	

		if [ -f $p.dep ]; then
			parsedep $p;
		fi
	done < $1
}

cd optional

echo $1
if [ -f "$1" ]; then
	getAll $1
else
	echo "Getting $1 + Dependencies and unpacking to ../cpio"
	getOne $1
fi


