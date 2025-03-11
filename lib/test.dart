import 'package:flutter/material.dart';
import 'package:odyssey/utils/string_constants.dart';
import 'package:odyssey/utils/theme.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final String hintText;

  const VoiceSearchBar({
    Key? key,
    required this.onSearch,
    this.hintText = 'Ask Gemini',
  }) : super(key: key);

  @override
  _VoiceSearchBarState createState() => _VoiceSearchBarState();
}

class _VoiceSearchBarState extends State<VoiceSearchBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _glowAnimation;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 2.0, end: 4.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeSpeech() async {
    try {
      await _speech.initialize();
    } catch (e) {
      print("Failed to initialize speech: $e");
    }
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              _textController.text = result.recognizedWords;
              widget.onSearch(result.recognizedWords);
              _stopListening();
            }
          },
        );
      }
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            Icon(Icons.search, color: Colors.grey[400]),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _textController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return IconButton(
                  icon: Icon(
                    Icons.mic,
                    color: _isListening ? Colors.blue : Colors.grey[400],
                    size: 28,
                  ),
                  onPressed: _isListening ? _stopListening : _startListening,
                );
              },
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.more_vert, color: Colors.grey[400]),
              onPressed: () {
                // Handle more options
              },
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

// Usage example:
class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: VoiceSearchBar(
          onSearch: (String text) {
            print('Search text: $text');
            // Handle the search text here
          },
        ),
      ),
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: StringConstants.appName,
      theme: ThemeData(
        fontFamily: 'Play',
        hintColor: Colors.white,
        scaffoldBackgroundColor: ThemesDark().normalColor,
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: ThemesDark().oppositeColor,
            ),
          ),
          hintStyle: TextStyle(color: ThemesDark().oppositeColor),
        ),
      ),
      home: Scaffold(
        body: VoiceSearchBar(
          onSearch: (String text) {
            print('Search text: $text');
          },
        ),
      ),
    );
  }
}