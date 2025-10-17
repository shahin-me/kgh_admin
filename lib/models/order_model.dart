import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  String image;
  double pricePerUnit;
  String productId;
  String productName;
  int quantity;
  double totalPrice;

  OrderItem({
    required this.image,
    required this.pricePerUnit,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.totalPrice,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      image: map['image'] ?? '',
      pricePerUnit: (map['pricePerUnit'] ?? 0).toDouble(),
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      quantity: (map['quantity'] ?? 0).toInt(),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'image': image,
      'pricePerUnit': pricePerUnit,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'totalPrice': totalPrice,
    };
  }
}

class OrderModel {
  String? id;
  DateTime createdAt;
  List<OrderItem> items;
  String orderId;
  double paidAmount;
  double previousCustomerPayable;
  double previousDue;
  String shopAddress;
  String shopName;
  String status;
  double totalAmount;
  int totalItems;
  String userId;
  String? phoneNumber;

  OrderModel({
    this.id,
    required this.createdAt,
    required this.items,
    required this.orderId,
    required this.paidAmount,
    required this.previousCustomerPayable,
    required this.previousDue,
    required this.shopAddress,
    required this.shopName,
    required this.status,
    required this.totalAmount,
    required this.totalItems,
    required this.userId,
    this.phoneNumber,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
    return OrderModel(
      id: id,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      items: List<OrderItem>.from(
        (map['items'] ?? []).map((item) => OrderItem.fromMap(item)),
      ),
      orderId: map['orderId'] ?? '',
      paidAmount: (map['paidAmount'] ?? 0).toDouble(),
      previousCustomerPayable: (map['previousCustomerPayable'] ?? 0).toDouble(),
      previousDue: (map['previousDue'] ?? 0).toDouble(),
      shopAddress: map['shopAddress'] ?? '',
      shopName: map['shopName'] ?? '',
      status: map['status'] ?? 'pending',
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      totalItems: (map['totalItems'] ?? 0).toInt(),
      userId: map['userId'] ?? '',
      phoneNumber: map['phoneNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'createdAt': Timestamp.fromDate(createdAt),
      'items': items.map((item) => item.toMap()).toList(),
      'orderId': orderId,
      'paidAmount': paidAmount,
      'previousCustomerPayable': previousCustomerPayable,
      'previousDue': previousDue,
      'shopAddress': shopAddress,
      'shopName': shopName,
      'status': status,
      'totalAmount': totalAmount,
      'totalItems': totalItems,
      'userId': userId,
      'phoneNumber': phoneNumber,
    };
  }

  // Helper methods
  double get dueAmount => totalAmount - paidAmount;
  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isProcessing => status == 'processing';
  bool get isShipped => status == 'shipped';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  // Status progression methods
  bool get canApprove => isPending;
  bool get canProcess => isApproved;
  bool get canShip => isProcessing;
  bool get canComplete => isShipped;
  bool get canCancel => !isCompleted && !isCancelled;
}

// import 'package:cloud_firestore/cloud_firestore.dart';

// class OrderItem {
//   String image;
//   double pricePerUnit;
//   String productId;
//   String productName;
//   int quantity;
//   double totalPrice;

//   OrderItem({
//     required this.image,
//     required this.pricePerUnit,
//     required this.productId,
//     required this.productName,
//     required this.quantity,
//     required this.totalPrice,
//   });

//   factory OrderItem.fromMap(Map<String, dynamic> map) {
//     return OrderItem(
//       image: map['image'] ?? '',
//       pricePerUnit: (map['pricePerUnit'] ?? 0).toDouble(),
//       productId: map['productId'] ?? '',
//       productName: map['productName'] ?? '',
//       quantity: (map['quantity'] ?? 0).toInt(),
//       totalPrice: (map['totalPrice'] ?? 0).toDouble(),
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'image': image,
//       'pricePerUnit': pricePerUnit,
//       'productId': productId,
//       'productName': productName,
//       'quantity': quantity,
//       'totalPrice': totalPrice,
//     };
//   }
// }

// class OrderModel {
//   String? id;
//   DateTime createdAt;
//   List<OrderItem> items;
//   String orderId;
//   double paidAmount;
//   double previousCustomerPayable;
//   double previousDue;
//   String shopAddress;
//   String shopName;
//   String status;
//   double totalAmount;
//   int totalItems;
//   String userId;
//   String? phoneNumber;

//   OrderModel({
//     this.id,
//     required this.createdAt,
//     required this.items,
//     required this.orderId,
//     required this.paidAmount,
//     required this.previousCustomerPayable,
//     required this.previousDue,
//     required this.shopAddress,
//     required this.shopName,
//     required this.status,
//     required this.totalAmount,
//     required this.totalItems,
//     required this.userId,
//     this.phoneNumber,
//   });

//   factory OrderModel.fromMap(Map<String, dynamic> map, String id) {
//     return OrderModel(
//       id: id,
//       createdAt: (map['createdAt'] as Timestamp).toDate(),
//       items: List<OrderItem>.from(
//         (map['items'] ?? []).map((item) => OrderItem.fromMap(item)),
//       ),
//       orderId: map['orderId'] ?? '',
//       paidAmount: (map['paidAmount'] ?? 0).toDouble(),
//       previousCustomerPayable: (map['previousCustomerPayable'] ?? 0).toDouble(),
//       previousDue: (map['previousDue'] ?? 0).toDouble(),
//       shopAddress: map['shopAddress'] ?? '',
//       shopName: map['shopName'] ?? '',
//       status: map['status'] ?? 'pending',
//       totalAmount: (map['totalAmount'] ?? 0).toDouble(),
//       totalItems: (map['totalItems'] ?? 0).toInt(),
//       userId: map['userId'] ?? '',
//       phoneNumber: map['phoneNumber'],
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'createdAt': Timestamp.fromDate(createdAt),
//       'items': items.map((item) => item.toMap()).toList(),
//       'orderId': orderId,
//       'paidAmount': paidAmount,
//       'previousCustomerPayable': previousCustomerPayable,
//       'previousDue': previousDue,
//       'shopAddress': shopAddress,
//       'shopName': shopName,
//       'status': status,
//       'totalAmount': totalAmount,
//       'totalItems': totalItems,
//       'userId': userId,
//       'phoneNumber': phoneNumber,
//     };
//   }

//   // Helper methods
//   double get dueAmount => totalAmount - paidAmount;
//   bool get isPending => status == 'pending';
//   bool get isApproved => status == 'approved';
//   bool get isProcessing => status == 'processing';
//   bool get isShipped => status == 'shipped';
//   bool get isCompleted => status == 'completed';
//   bool get isCancelled => status == 'cancelled';

//   // Status progression methods
//   bool get canApprove => isPending;
//   bool get canProcess => isApproved;
//   bool get canShip => isProcessing;
//   bool get canComplete => isShipped;
//   bool get canCancel => !isCompleted && !isCancelled;
// }
