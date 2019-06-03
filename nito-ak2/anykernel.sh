# AnyKernel2 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=Nito Kernel Install
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=1
supported.versions=28
device.name1=vince
'; } # end properties

# shell variables
block=/dev/block/mmcblk0p21;
ramdisk_compression=auto;
is_slot_device=0;


## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. /tmp/anykernel/tools/ak2-core.sh;


## AnyKernel file attributes
# set permissions/ownership for included ramdisk files


## AnyKernel install
dump_boot;

# begin ramdisk changes


# end ramdisk changes

write_boot;

about_nito;

## end install

