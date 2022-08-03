#!/bin/bash

if [ -z "$1" ]; then
  echo "You need to supply an initrd(catually it's a /boot/initramfs-xxx) file"
  exit 1
fi

INITRD="$1"

DSTDIR=kernel/x86/microcode
TMPDIR=/tmp/initrd

echo "Clean first: rm -rf $TMPDIR"
rm -rf $TMPDIR

echo "mkdir $TMPDIR"
mkdir "$TMPDIR"
echo "cd $TMPDIR"
cd "$TMPDIR"
echo "mkdir -p $DSTDIR"
mkdir -p "$DSTDIR"

if [ -d "/lib/firmware/amd-ucode" ]; then
        cat /lib/firmware/amd-ucode/microcode_amd*.bin > $DSTDIR/AuthenticAMD.bin
fi

echo "Files in /lib/firmware/intel-ucode:"
ls -ltra "/lib/firmware/intel-ucode"

if [ -d "/lib/firmware/intel-ucode" ]; then
  echo "Please make sure pdb file in /lib/firmware/intel-ucode!!! Otherwise early ucode load will be failed!"
  echo "cat /lib/firmware/intel-ucode/*.pdb > $DSTDIR/GenuineIntel.bin"
        cat /lib/firmware/intel-ucode/*.pdb > $DSTDIR/GenuineIntel.bin
fi

find . | cpio -o -H newc >../ucode.cpio
cd ..
if [[  -e "$INITRD.orig" ]]; then
  echo "There is origin initramfs file:$INITRD.orig! Backup it into /tmp"
  cp -rf "${INITRD}.orig" /tmp
  echo "Please recover the orign $INITRD file and delete $INITRD.orig and try again!"
  exit 2
fi
echo "mv $INITRD $INITRD.orig"
mv $INITRD $INITRD.orig
echo "cat ucode.cpio $INITRD.orig > $INITRD"
cat ucode.cpio $INITRD.orig > $INITRD

ls -ltra ${INITRD}*

echo "Done."
#rm -rf $TMPDIR
