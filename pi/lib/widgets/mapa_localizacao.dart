import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaLocalizacao extends StatelessWidget {
  final double latitude;
  final double longitude;

  MapaLocalizacao({required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(latitude, longitude),
          initialZoom: 15.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(latitude, longitude),
                child: 
                  Container(
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40.0,
                    ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
