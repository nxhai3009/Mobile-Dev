// lib/main.dart
import 'package:flutter/material.dart';
import 'screens/survey_station.dart';
import 'screens/data_map.dart';
import 'services/sensor_service.dart';
import 'services/storage_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final sensorService = SensorService();
    final storageService = StorageService();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Schoolyard Heatmap',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeContainer(
        sensorService: sensorService,
        storageService: storageService,
      ),
    );
  }
}

class HomeContainer extends StatefulWidget {
  final SensorService sensorService;
  final StorageService storageService;
  const HomeContainer({
    Key? key,
    required this.sensorService,
    required this.storageService,
  }) : super(key: key);

  @override
  State<HomeContainer> createState() => _HomeContainerState();
}

class _HomeContainerState extends State<HomeContainer> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    final screens = [
      SurveyStation(sensorService: widget.sensorService, storageService: widget.storageService),
      DataMapScreen(storageService: widget.storageService),
    ];
    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.sensors), label: 'Trạm Khảo sát'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Bản đồ Dữ liệu'),
        ],
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
