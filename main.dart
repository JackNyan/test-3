import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MaterialApp(
    home: IndicatorEntrySender(),
  ));
}

class IndicatorEntrySender extends StatefulWidget {
  @override
  _IndicatorEntrySenderState createState() => _IndicatorEntrySenderState();
}

class _IndicatorEntrySenderState extends State<IndicatorEntrySender> {
  final valueController = TextEditingController();
  final shiftLeaderController = TextEditingController();
  final commentController = TextEditingController();

  String selectedArea = 'Birch A';
  String selectedShift = '0';
  DateTime recordDate = DateTime.now();
  DateTime recordDateTime = DateTime.now().toUtc();

  String statusMessage = '';
  Color statusColor = Colors.black;

  final apiConfig = {
    "Birch A": {
      "uri": "https://digital-pcs.saint-gobain.net/api/open/indicator/42127/values",
      "token": "6eae05a0d09dbf7ec13edac2aa2129139f6afbe66e7ccb0467bdff984411a493"
    },
    "Birch B": {
      "uri": "https://digital-pcs.saint-gobain.net/api/open/indicator/42128/values",
      "token": "47f7115ab3703f3b5c43294ec88efaa4e910a45d5bf5e7f550682877631ee879"
    }
  };

  Future<void> submitEntry() async {
    try {
      final config = apiConfig[selectedArea]!;
      final data = {
        "value": double.parse(valueController.text),
        "recordDate": recordDate.toIso8601String().split('T')[0],
        "recordDateTime": recordDateTime.toIso8601String(),
        "shift": int.parse(selectedShift),
        "shiftLeader": shiftLeaderController.text,
        "comment": commentController.text,
        "shouldDeformat": true
      };

      final response = await http.post(
        Uri.parse(config['uri']),
        headers: {
          'Authorization': 'Bearer ${config['token']}',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(data),
      );

      setState(() {
        statusMessage = '✅ Success: ${response.body}';
        statusColor = Colors.green;
      });
    } catch (e) {
      setState(() {
        statusMessage = '❌ Error: $e';
        statusColor = Colors.red;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Indicator Entry Sender')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField(
              value: selectedArea,
              items: ['Birch A', 'Birch B']
                  .map((area) => DropdownMenuItem(value: area, child: Text(area)))
                  .toList(),
              onChanged: (value) => setState(() => selectedArea = value!),
              decoration: InputDecoration(labelText: 'Area'),
            ),
            TextFormField(
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Value'),
            ),
            ListTile(
              title: Text("Record Date: ${recordDate.toLocal().toString().split(' ')[0]}"),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: recordDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null) setState(() => recordDate = picked);
              },
            ),
            ListTile(
              title: Text("Record DateTime (UTC): ${recordDateTime.toString()}"),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(recordDateTime),
                );
                if (picked != null) {
                  final now = DateTime.now().toUtc();
                  setState(() {
                    recordDateTime = DateTime.utc(
                      now.year, now.month, now.day,
                      picked.hour, picked.minute,
                    );
                  });
                }
              },
            ),
            DropdownButtonFormField(
              value: selectedShift,
              items: ['0', '1', '2']
                  .map((shift) => DropdownMenuItem(value: shift, child: Text('Shift $shift')))
                  .toList(),
              onChanged: (value) => setState(() => selectedShift = value!),
              decoration: InputDecoration(labelText: 'Shift'),
            ),
            TextFormField(
              controller: shiftLeaderController,
              decoration: InputDecoration(labelText: 'Shift Leader'),
            ),
            TextFormField(
              controller: commentController,
              maxLines: null,
              decoration: InputDecoration(labelText: 'Comment'),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: submitEntry,
                child: Text('Send Entry'),
              ),
            ),
            SizedBox(height: 20),
            Text(statusMessage, style: TextStyle(color: statusColor)),
          ],
        ),
      ),
    );
  }
}
