import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NoteScreen extends StatefulWidget {
  final String title;
  final String body;
  final Object? noteId;

  const NoteScreen({
    super.key,
    required this.title,
    required this.body,
    this.noteId,
  });

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  bool _isSaving = false;

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final description = _bodyController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Enter a title and description.')));
      return;
    }

    setState(() => _isSaving = true);
    try {
      final values = {'title': title, 'body': description};

      final notes = Supabase.instance.client.from('notes');
      if (widget.noteId == null) {
        await notes.insert(values);
      } else {
        await notes.update(values).eq('id', widget.noteId!);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not save note: $error')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title);
    _bodyController = TextEditingController(text: widget.body);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actionsPadding: EdgeInsets.only(right: 16),
        leading: BackButton(),
        actions: [
          IconButton(
            onPressed: _isSaving ? null : _saveNote,
            icon: Icon(Icons.save_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              maxLines: 1,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Title',
                border: InputBorder.none,
              ),
            ),
            Divider(),
            Expanded(
              child: TextField(
                
                controller: _bodyController,
                focusNode: FocusNode(),
                autofocus: true,
                expands: true,
                maxLines: null,
                minLines: null,
                textAlignVertical: TextAlignVertical.top,
                keyboardType: TextInputType.multiline,
                style: TextStyle(fontSize: 14, height: 1.5),
                decoration: InputDecoration(
                  hintText: 'Start writing your note...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
