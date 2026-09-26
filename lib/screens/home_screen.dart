import 'package:flutter/material.dart';
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
            child: const Text('Delete'),
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
          .showSnackBar(const SnackBar(content: Text('Note deleted.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not delete note: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: DrawerButton(),
        title: Text(
          'Home',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Notes App',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home_outlined),
                title: Text(
                  'Home',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: Icon(Icons.archive_outlined),
                title: Text(
                  'Archive',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ArchiveScreen()),
                ),
              ),
              ListTile(
                leading: Icon(Icons.delete_outlined),
                title: Text(
                  'Deleted',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DeletedScreen()),
                ),
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
                  FilledButton(
                    onPressed: _refreshNotes,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notes = snapshot.data ?? <Map<String, dynamic>>[];
          if (notes.isEmpty) {
            return Center(child: Text('No notes yet. Add your first note.'));
          }

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];
              return ListTile(
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
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                subtitle: Text(
                  note['body']?.toString() ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    overflow: TextOverflow.clip,
                  ),
                ),
                trailing: IconButton(
                  tooltip: 'Delete note',
                  onPressed: () => _deleteNote(note['id']),
                  icon: const Icon(Icons.delete_outline),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NoteScreen(title: '', body: ''),
            ),
          );
          if (mounted) _refreshNotes();
        },
        backgroundColor: Colors.deepOrange,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        child: Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
