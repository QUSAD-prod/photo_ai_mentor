import 'dart:io';

import 'package:flutter/material.dart';

class PhotoPreviewScreen extends StatelessWidget {
  final String imagePath;

  const PhotoPreviewScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(
            context), // Go back to the camera to take the picture again
        child: const Icon(Icons.camera_alt),
      ),
      appBar: AppBar(title: const Text('Display the Picture')),
      body: Column(
        children: [
          Expanded(child: Image.file(File(imagePath))),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Назад"),
          )
        ],
      ),
    );
  }
}
