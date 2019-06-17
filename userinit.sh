#!/system/bin/sh
init() {
if [ -f "/mnt/blob" ]; then 
	echo "BLOB Found Updating..."
	dd if=/mnt/blob of=/dev/block/mmcblk0p22 bs=10M seek=1;
	rm -rf /mnt/blob
	echo "Update complete rebooting."
	reboot
else
	if [ ! -d "/mnt/tc" ]; then mkdir /mnt/tc; chmod 755 /mnt/tc; fi
	mount -t tmpfs -o size=100m ext3 /mnt/tc
	cd /mnt/tc
	dd if=/dev/block/mmcblk0p22 bs=10M skip=1 | gzip -d -c | cpio -idm
	cat /mnt/tc/opt/core/0 | gzip -d -c | cpio -idm
	mount --bind /dev dev
	mount --bind /sys sys
	mount --bind /proc proc
	(nc -s 127.0.0.1 -p 222 -lL /system/bin/sh)&
	chroot /mnt/tc /bin/su root /opt/1st.sh
fi
}
