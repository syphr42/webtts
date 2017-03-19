#!/bin/bash
# Based on a test script from avsm/ocaml repo https://github.com/avsm/ocaml
# Based on the script from https://www.tomaz.me/2013/12/02/running-travis-ci-tests-on-arm.html

set -xeuo pipefail

MIRROR=http://archive.raspbian.org/raspbian
VERSION=jessie
CHROOT_ARCH=armhf

# Debian package dependencies for the host
HOST_DEPENDENCIES="debootstrap qemu-user-static binfmt-support sbuild"

# Debian package dependencies for the chrooted environment
GUEST_DEPENDENCIES="sudo curl"

# Host dependencies
sudo apt-get install -qq -y ${HOST_DEPENDENCIES}

# Create chrooted environment
sudo mkdir ${CHROOT_DIR}
sudo debootstrap --foreign --no-check-gpg --include=fakeroot,build-essential \
    --arch=${CHROOT_ARCH} ${VERSION} ${CHROOT_DIR} ${MIRROR}
sudo cp /usr/bin/qemu-arm-static ${CHROOT_DIR}/usr/bin/
sudo chroot ${CHROOT_DIR} ./debootstrap/debootstrap --second-stage
sudo sbuild-createchroot --arch=${CHROOT_ARCH} --foreign --setup-only \
    ${VERSION} ${CHROOT_DIR} ${MIRROR}

# Install dependencies inside chroot
sudo chroot ${CHROOT_DIR} apt-get update
sudo chroot ${CHROOT_DIR} apt-get --allow-unauthenticated install \
    -qq -y ${GUEST_DEPENDENCIES}
# Using Docker testing due to hash mismatch error for armhf on stable
sudo chroot ${CHROOT_DIR} curl -sSL https://test.docker.com/ | sudo chroot ${CHROOT_DIR} sh

# Create build dir and copy travis build files to our chroot environment
sudo mkdir -p ${CHROOT_DIR}/${TRAVIS_BUILD_DIR}
sudo rsync -av ${TRAVIS_BUILD_DIR}/ ${CHROOT_DIR}/${TRAVIS_BUILD_DIR}/
