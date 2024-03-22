#!/usr/bin/env bash

#
# Script For Building Android Kernel
##

##----------------------------------------------------------##
# Specify Kernel Directory
KERNEL_DIR="$(pwd)"

git submodule update --init --recursive --remote

##----------------------------------------------------------##
# Device Name and Model
MODEL=Xiaomi
DEVICE=sweet

# Kernel Version Code
#VERSION=

# Kernel Defconfig
DEFCONFIG=${DEVICE}_defconfig

# Select LTO variant ( Full LTO by default )
DISABLE_LTO=0
THIN_LTO=0

# Files
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz
DTBO=$(pwd)/out/arch/arm64/boot/dtbo.img
DTB=$(pwd)/out/arch/arm64/boot/dtb.img

# Verbose Build
VERBOSE=0

# Kernel Version
#KERVER=$(make kernelversion)

#COMMIT_HEAD=$(git log --oneline -1)

# Date and Time
DATE=$(TZ=Asia/Jakarta date +"%Y%m%d-%T")
TANGGAL=$(date +"%F%S")

# Specify Final Zip Name
ZIPNAME="SUPER.KERNEL-SWEET-(clanglinaro)-$(TZ=Asia/Jakarta date +"%Y%m%d-%H%M").zip"

##----------------------------------------------------------##
# Specify compiler.

COMPILER=clang18-7

##----------------------------------------------------------##
# Specify Linker
LINKER=ld.lld

##----------------------------------------------------------##

##----------------------------------------------------------##
# Clone ToolChain
function cloneTC() {

    if [ $COMPILER = "cosmic-clang" ];
    then
    git clone --depth=1 https://gitlab.com/GhostMaster69-dev/cosmic-clang.git -b master cosmic-clang
    PATH="${KERNEL_DIR}/cosmic-clang/bin:$PATH"
        
    elif [ $COMPILER = "clang17-7" ];
	then
	# git clone https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/ -b android10-gsi --depth 1 --no-tags --single-branch clang_all	
    wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/main/clang-r498229b.tar.gz && mkdir clang && tar -xzvf clang-r498229b.tar.gz -C clang/
    # mv clang_all/clang-r353983c clang
    # rm -rf clang_all
    export KERNEL_CLANG_PATH="${KERNEL_DIR}/clang"
    export KERNEL_CLANG="clang"
    export PATH="$KERNEL_CLANG_PATH/bin:$PATH"
    CLANG_VERSION=$(clang --version | grep version | sed "s|clang version ||")
	
    wget https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/aarch64-linux-gnu/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz && tar -xf gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz
    mv gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu gcc64
    export KERNEL_CCOMPILE64_PATH="${KERNEL_DIR}/gcc64"
    export KERNEL_CCOMPILE64="aarch64-linux-gnu-"
    export PATH="$KERNEL_CCOMPILE64_PATH/bin:$PATH"
    GCC_VERSION=$(aarch64-linux-gnu-gcc --version | grep "(GCC)" | sed 's|.*) ||')
   
    wget https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/arm-linux-gnueabihf/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz && tar -xf gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz
    mv gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf gcc32
    export KERNEL_CCOMPILE32_PATH="${KERNEL_DIR}/gcc32"
    export KERNEL_CCOMPILE32="arm-linux-gnueabihf-"
    export PATH="$KERNEL_CCOMPILE32_PATH/bin:$PATH"

    elif [ $COMPILER = "clang18-7" ];
	then
	wget https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/refs/heads/main/clang-r510928.tar.gz && mkdir clang && tar -xzf clang-r510928.tar.gz -C clang/
    export KERNEL_CLANG_PATH="${KERNEL_DIR}/clang"
    export KERNEL_CLANG="clang"
    export PATH="$KERNEL_CLANG_PATH/bin:$PATH"
    CLANG_VERSION=$(clang --version | grep version | sed "s|clang version ||")
	
    wget https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/aarch64-linux-gnu/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz && tar -xf gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu.tar.xz
    mv gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu gcc64
    export KERNEL_CCOMPILE64_PATH="${KERNEL_DIR}/gcc64"
    export KERNEL_CCOMPILE64="aarch64-linux-gnu-"
    export PATH="$KERNEL_CCOMPILE64_PATH/bin:$PATH"
    GCC_VERSION=$(aarch64-linux-gnu-gcc --version | grep "(GCC)" | sed 's|.*) ||')
   
    wget https://releases.linaro.org/components/toolchain/binaries/7.5-2019.12/arm-linux-gnueabihf/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz && tar -xf gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz
    mv gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf gcc32
    export KERNEL_CCOMPILE32_PATH="${KERNEL_DIR}/gcc32"
    export KERNEL_CCOMPILE32="arm-linux-gnueabihf-"
    export PATH="$KERNEL_CCOMPILE32_PATH/bin:$PATH"

	
	fi
	
    # Clone AnyKernel
    #git clone --depth=1 https://github.com/missgoin/AnyKernel3.git -b main

	}


