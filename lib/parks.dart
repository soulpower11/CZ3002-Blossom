import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'src/locations.dart' as locations;

class Parks extends StatefulWidget {
  @override
  State<Parks> createState() => _ParksState();
}

class _ParksState extends State<Parks> {
  late GoogleMapController mapController;

  final Map<String, Marker> _markers = {};

  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;

    final parkLocations = await locations.getParksLocation();
    setState(() {
      _markers.clear();
      for (final feature in parkLocations.features) {
        var html = feature.properties.Description;
        var name = html.substring(html.indexOf("<th>NAME</th> <td>") + 18,
            html.indexOf("<th>PHOTOURL</th>") - 27);

        final marker = Marker(
          markerId: MarkerId(name),
          position: LatLng(
              feature.geometry.coordinates[1], feature.geometry.coordinates[0]),
          infoWindow: InfoWindow(
            title: name,
          ),
        );
        _markers[name] = marker;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Parks'),
          backgroundColor: Colors.blue,
        ),
        body: GoogleMap(
          onMapCreated: _onMapCreated,
          myLocationEnabled: true,
          initialCameraPosition: const CameraPosition(
            target: LatLng(1.3139843, 103.5640535),
            zoom: 11.0,
          ),
          markers: _markers.values.toSet(),
        ),
      ),
    );
  }
}
