import 'dart:io';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:just_audio/just_audio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const FaceDropStudioAI());

class FaceDropStudioAI extends StatelessWidget {
  const FaceDropStudioAI({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FACEDROP STUDIO AI',
      theme: ThemeData.dark(),
      home: const StudioHome(),
    );
  }
}

class StudioHome extends StatefulWidget {
  const StudioHome({super.key});
  @override
  State<StudioHome> createState() => _StudioHomeState();
}

class _StudioHomeState extends State<StudioHome> with TickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();
  final ImagePicker _picker = ImagePicker();
  bool _isRecording = false;
  bool _isPlaying = false;
  String _status = "Ready to record - CGN Global";
  String? _recordPath;
  File? _bgImage;
  int _selectedBeat = 0;
  int _bpm = 90;
  List<String> _myTracks = [];
  TabController? _tabController;
  final List<String> _beats = ["Afro Drill","Trap Soul","Gengetone","Amapiano","Boom Bap","Afro Pop","Dancehall","LoFi Chill"];
  final List<Color> _themes = [Colors.black, Color(0xFF2D1B4E), Color(0xFF0F172A), Color(0xFF1A1A2E), Colors.deepPurple];
  int _themeIndex = 0;
  final TextEditingController _lyricsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadTracks();
  }

  Future<void> _loadTracks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _myTracks = prefs.getStringList('cgn_tracks') ?? []);
  }

  Future<void> _toggleRecord() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() { _isRecording = false; _status = "Saved to CGN Cloud!"; _recordPath = path; });
      if (path != null) {
        final prefs = await SharedPreferences.getInstance();
        _myTracks.add(path.split('/').last);
        await prefs.setStringList('cgn_tracks', _myTracks);
      }
    } else {
      if (await Permission.microphone.request().isGranted) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/cgn_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000, sampleRate: 44100), path: path);
        setState(() { _isRecording = true; _status = "Recording... $_bpm BPM"; });
      }
    }
  }

  Future<void> _togglePlay() async {
    if (_recordPath == null) return;
    if (_isPlaying) { await _player.stop(); setState(() => _isPlaying = false); }
    else { await _player.setFilePath(_recordPath!); await _player.play(); setState(() => _isPlaying = true); }
  }

  Future<void> _pickBackground() async {
    final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _bgImage = File(img.path));
  }

  void _aiHelp() {
    final prompts = ["Hook: CGN to the world!", "AI: Drop bass at 0:08", "Tune: +2 semitones", "${_beats[_selectedBeat]} at $_bpm BPM is fire!", "Lyric: From Eldoret to the world..."];
    setState(() => _status = (prompts..shuffle()).first);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _themes[_themeIndex],
      appBar: AppBar(backgroundColor: Colors.black, title: const Text("FACEDROP STUDIO AI", style: TextStyle(fontWeight: FontWeight.bold)), actions: [IconButton(icon: const Icon(Icons.image), onPressed: _pickBackground), IconButton(icon: const Icon(Icons.palette), onPressed: () => setState(() => _themeIndex = (_themeIndex+1)%_themes.length))], bottom: TabBar(controller: _tabController, tabs: const [Tab(icon: Icon(Icons.mic), text: "Record"), Tab(icon: Icon(Icons.music_note), text: "Beats"), Tab(icon: Icon(Icons.auto_awesome), text: "AI"), Tab(icon: Icon(Icons.cloud), text: "CGN Cloud")])),
      body: Stack(children: [
        if (_bgImage != null) Opacity(opacity: 0.25, child: Image.file(_bgImage!, fit: BoxFit.cover, width: double.infinity, height: double.infinity)),
        TabBarView(controller: _tabController, children: [
          Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(_status), const SizedBox(height: 20), GestureDetector(onTap: _toggleRecord, child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, color: _isRecording?Colors.red:Colors.deepPurple), child: Icon(_isRecording?Icons.stop:Icons.mic, size: 60))), const SizedBox(height: 20), Row(mainAxisAlignment: MainAxisAlignment.center, children: [ElevatedButton.icon(onPressed: _recordPath==null?null:_togglePlay, icon: Icon(_isPlaying?Icons.stop:Icons.play_arrow), label: Text(_isPlaying?"Stop":"Play")), const SizedBox(width: 10), ElevatedButton.icon(onPressed: _aiHelp, icon: const Icon(Icons.auto_awesome), label: const Text("AI Mix"))])])),
          ListView(padding: const EdgeInsets.all(16), children: [Slider(value: _bpm.toDouble(), min: 60, max: 180, label: "$_bpm BPM", onChanged: (v) => setState(() => _bpm = v.toInt())), ..._beats.asMap().entries.map((e) => Card(color: _selectedBeat==e.key?Colors.purple.withOpacity(0.3):Colors.white10, child: ListTile(title: Text(e.value), subtitle: Text("$_bpm BPM"), trailing: ElevatedButton(onPressed: () => setState(() {_selectedBeat=e.key;}), child: const Text("Use"))))), ElevatedButton.icon(icon: const Icon(Icons.merge), label: const Text("MERGE BEAT + VOCALS"), onPressed: () => setState(() => _status="Merged! ${_beats[_selectedBeat]} + Voice"), style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple))]),
          Padding(padding: const EdgeInsets.all(16), child: Column(children: [TextField(controller: _lyricsController, maxLines: 5, decoration: const InputDecoration(hintText: "Write lyrics... AI helps", border: OutlineInputBorder())), const SizedBox(height: 10), Row(children: [Expanded(child: ElevatedButton(onPressed: _aiHelp, child: const Text("AI Write Hook"))), const SizedBox(width: 10), Expanded(child: ElevatedButton(onPressed: _aiHelp, child: const Text("AI Improve Mix")))]), const SizedBox(height: 20), Text(_status, style: const TextStyle(fontStyle: FontStyle.italic)) ])),
          ListView(padding: const EdgeInsets.all(16), children: [Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.purple, Colors.deepPurple]), borderRadius: BorderRadius.circular(12)), child: Column(children: [const Icon(Icons.cloud_upload, size: 40), const Text("CGN GLOBAL CLOUD", style: TextStyle(fontWeight: FontWeight.bold)), Text("${_myTracks.length} Tracks"), ElevatedButton.icon(icon: const Icon(Icons.share), label: const Text("SHARE TO WORLD"), onPressed: () => setState(() => _status="Shared! cgn.global/track"))])), ..._myTracks.map((t) => Card(child: ListTile(leading: const Icon(Icons.audio_file), title: Text(t))))]),
        ]),
      ]),
    );
  }
}
