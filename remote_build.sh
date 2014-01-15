#!/bin/bash
# Copyright 2013 Canonical Ltd.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as published by
# the Free Software Foundation; version 2.1.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# Author: Juhapekka Piiroinen <juhapekka.piiroinen@canonical.com>

DEBEMAIL=`grep -G "^DEBEMAIL" ~/.bashrc`
DEBFULLNAME=`grep -G "^DEBFULLNAME" ~/.bashrc`

if [[ ! -z "$DEBEMAIL" ]]; then
  export $DEBEMAIL
else
  CMD=`grep -G "export DEBEMAIL=" ~/.bashrc|sed "s/\"//g"`
  if [[ ! -z $CMD ]]; then
    $CMD
  fi
fi
if [[ ! -z $DEBFULLNAME ]]; then
  export $DEBFULLNAME
else
  CMD=`grep -G "export DEBFULLNAME=" ~/.bashrc|sed "s/\"//g"|sed "s/export DEBFULLNAME=//g"`
  if [[ ! -z $CMD ]]; then
    export DEBFULLNAME="$CMD"
  fi
fi

. `dirname $0`/functions.inc

FOLDERNAME=$2
TARGET_DEVICE=$3
TARGET_DEVICE_PORT=$4
TARGET_DEVICE_HOME=$5

USAGE="$0 [serialnumber] [foldername] [target_device] [target_device_port] [target_device_home]"

if [[ -z $FOLDERNAME ]]; then
  echo ${USAGE}
  exit
fi

if [[ -z ${TARGET_DEVICE_PORT} ]]; then
  TARGET_DEVICE_PORT=2222
fi

if [[ -z ${TARGET_DEVICE} ]]; then
  TARGET_DEVICE=phablet@127.0.0.1
fi

if [[ -z ${TARGET_DEVICE_HOME} ]]; then
  TARGET_DEVICE_HOME=/home/phablet/dev_tmp
fi

SCP="scp -i ${SSHIDENTITY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -P${TARGET_DEVICE_PORT}"
SSH="ssh -i ${SSHIDENTITY} -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p${TARGET_DEVICE_PORT} ${TARGET_DEVICE}"

#pushd "${FOLDERNAME}"
# set +e
# if [[ -f Makefile ]]; then
#  make distclean
# fi
# set -e
#popd

#parent=`dirname ${FOLDERNAME}`
#echo "PARENT: $parent"

cd ..

tar -cjf "${FOLDERNAME}.tar.bz2" "./${FOLDERNAME}"

# remove old files
if [[ ! -z ${TARGET_DEVICE_HOME} ]]; then
$SSH rm -rf ${TARGET_DEVICE_HOME}/*
fi

# make sure that the device has the target directory
$SSH mkdir -p ${TARGET_DEVICE_HOME}

$SCP "${FOLDERNAME}.tar.bz2" ${TARGET_DEVICE}:${TARGET_DEVICE_HOME}
$SSH "cd ${TARGET_DEVICE_HOME}; tar -xvf ${FOLDERNAME}.tar.bz2"

if [[ -d "${FOLDERNAME}/debian" ]]; then
  echo "Packaging already exists for project."
  $SSH "cd ${TARGET_DEVICE_HOME}/${FOLDERNAME}; debuild --no-tgz-check -i -I -S -sa -us -uc"
else
  $SSH "cd ${TARGET_DEVICE_HOME}/${FOLDERNAME}; dh_make -p ${FOLDERNAME}_0.1 -s -y --createorig"
  if [[ $? -gt 0 ]]; then
    echo "Have you enabled Platform Development Mode? (Devices > Advanced)"
    exit
  fi
  $SSH "cd ${TARGET_DEVICE_HOME}/${FOLDERNAME}; debuild -i -I -S -sa -us -uc"
fi

MISSING_DEPENDENCIES=`$SSH "cd ${TARGET_DEVICE_HOME}/${FOLDERNAME}; dpkg-checkbuilddeps 2>&1|sed 's/dpkg-checkbuilddeps: Unmet build dependencies://'"`

adb_shell apt-get --assume-yes install ${MISSING_DEPENDENCIES}

$SSH "cd ${TARGET_DEVICE_HOME}/${FOLDERNAME}; dpkg-buildpackage -us -uc -nc"

echo "Transferring files from device to host.."
FILES=`$SSH "cd ${TARGET_DEVICE_HOME}; ls -1|grep -v ${FOLDERNAME}.tar.bz2|grep -v ${FOLDERNAME}$"`
echo $FILES | tr ' ' '\n' | xargs -I FILE $SCP ${TARGET_DEVICE}:${TARGET_DEVICE_HOME}/FILE .
echo "..transfer complete!"
echo
echo "Transferred following files: "
echo $FILES | tr ' ' '\n'
echo
echo "@ $PWD"
echo
adb_shell apt-get --assume-yes remove ${MISSING_DEPENDENCIES}
