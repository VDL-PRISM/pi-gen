FROM debian:jessie
MAINTAINER Philip Lundrigan <philipbl@cs.utah.edu>

RUN apt-get update && apt-get upgrade -y && apt-get install -y \
  git \
  quilt \
  qemu-user-static \
  debootstrap \
  kpartx \
  zerofree \
  pxz \
  zip \
  dosfstools && \
  rm -rf /var/lib/apt/lists/*

COPY . /build

CMD cd /build && ./build_base.sh && ./build_prisms.sh
