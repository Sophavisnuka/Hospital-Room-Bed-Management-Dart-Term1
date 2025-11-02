import 'dart:io';
import 'dart:convert';

class HospitalRepository {
  static const String _basePath = 'lib/Data/';

  Future<void> saveData<T>(String fileName, List<T> items, Map<String, dynamic> Function(T) toMap) async {
    final file = File('$_basePath$fileName');
    
    // Create directory if it doesn't exist
    if (!file.parent.existsSync()) {
      file.parent.createSync(recursive: true);
    }

    try {
      final data = items.map(toMap).toList();
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(data));
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  Future<List<T>> loadData<T>(String fileName, T Function(Map<String, dynamic>) fromMap) async {
    final file = File('$_basePath$fileName');
    if (!file.existsSync()) {
      return [];
    }

    try {
      final content = await file.readAsString();
      final List decoded = jsonDecode(content);
      return decoded.map((e) => fromMap(e as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error loading data: $e');
      return [];
    }
  }
}