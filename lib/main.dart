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
  String status = "Ready to record";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FACEDROP STUDIO AI'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Status: $status', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
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
