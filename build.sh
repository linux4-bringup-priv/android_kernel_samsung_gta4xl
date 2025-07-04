#!/usr/bin/env bash

# ================================
#   Kernel Build Script
# ================================

# Ortam değişkenleri
KERNEL_DIR=$(pwd)
DEFCONFIG=exynos9611-gta4xlwifi_defconfig
TOOLCHAIN_DIR=$KERNEL_DIR/toolchain
CLANG_PATH=$TOOLCHAIN_DIR/weebx
OUT_DIR=$KERNEL_DIR/out

# Temizleme
rm -rf "$OUT_DIR" "$TOOLCHAIN_DIR"
mkdir -p "$TOOLCHAIN_DIR"

# Toolchain indirme
echo ">>> WeebX Clang indiriliyor..."
wget "$(curl -s https://raw.githubusercontent.com/XSans0/WeebX-Clang/main/main/link.txt)" -O weebx-clang.tar.gz
tar -xvf weebx-clang.tar.gz -C "$TOOLCHAIN_DIR"
rm weebx-clang.tar.gz

# Out klasörü
mkdir -p "$OUT_DIR"

# Derleme ortamı
export ARCH=arm64
export SUBARCH=arm64
export CROSS_COMPILE="$CLANG_PATH/bin/aarch64-linux-gnu-"
export CLANG_TRIPLE="$CLANG_PATH/bin/aarch64-linux-gnu-"
export PATH="$CLANG_PATH/bin:$PATH"

# Config
echo ">>> Defconfig uygulanıyor: $DEFCONFIG"
make O="$OUT_DIR" "$DEFCONFIG"

# Derleme
echo ">>> Kernel derleniyor..."
make -j$(nproc --all) O="$OUT_DIR" \
    CC=clang \
    LD=ld.lld \
    AR=llvm-ar \
    NM=llvm-nm \
    OBJCOPY=llvm-objcopy \
    OBJDUMP=llvm-objdump \
    STRIP=llvm-strip

# Sonuç
if [ -f "$OUT_DIR/arch/arm64/boot/Image" ]; then
    echo ">>> ✔ Kernel başarıyla derlendi!"
else
    echo ">>> ❌ Kernel derlemesi başarısız oldu."
fi
