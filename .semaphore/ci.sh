#!/bin/bash

# Nito CI Script v2
# Copyright (C) 2019 urK -kernelaesthesia- (Z5X67280@163.com)
# Copyright (C) 2019 Raphiel Rollerscaperers (raphielscape)
# Copyright (C) 2019 Rama Bondan Prakoso (rama982) 
# SPDX-License-Identifier: GPL-3.0-or-later

#
# Telegram FUNCTION begin
#

git clone https://github.com/fabianonline/telegram.sh telegram

TELEGRAM_ID=-1001268516549
TELEGRAM=telegram/telegram
BOT_API_KEY=723044228:AAFpmF9aHsMTinCJ7Yq3HLxEzjEBiO47rlU
TELEGRAM_TOKEN=${BOT_API_KEY}

export TELEGRAM_TOKEN

# Push kernel installer to channel
function push() {
	JIP="Nito-Kernel-CI-$BUILD_TIME.zip"
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

# Send sticker
function tg_sendstick() {
	curl -s -X POST "https://api.telegram.org/bot$BOT_API_KEY/sendSticker" \
		-d sticker="CAADAQADDgEAAtYvmwa3XVlL__xsuwI" \
		-d chat_id="$TELEGRAM_ID" >> /dev/null
}

# Fin prober
function fin() {
	tg_channelcast "<b>Build done!</b>" \
	"Use $(($DIFF / 60)) min $(($DIFF % 60)) sec!"
}

# Errored prober
function finerr() {
	tg_channelcast "<b>Build fail...</b>" \
	"Used $(($DIFF / 60)) min $(($DIFF % 60)) sec." \
	"Check build log to fix compile error!"
	exit 1
}

#
# Telegram FUNCTION end
#

export DATE=`date`
export BUILD_START=$(date "+%s")

tg_sendstick

tg_channelcast "<b>Nito Kernel</b> new build!" \
		"Started on <b>Ubuntu 16.04 LTS (Xenial)</b>" \
		"From <b>lite (Nito Kernel Lite Sildeline)</b>" \
		"Under commit <b>$(git log --pretty=format:'"%h : %s"' -1)</b>" \
		"Started on <b>$(date)</b>"

export ARCH=arm64
export SUBARCH=arm64
export CC=$PWD/Clang/bin/clang
export CLANG_TREPLE=aarch64-linux-gnu-
export USE_CCACHE=1
export CROSS_COMPILE="$PWD/Toolchain/bin/aarch64-opt-linux-android-"
export KBUILD_BUILD_USER="urK -kernelaesthesia-"
export KBUILD_BUILD_HOST="-buildaesthesia- Travis-CI"
export KBUILD_COMPILER_STRING=$($CC --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
export IMG=$PWD/out/arch/arm64/boot/Image.gz-dtb

git clone https://github.com/krasCGQ/aarch64-linux-android -b opt-gnu-8.x --depth=1 Toolchain
git clone https://github.com/Z5X67280/aosp-clang-mirror --depth=1 Clang

make O=out vince-perf_defconfig -j32
make O=out -j32

if ! [ -a out/arch/arm64/boot/Image.gz-dtb ]; then
	echo -e "Kernel compilation failed, See buildlog to fix errors"
	finerr
	exit 127
fi

export BUILD_END=$(date "+%s")
export DIFF=$(($BUILD_END - $BUILD_START))

export BUILD_TIME=$(date "+%Y%m%d-%H:%M:%S-$(git log --pretty=format:'%h' -1)")

cp $IMG nito-ak2/
cd nito-ak2/
zip -r9 -9 "Nito-Kernel-CI-$BUILD_TIME.zip" .
echo "Flashable zip generated."

tg_channelcast "Notes: Don't try install it on non-4.9 roms." \
	       "If u want to try, don't worry, I have already prepared Chopin’s songs for u."

push
cd ..
fin

echo "Build done!"

