import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pi/url.dart';

class ImageGallery extends StatefulWidget {
  final int orderId;
  ImageGallery({required this.orderId});

  @override
  _ImageGalleryState createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  List<String> _imageUrls = [];
  String? _token;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchImageUrls();
  }

  Future<void> _loadTokenAndFetchImageUrls() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _token = prefs.getString('jwt_token');
      print('Loaded token: $_token');
    });
    if (_token != null) {
      await _fetchImageUrls();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _imageUrls.map((url) => _buildNetworkImage(url)).toList(),
      ),
    );
  }

  Widget _buildNetworkImage(String imageUrl) {
    return FutureBuilder<Uint8List>(
      future: _fetchImageWithToken(imageUrl),
      builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            margin: EdgeInsets.all(8.0),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.grey[300],
            ),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Container(
            margin: EdgeInsets.all(8.0),
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.grey[300],
            ),
            child: Center(
              child: Icon(Icons.error, color: Colors.red),
            ),
          );
        } else {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenImage(
                    imageProvider: MemoryImage(snapshot.data!),
                  ),
                ),
              );
            },
            child: Container(
              margin: EdgeInsets.all(8.0),
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: MemoryImage(snapshot.data!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _fetchImageUrls() async {
    print('Fetching image URLs for order: ${widget.orderId}');
    final response = await http.get(
      Uri.parse(BackendUrls().getOrdemServicoImagens(widget.orderId)),
      headers: {
        'Authorization': 'Bearer $_token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _imageUrls = data.map((url) => url.toString()).toList();
        print('Fetched image URLs: $_imageUrls');
      });
    } else {
      print('Failed to load images: ${response.body}');
      throw Exception('Failed to load images');
    }
  }

  Future<Uint8List> _fetchImageWithToken(String imageUrl) async {
    print('_fetchImageWithToken: $imageUrl');
    if (_token == null) {
      print('JWT token is null');
      throw Exception('JWT token is null');
    }

    try {
      final response = await http.get(
        Uri.parse(imageUrl),
        headers: {
          'Authorization': 'Bearer $_token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        print('Carregou com sucesso: ${response.statusCode} ${response.bodyBytes.length}');
        return response.bodyBytes;
      } else if (response.statusCode == 403) {
        print('Acesso proibido: ${response.statusCode} ${response.body}');
        throw Exception('Acesso proibido');
      } else {
        print('Failed to load image: ${response.statusCode} ${response.body}');
        throw Exception('Falha ao carregar imagem');
      }
    } catch (e) {
      print('Error fetching image: $e');
      rethrow;
    }
  }
}

class FullScreenImage extends StatelessWidget {
  final ImageProvider imageProvider;

  FullScreenImage({required this.imageProvider});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Imagem em Tela Cheia'),
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image(
            image: imageProvider,
          ),
        ),
      ),
    );
  }
}
