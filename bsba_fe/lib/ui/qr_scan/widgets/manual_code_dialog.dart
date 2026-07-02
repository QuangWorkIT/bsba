import 'package:flutter/material.dart';

class ManualCodeDialog extends StatefulWidget {
  const ManualCodeDialog({super.key});

  @override
  State<ManualCodeDialog> createState() => _ManualCodeDialogState();
}

class _ManualCodeDialogState extends State<ManualCodeDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _submitted = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enter Booking Code'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(
            labelText: 'Booking code',
            hintText: '123456',
          ),
          validator: (value) {
            final code = value?.trim() ?? '';
            if (code.isEmpty) {
              return 'Booking code is required.';
            }
            if (code.length < 6) {
              return 'Use at least 6 characters.';
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Check in')),
      ],
    );
  }

  void _submit() {
    if (_submitted) {
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      _submitted = true;
      Navigator.of(context).pop(_controller.text.trim());
    }
  }
}
