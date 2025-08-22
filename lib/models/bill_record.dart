// lib/models/bill_record.dart
import 'package:uuid/uuid.dart';

class BillRecord {
  String id; // Unique ID for each record
  int month; // 1-12
  int year;
  double totalUnits;
  double newReading;
  double oldReading;
  double totalBill;
  double myShare; // The calculated share for this record
  double myUnits; // Units consumed by 'me' for this record
  DateTime timestamp; // When the record was saved

  BillRecord({
    String? id, // Optional, generate if not provided
    required this.month,
    required this.year,
    required this.totalUnits,
    required this.newReading,
    required this.oldReading,
    required this.totalBill,
    required this.myShare,
    required this.myUnits,
    DateTime? timestamp, // Optional, set to now if not provided
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  // Convert a BillRecord object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'month': month,
      'year': year,
      'totalUnits': totalUnits,
      'newReading': newReading,
      'oldReading': oldReading,
      'totalBill': totalBill,
      'myShare': myShare,
      'myUnits': myUnits,
      'timestamp': timestamp.toIso8601String(), // Convert DateTime to String
    };
  }

  // Create a BillRecord object from a JSON map
  factory BillRecord.fromJson(Map<String, dynamic> json) {
    return BillRecord(
      id: json['id'],
      month: json['month'],
      year: json['year'],
      totalUnits: json['totalUnits'],
      newReading: json['newReading'],
      oldReading: json['oldReading'],
      totalBill: json['totalBill'],
      myShare: json['myShare'],
      myUnits: json['myUnits'],
      timestamp: DateTime.parse(json['timestamp']), // Convert String back to DateTime
    );
  }
}