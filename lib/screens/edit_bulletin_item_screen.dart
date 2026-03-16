import 'package:flutter/material.dart';
import '../models/bulletin_item.dart';

class EditBulletinItemScreen extends StatefulWidget {
  final BulletinItem? item;

  const EditBulletinItemScreen({super.key, this.item});

  @override
  State<EditBulletinItemScreen> createState() => _EditBulletinItemScreenState();
}

class _EditBulletinItemScreenState extends State<EditBulletinItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.item?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.item?.description ?? '',
    );
    _timeController = TextEditingController(text: widget.item?.time ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newItem = BulletinItem(
        id: widget.item?.id ?? '',
        title: _titleController.text,
        description: _descriptionController.text,
        time: _timeController.text,
      );
      Navigator.pop(context, newItem);
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.item == null ? 'Add Program Item' : 'Edit Program Item',
        ),
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
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description / Person',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _timeController,
                      decoration: const InputDecoration(
                        labelText: 'Time (Optional)',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: _pickTime,
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
