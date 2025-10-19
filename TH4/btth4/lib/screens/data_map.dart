import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/data_point.dart';
import 'dart:math';

class DataMapScreen extends StatefulWidget {
  final StorageService storageService;
  const DataMapScreen({Key? key, required this.storageService}) : super(key: key);

  @override
  State<DataMapScreen> createState() => _DataMapScreenState();
}

class _DataMapScreenState extends State<DataMapScreen> {
  List<DataPoint> points = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await widget.storageService.readAll();
    setState(() {
      points = list.reversed.toList(); // mới nhất lên đầu
    });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản đồ Dữ liệu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: points.isEmpty
          ? const Center(child: Text('Chưa có dữ liệu. Vào "Trạm Khảo sát" để ghi điểm.'))
          : ListView.builder(
        itemCount: points.length,
        itemBuilder: (context, i) {
          final p = points[i];
          final mag = sqrt(p.magX * p.magX + p.magY * p.magY + p.magZ * p.magZ);
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.place, color: Colors.blue),
                ],
              ),
              title: Text('(${p.latitude.toStringAsFixed(6)}, ${p.longitude.toStringAsFixed(6)})'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Thời gian: ${p.timestamp.toLocal().toString()}'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.wb_sunny, color: _colourForLux(p.lux)),
                      const SizedBox(width: 6),
                      Text('${p.lux.toStringAsFixed(1)} lux'),
                      const SizedBox(width: 12),
                      Icon(Icons.directions_walk, color: _colourForAccel(p.accelMagnitude)),
                      const SizedBox(width: 6),
                      Text('${p.accelMagnitude.toStringAsFixed(2)}'),
                      const SizedBox(width: 12),
                      Icon(Icons.attractions, color: _colourForMag(mag)),
                      const SizedBox(width: 6),
                      Text('${mag.toStringAsFixed(2)} μT'),
                    ],
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
