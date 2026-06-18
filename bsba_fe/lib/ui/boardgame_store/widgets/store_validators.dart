String? requiredField(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'This field is required';
  }
  return null;
}

String? positiveNumber(String? value) {
  final requiredError = requiredField(value);
  if (requiredError != null) {
    return requiredError;
  }

  final parsed = num.tryParse(value!.trim());
  if (parsed == null || parsed <= 0) {
    return 'Enter a number greater than 0';
  }
  return null;
}

String? storeNameField(String? value) {
  final requiredError = requiredField(value);
  if (requiredError != null) {
    return requiredError;
  }

  if (value!.trim().length > 255) {
    return 'Name cannot exceed 255 characters';
  }
  return null;
}

String? storeDescriptionField(String? value) {
  final requiredError = requiredField(value);
  if (requiredError != null) {
    return requiredError;
  }

  if (value!.trim().length > 500) {
    return 'Description cannot exceed 500 characters';
  }
  return null;
}

String? storeTimeField(String? value) {
  final requiredError = requiredField(value);
  if (requiredError != null) {
    return requiredError;
  }

  final trimmed = value!.trim();
  final match = RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2}))?$').firstMatch(trimmed);
  if (match == null) {
    return 'Enter a valid time, e.g. 08:00';
  }

  final hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  final second = int.tryParse(match.group(3) ?? '0') ?? -1;
  if (hour > 23 || minute > 59 || second > 59) {
    return 'Enter a valid time, e.g. 08:00';
  }
  return null;
}

String? storeCapacityField(String? value) {
  return _wholeNumberInRange(value, min: 1, max: 1000000, label: 'Capacity');
}

String? storeChargeFeeField(String? value) {
  return _numberInRange(value, min: 1000, max: 10000000, label: 'Charge fee');
}

String? storePhoneField(String? value) {
  final requiredError = requiredField(value);
  if (requiredError != null) {
    return requiredError;
  }

  if (!RegExp(r'^\d{10}$').hasMatch(value!.trim())) {
    return 'Phone must be exactly 10 numbers';
  }
  return null;
}

String? emailField(String? value) {
  final requiredError = requiredField(value);
  if (requiredError != null) {
    return requiredError;
  }

  final trimmed = value!.trim();
  final gmailPattern = RegExp(
    r'^[A-Za-z0-9._%+-]+@gmail\.com$',
    caseSensitive: false,
  );
  if (!gmailPattern.hasMatch(trimmed)) {
    return 'Enter a valid Gmail address';
  }
  return null;
}

String? _wholeNumberInRange(
  String? value, {
  required int min,
  required int max,
  required String label,
}) {
  final requiredError = requiredField(value);
  if (requiredError != null) {
    return requiredError;
  }

  final parsed = int.tryParse(value!.trim());
  if (parsed == null) {
    return '$label must be a whole number';
  }
  if (parsed < min || parsed > max) {
    return '$label must be between $min and $max';
  }
  return null;
}

String? _numberInRange(
  String? value, {
  required num min,
  required num max,
  required String label,
}) {
  final requiredError = requiredField(value);
  if (requiredError != null) {
    return requiredError;
  }

  final parsed = num.tryParse(value!.trim());
  if (parsed == null) {
    return '$label must be a number';
  }
  if (parsed < min || parsed > max) {
    return '$label must be between $min and $max';
  }
  return null;
}
