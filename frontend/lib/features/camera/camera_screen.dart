import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  CameraController? controller;
  List<File> capturedPhotos = [];
  final photoTypes = ['Roots', 'Mid-length', 'Ends'];

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    controller = CameraController(cameras[0], ResolutionPreset.high);
    await controller?.initialize();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Take Photos (${capturedPhotos.length}/3)')),
      body: Column(
        children: [
          Expanded(child: CameraPreview(controller!)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Take photo of: ${photoTypes[capturedPhotos.length]}',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (capturedPhotos.length < 3) {
                final image = await controller!.takePicture();
                setState(() {
                  capturedPhotos.add(File(image.path));
                });

                if (capturedPhotos.length == 3) {
                  if (mounted) {
                    context.push('/analysis', extra: capturedPhotos);
                  }
                }
              }
            },
            child: const Text('Capture'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
