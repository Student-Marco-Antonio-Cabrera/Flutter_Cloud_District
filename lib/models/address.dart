class Address {
  Address({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.city,
    this.postalCode,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String fullAddress;
  final String city;
  final String? postalCode;
  final bool isDefault;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'fullAddress': fullAddress,
        'city': city,
        'postalCode': postalCode,
        'isDefault': isDefault,
      };

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json['id'] as String,
        label: json['label'] as String,
        fullAddress: json['fullAddress'] as String,
        city: json['city'] as String,
        postalCode: json['postalCode'] as String?,
        isDefault: json['isDefault'] as bool? ?? false,
      );

  Address copyWith({
    String? id,
    String? label,
    String? fullAddress,
    String? city,
    String? postalCode,
    bool? isDefault,
  }) =>
      Address(
        id: id ?? this.id,
        label: label ?? this.label,
        fullAddress: fullAddress ?? this.fullAddress,
        city: city ?? this.city,
        postalCode: postalCode ?? this.postalCode,
        isDefault: isDefault ?? this.isDefault,
      );
}
