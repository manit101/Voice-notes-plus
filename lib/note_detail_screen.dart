import 'package:flutter/material.dart';
import 'note_model.dart';
import 'database_helper.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;
  final bool isEditing;

  const NoteDetailScreen({
    super.key,
    required this.note,
    this.isEditing = false,
  });

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late bool _isEditing;
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.isEditing;
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() async {
    final updatedNote = Note(
      id: widget.note.id,
      title: _titleController.text,
      content: _contentController.text,
      dateTime: DateTime.now().toString(), // Update timestamp
    );

    await DatabaseHelper().updateNote(updatedNote.toMap());

    if (mounted) {
      Navigator.pop(context, true); // Return true to indicate update
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isEditing
            ? TextField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white, fontSize: 20),
                decoration: const InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
              )
            : Text(widget.note.title.isNotEmpty
                ? widget.note.title
                : 'Untitled Note'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: _isEditing ? _saveNote : _toggleEdit,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isEditing)
                Text(
                  widget.note.dateTime,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              const SizedBox(height: 16),
              _isEditing
                  ? TextField(
                      controller: _contentController,
                      style: const TextStyle(fontSize: 18),
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: 'Note Content',
                        border: InputBorder.none,
                      ),
                    )
                  : SelectableText(
                      widget.note.content,
                      style: const TextStyle(fontSize: 18),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
