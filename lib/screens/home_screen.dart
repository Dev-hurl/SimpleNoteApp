import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:note_app/core/theme/theme_provider.dart';
import 'package:note_app/screens/archive_screen.dart';
import 'package:note_app/screens/deleted_screen.dart';
import 'package:note_app/screens/note_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _notesFuture;

  String _formatNoteTimestamp(Map<String, dynamic> note) {
    final timestamp = note['updated_at'] ?? note['created_at'];
    if (timestamp == null) return '';

    try {
      final dateTime = DateTime.parse(timestamp.toString()).toLocal();
      final localizations = MaterialLocalizations.of(context);
      final date = localizations.formatShortDate(dateTime);
      final time = TimeOfDay.fromDateTime(dateTime).format(context);
      return '$date · $time';
    } on FormatException {
      return '';
    }
  }

  @override
  void initState() {
    super.initState();
    _notesFuture = _fetchNotes();
  }

  Future<List<Map<String, dynamic>>> _fetchNotes() async {
    final rows = await Supabase.instance.client.from('notes').select();
    return List<Map<String, dynamic>>.from(rows);
  }

  void _refreshNotes() {
    setState(() {
      _notesFuture = _fetchNotes();
    });
  }

  Future<void> _deleteNote(Object? noteId) async {
    if (noteId == null) return;

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('This note will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    try {
      await Supabase.instance.client.from('notes').delete().eq('id', noteId);
      if (!mounted) return;
      _refreshNotes();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Note deleted.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not delete note: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: DrawerButton(),
        title: Text('Home', style: textTheme.titleLarge),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text('Notes App', style: textTheme.titleLarge),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home_outlined),
                title: Text('Home', style: textTheme.bodyMedium),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.archive_outlined),
                title: Text('Archive', style: textTheme.bodyMedium),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ArchiveScreen()),
                ),
              ),
              ListTile(
                leading: Icon(Icons.delete_outlined),
                title: Text('Deleted', style: textTheme.bodyMedium),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeletedScreen()),
                ),
              ),
              SwitchListTile(
                secondary: Icon(
                  themeProvider.isDarkMode
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                ),
                title: Text('Dark mode', style: textTheme.bodyMedium),
                value: themeProvider.isDarkMode,
                onChanged: themeProvider.toggleTheme,
              ),
            ],
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _notesFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error loading notes: ${snapshot.error}'),
                  SizedBox(height: 12),
                  FilledButton(onPressed: _refreshNotes, child: Text('Retry')),
                ],
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final notes = snapshot.data ?? <Map<String, dynamic>>[];
          if (notes.isEmpty) {
            return Center(child: Text('No notes yet. Add your first note.'));
          }

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slidable(
                    key: ValueKey(note['id']),
                    startActionPane: ActionPane(
                      motion: ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: null,
                          backgroundColor: colorScheme.primary,
                          icon: Icons.archive_outlined,
                          label: 'Archive',
                          spacing: 4,
                        ),
                      ],
                    ),
                    endActionPane: ActionPane(
                      motion: ScrollMotion(),
                      children: [
                        SlidableAction(
                          onPressed: (_) => _deleteNote(note['id']),
                          backgroundColor: colorScheme.error,
                          icon: Icons.archive_outlined,
                          label: 'Delete',
                          padding: EdgeInsets.all(8.0),
                        ),
                      ],
                    ),
                    child: ListTile(
                      //tileColor: colorScheme.secondary.withValues(alpha: 0.2),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NoteScreen(
                              noteId: note['id'],
                              title: note['title']?.toString() ?? '',
                              body: note['body']?.toString() ?? '',
                            ),
                          ),
                        );
                        if (mounted) _refreshNotes();
                      },
                      title: Text(
                        note['title']?.toString() ?? 'Untitled',
                        style: textTheme.titleLarge,
                      ),
                      subtitle: Text(
                        note['body']?.toString() ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Text(
                        _formatNoteTimestamp(note),
                        textAlign: TextAlign.end,
                        style: textTheme.bodySmall,
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    indent: 20,
                    endIndent: 20,
                    color: Color(0xff656E80),
                  ),
                ],
              );
            },
          );
        },
      ),

      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 40, right: 12),
        child: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NoteScreen(title: '', body: ''),
              ),
            );
            if (mounted) _refreshNotes();
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
