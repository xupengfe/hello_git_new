It's learned from link: https://www.kernel.org/doc/html/latest/x86/microcode.html

And improve above link mentioned script as follow points:
1. Avoid to copy several cpio files into initramfs files if execute script
  more than 2 times.
2. Improve the print info.


Steps:
1. Download the ucode zip file.
2. unzip the zip file
3. Only copy the .pdb file into /lib/firmware/intel-ucode,  make sure there is
   no old pcb file in /lib/firmware/intel-ucode folder
4. Execute script:
   # ./early_load_ucode.sh /boot/initramfs-xxx.img
   If you see "Done.", it means update early ucode successfully.
   If no, please check above print info and do above action and execute
   script again.