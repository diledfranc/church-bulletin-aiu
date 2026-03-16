import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/sabbath_service.dart';

class ArchiveSelectorCard extends StatelessWidget {
  final List<SabbathService> services;
  final String selectedServiceId;
  final String activeServiceId;
  final bool canEdit;
  final ValueChanged<String?> onChanged;
  final VoidCallback onCreateNextSabbath;
  final VoidCallback onSetActive;

  const ArchiveSelectorCard({
    super.key,
    required this.services,
    required this.selectedServiceId,
    required this.activeServiceId,
    required this.canEdit,
    required this.onChanged,
    required this.onCreateNextSabbath,
    required this.onSetActive,
  });

  @override
  Widget build(BuildContext context) {
    final hasValidSelection = services.any(
      (service) => service.id == selectedServiceId,
    );

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sabbath Archive',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              key: ValueKey(selectedServiceId),
              isExpanded: true,
              initialValue: hasValidSelection ? selectedServiceId : null,
              hint: const Text('Select a Sabbath service'),
              items: services.map((service) {
                final isActive = service.id == activeServiceId;
                final dateLabel = DateFormat.yMMMd().format(
                  service.serviceDate,
                );
                final label = isActive ? '$dateLabel (Active)' : dateLabel;

                return DropdownMenuItem<String>(
                  value: service.id,
                  child: Text(label, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: onChanged,
            ),
            if (canEdit) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: onCreateNextSabbath,
                    icon: const Icon(Icons.add),
                    label: const Text('Create / Open Next Sabbath'),
                  ),
                  FilledButton.tonalIcon(
                    onPressed:
                        selectedServiceId.isNotEmpty &&
                            selectedServiceId != activeServiceId
                        ? onSetActive
                        : null,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Set Selected as Active'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
