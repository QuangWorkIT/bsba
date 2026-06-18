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

String? emailField(String? value) {
  final requiredError = requiredField(value);
  if (requiredError != null) {
    return requiredError;
  }

  if (!value!.contains('@') || !value.contains('.')) {
    return 'Enter a valid email';
  }
  return null;
}
