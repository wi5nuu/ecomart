import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id; // Firestore document ID, default '' saat registrasi
  final String email;
  final String name;
  final String role; // 'admin' atau 'user'
  final String gender;
  final String phone;
  final String address;
  final bool agreeToTerms;
  final String? password; // Optional, bisa simpan hashed password jika perlu

  UserModel({
    this.id = '', // default kosong agar bisa dibuat sebelum simpan di Firestore
    required this.email,
    required this.name,
    this.role = 'user',
    required this.gender,
    required this.phone,
    required this.address,
    required this.agreeToTerms,
    this.password,
  });

  // copyWith untuk update sebagian field
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    String? gender,
    String? phone,
    String? address,
    bool? agreeToTerms,
    String? password,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      agreeToTerms: agreeToTerms ?? this.agreeToTerms,
      password: password ?? this.password,
    );
  }

  // Convert ke Map untuk simpan di Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'gender': gender,
      'phone': phone,
      'address': address,
      'agreeToTerms': agreeToTerms,
      'password': password,
    };
  }


  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'user',
      gender: map['gender'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      agreeToTerms: map['agreeToTerms'] ?? false,
      password: map['password'],
    );
  }

}
