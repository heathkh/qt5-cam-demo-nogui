#include <QtCore/QCoreApplication>
#include "cameracapture.h"
#include <iostream>


#include "qtmultimedia/src/multimedia/qmediaserviceprovider_p.h"

using namespace std;

int main(int argc, char *argv[])
{
    QCoreApplication app(argc, argv);


/*
    CameraCapture* cameraCapture;
    try {
      cameraCapture = new CameraCapture();
    } catch(const char* msg){
      cerr << msg << endl;
    }
*/

    cout << "camera service device list: " << endl;
    foreach(const QByteArray &deviceName, QMediaServiceProvider::defaultServiceProvider()->devices(Q_MEDIASERVICE_CAMERA)) {
        QString description = deviceName;
        cout << description.toStdString() << endl;
    }


    return 0;

    //return app.exec();
};
