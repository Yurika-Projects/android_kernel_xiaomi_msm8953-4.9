# Nito CI Script
# Copyright (C) 2019 Lau (laststandrighthere)
#                    urK -kernelaesthesia- (Z5X67280@163.com)
# SPDX-License-Identifier: GPL-3.0-or-later

git clone https://github.com/fabianonline/telegram.sh telegram
TELEGRAM_ID=-1001190342733
TELEGRAM=telegram/telegram
TELEGRAM_TOKEN=${BOT_API_KEY}

export TELEGRAM_TOKEN
# Push kernel installer to channel
function push() {
	JIP="$PWD/Nito Kernel CI.zip"
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
	tg_sendinfo "$(echo -e "Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds\nbut it's error...")"
	exit 1
}

# Send Sticker
function tg_sendstick() {
	curl -s -X POST "https://api.telegram.org/bot$BOT_API_KEY/sendSticker" \
		-d sticker="CAADAQADDgEAAtYvmwa3XVlL__xsuwl" \
		-d chat_id="$TELEGRAM_ID" >> /dev/null
}

# Fin prober
function fin() {
	tg_sendinfo "$(echo "Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.")"
}


DATE=`date`
BUILD_START=$(date +"%s")

tg_sendstick

tg_channelcast "<b>Nito</b> Kernel CI new build!" \
		"Under commit <code>$(git log --pretty=format:'"%h : %s"' -1)</code>" \
		"Started on <code>$(date)</code>"

export ARCH=arm64
export SUBARCH=arm64
export CROSS_COMPILE=$PWD/Toolchain/bin/aarch64-linux-android-
export KBUILD_BUILD_USER="urK -kernelaesthesia-"
export KBUILD_BUILD_HOST="-buildaesthesia- Travis-CI"

git clone https://aosp.tuna.tsinghua.edu.cn/platform/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9 Toolchain --depth=1

make O=out vince-perf_defconfig -j$(grep -c ^processor /proc/cpuinfo)
make O=out -j$(grep -c ^processor /proc/cpuinfo)

cp out/arch/arm64/boot/Image.gz nito-ak2/kernel
cp out/arch/arm64/boot/dts/qcom/msm8953-qrd-sku3-vince.dtb nito-ak2/kernel/treble
zip "Nito Kernel CI.zip" nito-ak2/

push
fin
done


