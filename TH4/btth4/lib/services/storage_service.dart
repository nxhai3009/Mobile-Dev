import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/data_point.dart';

class StorageService {
  static const String fileName = 'schoolyard_map_data.json';

  Future<File> _localFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$fileName');
  }

  Future<List<DataPoint>> readAll() async {
    try {
      final f = await _localFile();
      if (!await f.exists()) return [];
      final content = await f.readAsString();
      if (content.isEmpty) return [];
      return DataPoint.listFromJson(content);
    } catch (e) {
      return [];
    }
  }

  Future<void> save(List<DataPoint> points) async {
    final f = await _localFile();
    final jsonStr = DataPoint.listToJson(points);
    await f.writeAsString(jsonStr);
  }

  Future<void> append(DataPoint point) async {
    final list = await readAll();
    list.add(point);
    await save(list);
  }
}
