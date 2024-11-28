import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:camera/camera.dart';
import '../manager/real_time_detection_manager/camera_cubit.dart';
import '../manager/real_time_detection_manager/camera_state.dart';
import '../widgets/objectDetectionPainter.dart';



class RealTimeDetectionScreen extends StatelessWidget {
  const RealTimeDetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CameraCubit()..initializeCamera(),
      child: BlocBuilder<CameraCubit, CameraState>(builder: (context, state) {
        final cubit = context.read<CameraCubit>();

        if (state is CameraLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is CameraError) {
          return Scaffold(
            body: Center(child: Text(state.message)),
          );
        } else if (state is CameraReady || state is CameraDetecting) {
          return Scaffold(
            appBar: AppBar(title: const Text("Real-Time Detection")),
            body: Stack(
              children: [
                if (cubit.cameraController != null &&
                    cubit.cameraController!.value.isInitialized)
                  Positioned.fill(
                    child: CameraPreview(cubit.cameraController!),
                  ),
                if (state is CameraDetecting)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: ObjectDetectionPainter(
                        state.recognitions,
                        cubit.cameraController!.value.previewSize!.width,
                        cubit.cameraController!.value.previewSize!.height,
                      ),
                    ),
                  ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => cubit.captureAndSaveImage(context),
              child: const Icon(Icons.camera),
            ),
          );
        }

        return const SizedBox.shrink();
      }),
    );
  }
}


