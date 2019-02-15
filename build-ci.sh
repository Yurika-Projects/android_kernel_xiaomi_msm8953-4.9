# Nito CI Script
# Copyright (C) 2019 urK -kernelaesthesia- (Z5X67280@163.com)
# SPDX-License-Identifier: GPL-3.0-or-later

export ARCH=arm64
export SUBARCH=arm64
export CROSS_COMPILE=$PWD/Toolchain/bin/aarch64-linux-android-
export KBUILD_BUILD_USER="urK -kernelaesthesia-"
export KBUILD_BUILD_HOST="-buildaesthesia- Travis-CI"

git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 Toolchain --depth=1

make O=out vince-perf_defconfig -j96
make O=out -j96

mkdir nito-ak2/kernel
mkdir nito-ak2/kernel/treble
cp out/arch/arm64/boot/Image.gz nito-ak2/kernel/
cp out/arch/arm64/boot/dts/qcom/msm8953-qrd-sku3-vince.dtb nito-ak2/kernel/treble/
cd nito-ak2/
zip "Nito Kernel CI.zip" *

echo "Build done!"
