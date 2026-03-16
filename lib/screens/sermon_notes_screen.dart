import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/user_note.dart';
import '../providers/auth_provider.dart';
import '../services/notes_service.dart';

class SermonNotesScreen extends StatefulWidget {
  final String serviceId;
  final String serviceLabel;
  final String programItemId;
  final String programTitle;

  const SermonNotesScreen({
    super.key,
    required this.serviceId,
    required this.serviceLabel,
    required this.programItemId,
    required this.programTitle,
  });

  @override
  State<SermonNotesScreen> createState() => _SermonNotesScreenState();
}

class _SermonNotesScreenState extends State<SermonNotesScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _noteController = TextEditingController();
  final NotesService _notesService = NotesService();

  late TabController _tabController;
  Timer? _autoSaveDebounce;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isHydrating = false;
  String _saveStatus = 'Loading note...';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _noteController.addListener(_onTextChanged);
    _loadNote();
  }

  @override
  void dispose() {
    _autoSaveDebounce?.cancel();
    _noteController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_isLoading || _isHydrating) {
      return;
    }

    setState(() {
      _saveStatus = 'Editing...';
    });

    _autoSaveDebounce?.cancel();
    _autoSaveDebounce = Timer(const Duration(milliseconds: 900), () async {
      await _saveNote(manual: false);
    });
  }

  Future<void> _loadNote() async {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _saveStatus = 'Sign in to use notes.';
      });
      return;
    }

    try {
      final existing = await _notesService.getNoteForProgram(
        userId: user.id,
        serviceId: widget.serviceId,
        programItemId: widget.programItemId,
      );

      if (existing != null) {
        _isHydrating = true;
        _noteController.text = existing.content;
        _isHydrating = false;
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _saveStatus = existing == null
            ? 'Start typing. Auto-save is on.'
            : 'Loaded saved note.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _saveStatus = 'Could not load note.';
      });
    }
  }

  Future<void> _saveNote({required bool manual}) async {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user == null) {
      if (manual && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to save notes.')),
        );
      }
      return;
    }

    final content = _noteController.text.trim();
    if (content.isEmpty) {
      if (!mounted) {
        return;
      }
      setState(() {
        _saveStatus = 'Type something to save.';
      });
      if (manual) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot save an empty note.')),
        );
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isSaving = true;
      });
    }

    try {
      await _notesService.saveNoteForProgram(
        userId: user.id,
        serviceId: widget.serviceId,
        programItemId: widget.programItemId,
        title: widget.programTitle,
        content: _noteController.text,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _saveStatus = 'Saved at ${DateFormat.jm().format(DateTime.now())}';
      });

      if (manual) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Note saved.')));
      }
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
        _saveStatus = 'Save failed. Please try again.';
      });

      if (manual) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to save note.')));
      }
    }
  }

  String _preview(String content) {
    final normalized = content.replaceAll('\n', ' ').trim();
    if (normalized.length <= 80) {
      return normalized;
    }
    return '${normalized.substring(0, 80)}...';
  }

  Future<void> _showNoteDialog(UserNote note) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(note.title),
          content: SingleChildScrollView(child: Text(note.content)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditorTab() {
    final user = Provider.of<AuthProvider>(context).currentUser;
    if (user == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Please sign in to create and save personal notes.'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sabbath: ${widget.serviceLabel}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Program: ${widget.programTitle}',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TextField(
              controller: _noteController,
              maxLines: null,
              expands: true,
              keyboardType: TextInputType.multiline,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                hintText: 'Write your sermon or Sabbath School notes here...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                _isSaving ? Icons.sync : Icons.check_circle_outline,
                size: 18,
                color: _isSaving ? Colors.orange : Colors.green,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(_saveStatus, overflow: TextOverflow.ellipsis),
              ),
              TextButton.icon(
                onPressed: () async {
                  await _saveNote(manual: true);
                },
                icon: const Icon(Icons.save_outlined),
                label: const Text('Save now'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    final user = Provider.of<AuthProvider>(context).currentUser;
    if (user == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Sign in to see your personal note history.'),
        ),
      );
    }

    return StreamBuilder<List<UserNote>>(
      stream: _notesService.watchNotesForService(
        userId: user.id,
        serviceId: widget.serviceId,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final notes = snapshot.data ?? [];
        if (notes.isEmpty) {
          return const Center(
            child: Text('No notes yet for this Sabbath archive.'),
          );
        }

        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return ListTile(
              leading: const Icon(Icons.sticky_note_2_outlined),
              title: Text(
                note.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${_preview(note.content)}\nUpdated ${DateFormat.yMMMd().add_jm().format(note.updatedAt)}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              isThreeLine: true,
              onTap: () async {
                await _showNoteDialog(note);
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          if (user != null)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                await _saveNote(manual: true);
              },
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Editor'),
            Tab(text: 'This Sabbath'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildEditorTab(), _buildHistoryTab()],
            ),
    );
  }
}
