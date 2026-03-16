import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/duty_roster_item.dart';

class EditDutyRosterScreen extends StatefulWidget {
  final DutyRosterItem? item;

  const EditDutyRosterScreen({super.key, this.item});

  @override
  State<EditDutyRosterScreen> createState() => _EditDutyRosterScreenState();
}

class _EditDutyRosterScreenState extends State<EditDutyRosterScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _roleController;
  late TextEditingController _nameController;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _roleController = TextEditingController(text: widget.item?.role ?? '');
    _nameController = TextEditingController(text: widget.item?.name ?? '');
    _selectedDate = widget.item?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _roleController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newItem = DutyRosterItem(
        id: widget.item?.id ?? '',
        role: _roleController.text,
        name: _nameController.text,
        date: _selectedDate,
      );
      Navigator.pop(context, newItem);
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      if (!mounted) return;
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Add Duty' : 'Edit Duty'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _saveForm),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(
                  labelText: 'Role (e.g. Greeter)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a role';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text(
                  'Date: ${DateFormat.yMMMd().format(_selectedDate)}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
