import 'package:blossom/screen/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:blossom/src/locations.dart' as locations;

class Parks extends StatefulWidget {
  @override
  State<Parks> createState() => _ParksState();
}

class _ParksState extends State<Parks> {
  late GoogleMapController mapController;

  final Map<String, Marker> _markers = {};

  late CameraPosition cameraPosition;
  late Position currentPositon;
  var geoLocator = Geolocator();

  @override
  void initState() {
    super.initState();
  }

  void locatePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPositon = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    cameraPosition = CameraPosition(target: latLngPosition, zoom: 15.0);

    mapController.moveCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    mapController = controller;

    final parkLocations = await locations.getParksLocation();
    setState(() {
      _markers.clear();
      for (final feature in parkLocations.features) {
        var html = feature.properties.Description;
        var name = html.substring(html.indexOf("<th>NAME</th> <td>") + 18,
            html.indexOf("<th>PHOTOURL</th>") - 27);

        var address = html.substring(
            html.indexOf("<th>DESCRIPTION<\/th> <td>") + 25,
            html.indexOf("<th>ADDRESSSTREETNAME</th>") - 34);

        final marker = Marker(
          markerId: MarkerId(name),
          position: LatLng(
              feature.geometry.coordinates[1], feature.geometry.coordinates[0]),
          infoWindow: InfoWindow(
            title: name,
            snippet: address,
          ),
        );
        _markers[name] = marker;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: GoogleMap(
        onMapCreated: (GoogleMapController controller) {
          _onMapCreated(controller);
          mapController = controller;

          locatePosition();
        },
        myLocationEnabled: true,
        initialCameraPosition: const CameraPosition(
          target: LatLng(1.3139843, 103.5640535),
          zoom: 15.0,
        ),
        markers: _markers.values.toSet(),
      ),
      bottomNavigationBar: Dashboard(),
    );
  }
}
