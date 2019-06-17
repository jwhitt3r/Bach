
./extract-tce.sh /home/munk/Desktop/tce/deps

cd cpio
find . -print -depth | cpio -vo -H newc | gzip > ../blob
cd ..

cp userinit.sh userinit.tmp
echo init `stat --printf=%s blob` >> userinit.tmp

adb shell su root chmod a+wx /mnt
adb shell su root chmod a+wx /data/local/userinit.sh
adb push blob /mnt/blob
adb push userinit.tmp /data/local/userinit.sh
adb shell su root /system/bin/sh /data/local/userinit.sh
rm userinit.tmp

echo SSH Password : `cat ~/Desktop/tce/cpio/opt/1st.sh | grep chpasswd`
