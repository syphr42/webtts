#!/bin/bash
# Based on a test script from avsm/ocaml repo https://github.com/avsm/ocaml
# Based on the script from https://www.tomaz.me/2013/12/02/running-travis-ci-tests-on-arm.html

ARCH="${ARCH:?The environment variable 'ARCH' must be set and non-empty}"
echo "Architecture: ${ARCH}"

CHROOT_DIR=/tmp/arm-chroot
MIRROR=http://archive.raspbian.org/raspbian
VERSION=jessie
CHROOT_ARCH=${ARCH}

# Debian package dependencies for the host
HOST_DEPENDENCIES="debootstrap qemu-user-static binfmt-support sbuild"

# Debian package dependencies for the chrooted environment
GUEST_DEPENDENCIES="sudo curl"

function setup_arm_chroot {
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

    # Create file with environment variables which will be used inside chrooted
    # environment
    echo "export ARCH=${ARCH}" > envvars.sh
    echo "export TRAVIS_BUILD_DIR=${TRAVIS_BUILD_DIR}" >> envvars.sh
    chmod a+x envvars.sh

    # Install dependencies inside chroot
    sudo chroot ${CHROOT_DIR} apt-get update
    sudo chroot ${CHROOT_DIR} apt-get --allow-unauthenticated install \
        -qq -y ${GUEST_DEPENDENCIES}
    # Using Docker testing due to hash mismatch error for armhf on stable
    sudo chroot ${CHROOT_DIR} curl -sSL https://test.docker.com/ | sudo chroot ${CHROOT_DIR} sh

    # Create build dir and copy travis build files to our chroot environment
    sudo mkdir -p ${CHROOT_DIR}/${TRAVIS_BUILD_DIR}
    sudo rsync -av ${TRAVIS_BUILD_DIR}/ ${CHROOT_DIR}/${TRAVIS_BUILD_DIR}/

    # Indicate chroot environment has been set up
    sudo touch ${CHROOT_DIR}/.chroot_is_done

    # Call ourselves again which will cause tests to run
    sudo chroot ${CHROOT_DIR} bash -c "cd ${TRAVIS_BUILD_DIR} && ./$0"
}

if [ -e "/.chroot_is_done" ]; then
  # We are inside ARM chroot
  echo "Running inside chrooted environment"
  . ./envvars.sh
else
  if [ "${ARCH}" = "armhf" ]; then
    # ARM test run, need to set up chrooted environment and execute self
    echo "Setting up chrooted ARM environment"
    setup_arm_chroot
    exit 0
  fi
fi

echo "Running tests"
echo "Environment: $(uname -a)"

sudo docker build -t syphr/webtts:${ARCH} -f Dockerfile.${ARCH} . \
&& sudo docker run -d -p 127.0.0.1:80:80 syphr/webtts:${ARCH} \
&& docker ps
