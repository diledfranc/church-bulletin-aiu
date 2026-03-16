import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';

class EditEventScreen extends StatefulWidget {
  final Event? event;

  const EditEventScreen({super.key, this.event});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _locationController = TextEditingController(
      text: widget.event?.location ?? '',
    );
    _selectedDateTime = widget.event?.dateTime ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newEvent = Event(
        id: widget.event?.id ?? '',
        title: _titleController.text,
        dateTime: _selectedDateTime,
        location: _locationController.text,
      );
      Navigator.pop(context, newEvent);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Add Event' : 'Edit Event'),
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
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    'Date & Time: ${DateFormat.yMMMd().add_jm().format(_selectedDateTime)}',
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _pickDateTime,
                    child: const Text('Select Date & Time'),
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
