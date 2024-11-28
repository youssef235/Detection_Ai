
abstract class CameraState {}

class CameraInitial extends CameraState {}

class CameraReady extends CameraState {}

class CameraLoading extends CameraState {}

class CameraError extends CameraState {
  final String message;

  CameraError(this.message);
}

class CameraDetecting extends CameraState {
  final List<dynamic>? recognitions;

  CameraDetecting(this.recognitions);
}

class CameraCaptureSuccess extends CameraState {
  final String imagePath;

  CameraCaptureSuccess(this.imagePath);
}
