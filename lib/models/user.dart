class User {
  final String? id;       // Firebase UID (String)
  final String nationalId;
  final String phoneNumber;
  final String name;
  final String userType;
  final String? email;
  final String? address;

  User({
    this.id,
    required this.nationalId,
    required this.phoneNumber,
    required this.name,
    required this.userType,
    this.email,
    this.address,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nationalId': nationalId,
    'phoneNumber': phoneNumber,
    'name': name,
    'userType': userType,
    'email': email,
    'address': address,
  };

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id']?.toString(),
    nationalId: map['nationalId'] ?? '',
    phoneNumber: map['phoneNumber'] ?? map['phone'] ?? '',
    name: map['name'] ?? '',
    userType: map['userType'] ?? 'user',
    email: map['email'],
    address: map['address'],
  );
}
