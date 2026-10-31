import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: StudioHome(),
    debugShowCheckedModeBanner: false,
  ));
}

class StudioHome extends StatefulWidget {
  @override
  _StudioHomeState createState() => _StudioHomeState();
}

class _StudioHomeState extends State<StudioHome> {
  bool isRecording = false;
  bool cloned = false;
  String status = "Ready to record";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FACEDROP STUDIO AI'),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.all(16),
              child: Text(
                'Status: $status',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isRecording ? 'Recording...' : 'Not Recording',
                    style: const TextStyle(color: Colors.white),
                  ),
                  Icon(
                    isRecording ? Icons.mic : Icons.mic_off,
                    color: isRecording ? Colors.red : Colors.white,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade800,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                cloned ? 'Voice Cloned!' : 'Voice Not Cloned',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isRecording = !isRecording;
                  status = isRecording ? 'Recording...' : 'Ready to record';
                });
              },
              icon: Icon(isRecording ? Icons.stop : Icons.play_arrow),
              label: Text(isRecording ? 'Stop' : 'Start Recording'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
