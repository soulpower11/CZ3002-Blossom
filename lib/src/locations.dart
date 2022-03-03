import 'dart:convert';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/services.dart' show rootBundle;

part 'locations.g.dart';

@JsonSerializable()
class Geometry {
  Geometry({
    required this.type,
    required this.coordinates,
  });

  factory Geometry.fromJson(Map<String, dynamic> json) => _$GeometryFromJson(json);
  Map<String, dynamic> toJson() => _$GeometryToJson(this);

  final String type;
  final List<double> coordinates;
}

@JsonSerializable()
class Property {
  Property({
    required this.Name,
    required this.Description,
  });

  factory Property.fromJson(Map<String, dynamic> json) => _$PropertyFromJson(json);
  Map<String, dynamic> toJson() => _$PropertyToJson(this);

  final String Name;
  final String Description;
}

@JsonSerializable()
class Feature {
  Feature({
    required this.type,
    required this.properties,
    required this.geometry,
  });

  factory Feature.fromJson(Map<String, dynamic> json) => _$FeatureFromJson(json);
  Map<String, dynamic> toJson() => _$FeatureToJson(this);

  final String type;
  final Property properties;
  final Geometry geometry;
}

@JsonSerializable()
class Property2 {
  Property2({
    required this.name,
  });

  factory Property2.fromJson(Map<String, dynamic> json) => _$Property2FromJson(json);
  Map<String, dynamic> toJson() => _$Property2ToJson(this);

  final String name;
}

@JsonSerializable()
class CRS {
  CRS({
    required this.type,
    required this.properties,
  });

  factory CRS.fromJson(Map<String, dynamic> json) => _$CRSFromJson(json);
  Map<String, dynamic> toJson() => _$CRSToJson(this);

  final String type;
  final Property2 properties;
}

@JsonSerializable()
class Locations {
  Locations({
    required this.type,
    required this.crs,
    required this.features,
  });

  factory Locations.fromJson(Map<String, dynamic> json) =>
      _$LocationsFromJson(json);
  Map<String, dynamic> toJson() => _$LocationsToJson(this);

  final String type;
  final CRS crs;
  final List<Feature> features;
}

Future<Locations> getParksLocation() async {
  // Fallback for when the above HTTP request fails.
  return Locations.fromJson(
    json.decode(
      await rootBundle.loadString('assets/locations.json'),
    ),
  );
}