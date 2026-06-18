import 'package:flutter/material.dart';

class StoreProfileViewModel extends ChangeNotifier {
  StoreProfileViewModel()
    : storeNameController = TextEditingController(text: 'BoardNest Downtown'),
      descriptionController = TextEditingController(
        text:
            'A premier destination for enthusiasts and families alike. '
            'Featuring over 500 board games, private rooms, and a specialty '
            'cafe. We prioritize a community-first atmosphere for gaming '
            'events and tournaments.',
      ),
      openTimeController = TextEditingController(text: '09:00 AM'),
      closeTimeController = TextEditingController(text: '10:00 PM'),
      capacityController = TextEditingController(text: '45'),
      chargeController = TextEditingController(text: r'$9.50'),
      addressController = TextEditingController(
        text: '123 Gaming Lane, Suite 400, Central City',
      ),
      latitudeController = TextEditingController(text: '40.7128 N'),
      longitudeController = TextEditingController(text: '74.0060 W'),
      phoneController = TextEditingController(text: '+1 (555) 902-1040'),
      emailController = TextEditingController(text: 'contact@boardnest-dt.com');

  final formKey = GlobalKey<FormState>();
  final TextEditingController storeNameController;
  final TextEditingController descriptionController;
  final TextEditingController openTimeController;
  final TextEditingController closeTimeController;
  final TextEditingController capacityController;
  final TextEditingController chargeController;
  final TextEditingController addressController;
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final TextEditingController phoneController;
  final TextEditingController emailController;

  bool _isSaving = false;

  bool get isSaving => _isSaving;

  Future<bool> save() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return false;
    }

    _isSaving = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 450));
    _isSaving = false;
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    storeNameController.dispose();
    descriptionController.dispose();
    openTimeController.dispose();
    closeTimeController.dispose();
    capacityController.dispose();
    chargeController.dispose();
    addressController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
