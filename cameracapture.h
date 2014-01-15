#pragma once

#include <QtMultimedia/qcamera.h>
#include <QtMultimedia/qmediarecorder.h>
#include <QtCore/QDir>

class CameraCapture : public QObject
{
   Q_OBJECT
public:
   CameraCapture();
   ~CameraCapture();

public slots:
   void setCamera();

   void displayErrorMessage();
   void cameraStateChanged(QCamera::State);
   void recorderStateChanged(QMediaRecorder::State state);
   void updateRecordTime();
   void record();

private:
   QDir outputDir;
   QMediaRecorder* recorder;
   QCamera *camera;
   //QMediaService *service;
};

