import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/announcement.dart';

class EditAnnouncementScreen extends StatefulWidget {
  final Announcement? announcement;

  const EditAnnouncementScreen({super.key, this.announcement});

  @override
  State<EditAnnouncementScreen> createState() => _EditAnnouncementScreenState();
}

class _EditAnnouncementScreenState extends State<EditAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _detailController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.announcement?.title ?? '',
    );
    _detailController = TextEditingController(
      text: widget.announcement?.detail ?? '',
    );
    _selectedDate = widget.announcement?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newAnnouncement = Announcement(
        id:
            widget.announcement?.id ??
            '', // ID handled by Firestore for new items
        title: _titleController.text,
        detail: _detailController.text,
        date: _selectedDate,
      );
      Navigator.pop(context, newAnnouncement);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.announcement == null
              ? 'Add Announcement'
              : 'Edit Announcement',
        ),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveForm),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _detailController,
                decoration: const InputDecoration(labelText: 'Detail'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter details';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Date: ${DateFormat.yMMMd().format(_selectedDate)}'),
                  const Spacer(),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Select Date'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
