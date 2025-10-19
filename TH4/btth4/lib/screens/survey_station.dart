import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import '../models/data_point.dart';
import '../services/sensor_service.dart';
import '../services/storage_service.dart';

class SurveyStation extends StatefulWidget {
  final SensorService sensorService;
  final StorageService storageService;
  const SurveyStation({
    Key? key,
    required this.sensorService,
    required this.storageService,
  }) : super(key: key);

  @override
  State<SurveyStation> createState() => _SurveyStationState();
}

class _SurveyStationState extends State<SurveyStation> {
  Location location = Location();
  bool _permissionGranted = false;
  String _status = 'Đang chờ cảm biến...';
  Timer? _uiTimer;

  @override
  void initState() {
    super.initState();
    widget.sensorService.start();
    _checkLocationPermission();
    // refresh UI periodically to show live sensor values
    _uiTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _uiTimer?.cancel();
    widget.sensorService.stop();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    final perm = await location.hasPermission();
    if (perm == PermissionStatus.denied) {
      final r = await location.requestPermission();
      _permissionGranted = r == PermissionStatus.granted;
    } else {
      _permissionGranted = perm == PermissionStatus.granted;
    }
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _recordPoint() async {
    setState(() {
      _status = 'Đang lấy vị trí...';
    });

    try {
      if (!_permissionGranted) {
        await _checkLocationPermission();
        if (!_permissionGranted) {
          setState(() {
            _status = 'Cần quyền vị trí để lưu điểm';
          });
          return;
        }
      }

      final loc = await location.getLocation();
      final dp = DataPoint(
        latitude: loc.latitude ?? 0.0,
        longitude: loc.longitude ?? 0.0,
        lux: widget.sensorService.lux,
        accelMagnitude: widget.sensorService.accelMagnitude(),
        magX: widget.sensorService.magX,
        magY: widget.sensorService.magY,
        magZ: widget.sensorService.magZ,
        timestamp: DateTime.now(),
      );

      await widget.storageService.append(dp);

      setState(() {
        _status = 'Đã lưu điểm tại (${dp.latitude.toStringAsFixed(6)}, ${dp.longitude.toStringAsFixed(6)})';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lưu thành công ✅')),
      );
    } catch (e) {
      setState(() {
        _status = 'Lỗi khi lưu: $e';
      });
    }
  }

  Color _colourForLux(double lux) {
    if (lux <= 10) return Colors.grey.shade600;
    if (lux <= 200) return Colors.yellow.shade200;
    if (lux <= 1000) return Colors.yellow.shade600;
    return Colors.orange.shade700;
  }

  Color _colourForAccel(double v) {
    if (v < 1.2) return Colors.green;
    if (v < 3) return Colors.orange;
    return Colors.red;
  }

  Color _colourForMag(double v) {
    if (v < 30) return Colors.blueGrey;
    if (v < 80) return Colors.blue;
    return Colors.indigo.shade900;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.sensorService;
    final accelMag = s.accelMagnitude();
    // Sử dụng sqrt từ dart:math thay vì gọi .sqrt() trên double
    final magMagnitude = sqrt(s.magX * s.magX + s.magY * s.magY + s.magZ * s.magZ);

    return Scaffold(
      appBar: AppBar(title: const Text('Trạm Khảo sát')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Live readouts
            Card(
              child: ListTile(
                leading: Icon(Icons.wb_sunny, color: _colourForLux(s.lux)),
                title: Text('Ánh sáng: ${s.lux.toStringAsFixed(1)} lux'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.directions_walk, color: _colourForAccel(accelMag)),
                title: Text('Năng động (|a|): ${accelMag.toStringAsFixed(2)}'),
                subtitle: Text('Trục (x,y,z): ${s.accelX.toStringAsFixed(2)}, ${s.accelY.toStringAsFixed(2)}, ${s.accelZ.toStringAsFixed(2)}'),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.attractions, color: _colourForMag(magMagnitude)),
                title: Text('Từ trường: ${magMagnitude.toStringAsFixed(2)} μT (raw x,y,z)'),
                subtitle: Text('${s.magX.toStringAsFixed(2)}, ${s.magY.toStringAsFixed(2)}, ${s.magZ.toStringAsFixed(2)}'),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _recordPoint,
              icon: const Icon(Icons.save),
              label: const Text('Ghi dữ liệu tại Điểm này'),
            ),
            const SizedBox(height: 12),
            Text(_status),
            const SizedBox(height: 8),
            const Divider(),
            const Text('Gợi ý khảo sát:\n - Đi điểm sáng/tối\n - Điểm tĩnh/năng động\n - Gần cột/kim loại để kiểm tra từ trường', textAlign: TextAlign.left),
          ],
        ),
      ),
    );
  }
}
