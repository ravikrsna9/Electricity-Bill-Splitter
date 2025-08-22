// lib/services/data_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bill_record.dart';

class DataService {
  static const String _recordsKey = 'bill_records';

  // Save a single bill record
  Future<void> saveRecord(BillRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    List<BillRecord> records = await loadRecords();

    // Remove existing record with same ID (for updating/replacing, though our app currently only adds)
    records.removeWhere((r) => r.id == record.id);

    records.add(record);

    // Sort records by year then month (newest first)
    records.sort((a, b) => b.year == a.year
        ? b.month.compareTo(a.month)
        : b.year.compareTo(a.year));

    List<String> jsonList = records.map((r) => jsonEncode(r.toJson())).toList();
    await prefs.setStringList(_recordsKey, jsonList);
  }

  // Load all bill records
  Future<List<BillRecord>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList(_recordsKey);

    if (jsonList == null) {
      return [];
    }

    return jsonList.map((jsonString) => BillRecord.fromJson(jsonDecode(jsonString))).toList();
  }

  // Clear all saved records (for debugging/resetting)
  Future<void> clearAllRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recordsKey);
  }
}