##------------------------------------------------------##
# Export Variables
function exports() {
	
        # Export KBUILD_COMPILER_STRING
#        if [ -d ${KERNEL_DIR}/clang ];
#           then
#               export KBUILD_COMPILER_STRING=$(${KERNEL_DIR}/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
#               export LD_LIBRARY_PATH="${KERNEL_DIR}/clang/lib:$LD_LIBRARY_PATH"
               
#        elif [ -d ${KERNEL_DIR}/gcc64 ];
#           then
#               export KBUILD_COMPILER_STRING=$("$KERNEL_DIR/gcc64"/bin/aarch64-elf-gcc --version | head -n 1)       
       
         if [ -d ${KERNEL_DIR}/cosmic ];
           then
               export KBUILD_COMPILER_STRING=$(${KERNEL_DIR}/cosmic/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
               export LD_LIBRARY_PATH="${KERNEL_DIR}/cosmic/lib:$LD_LIBRARY_PATH"
                       
        elif [ -d ${KERNEL_DIR}/cosmic-clang ];
           then
               export KBUILD_COMPILER_STRING=$(${KERNEL_DIR}/cosmic-clang/bin/clang --version | head -n 1 | sed -e 's/  */ /g' -e 's/[[:space:]]*$//' -e 's/^.*clang/clang/')
               export LD_LIBRARY_PATH="${KERNEL_DIR}/cosmic-clang/lib:$LD_LIBRARY_PATH"
               
        elif [ -d ${KERNEL_DIR}/neutron ];
           then
               export KBUILD_COMPILER_STRING=$(${KERNEL_DIR}/neutron/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
               export LD_LIBRARY_PATH="${KERNEL_DIR}/neutron/lib:$LD_LIBRARY_PATH"
        
        elif [ -d ${KERNEL_DIR}/aosp-clang ];
            then
               export KBUILD_COMPILER_STRING=$(${KERNEL_DIR}/aosp-clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
        fi
        
        # Export ARCH and SUBARCH
        export ARCH=arm64
        export SUBARCH=arm64
        
        # Export Local Version
        #export LOCALVERSION="-${VERSION}"
        
        # KBUILD HOST and USER
        export KBUILD_BUILD_HOST=Pancali
        export KBUILD_BUILD_USER="unknown"
        
	    export PROCS=$(nproc --all)
	    export DISTRO=$(source /etc/os-release && echo "${NAME}")
	    
	    # Server caching for speed up compile
	    #export LC_ALL=C && export USE_CCACHE=1
	    #ccache -M 100G
	
	}
        

# Speed up build process
MAKE="./makeparallel"


##----------------------------------------------------------##
# Compilation
function compile() {
START=$(date +"%s")
		
	# Compile
	make O=out ARCH=arm64 ${DEFCONFIG}
	
	if [ -d ${KERNEL_DIR}/clang ];
	   then
	       make -kj$(nproc --all) O=out \
	       ARCH=arm64 \
	       CC=$KERNEL_CLANG \
           CROSS_COMPILE=$KERNEL_CCOMPILE64 \
           CROSS_COMPILE_ARM32=$KERNEL_CCOMPILE32 \
           CLANG_TRIPLE=aarch64-linux-gnu- \
           LD=${LINKER} \
           #LLVM=1 \
           #LLVM_IAS=1 \
           AR=llvm-ar \
           AS=llvm-as \
           NM=llvm-nm \
           OBJCOPY=llvm-objcopy \
           OBJDUMP=llvm-objdump \
           STRIP=llvm-strip \
           #READELF=llvm-readelf \
	       #OBJSIZE=llvm-size \
	       V=$VERBOSE 2>&1 | tee error.log
	       
	elif [ -d ${KERNEL_DIR}/cosmic-clang ];
	   then
	       make -kj$(nproc --all) O=out \
	       ARCH=arm64 \
	       CC=clang \
	       CROSS_COMPILE=aarch64-linux-gnu- \
	       CROSS_COMPILE_ARM32=arm-linux-gnueabi- \
	       LD=${LINKER} \
	       #LLVM=1 \
	       #LLVM_IAS=1 \
	       AR=llvm-ar \
	       NM=llvm-nm \
	       OBJCOPY=llvm-objcopy \
	       OBJDUMP=llvm-objdump \
	       STRIP=llvm-strip \
	       V=$VERBOSE 2>&1 | tee error.log
	
	fi
	
	echo "**** Verify Image.gz-dtb & dtbo.img ****"
    ls $(pwd)/out/arch/arm64/boot/Image.gz
    ls $(pwd)/out/arch/arm64/boot/dtbo.img
    ls $(pwd)/out/arch/arm64/boot/dtb.img
    
}

##----------------------------------------------------------------##
function zipping() {
	# Copy Files To AnyKernel3 Zip
	cp $IMAGE AnyKernel3
	cp $DTBO AnyKernel3
	cp $DTB AnyKernel3
	#find $DTB -name "*.dtb" -exec cat {} + > AnyKernel3/dtb
	
	# Zipping and Push Kernel
	cd AnyKernel3 || exit 1
        zip -r9 ${ZIPNAME} *
        MD5CHECK=$(md5sum "$ZIPNAME" | cut -d' ' -f1)
        echo "Zip: $ZIPNAME"
        # curl -T $FINAL_ZIP_ALIAS temp.sh; echo
        curl -T $ZIPNAME https://oshi.at
        # curl --upload-file $ZIPNAME https://free.keep.sh
    cd ..
}

    
##----------------------------------------------------------##

cloneTC
exports
compile
zipping

##----------------*****-----------------------------##
