#!/bin/bash
DEVICE_SERIAL_NUM=0149C7A517015010
FOLDERNAME="qt5-cam-demo-nogui"
DEVICE=phablet@192.168.1.107
DEVICE_PORT=22

#mkdir ${PROJECT_PATH}/build
./remote_build.sh "$DEVICE_SERIAL_NUM" "$FOLDERNAME" "$DEVICE" $DEVICE_PORT
