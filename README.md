Fork of `pi_gen` by [@RPI-Distro](https://github.com/RPi-Distro/pi-gen).

#Building your own
The Haspbian image is built with the same script that generates the official [Raspbian](https://www.raspberrypi.org/downloads/raspbian/) image's from the [Raspberry Pi Foundation](https://www.raspberrypi.org/about/).

By default the Haspbian image is built on a Debian 8 droplet on Digital Ocean and takes about 30 minutes to build in the cheapest droplet. Dependencies and everything is handled by the build script with the exception of `git`.

Build instructions:
- Install git and other dependencies: `sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get install git `
- Clone the `rpi_gen` code
- Run the build script, with sudo or as root: `sudo ./build.sh`
- Wait ~30 minutes for build to complete.
- Retrieve your freshly built Raspberry Pi image from the `rpi_gen\deploy` folder.


#Dependencies

`quilt kpartx realpath qemu-user-static debootstrap zerofree pxz zip dosfstools`

#Config

Upon execution, `build.sh` will source the file `config` in the current
working directory.  This bash shell fragment is intended to set needed
environment variables.

The following environment variables are supported:

 * `IMG_NAME`, the name of the distribution to build (required)
 * `APT_PROXY`, proxy/cache URL to be included in the build

A simple example for building Raspbian:

```bash
IMG_NAME='Raspbian'
```

#Raspbian Stage Overview

The build of Raspbian is divided up into several stages for logical clarity
and modularity.  This causes some initial complexity, but it simplifies
maintenance and allows for more easy customization.

 - Stage 0, bootstrap.  The primary purpose of this stage is to create a
   usable filesystem.  This is accomplished largely through the use of
   `debootstrap`, which creates a minimal filesystem suitable for use as a
   base.tgz on Debian systems.  This stage also configures apt settings and
   installs `raspberrypi-bootloader` which is missed by debootstrap.  The
   minimal core is installed but not configured, and the system will not quite
   boot yet.

 - Stage 1, truly minimal system.  This stage makes the system bootable by
   installing system files like `/etc/fstab`, configures the bootloader, makes
   the network operable, and installs packages like raspi-config.  At this
   stage the system should boot to a local console from which you have the
   means to perform basic tasks needed to configure and install the system.
   This is as minimal as a system can possibly get, and its arguably not
   really usable yet in a traditional sense yet.  Still, if you want minimal,
   this is minimal and the rest you could reasonably do yourself as sysadmin.

 - State 2, lite system.  This stage produces the Raspbian-Lite image.  It
   installs some optimized memory functions, sets timezone and charmap
   defaults, installs fake-hwclock and ntp, wifi and bluetooth support,
   dphys-swapfile, and other basics for managing the hardware.  It also
   creates necessary groups and gives the pi user access to sudo and the
   standard console hardware permission groups.

   There are a few tools that may not make a whole lot of sense here for
   development purposes on a minimal system such as basic python and lua
   packages as well as the `build-essential` package.  They are lumped right
   in with more essential packages presently, though they need not be with
   pi-gen.  These are understandable for Raspbian's target audience, but if
   you were looking for something between truly minimal and Raspbian-lite,
   here's where you start trimming.

 - Stage 3, This is where all the Home Assistant specific packages are installed, permissions are set and users created. This is the only change that we do to the original build script.
