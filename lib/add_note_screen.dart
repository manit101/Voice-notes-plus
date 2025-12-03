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
  String _previousText = ''; // Store text before current session
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
            if (_isListening) {
              // If user still wants to listen but system stopped it, restart!
              _startListening();
            } else {
              setState(() {
                _statusText = 'Tap on mic to start recording';
              });
            }
          }
        },
        onError: (val) => print('onError: $val'),
      );
      if (available) {
        setState(() {
          _isListening = true;
        });
        _startListening();
      }
    } else {
      setState(() {
        _isListening = false;
        _statusText = 'Tap on mic to start recording';
      });
      _speech.stop();
      // Show dialog ONLY on manual stop
      if (_contentController.text.isNotEmpty) {
        _showSaveDialog();
      }
    }
  }

  void _startListening() {
    setState(() {
      _statusText = 'Recording...';
      _previousText = _contentController.text; // Save existing text
    });
    _speech.listen(
      pauseFor: const Duration(seconds: 30), // Wait longer before auto-stop
      onResult: (val) => setState(() {
        _text = val.recognizedWords;
        // Append new speech to previous text
        if (_previousText.isNotEmpty) {
          _contentController.text = '$_previousText $_text';
        } else {
          _contentController.text = _text;
        }
      }),
    );
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
                _previousText = '';
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
                readOnly: true,
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
