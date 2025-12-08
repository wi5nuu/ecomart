import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id; // UID Firebase Auth
  final String name;
  final String email;
  final String phone;
  final String address;
  final String gender;
  final bool agreeToTerms;
  final bool isAdmin;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.gender,
    required this.agreeToTerms,
    this.isAdmin = false,
  });

  // copyWith method
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? gender,
    bool? agreeToTerms,
    bool? isAdmin,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      agreeToTerms: agreeToTerms ?? this.agreeToTerms,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  // Untuk menyimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'gender': gender,
      'agreeToTerms': agreeToTerms,
      'isAdmin': isAdmin,
    };
  }

  // Factory untuk FirestoreService, menerima id terpisah
  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      gender: data['gender'] ?? '',
      agreeToTerms: data['agreeToTerms'] ?? false,
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  // Factory dari DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception("Document ${doc.id} tidak memiliki data");
    }
    return UserModel.fromMap(doc.id, data);
  }
}
