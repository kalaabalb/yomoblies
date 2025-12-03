class Order {
  ShippingAddress? shippingAddress;
  OrderTotal? orderTotal;
  String? sId;
  UserID? userID;
  String? orderStatus;
  List<Items>? items;
  double? totalPrice;
  String? paymentMethod;
  String? paymentStatus;
  PaymentProof? paymentProof;
  String? trackingUrl;
  String? orderDate;
  int? iV;

  Order({
    this.shippingAddress,
    this.orderTotal,
    this.sId,
    this.userID,
    this.orderStatus,
    this.items,
    this.totalPrice,
    this.paymentMethod,
    this.paymentStatus,
    this.paymentProof,
    this.trackingUrl,
    this.orderDate,
    this.iV,
  });

  Order.fromJson(Map<String, dynamic> json) {
    shippingAddress = json['shippingAddress'] != null
        ? ShippingAddress.fromJson(json['shippingAddress'])
        : null;
    orderTotal = json['orderTotal'] != null
        ? OrderTotal.fromJson(json['orderTotal'])
        : null;
    sId = json['_id'];
    userID = json['userID'] != null ? UserID.fromJson(json['userID']) : null;
    orderStatus = json['orderStatus'];
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
    totalPrice = json['totalPrice']?.toDouble();
    paymentMethod = json['paymentMethod'];
    paymentStatus = json['paymentStatus'];
    paymentProof = json['paymentProof'] != null
        ? PaymentProof.fromJson(json['paymentProof'])
        : null;
    trackingUrl = json['trackingUrl'];
    orderDate = json['orderDate'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (shippingAddress != null) {
      data['shippingAddress'] = shippingAddress!.toJson();
    }
    if (orderTotal != null) {
      data['orderTotal'] = orderTotal!.toJson();
    }
    data['_id'] = sId;
    if (userID != null) {
      data['userID'] = userID!.toJson();
    }
    data['orderStatus'] = orderStatus;
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    data['totalPrice'] = totalPrice;
    data['paymentMethod'] = paymentMethod;
    data['paymentStatus'] = paymentStatus;
    if (paymentProof != null) {
      data['paymentProof'] = paymentProof!.toJson();
    }
    data['trackingUrl'] = trackingUrl;
    data['orderDate'] = orderDate;
    data['__v'] = iV;
    return data;
  }

  // Helper methods
  bool get isPaymentPending => paymentStatus == 'pending';
  bool get isPaymentVerified => paymentStatus == 'verified';
  bool get isPaymentFailed => paymentStatus == 'failed';
  bool get isCashOnDelivery => paymentMethod == 'cod';
  bool get isBankTransfer => paymentMethod == 'cbe';
  bool get isMobilePayment => paymentMethod == 'telebirr';

  String get paymentStatusDisplay {
    switch (paymentStatus) {
      case 'verified':
        return 'Payment Verified';
      case 'failed':
        return 'Payment Failed';
      case 'pending':
      default:
        return 'Payment Pending';
    }
  }

  String get orderStatusDisplay {
    switch (orderStatus) {
      case 'payment_pending':
        return 'Awaiting Payment';
      case 'payment_verified':
        return 'Payment Verified';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      case 'pending':
      default:
        return 'Pending';
    }
  }
}

class ShippingAddress {
  String? phone;
  String? street;
  String? city;
  String? state;
  String? postalCode;
  String? country;

  ShippingAddress({
    this.phone,
    this.street,
    this.city,
    this.state,
    this.postalCode,
    this.country,
  });

  ShippingAddress.fromJson(Map<String, dynamic> json) {
    phone = json['phone'];
    street = json['street'];
    city = json['city'];
    state = json['state'];
    postalCode = json['postalCode'];
    country = json['country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['phone'] = phone;
    data['street'] = street;
    data['city'] = city;
    data['state'] = state;
    data['postalCode'] = postalCode;
    data['country'] = country;
    return data;
  }

  String get formattedAddress {
    final parts = [street, city, state, postalCode, country]
        .where((part) => part != null && part.isNotEmpty)
        .toList();
    return parts.join(', ');
  }
}

class OrderTotal {
  double? subtotal;
  double? discount;
  double? total;

  OrderTotal({this.subtotal, this.discount, this.total});

  OrderTotal.fromJson(Map<String, dynamic> json) {
    subtotal = json['subtotal']?.toDouble();
    discount = json['discount']?.toDouble();
    total = json['total']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['subtotal'] = subtotal;
    data['discount'] = discount;
    data['total'] = total;
    return data;
  }
}

class UserID {
  String? sId;
  String? name;

  UserID({this.sId, this.name});

  UserID.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['name'] = name;
    return data;
  }
}

class Items {
  String? productID;
  String? productName;
  int? quantity;
  double? price;
  String? variant;
  String? sId;

  Items({
    this.productID,
    this.productName,
    this.quantity,
    this.price,
    this.variant,
    this.sId,
  });

  Items.fromJson(Map<String, dynamic> json) {
    productID = json['productID'];
    productName = json['productName'];
    quantity = json['quantity'];
    price = json['price']?.toDouble();
    variant = json['variant'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['productID'] = productID;
    data['productName'] = productName;
    data['quantity'] = quantity;
    data['price'] = price;
    data['variant'] = variant;
    data['_id'] = sId;
    return data;
  }
}

class PaymentProof {
  String? imageUrl;
  String? uploadedAt;
  bool? verified;
  String? verifiedAt;

  PaymentProof({
    this.imageUrl,
    this.uploadedAt,
    this.verified,
    this.verifiedAt,
  });

  PaymentProof.fromJson(Map<String, dynamic> json) {
    imageUrl = json['imageUrl'];
    uploadedAt = json['uploadedAt'];
    verified = json['verified'];
    verifiedAt = json['verifiedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['imageUrl'] = imageUrl;
    data['uploadedAt'] = uploadedAt;
    data['verified'] = verified;
    data['verifiedAt'] = verifiedAt;
    return data;
  }
}
