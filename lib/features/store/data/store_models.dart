double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _toInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _toDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

String? _toString(dynamic value) => value?.toString();

class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.currency,
    required this.availableQuantity,
    required this.isOutOfStock,
    required this.status,
    this.category,
    this.image,
    this.description,
  });

  final String id;
  final String name;
  final String? category;
  final String? image;
  final String? description;
  final double price;
  final String currency;
  final int availableQuantity;
  final bool isOutOfStock;
  final String status;

  factory StoreProduct.fromJson(Map<String, dynamic> json) {
    return StoreProduct(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: _toString(json['category']),
      image: _toString(json['image']),
      description: _toString(json['description']),
      price: _toDouble(json['price']),
      currency: json['currency']?.toString() ?? 'USD',
      availableQuantity: _toInt(json['availableQuantity']),
      isOutOfStock:
          json['isOutOfStock'] == true ||
          _toInt(json['availableQuantity']) <= 0,
      status: json['status']?.toString() ?? '',
    );
  }
}

class StoreOrder {
  const StoreOrder({
    required this.id,
    required this.orderNumber,
    required this.buyerName,
    required this.buyerType,
    required this.buyerPhoneNumber,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    required this.currency,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.orderStatus,
    this.product,
    this.provider,
    this.evcTransactionReference,
    this.orderDate,
    this.paidAt,
    this.transaction,
  });

  final String id;
  final String orderNumber;
  final String buyerName;
  final String buyerType;
  final String buyerPhoneNumber;
  final StoreProduct? product;
  final int quantity;
  final double unitPrice;
  final double totalAmount;
  final String currency;
  final String paymentMethod;
  final String? provider;
  final String? evcTransactionReference;
  final String paymentStatus;
  final String orderStatus;
  final DateTime? orderDate;
  final DateTime? paidAt;
  final Map<String, dynamic>? transaction;

  factory StoreOrder.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'];
    final transactionJson = json['transaction'];
    return StoreOrder(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? '',
      buyerName: json['buyerName']?.toString() ?? '',
      buyerType: json['buyerType']?.toString() ?? '',
      buyerPhoneNumber: json['buyerPhoneNumber']?.toString() ?? '',
      product: productJson is Map<String, dynamic>
          ? StoreProduct.fromJson(productJson)
          : null,
      quantity: _toInt(json['quantity']),
      unitPrice: _toDouble(json['unitPrice']),
      totalAmount: _toDouble(json['totalAmount']),
      currency: json['currency']?.toString() ?? 'USD',
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      provider: _toString(json['provider']),
      evcTransactionReference: _toString(json['evcTransactionReference']),
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      orderStatus: json['orderStatus']?.toString() ?? '',
      orderDate: _toDate(json['orderDate']),
      paidAt: _toDate(json['paidAt']),
      transaction: transactionJson is Map<String, dynamic>
          ? transactionJson
          : null,
    );
  }
}

class StorePurchaseResult {
  const StorePurchaseResult({
    required this.paymentStatus,
    required this.message,
    this.product,
    this.order,
    this.transaction,
  });

  final String paymentStatus;
  final String message;
  final StoreProduct? product;
  final StoreOrder? order;
  final Map<String, dynamic>? transaction;

  factory StorePurchaseResult.fromJson(Map<String, dynamic> json) {
    final productJson = json['product'];
    final orderJson = json['order'];
    final transactionJson = json['transaction'];
    return StorePurchaseResult(
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      message:
          json['message']?.toString() ??
          json['responseMessage']?.toString() ??
          '',
      product: productJson is Map<String, dynamic> && productJson.isNotEmpty
          ? StoreProduct.fromJson(productJson)
          : null,
      order: orderJson is Map<String, dynamic>
          ? StoreOrder.fromJson(orderJson)
          : null,
      transaction: transactionJson is Map<String, dynamic>
          ? transactionJson
          : null,
    );
  }

  bool get hasCreatedOrder =>
      paymentStatus.toUpperCase() == 'PAID' && order != null;

  bool get isPending => paymentStatus.toUpperCase() == 'PENDING';

  bool get isFailedOrCancelled {
    final status = paymentStatus.toUpperCase();
    return status == 'FAILED' || status == 'CANCELLED' || order == null;
  }

  String get displayMessage {
    final failedReason = transaction?['failedReason']?.toString();
    if (message.isNotEmpty) return message;
    if (failedReason != null && failedReason.isNotEmpty) return failedReason;
    return 'Payment was not completed';
  }
}
