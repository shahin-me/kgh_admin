import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  String? id;
  String address;
  DateTime createdAt;
  String deliveryDay;
  String email;
  String phone;
  String proprietorName;
  String shopName;
  double totalDue;
  double totalPayableToCustomer;

  CustomerModel({
    this.id,
    required this.address,
    required this.createdAt,
    required this.deliveryDay,
    required this.email,
    required this.phone,
    required this.proprietorName,
    required this.shopName,
    required this.totalDue,
    required this.totalPayableToCustomer,
  });

  factory CustomerModel.fromMap(Map<String, dynamic> map, String id) {
    return CustomerModel(
      id: id,
      address: map['address'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      deliveryDay: map['deliveryDay'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      proprietorName: map['proprietorName'] ?? '',
      shopName: map['shopName'] ?? '',
      totalDue: (map['totalDue'] ?? 0).toDouble(),
      totalPayableToCustomer: (map['totalPayableToCustomer'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'address': address,
      'createdAt': Timestamp.fromDate(createdAt),
      'deliveryDay': deliveryDay,
      'email': email,
      'phone': phone,
      'proprietorName': proprietorName,
      'shopName': shopName,
      'totalDue': totalDue,
      'totalPayableToCustomer': totalPayableToCustomer,
    };
  }

  // Helper methods
  double get netBalance => totalPayableToCustomer - totalDue;
  bool get hasDue => totalDue > 0;
  bool get hasPayable => totalPayableToCustomer > 0;
}
