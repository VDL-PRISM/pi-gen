#!/bin/bash -e

if [ -f config ]; then
    source config
fi

if [ -z "${IMG_NAME}" ]; then
    echo "IMG_NAME not set" 1>&2
    exit 1
fi

if [ -z "${BASE_STAGES}" ]; then
    echo "BASE_STAGES not set" 1>&2
    exit 1
fi

if [ -z "${EXPORT_BASE_DIR}" ]; then
    echo "EXPORT_BASE_DIR not set" 1>&2
    exit 1
fi

array=($BASE_STAGES)
export LAST_STAGE=${array[${#array[@]}-1]}
export IMG_DATE=${IMG_DATE:-"$(date -u +%Y-%m-%d)"}
export BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export WORK_DIR="${BASE_DIR}/work/${IMG_DATE}-${IMG_NAME}"
export EXPORT_ROOTFS_DIR="${BASE_DIR}/${EXPORT_BASE_DIR}/rootfs"
export LAST_STAGE_ROOTFS_DIR="${WORK_DIR}/${LAST_STAGE}/rootfs"

# Check to see if base dir is there and if not, download it!

# Make sure all SKIPs have been removed
for STAGE_DIR in ${BASE_DIR}/stage*; do
    rm -f ${STAGE_DIR}/SKIP
done

# Skip all stages except for the base ones
for STAGE_DIR in ${BASE_DIR}/stage*; do
    if [[ ${BASE_STAGES} == *$(basename ${STAGE_DIR})* ]]; then
        echo "" > ${STAGE_DIR}/SKIP
    fi
done

# Copy rootfs from export area
mkdir -p ${LAST_STAGE_ROOTFS_DIR}
rsync -aHAX ${EXPORT_ROOTFS_DIR} ${LAST_STAGE_ROOTFS_DIR}

# Build the PRISMS image
./build.sh

# Skip all stages except for the base ones
for STAGE_DIR in ${BASE_DIR}/stage*; do
    if [[ ${BASE_STAGES} == *$(basename ${STAGE_DIR})* ]]; then
        rm ${STAGE_DIR}/SKIP
    fi
done
