# Nito CI Script
# Copyright (C) 2019 urK -kernelaesthesia- (Z5X67280@163.com)
# SPDX-License-Identifier: GPL-3.0-or-later

export ARCH=arm64
export SUBARCH=arm64
export CROSS_COMPILE=$PWD/Toolchain/bin/aarch64-linux-android-
export KBUILD_BUILD_USER="urK -kernelaesthesia-"
export KBUILD_BUILD_HOST="-buildaesthesia- Travis-CI"

git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 Toolchain --depth=1

make O=out vince-perf_defconfig -j64
make O=out -j64

cp out/arch/arm64/boot/Image.gz nito-ak2/kernel
cp out/arch/arm64/boot/dts/qcom/msm8953-qrd-sku3-vince.dtb nito-ak2/kernel/treble
zip "Nito Kernel CI.zip" nito-ak2/

echo "Build done!"
