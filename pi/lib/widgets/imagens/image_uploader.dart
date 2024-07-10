import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:pi/url.dart';

class ImageUploader extends StatefulWidget {
  final int orderId;
  ImageUploader({required this.orderId});

  @override
  _ImageUploaderState createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  List<XFile>? _selectedFiles;

  Future<void> _selectImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile>? images = await picker.pickMultiImage();
    setState(() {
      _selectedFiles = images;
    });
  }

  Future<void> _uploadImages() async {
    final url = Uri.parse(BackendUrls().deleteImage());
    var request = http.MultipartRequest('POST', url);

    if (_selectedFiles != null) {
      for (var image in _selectedFiles!) {
        var pic = await http.MultipartFile.fromPath("files", image.path);
        request.files.add(pic);
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        // Handle success
        _showSuccessScreen();
      } else {
        // Handle error
        _showErrorScreen('Failed to upload images');
      }
    }
  }

  void _showSuccessScreen() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Images uploaded successfully')));
  }

  void _showErrorScreen(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _selectImages,
          child: Text('Select Images'),
        ),
        ElevatedButton(
          onPressed: _uploadImages,
          child: Text('Upload Images'),
        ),
      ],
    );
  }
}
