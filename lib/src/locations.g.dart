// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locations.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Geometry _$GeometryFromJson(Map<String, dynamic> json) => Geometry(
      type: json['type'] as String,
      coordinates: (json['coordinates'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$GeometryToJson(Geometry instance) => <String, dynamic>{
      'type': instance.type,
      'coordinates': instance.coordinates,
    };

Property _$PropertyFromJson(Map<String, dynamic> json) => Property(
      Name: json['Name'] as String,
      Description: json['Description'] as String,
    );

Map<String, dynamic> _$PropertyToJson(Property instance) => <String, dynamic>{
      'Name': instance.Name,
      'Description': instance.Description,
    };

Feature _$FeatureFromJson(Map<String, dynamic> json) => Feature(
      type: json['type'] as String,
      properties: Property.fromJson(json['properties'] as Map<String, dynamic>),
      geometry: Geometry.fromJson(json['geometry'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FeatureToJson(Feature instance) => <String, dynamic>{
      'type': instance.type,
      'properties': instance.properties,
      'geometry': instance.geometry,
    };

Property2 _$Property2FromJson(Map<String, dynamic> json) => Property2(
      name: json['name'] as String,
    );

Map<String, dynamic> _$Property2ToJson(Property2 instance) => <String, dynamic>{
      'name': instance.name,
    };

CRS _$CRSFromJson(Map<String, dynamic> json) => CRS(
      type: json['type'] as String,
      properties:
          Property2.fromJson(json['properties'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CRSToJson(CRS instance) => <String, dynamic>{
      'type': instance.type,
      'properties': instance.properties,
    };

Locations _$LocationsFromJson(Map<String, dynamic> json) => Locations(
      type: json['type'] as String,
      crs: CRS.fromJson(json['crs'] as Map<String, dynamic>),
      features: (json['features'] as List<dynamic>)
          .map((e) => Feature.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$LocationsToJson(Locations instance) => <String, dynamic>{
      'type': instance.type,
      'crs': instance.crs,
      'features': instance.features,
    };
