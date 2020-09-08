#! /bin/bash
# Copyright (C) 2018 Abubakar Yagob (blacksuan19)
# Copyright (C) 2018 Rama Bondan Prakoso (rama982)
# Copyright (C) 2019 Dhimas Bagus Prayoga (Kry9toN)
# Copyright (C) 2020 StarLight5234
# Copyright (C) 2020 William Zambrano (willizambrano)
# SPDX-License-Identifier: GPL-3.0-or-later
#

DATE=`date`
BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

echo -e "\n###############################################################"

# Is this logo
echo -e "$cyan-----------------------------------------------------------------------";
echo -e "-----------------------------------------------------------------------";
echo -e "   _____   ______   _____    ____    ______   _____    _    _    _____ "; 
echo -e "  / ____| |  ____| |  __ \  |  _ \  |  ____| |  __ \  | |  | |  / ____|";
echo -e " | |      | |__    | |__) | | |_) | | |__    | |__) | | |  | | | (___  ";
echo -e " | |      |  __|   |  _  /  |  _ <  |  __|   |  _  /  | |  | |  \___ \ ";
echo -e " | |____  | |____  | | \ \  | |_) | | |____  | | \ \  | |__| |  ____) |";
echo -e "  \_____| |______| |_|  \_\ |____/  |______| |_|  \_\  \____/  |_____/ ";
echo -e "                                                                       "; 
echo -e "-----------------------------------------------------------------------";
echo -e "-----------------------------------------------------------------------$nocol";
echo -e ""
sleep 5

echo -e "#=============================================================="
echo -e "#========================= Cleaning ==========================="
echo -e "#========================== Source ============================"
echo -e "#=============================================================="

make clean
make mrproper
rm -rf out/*

echo -e "\n###############################################################"

# Main Environment
KERNEL_DIR=/home/william/Kernel_vince/cerbnitobase
KERN_IMG=$KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb
ZIP_DIR=/home/william/Kernel_vince/AnyKernel-vince
CONFIG_DIR=$KERNEL_DIR/arch/arm64/configs
CONFIG=vince_defconfig
CORES=$(grep -c ^processor /proc/cpuinfo)
THREAD="-j$CORES"
CROSS_COMPILE=/home/toolchains/gcc64/bin/aarch64-elf-
CROSS_COMPILE_ARM32=/home/toolchains/gcc32/bin/arm-eabi-

# Export
export KBUILD_BUILD_USER="willizambrano"  
export KBUILD_BUILD_HOST="william-pc"
export ARCH=arm64
export SUBARCH=arm64
export CROSS_COMPILE=/home/toolchains/gcc64/bin/aarch64-elf-
export CROSS_COMPILE_ARM32=/home/toolchains/gcc32/bin/arm-eabi-

echo -e "$cyan#=============================================================="
echo -e "#=========================== Make ============================="
echo -e "#========================== Kernel ============================"
echo -e "#==============================================================$nocol"

make  O=out $CONFIG $THREAD 
make  O=out $THREAD

echo -e "\n###############################################################"

echo -e "\n#=============================================================="
echo -e "#=========================== Make ============================="
echo -e "#========================== zImage ============================"
echo -e "\n#=============================================================="
sleep 3

cd $ZIP_DIR
	make clean &>/dev/null
	cp $KERN_IMG $ZIP_DIR/zImage
	make normal &>/dev/null
	cd ..

echo -e " Flashable zip generated under $ZIP_DIR "

echo -e "\n###############################################################"
sleep 3



BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow Kernel compiled on $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds$nocol"

