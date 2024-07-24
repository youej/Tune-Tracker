import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (isRunning) {
        setState(() {
          duration += const Duration(seconds: 1);
        });
      }
    });
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
                  child: Text(isRunning ? 'Stop' : 'Start'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Dark blue color
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _resetTimer,
                  child: const Text('Reset'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey, // Grey color for reset button
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
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
