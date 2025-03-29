import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  final String latitude;
  final String longitude;

  const MapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _mapController = Completer();

  late double parsedLat;
  late double parsedLon;

  @override
  void initState() {
    super.initState();
    parsedLat = _tryParse(widget.latitude);
    parsedLon = _tryParse(widget.longitude);
  }

  // تحويل نص إلى double أو 0 عند الفشل
  double _tryParse(String val) {
    try {
      return double.parse(val);
    } catch (_) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final initialCameraPosition = CameraPosition(
      target: LatLng(parsedLat, parsedLon),
      zoom: 14,
    );

    final marker = Marker(
      markerId: const MarkerId('tankerMarker'),
      position: LatLng(parsedLat, parsedLon),
      infoWindow: const InfoWindow(title: 'Tanker Location'),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        backgroundColor: const Color(0xFF2C2C2C),
      ),
      backgroundColor: const Color(0xFF1C1C1C),
      body: GoogleMap(
        onMapCreated: (controller) => _mapController.complete(controller),
        initialCameraPosition: initialCameraPosition,
        markers: {marker},
        // يمكنك تعديل الخيارات مثل: myLocationEnabled, compassEnabled, إلخ.
      ),
    );
  }
}