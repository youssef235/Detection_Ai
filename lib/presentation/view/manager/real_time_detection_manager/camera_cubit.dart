import 'package:camera_detection/presentation/view/manager/real_time_detection_manager/camera_state.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_v2/tflite_v2.dart';
import '../../../../data/local/models/image.dart';


class CameraCubit extends Cubit<CameraState> {
  CameraController? cameraController;
  bool _isDetecting = false;
  List<dynamic>? _recognitions;
  double _cameraHeight = 0;
  double _cameraWidth = 0;
  bool _isCameraInitialized = false;

  CameraCubit() : super(CameraInitial()) {
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/models/ssd_mobilenet.tflite",
        labels: "assets/models/ssd_mobilenet.txt",
        isAsset: true,
      );
      print("Model loaded successfully!");
    } catch (e) {
      print("Error loading model: $e");
      emit(CameraError("Error loading model: $e"));
    }
  }

  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      final camera = cameras.first;

      cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController!.initialize();

      _cameraHeight = cameraController!.value.previewSize!.height;
      _cameraWidth = cameraController!.value.previewSize!.width;
      _isCameraInitialized = true;

      emit(CameraReady());

      cameraController!.startImageStream((CameraImage image) {
        if (!_isDetecting) {
          _isDetecting = true;
          _runObjectDetection(image);
        }
      });
    } catch (e) {
      print("Error initializing camera: $e");
      emit(CameraError("Error initializing camera: $e"));
    }
  }

  Future<void> _runObjectDetection(CameraImage image) async {
    try {
      final recognitions = await Tflite.detectObjectOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        numResultsPerClass: 2,
        threshold: 0.4,
      );

      emit(CameraDetecting(recognitions));
    } catch (e) {
      print("Error during detection: $e");
      emit(CameraError("Error during detection: $e"));
    } finally {
      _isDetecting = false;
    }
  }

  Future<void> captureAndSaveImage(BuildContext context) async {
    try {
      final XFile picture = await cameraController!.takePicture();

      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final path = '${imagesDir.path}/captured_image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await picture.saveTo(path);

      final photoBox = await Hive.openBox<Photo>('photos');
      final newPhoto = Photo(path: path, isUploaded: false);
      await photoBox.add(newPhoto);

      emit(CameraCaptureSuccess(path));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Photo Captured Sucessfully !'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Error capturing image: $e");
      emit(CameraError("Error capturing image: $e"));
    }
  }

  @override
  Future<void> close() {
    cameraController?.dispose();
    Tflite.close();
    return super.close();
  }

  void disposeCamera() {
    cameraController?.dispose();
    cameraController = null;
    _isCameraInitialized = false;
    Tflite.close();
    emit(CameraInitial());
  }

}
