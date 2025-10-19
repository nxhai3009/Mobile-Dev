import 'dart:convert';

class DataPoint {
  final double latitude;
  final double longitude;
  final double lux; // ánh sáng (lux)
  final double accelMagnitude; // độ "năng động"
  final double magX, magY, magZ; // từ kế raw
  final DateTime timestamp;

  DataPoint({
    required this.latitude,
    required this.longitude,
    required this.lux,
    required this.accelMagnitude,
    required this.magX,
    required this.magY,
    required this.magZ,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'lux': lux,
    'accelMagnitude': accelMagnitude,
    'magX': magX,
    'magY': magY,
    'magZ': magZ,
    'timestamp': timestamp.toIso8601String(),
  };

  factory DataPoint.fromJson(Map<String, dynamic> json) => DataPoint(
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    lux: (json['lux'] as num).toDouble(),
    accelMagnitude: (json['accelMagnitude'] as num).toDouble(),
    magX: (json['magX'] as num).toDouble(),
    magY: (json['magY'] as num).toDouble(),
    magZ: (json['magZ'] as num).toDouble(),
    timestamp: DateTime.parse(json['timestamp'] as String),
  );

  static List<DataPoint> listFromJson(String jsonStr) {
    final List<dynamic> arr = json.decode(jsonStr) as List<dynamic>;
    return arr.map((e) => DataPoint.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJson(List<DataPoint> list) {
    final arr = list.map((e) => e.toJson()).toList();
    return json.encode(arr);
  }
}
