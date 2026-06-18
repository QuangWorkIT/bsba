class StaffStore {
  const StaffStore({
    required this.id,
    required this.storeName,
    required this.description,
    required this.address,
    required this.coverLetterUrl,
    required this.phone,
    required this.email,
    required this.openTime,
    required this.closeTime,
    required this.totalCapacity,
    required this.chargeFee,
  });

  final String id;
  final String storeName;
  final String description;
  final String address;
  final String coverLetterUrl;
  final String phone;
  final String email;
  final String openTime;
  final String closeTime;
  final int totalCapacity;
  final double chargeFee;

  factory StaffStore.fromJson(Map<String, dynamic> json) {
    return StaffStore(
      id: json['id']?.toString() ?? '',
      storeName: json['storeName']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      coverLetterUrl: json['coverLetterUrl']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      openTime: json['openTime']?.toString() ?? '',
      closeTime: json['closeTime']?.toString() ?? '',
      totalCapacity: int.tryParse(json['totalCapacity']?.toString() ?? '') ?? 0,
      chargeFee: double.tryParse(json['chargeFee']?.toString() ?? '') ?? 0,
    );
  }
}
