TEMPLATE = app
TARGET = qt5-cam-demo-nogui

CONFIG += DEBUG

QMAKE_LFLAGS += -L/usr/lib/arm-linux-gnueabihf/

QT += core
QT += multimedia

QTPLUGIN += aalcamera 

INCLUDEPATH += "/home/heathkh/Downloads/qt-everywhere-opensource-src-5.2.0/"
INCLUDEPATH += "/home/phablet/Downloads/qt-everywhere-opensource-src-5.2.0/"

HEADERS = cameracapture.h
          
SOURCES = main.cpp cameracapture.cpp
     
          
OTHER_FILES += deploy.sh

