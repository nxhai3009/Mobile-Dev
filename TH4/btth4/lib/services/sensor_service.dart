// lib/services/sensor_service.dart
import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:light/light.dart';

class SensorService {
  // Latest values
  double accelX = 0, accelY = 0, accelZ = 0;
  double magX = 0, magY = 0, magZ = 0;
  double lux = 0;

  StreamSubscription<AccelerometerEvent>? _accelSub;
  StreamSubscription<MagnetometerEvent>? _magSub;
  StreamSubscription<int>? _lightSub;
  Light? _light;

  void start() {
    _accelSub ??= accelerometerEvents.listen((AccelerometerEvent e) {
      accelX = e.x;
      accelY = e.y;
      accelZ = e.z;
    });

    _magSub ??= magnetometerEvents.listen((MagnetometerEvent e) {
      magX = e.x;
      magY = e.y;
      magZ = e.z;
    });

    try {
      _light ??= Light();
      _lightSub ??= _light!.lightSensorStream.listen((int value) {
        // value is lux (int)
        lux = value.toDouble();
      });
    } catch (e) {
      // Không có cảm biến ánh sáng -> giữ lux = 0
      lux = 0;
    }
  }

  void stop() {
    _accelSub?.cancel();
    _accelSub = null;
    _magSub?.cancel();
    _magSub = null;
    _lightSub?.cancel();
    _lightSub = null;
  }

  double accelMagnitude() {
    return sqrt(accelX * accelX + accelY * accelY + accelZ * accelZ);
  }
}
