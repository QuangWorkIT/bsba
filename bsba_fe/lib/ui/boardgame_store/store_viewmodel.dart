import 'package:flutter/material.dart';
import 'package:project/data/models/staff_store.dart';
import 'package:project/data/repositories/store_repository.dart';
import 'package:project/data/services/api_client.dart';

enum StoreProfileStatus { loading, loaded, unassigned, adding, error }

class StoreProfileViewModel extends ChangeNotifier {
  StoreProfileViewModel({required this.repository, required this.staffId})
    : storeNameController = TextEditingController(),
      descriptionController = TextEditingController(),
      openTimeController = TextEditingController(),
      closeTimeController = TextEditingController(),
      capacityController = TextEditingController(),
      chargeController = TextEditingController(),
      addressController = TextEditingController(),
      latitudeController = TextEditingController(),
      longitudeController = TextEditingController(),
      phoneController = TextEditingController(),
      emailController = TextEditingController();

  final StoreRepository repository;
  final String staffId;

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

  StoreProfileStatus _status = StoreProfileStatus.loading;
  bool _isSaving = false;
  String? _errorMessage;
  StaffStore? _store;

  StoreProfileStatus get status => _status;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  StaffStore? get store => _store;
  String get coverLetterUrl => _store?.coverLetterUrl ?? '';
  bool get isAddingStore => _status == StoreProfileStatus.adding;

  Future<void> loadStore() async {
    _status = StoreProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final store = await repository.fetchStoreByStaffId(staffId);
      _store = store;
      _populateForm(store);
      _status = StoreProfileStatus.loaded;
    } on ApiException catch (error) {
      if (error.statusCode == 404) {
        _store = null;
        _clearForm();
        _status = StoreProfileStatus.unassigned;
        _errorMessage = error.message;
      } else {
        _status = StoreProfileStatus.error;
        _errorMessage = error.message;
      }
    } catch (_) {
      _status = StoreProfileStatus.error;
      _errorMessage = 'Unable to load store profile. Please try again.';
    }

    notifyListeners();
  }

  void startAddingStore() {
    _store = null;
    _clearForm();
    _status = StoreProfileStatus.adding;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> save() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return false;
    }

    final store = _store;
    if (store == null) {
      _errorMessage = 'Load an existing store before saving changes.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedStore = await repository.updateStaffStore(
        StaffStoreUpdateRequest(
          staffId: staffId,
          storeId: store.id,
          storeName: storeNameController.text.trim(),
          description: descriptionController.text.trim(),
          address: addressController.text.trim(),
          coverLetterUrl: coverLetterUrl,
          phone: phoneController.text.trim(),
          email: emailController.text.trim(),
          openTime: _requestTime(openTimeController.text),
          closeTime: _requestTime(closeTimeController.text),
          totalCapacity: int.parse(capacityController.text.trim()),
          chargeFee: double.parse(chargeController.text.trim()),
        ),
      );
      _store = updatedStore;
      _populateForm(updatedStore);
      _status = StoreProfileStatus.loaded;
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
      return false;
    } catch (_) {
      _errorMessage = 'Unable to save store profile. Please try again.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void _populateForm(StaffStore store) {
    storeNameController.text = store.storeName;
    descriptionController.text = store.description;
    openTimeController.text = _formatTime(store.openTime);
    closeTimeController.text = _formatTime(store.closeTime);
    capacityController.text = store.totalCapacity.toString();
    chargeController.text = _formatMoney(store.chargeFee);
    addressController.text = store.address;
    latitudeController.clear();
    longitudeController.clear();
    phoneController.text = store.phone;
    emailController.text = store.email;
  }

  void _clearForm() {
    storeNameController.clear();
    descriptionController.clear();
    openTimeController.clear();
    closeTimeController.clear();
    capacityController.clear();
    chargeController.clear();
    addressController.clear();
    latitudeController.clear();
    longitudeController.clear();
    phoneController.clear();
    emailController.clear();
  }

  String _formatTime(String value) {
    final parts = value.split(':');
    if (parts.length >= 2) {
      return '${parts[0]}:${parts[1]}';
    }
    return value;
  }

  String _formatMoney(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2);
  }

  String _requestTime(String value) {
    final trimmed = value.trim();
    final parts = trimmed.split(':');
    if (parts.length == 2) {
      return '$trimmed:00';
    }
    return trimmed;
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
