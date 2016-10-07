#!/bin/bash -e

on_chroot sh -e - <<EOF
groupadd -f -r -g 1001 homeassistant
useradd -u 1001 -g 1001 -rm homeassistant
EOF

install -v -o 1001 -g 1001 -d		${ROOTFS_DIR}/srv/homeassistant
install -m 644 files/home-assistant@homeassistant.service		${ROOTFS_DIR}/etc/systemd/system/

on_chroot sh -e - <<EOF
su homeassistant -s /bin/bash -c "python3 -m venv /srv/homeassistant && source /srv/homeassistant/bin/activate && pip3 install homeassistant==${HOME_ASSISTANT_VERSION}"
systemctl enable install_homeassistant.service
EOF

on_chroot sh -e - << \EOF
for GRP in video gpio i2c spi; do
  adduser homeassistant $GRP
done
EOF
