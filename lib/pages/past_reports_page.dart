// lib/pages/past_reports_page.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bill_record.dart';
import '../services/data_service.dart';

class PastReportsPage extends StatefulWidget {
  @override
  _PastReportsPageState createState() => _PastReportsPageState();
}

class _PastReportsPageState extends State<PastReportsPage> {
  late Future<List<BillRecord>> _recordsFuture;
  final DataService _dataService = DataService();
  // CHANGE: State variable to control the visibility of the clear button.
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _recordsFuture = _loadInitialRecords();
  }

  // CHANGE: This method now also updates the state for the clear button.
  Future<List<BillRecord>> _loadInitialRecords() async {
    final records = await _dataService.loadRecords();
    if (mounted) {
      setState(() {
        _showClearButton = records.isNotEmpty;
      });
    }
    return records;
  }

  Future<void> _refreshData() async {
    setState(() {
      _recordsFuture = _dataService.loadRecords();
    });
    // Await the future to update the button visibility after refresh
    final records = await _recordsFuture;
    if (mounted) {
      setState(() {
        _showClearButton = records.isNotEmpty;
      });
    }
  }

  void _confirmClearAllData() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: const Text('Clear All Data?'),
          content: const Text('This will permanently delete all saved bill records.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text('Clear All', style: TextStyle(color: Colors.red.shade700)),
              onPressed: () async {
                await _dataService.clearAllRecords();
                Navigator.of(dialogContext).pop();
                _refreshData(); // Refresh the UI after clearing
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('All historical data cleared!')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Past Electricity Bills'),
        backgroundColor: Colors.red.shade700,
        actions: [
          // CHANGE: The button's visibility is now controlled by the state variable.
          if (_showClearButton)
            IconButton(
              icon: Icon(Icons.delete_forever),
              tooltip: 'Clear All Data',
              onPressed: _confirmClearAllData,
            ),
        ],
      ),
      body: FutureBuilder<List<BillRecord>>(
        future: _recordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Colors.red.shade700));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white70)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No past records found.\nCalculate a bill on the main page to save it here.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
              ),
            );
          }

          final allRecords = snapshot.data!;
          return ReportsView(
            records: allRecords,
            onRefresh: _refreshData,
          );
        },
      ),
    );
  }
}


class ReportsView extends StatefulWidget {
  final List<BillRecord> records;
  final Future<void> Function() onRefresh;

  const ReportsView({
    Key? key,
    required this.records,
    required this.onRefresh,
  }) : super(key: key);

  @override
  _ReportsViewState createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  int? _selectedYear;
  Map<int, List<BillRecord>> _recordsByYear = {};

  @override
  void initState() {
    super.initState();
    _processRecords();
  }

  @override
  void didUpdateWidget(covariant ReportsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.records != oldWidget.records) {
      _processRecords();
    }
  }

  void _processRecords() {
    _recordsByYear.clear();
    for (var record in widget.records) {
      _recordsByYear.putIfAbsent(record.year, () => []).add(record);
    }
    _recordsByYear.forEach((year, records) {
      records.sort((a, b) => b.month.compareTo(a.month));
    });

    if (_recordsByYear.keys.isNotEmpty && (_selectedYear == null || !_recordsByYear.keys.contains(_selectedYear))) {
      _selectedYear = _recordsByYear.keys.reduce((a, b) => a > b ? a : b); // Select latest year
    }
  }

  @override
  Widget build(BuildContext context) {
    List<BillRecord> recordsForSelectedYear = _selectedYear != null ? (_recordsByYear[_selectedYear!] ?? []) : [];
    double totalUnitsForYear = recordsForSelectedYear.fold(0.0, (sum, record) => sum + record.myUnits);
    double totalShareForYear = recordsForSelectedYear.fold(0.0, (sum, record) => sum + record.myShare);

    // CHANGE: The problematic code that caused the error has been removed from here.

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      color: Colors.red.shade700,
      backgroundColor: Colors.grey.shade900,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text('Select Year: ', style: TextStyle(color: Colors.white, fontSize: 16)),
                SizedBox(width: 16),
                Expanded(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: _selectedYear,
                    dropdownColor: Colors.grey.shade900,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    icon: Icon(Icons.arrow_drop_down, color: Colors.red.shade700),
                    underline: Container(height: 1, color: Colors.red.shade700),
                    onChanged: (int? newValue) {
                      setState(() {
                        _selectedYear = newValue;
                      });
                    },
                    items: _recordsByYear.keys.map<DropdownMenuItem<int>>((int year) {
                      return DropdownMenuItem<int>(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          if (_selectedYear != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                color: Colors.red.shade900.withOpacity(0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('Summary for $_selectedYear', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 8),
                      Text('Total Units Consumed: ${totalUnitsForYear.toStringAsFixed(2)} KWh', style: TextStyle(color: Colors.white70)),
                      Text('Total Share for Year: ₹${totalShareForYear.toStringAsFixed(2)}', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: recordsForSelectedYear.isEmpty
                ? Center(child: Text('No records for the selected year.', style: TextStyle(color: Colors.white70)))
                : ListView.builder(
              itemCount: recordsForSelectedYear.length,
              itemBuilder: (context, index) {
                final record = recordsForSelectedYear[index];
                final monthName = DateFormat('MMMM').format(DateTime(record.year, record.month));
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  color: Colors.grey.shade800,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(monthName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                        SizedBox(height: 8),
                        Text('Units Consumed: ${record.myUnits.toStringAsFixed(2)} KWh', style: TextStyle(color: Colors.white)),
                        Text('Your Share: ₹${record.myShare.toStringAsFixed(2)}', style: TextStyle(color: Colors.white)),
                        Text('Total Bill: ₹${record.totalBill.toStringAsFixed(2)}', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}