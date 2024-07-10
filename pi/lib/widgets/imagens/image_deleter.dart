import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:pi/url.dart';

class ImageDeleter extends StatefulWidget {
  final String imageUrl;
  ImageDeleter({required this.imageUrl});

  @override
  _ImageDeleterState createState() => _ImageDeleterState();
}

class _ImageDeleterState extends State<ImageDeleter> {
  Future<void> _deleteImage() async {
    final response = await http.delete(
      Uri.parse(BackendUrls().deleteImage()),
      body: jsonEncode({'imageUrl': widget.imageUrl}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image deleted successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete image')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _deleteImage,
      child: Text('Delete Image'),
    );
  }
}
