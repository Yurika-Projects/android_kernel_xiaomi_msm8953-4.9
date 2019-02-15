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
TELEGRAM_TOKEN=${BOT_API_KEY}

export TELEGRAM_TOKEN

# Push kernel installer to channel
function push() {
	JIP="Nito Kernel CI.zip"
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

# Send sticker
function tg_sendstick() {
	curl -s -X POST "https://api.telegram.org/bot$BOT_API_KEY/sendSticker" \
		-d sticker="CAADAQADDgEAAtYvmwa3XVlL__xsuwI" \
		-d chat_id="$TELEGRAM_ID" >> /dev/null
}

# Fin prober
function fin() {
	tg_sendinfo "$(echo "Build took $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.")"
}

#
# Telegram FUNCTION end
#

tg_sendstick

tg_channelcast "<b>Nito Kernel</b> new build!" \
		"Started on <code>$(hostname)</code>" \
		"For device </b>Redmi 5 Plus</b>" \
		"At branch <code>9.0-caf-upstream</code>" \
		"Under commit <code>$(git log --pretty=format:'"%h : %s"' -1)</code>" \
		"Started on <code>$(date)</code>"

export ARCH=arm64
export SUBARCH=arm64
export CC=$PWD/Clang/bin/clang
export CLANG_TREPLE=aarch64-linux-gnu-
export CROSS_COMPILE=$PWD/Toolchain/bin/aarch64-linux-android-
export KBUILD_BUILD_USER="urK -kernelaesthesia-"
export KBUILD_BUILD_HOST="-buildaesthesia- Travis-CI"

git clone https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 Toolchain --depth=1
git clone https://github.com/nibaji/DragonTC-9.0 --depth=1 Clang

make O=out vince-perf_defconfig -j96
make O=out -j96

mkdir nito-ak2/kernel
mkdir nito-ak2/kernel/treble
cp out/arch/arm64/boot/Image.gz nito-ak2/kernel/
cp out/arch/arm64/boot/dts/qcom/msm8953-qrd-sku3-vince.dtb nito-ak2/kernel/treble/
cd nito-ak2/
zip "Nito Kernel CI.zip" *
push
cd ..

fin
echo "Build done!"
