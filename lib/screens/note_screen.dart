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
      final now = DateTime.now().toUtc().toIso8601String();
      final values = {
        'title': title,
        'body': description,
        if (widget.noteId == null) 'created_at': now,
        'updated_at': now,
      };

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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        actionsPadding: EdgeInsets.only(right: 16),
        leading: BackButton(),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.archive)),
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
              style: textTheme.titleLarge,
              decoration: InputDecoration(
                hintText: 'Title',
                hintStyle: textTheme.titleLarge?.copyWith(
                  color: colorScheme.secondary.withValues(alpha: 0.7),
                ),
                border: InputBorder.none,
              ),
            ),
            Divider(color: colorScheme.onSurface),
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
                style: textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Start writing your note...',
                  hintStyle: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.secondary.withValues(alpha: 0.7),
                  ),
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
