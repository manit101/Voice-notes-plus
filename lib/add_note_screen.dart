import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'database_helper.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = '';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  String _statusText = 'Tap on mic to start recording';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  void _initSpeech() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      await Permission.microphone.request();
    }
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          print('onStatus: $val');
          if (val == 'done' || val == 'notListening') {
            setState(() {
              _isListening = false;
              _statusText = 'Tap on mic to start recording';
            });
            if (_contentController.text.isNotEmpty) {
              _showSaveDialog();
            }
          }
        },
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() {
          _isListening = true;
          _statusText = 'Recording...';
        });
        _speech.listen(
          onResult: (val) => setState(() {
            _text = val.recognizedWords;
            _contentController.text = _text;
          }),
          listenFor: const Duration(minutes: 5),
          pauseFor: const Duration(seconds: 20),
        );
      }
    } else {
      setState(() {
        _isListening = false;
        _statusText = 'Tap on mic to start recording';
      });
      _speech.stop();
    }
  }

  void _showSaveDialog() {
    _titleController.text =
        DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Enter title',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Delete/Discard
                _contentController.clear();
                _text = '';
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                _saveNote();
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to home
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveNote() async {
    if (_contentController.text.isEmpty) return;

    String title = _titleController.text.isNotEmpty
        ? _titleController.text
        : 'Note ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}';

    Map<String, dynamic> note = {
      'title': title,
      'content': _contentController.text,
      'dateTime': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
    };

    await DatabaseHelper().insertNote(note);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              _statusText,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                readOnly:
                    true, // Make it read-only so user relies on speech or dialog?
                // User didn't specify read-only, but said "user can make notes using speech".
                // I'll keep it editable just in case, but the flow is speech-centric.
                decoration: const InputDecoration(
                  hintText: 'Speech output will appear here...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: _listen,
        backgroundColor: _isListening ? Colors.red : null,
        child: Icon(_isListening ? Icons.mic : Icons.mic_none),
      ),
    );
  }
}
