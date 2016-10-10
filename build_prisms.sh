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

# Skip all stages except for the base ones
for STAGE_DIR in ${BASE_DIR}/stage*; do
    if [[ ${BASE_STAGES} == *$(basename ${STAGE_DIR})* ]]; then
        echo "" > ${STAGE_DIR}/SKIP
    fi
done

# Copy rootfs from export area
array=($BASE_STAGES)
last_stage=${array[${#array[@]}-1]}
mkdir ${WORK_DIR}/${last_stage}/rootfs
rsync -aHAX ${BASE_DIR}/${OUTPUT_BASE_DIR}/rootfs ${WORK_DIR}/${last_stage}/rootfs

# Build the PRISMS image
./build

# Skip all stages except for the base ones
for STAGE_DIR in ${BASE_DIR}/stage*; do
    if [[ ${BASE_STAGES} == *$(basename ${STAGE_DIR})* ]]; then
        rm ${STAGE_DIR}/SKIP
    fi
done
