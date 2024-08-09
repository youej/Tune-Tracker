import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  bool isRunning = false;
  Duration duration = const Duration();
  late Ticker _ticker;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool isRecording = false;
  String audioFilePath = '';
  int secondsCounter = 0;
  bool activated = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (isRunning) {
        setState(() {
          duration += const Duration(seconds: 1);
        });
        secondsCounter += 1;
        if (secondsCounter >= 60) {
          _stopTimer();
          _restartRecording();
          secondsCounter = 0;
        }
      }

    });
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await Permission.microphone.request();
    await _recorder.openAudioSession();
    Directory tempDir = await getTemporaryDirectory();
    audioFilePath = '${tempDir.path}/audio.aac';
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _startTimer() {
    _ticker.start();
    setState(() {
      isRunning = true;
    });
  }

  void _stopTimer() {
    _ticker.stop();
    setState(() {
      isRunning = false;
    });
  }

  void _resetTimer() {
    setState(() {
      duration = const Duration();
    });
  }

  void _startRecording() {
    _recorder.startRecorder(toFile: audioFilePath);
    setState(() {
      isRecording = true;
    });
  }

  void _stopRecording() {
    _recorder.stopRecorder();
    setState(() {
      isRecording = false;
    });
  }

  void _restartRecording() async {
    _stopRecording(); // stops current recording
    _checkAudio(); // processes current recording
    _startRecording(); // starts new recording
  }

  void _activateFeature() {
    if (isRecording) {
      _stopRecording();
    }
    else {
      _startRecording();
    }

    activated = !activated;

    // Logic for activating the feature goes here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feature activated!')),
    );

  }

  void _checkAudio() async {
    final file = File(audioFilePath);
    bool isMusic = true;
    if (file.existsSync()) {
      // Perform audio classification
      isMusic = false;
    }

    if (isMusic) {
      _startTimer();
    }
    else {
      _stopTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[5000], // Lighter shade of black
        title: Row(
          children: const [
            Icon(Icons.music_note),
            SizedBox(width: 10),
            Text("Tune Tracker"),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Spacer(flex: 2),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 250, // Increased size for larger circle
                  height: 250, // Increased size for larger circle
                  child: CircularProgressIndicator(
                    value: (duration.inSeconds % 3600) / 3600.0,
                    strokeWidth: 8,
                    color: Colors.blue,
                    backgroundColor: Colors.grey,
                  ),
                ),
                Text(
                  '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 48, color: Colors.white),
                ),
              ],
            ),
            const Spacer(flex: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: isRunning ? _stopTimer : _startTimer,
                  child: Text(
                      isRunning ? 'Stop' : 'Start',
                      style: TextStyle(color: Colors.black)
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Dark blue color
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: const Text(
                      'Reset',
                      style: TextStyle(color: Colors.black)
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey, // Grey color for reset button
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _activateFeature,
                  child: Text(
                      isRecording ? 'Deactivate' : 'Activate',
                      style: TextStyle(color: Colors.black)
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600], // Dark blue color
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 16),
                  ),
                ),
              ],
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
