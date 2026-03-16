import 'package:flutter/material.dart';
import '../models/contact.dart';

class EditContactScreen extends StatefulWidget {
  final Contact? contact;

  const EditContactScreen({super.key, this.contact});

  @override
  State<EditContactScreen> createState() => _EditContactScreenState();
}

class _EditContactScreenState extends State<EditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _roleController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _roleController = TextEditingController(text: widget.contact?.role ?? '');
    _phoneController = TextEditingController(
      text: widget.contact?.phoneNumber ?? '',
    );
    _emailController = TextEditingController(text: widget.contact?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      final newContact = Contact(
        id: widget.contact?.id ?? '',
        name: _nameController.text,
        role: _roleController.text,
        phoneNumber: _phoneController.text,
        email: _emailController.text,
      );
      Navigator.pop(context, newContact);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact == null ? 'Add Contact' : 'Edit Contact'),
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
              TextFormField(
                controller: _roleController,
                decoration: const InputDecoration(labelText: 'Role'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a role';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  // Basic email validation
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
