#!/bin/bash -e
if [ ! -d ${ROOTFS_DIR} ]; then
    update-binfmts --enable "qemu-arm"
	bootstrap jessie ${ROOTFS_DIR} http://mirrordirector.raspbian.org/raspbian/
fi
