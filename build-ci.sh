#!/bin/bash

# Nito CI Script
# Copyright (C) 2019 urK -kernelaesthesia- (Z5X67280@163.com)
# Copyright (C) 2019 Raphiel Rollerscaperers (raphielscape)
# Copyright (C) 2019 Rama Bondan Prakoso (rama982) 
# SPDX-License-Identifier: GPL-3.0-or-later

#
# Telegram FUNCTION begin
#

git clone https://github.com/fabianonline/telegram.sh telegram

TELEGRAM_ID=-1001346873717
TELEGRAM=telegram/telegram
BOT_API_KEY=723044228:AAFpmF9aHsMTinCJ7Yq3HLxEzjEBiO47rlU
TELEGRAM_TOKEN=${BOT_API_KEY}

export TELEGRAM_TOKEN

# Push kernel installer to channel
function push() {
	JIP="Nito-Kernel-CI.zip"
	curl -F document=@$JIP  "https://api.telegram.org/bot$BOT_API_KEY/sendDocument" \
			-F chat_id="$TELEGRAM_ID"
}

# Send the info up
function tg_channelcast() {
	"${TELEGRAM}" -c ${TELEGRAM_ID} -H \
		"$(
			for POST in "${@}"; do
				echo "${POST}"
			done
		)"
}

function tg_sendinfo() {
	curl -s "https://api.telegram.org/bot$BOT_API_KEY/sendMessage" \
		-d "parse_mode=markdown" \
		-d text="${1}" \
		-d chat_id="$TELEGRAM_ID" \
		-d "disable_web_page_preview=true"
}

# Errored prober
function finerr() {
	tg_channelcast "<b>Build fail...</b>" \
	"Use $(($DIFF / 60)) min $(($DIFF % 60)) sec." \
	"Check build log to fix compile error!" \
	"—— <b>Nito CI Bot</b>"
	exit 1
}

# Send sticker
function tg_sendstick() {
	curl -s -X POST "https://api.telegram.org/bot$BOT_API_KEY/sendSticker" \
		-d sticker="CAADAQADDgEAAtYvmwa3XVlL__xsuwI" \
		-d chat_id="$TELEGRAM_ID" >> /dev/null
}

# Fin prober
function fin() {
	tg_channelcast "<b>Build done!</b>" \
	"Use $(($DIFF / 60)) min $(($DIFF % 60)) sec!" \
	"—— <b>Nito CI Bot</b>"
}

#
# Telegram FUNCTION end
#

export DATE=`date`
export BUILD_START=$(date +"%s")

tg_sendstick

tg_channelcast "<b>Nito Kernel</b> new build!" \
		"Started on <b>$(hostname)</b>" \
		"Under commit <b>$(git log --pretty=format:'"%h : %s"' -1)</b>" \
		"Started on <b>$(date)</b>" \
		"受け取る準備をしてください!キャプテン!" \
		"—— <b>Nito CI Bot</b>"

export ARCH=arm64
export SUBARCH=arm64
export CC=$PWD/Clang/bin/clang
export CLANG_TREPLE=aarch64-linux-gnu-
export CROSS_COMPILE=$PWD/Toolchain/bin/aarch64-linux-gnu-
export KBUILD_BUILD_USER="urK -kernelaesthesia-"
export KBUILD_BUILD_HOST="-buildaesthesia- Travis-CI"

# export BUILD_TIME=$(date +"%Y%m%d-%T")
export IMG=$PWD/out/arch/arm64/boot/Image.gz-dtb
# export DTB=$PWD/out/arch/arm64/boot/dts/qcom/msm8953-qrd-sku3-vince.dtb

git clone https://github.com/SomeFeaKOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-gnueabi-9.0 Toolchain --depth=1
git clone https://github.com/nibaji/DragonTC-9.0 --depth=1 Clang

git submodule init
git submodule update

make O=out vince-perf_defconfig -j$(grep -c '^processor' /proc/cpuinfo)
make O=out -j$(grep -c '^processor' /proc/cpuinfo)

if ! [ -a out/arch/arm64/boot/Image.gz-dtb ]; then
	echo -e "Kernel compilation failed, See buildlog to fix errors"
	finerr
	exit 127
fi

cp $IMG nito-ak2/
cd nito-ak2/
zip -r9 "Nito-Kernel-CI.zip" *
echo "Flashable zip generated."

export BUILD_END=$(date +"%s")
export DIFF=$(($BUILD_END - $BUILD_START))

push
cd ..
fin

echo "Build done!"

