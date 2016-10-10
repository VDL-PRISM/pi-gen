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

if [ -z "${OUTPUT_BASE_DIR}" ]; then
    echo "OUTPUT_BASE_DIR not set" 1>&2
    exit 1
fi

export IMG_DATE=${IMG_DATE:-"$(date -u +%Y-%m-%d)"}
export BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export WORK_DIR="${BASE_DIR}/work/${IMG_DATE}-${IMG_NAME}"

# Skip all stages except for the base ones
for STAGE_DIR in ${BASE_DIR}/stage*; do
    if [[ ${BASE_STAGES} != *$(basename ${STAGE_DIR})* ]]; then
        echo "" > ${STAGE_DIR}/SKIP
    fi
done

# Build the base rootfs
./build

# Copy rootfs from last stage
array=($BASE_STAGES)
last_stage=${array[${#array[@]}-1]}
mkdir ${BASE_DIR}/${OUTPUT_BASE_DIR}/rootfs
rsync -aHAX ${WORK_DIR}/${last_stage}/rootfs ${BASE_DIR}/${OUTPUT_BASE_DIR}/rootfs

# Remove all skips
for STAGE_DIR in ${BASE_DIR}/stage*; do
    if [[ ${BASE_STAGES} != *$(basename ${STAGE_DIR})* ]]; then
        rm ${STAGE_DIR}/SKIP
    fi
done
