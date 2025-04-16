#!/bin/bash
# Script outline to install and build kernel.
# Author: Siddhant Jajoo.

set -e
set -u

OUTDIR=/tmp/aeld
KERNEL_REPO=git://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git
KERNEL_VERSION=v5.15.163
BUSYBOX_VERSION=1_33_1
FINDER_APP_DIR=$(realpath $(dirname $0))
ARCH=arm64
TOOLCHAIN=/home/chiut/arm-gnu-toolchain/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/aarch64-none-linux-gnu
CROSS_COMPILE=aarch64-none-linux-gnu-

if [ $# -lt 1 ]
then
	echo "Using default directory ${OUTDIR} for output"
else
	OUTDIR=$(realpath $1)
	echo "Using passed directory ${OUTDIR} for output"
fi

ROOT_FS_DIR=$(realpath ${OUTDIR})/rootfs

mkdir -p ${OUTDIR}

cd "$OUTDIR"
if [ ! -d "${OUTDIR}/linux-stable" ]; then
    #Clone only if the repository does not exist.
	echo "CLONING GIT LINUX STABLE VERSION ${KERNEL_VERSION} IN ${OUTDIR}"
	git clone ${KERNEL_REPO} --depth 1 --single-branch --branch ${KERNEL_VERSION}
fi
if [ ! -e ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ]; then
    cd linux-stable
    echo "Checking out version ${KERNEL_VERSION}"
    git checkout ${KERNEL_VERSION}

    # TODO: Add your kernel build steps here

    make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
    make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} all
fi

echo "Adding the Image in outdir"
cp ${OUTDIR}/linux-stable/arch/${ARCH}/boot/Image ${OUTDIR}

echo "Creating the staging directory for the root filesystem"
cd "$OUTDIR"
if [ -d "${OUTDIR}/rootfs" ]
then
	echo "Deleting rootfs directory at ${OUTDIR}/rootfs and starting over"
    sudo rm  -rf ${OUTDIR}/rootfs
fi

# TODO: Create necessary base directories

if [ ! -d ${ROOT_FS_DIR} ]
then
    mkdir -p ${ROOT_FS_DIR} && cd ${ROOT_FS_DIR}
    
    mkdir -p bin dev etc home lib lib64 proc sbin sys tmp usr var
    mkdir -p usr/bin usr/sbin usr/lib
    mkdir -p var/log
fi

cd "$OUTDIR"

if [ ! -d "${OUTDIR}/busybox" ]
then
git clone git://busybox.net/busybox.git
    cd busybox
    git checkout ${BUSYBOX_VERSION}
    # TODO:  Configure busybox

    make -j4 ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} defconfig
    
else
    cd busybox
fi

# TODO: Make and install busybox
make distclean
make defconfig
make ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE}
make CONFIG_PREFIX=${ROOT_FS_DIR} ARCH=${ARCH} CROSS_COMPILE=${CROSS_COMPILE} install

cd ${ROOT_FS_DIR}

echo "Library dependencies"
${CROSS_COMPILE}readelf -a bin/busybox | grep "program interpreter"
${CROSS_COMPILE}readelf -a bin/busybox | grep "Shared library"

# TODO: Add library dependencies to rootfs
#ln -s ${TOOLCHAIN}/libc/lib/ld-linux-aarch64.so.1 lib/ld-linux-aarch64.so.1
#ln -s ${TOOLCHAIN}/libc/lib64/libm.so.6           lib64/libm.so.6
#ln -s ${TOOLCHAIN}/libc/lib64/libresolv.so.2      lib64/libresolv.so.2
#ln -s ${TOOLCHAIN}/libc/lib64/libc.so.6           lib64/libc.so.6
cp ${TOOLCHAIN}/libc/lib64/ld-2.33.so ./lib
mv ./lib/ld-2.33.so ./lib/ld-linux-aarch64.so.1
cp ${TOOLCHAIN}/libc/lib64/libm.so.6           ./lib64/
cp ${TOOLCHAIN}/libc/lib64/libresolv.so.2      ./lib64/
cp ${TOOLCHAIN}/libc/lib64/libc.so.6           ./lib64/

#cp ${FINDER_APP_DIR}/ld-linux-aarch64.so.1 lib
#cp ${FINDER_APP_DIR}/libm.so.6             lib64/
#cp ${FINDER_APP_DIR}/libresolv.so.2        lib64/
#cp ${FINDER_APP_DIR}/libc.so.6             lib64/



# TODO: Make device nodes
sudo mknod -m 666 dev/null c 1 3
#sudo mknod -m 666 dev/console c 1 5

# TODO: Clean and build the writer utility
make -C ${FINDER_APP_DIR} clean
make -C ${FINDER_APP_DIR} CROSS_COMPILE=aarch64-none-linux-gnu- 
mv ${FINDER_APP_DIR}/writer ${ROOT_FS_DIR}/home

# TODO: Copy the finder related scripts and executables to the /home directory
# on the target rootfs
cp ${FINDER_APP_DIR}/finder.sh ${ROOT_FS_DIR}/home
cp ${FINDER_APP_DIR}/finder-test.sh ${ROOT_FS_DIR}/home
cp ${FINDER_APP_DIR}/autorun-qemu.sh ${ROOT_FS_DIR}/home
mkdir -p ${ROOT_FS_DIR}/home/conf
cp ${FINDER_APP_DIR}/../conf/assignment.txt ${ROOT_FS_DIR}/home/conf
cp ${FINDER_APP_DIR}/../conf/username.txt ${ROOT_FS_DIR}/home/conf


# TODO: Chown the root directory
sudo chown root:root ${ROOT_FS_DIR}

# TODO: Create initramfs.cpio.gz
find . | cpio -H newc -ov --owner root:root > ${OUTDIR}/initramfs.cpio
cd ${OUTDIR}
gzip -kf initramfs.cpio