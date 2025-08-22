import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'models/bill_record.dart';
import 'services/data_service.dart';
import 'pages/past_reports_page.dart';

void main() {
  runApp(ElectricityBillApp());
}

class ElectricityBillApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Electricity Bill Calculator',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.red.shade700,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Roboto',
        textTheme: TextTheme(
          bodyMedium: TextStyle(color: Colors.white, fontSize: 16),
          labelLarge: TextStyle(color: Colors.white),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade800,
          // CHANGE: Label text is now white70 for a professional look
          labelStyle: TextStyle(color: Colors.white70),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade700, width: 2),
          ),
          errorStyle: TextStyle(color: Colors.yellow.shade700, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: BillCalculator(),
    );
  }
}

class BillCalculator extends StatefulWidget {
  @override
  _BillCalculatorState createState() => _BillCalculatorState();
}

class _BillCalculatorState extends State<BillCalculator> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController totalUnitsController = TextEditingController();
  final TextEditingController newReadingController = TextEditingController();
  final TextEditingController oldReadingController = TextEditingController();
  final TextEditingController totalBillController = TextEditingController();

  int _selectedMonth = DateTime.now().month;
  // CHANGE: Switched from a text controller to a state variable for the year
  int _selectedYear = DateTime.now().year;

  double _finalBill = 0.0;
  String _summary = "Enter the details above to calculate your share.";
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _loadLastMonthAndYear();
  }

  Future<void> _loadLastMonthAndYear() async {
    List<BillRecord> records = await _dataService.loadRecords();
    if (records.isNotEmpty) {
      records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      BillRecord latest = records.first;
      setState(() {
        _selectedMonth = latest.month;
        _selectedYear = latest.year;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red.shade900,
      ),
    );
  }

  void _calculateBill() async {
    FocusScope.of(context).unfocus();
    if (totalUnitsController.text.isEmpty ||
        newReadingController.text.isEmpty ||
        oldReadingController.text.isEmpty ||
        totalBillController.text.isEmpty) {
      _showErrorSnackBar("Please fill in all fields.");
      return;
    }

    double totalUnits = double.tryParse(totalUnitsController.text) ?? 0;
    double newReading = double.tryParse(newReadingController.text) ?? 0;
    double oldReading = double.tryParse(oldReadingController.text) ?? 0;
    double totalBill = double.tryParse(totalBillController.text) ?? 0;

    if (oldReading > newReading) {
      _showErrorSnackBar("Error: Old reading cannot be greater than the new reading.");
      return;
    }

    if (totalUnits <= 0 || totalBill <= 0) {
      _showErrorSnackBar("Error: Total units and bill amount must be positive numbers.");
      return;
    }

    double myUnits = newReading - oldReading;

    if (myUnits > totalUnits) {
      _showErrorSnackBar("Error: Your consumed units ($myUnits) cannot exceed the total units ($totalUnits).");
      return;
    }

    double calculatedShare = (myUnits / totalUnits) * totalBill;

    setState(() {
      _finalBill = calculatedShare;
      _summary = "Your consumed units: ${myUnits.toStringAsFixed(2)} KWh\nCalculation: (${myUnits.toStringAsFixed(2)} / ${totalUnits.toStringAsFixed(2)}) × ₹${totalBill.toStringAsFixed(2)}";
    });

    BillRecord record = BillRecord(
      month: _selectedMonth,
      year: _selectedYear, // CHANGE: use _selectedYear
      totalUnits: totalUnits,
      newReading: newReading,
      oldReading: oldReading,
      totalBill: totalBill,
      myShare: calculatedShare,
      myUnits: myUnits,
    );
    await _dataService.saveRecord(record);
    _showErrorSnackBar("Bill saved for ${DateFormat('MMMM').format(DateTime(0, _selectedMonth))} $_selectedYear!");
  }

  void _clearFields() {
    totalUnitsController.clear();
    newReadingController.clear();
    oldReadingController.clear();
    totalBillController.clear();
    FocusScope.of(context).unfocus();
    setState(() {
      _finalBill = 0.0;
      _summary = "Enter the details above to calculate your share.";
    });
  }

  void _launchURL() async {
    final Uri url = Uri.parse('https://gosiddhiinfotech.in/');
    if (!await launchUrl(url)) {
      _showErrorSnackBar('Could not launch $url');
    }
  }

  @override
  void dispose() {
    totalUnitsController.dispose();
    newReadingController.dispose();
    oldReadingController.dispose();
    totalBillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String formatCurrency(double amount) => '₹${amount.toStringAsFixed(2)}';

    return Scaffold(
      // CHANGE: Wrapped body in SafeArea to avoid system UI (like notches)
      body: SafeArea(
        // CHANGE: This combination of Center and SingleChildScrollView correctly centers content.
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400),
              child: Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade900.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Electricity Bill Splitter", textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(child: _buildMonthDropdown()),
                          SizedBox(width: 16),
                          // CHANGE: Swapped text field for a dropdown
                          Expanded(child: _buildYearDropdown()),
                        ],
                      ),
                      SizedBox(height: 8),
                      _buildTextField(totalUnitsController, "Total Units (KWh)", Icons.flash_on_outlined),
                      _buildTextField(newReadingController, "Your New Meter Reading", Icons.speed_outlined),
                      _buildTextField(oldReadingController, "Your Old Meter Reading", Icons.history_outlined),
                      _buildTextField(totalBillController, "Total Bill Amount (₹)", Icons.currency_rupee_outlined),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(onPressed: _clearFields, child: Text("Clear"), style: OutlinedButton.styleFrom(foregroundColor: Colors.red.shade700, side: BorderSide(color: Colors.red.shade700), padding: EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)))),
                          ),
                          SizedBox(width: 16),
                          Expanded(child: ElevatedButton(onPressed: _calculateBill, child: Text("Calculate"))),
                        ],
                      ),
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => PastReportsPage()));
                        },
                        icon: Icon(Icons.history),
                        label: Text("View Past Reports"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade800, foregroundColor: Colors.white, textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      SizedBox(height: 24),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.grey[850], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.red.shade700)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Your Share", style: TextStyle(color: Colors.red.shade700, fontSize: 16, fontWeight: FontWeight.bold)),
                            SizedBox(height: 8),
                            Text(formatCurrency(_finalBill), style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
                            SizedBox(height: 12),
                            Text(_summary, style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.5)),
                          ],
                        ),
                      ),
                      SizedBox(height: 24),
                      Center(
                        child: InkWell(
                          onTap: _launchURL,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('© GOSIDDDHI INFOTECH', style: TextStyle(color: Colors.red.shade700, decoration: TextDecoration.underline, decorationColor: Colors.red.shade700)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        style: TextStyle(color: Colors.white, fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.red.shade700),
        ),
      ),
    );
  }

  Widget _buildMonthDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Month',
          prefixIcon: Icon(Icons.date_range, color: Colors.red.shade700),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            isExpanded: true,
            value: _selectedMonth,
            dropdownColor: Colors.grey.shade900,
            style: TextStyle(color: Colors.white, fontSize: 16),
            icon: Icon(Icons.arrow_drop_down, color: Colors.red.shade700),
            onChanged: (int? newValue) {
              setState(() {
                _selectedMonth = newValue!;
              });
            },
            items: List.generate(12, (index) {
              int monthNumber = index + 1;
              String monthName = DateFormat('MMMM').format(DateTime(0, monthNumber));
              return DropdownMenuItem<int>(
                value: monthNumber,
                child: Text(monthName),
              );
            }),
          ),
        ),
      ),
    );
  }

  // NEW: Dropdown for selecting the year
  Widget _buildYearDropdown() {
    int currentYear = DateTime.now().year;
    List<int> years = List.generate(10, (index) => currentYear - 5 + index).reversed.toList(); // Range of 10 years

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Year',
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            isExpanded: true,
            value: _selectedYear,
            dropdownColor: Colors.grey.shade900,
            style: TextStyle(color: Colors.white, fontSize: 16),
            icon: SizedBox.shrink(), // Hides default dropdown arrow to save space
            onChanged: (int? newValue) {
              setState(() {
                _selectedYear = newValue!;
              });
            },
            items: years.map<DropdownMenuItem<int>>((int year) {
              return DropdownMenuItem<int>(
                value: year,
                child: Text(year.toString()),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}