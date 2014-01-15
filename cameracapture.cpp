#include "cameracapture.h"
#include <QtMultimedia/QMediaService>
#include <QtMultimedia/QMediaRecorder>
#include <QtMultimedia/QCamera>

#include <QtMultimedia/QVideoEncoderSettings>
#include <QtCore/QUrl>
#include <QtCore/QTimer>
#include <iostream>

using namespace std;

CameraCapture::CameraCapture() :
  recorder(0),
  camera(0)
{

  if (QCamera::availableDevices().isEmpty()){
    throw "No camera devices";
  }

  cout << "camera device list: " << endl;
  foreach(const QByteArray &deviceName, QCamera::availableDevices()) {
      QString description = deviceName+" "+camera->deviceDescription(deviceName);
      cout << description.toStdString() << endl;
  }


  setCamera();
}

CameraCapture::~CameraCapture()
{
    cout << "CameraCapture::~CameraCapture()" << endl;
    recorder->stop();
    delete recorder;
    delete camera;
}

void CameraCapture::setCamera()
{
    delete recorder;
    delete camera;
    camera = new QCamera(QCamera::availableDevices().first(), this);

    if (camera->error() != QCamera::NoError){
      throw "camera error";
    }

    recorder = new QMediaRecorder(camera, this);

    recorder->setOutputLocation(QUrl::fromLocalFile(QDir::currentPath() + "/" + "test.mp4"));

    connect(recorder, SIGNAL(durationChanged(qint64)), this, SLOT(updateRecordTime()));
    connect(recorder, SIGNAL(error(QMediaRecorder::Error)), this, SLOT(displayErrorMessage()));
    connect(recorder, SIGNAL(stateChanged(QMediaRecorder::State)), this, SLOT(recorderStateChanged(QMediaRecorder::State)));
    connect(camera, SIGNAL(stateChanged(QCamera::State)), this, SLOT(cameraStateChanged(QCamera::State)));

    //connect(camera, SIGNAL(availabilityChanged (bool)), ui->imageCaptureBox, SLOT(setEnabled(bool)));
    //connect(camera, SIGNAL(imageCaptured(QString,QImage)), this, SLOT(processCapturedImage(QString,QImage)));


    // starting camera
    camera->stop();
    camera->setCaptureMode(QCamera::CaptureVideo);
    camera->start();

    // schedule the recorder to start sometime in the future
    // hack because it needs time to start services?
    QTimer::singleShot(5000, this, SLOT(record()));

}

void CameraCapture::updateRecordTime()
{
    QString str = QString("Recorded %1 sec").arg(recorder->duration()/1000);
    cout << str.toStdString() << endl;
}


void CameraCapture::record(){
  cout << "starting recorder" << endl;
  recorder->setOutputLocation(QUrl::fromLocalFile(QDir::currentPath() + "/" + "test.mp4"));
  recorder->record();
}

void CameraCapture::cameraStateChanged(QCamera::State state){
    if (camera->service()) {
      cout << "camera state: " << state << endl;


    } else {
      cout << "Camera is not available" << endl;
    }
}

void CameraCapture::recorderStateChanged(QMediaRecorder::State state){
  cout << "recorder state: " << state << endl;
}

void CameraCapture::displayErrorMessage()
{
    cout << "recorder error: " <<  recorder->errorString().toStdString() << endl;
}

