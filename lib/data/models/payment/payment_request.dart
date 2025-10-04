// lib/data/models/payment_request.dart
class PaymentRequest {
  final String id;
  final String userId;
  final String subscriptionType;
  final double amount;
  final String paymentMethod;
  final String paymentProofUrl;
  final String? transactionReference;
  final String status; // pending, approved, rejected
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime? reviewedAt;

  PaymentRequest({
    required this.id,
    required this.userId,
    required this.subscriptionType,
    required this.amount,
    required this.paymentMethod,
    required this.paymentProofUrl,
    this.transactionReference,
    required this.status,
    this.adminNotes,
    required this.createdAt,
    this.reviewedAt,
  });

  factory PaymentRequest.fromJson(Map<String, dynamic> json) {
    return PaymentRequest(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      subscriptionType: json['subscription_type'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      paymentProofUrl: json['payment_proof_url'] as String,
      transactionReference: json['transaction_reference'] as String?,
      status: json['status'] as String,
      adminNotes: json['admin_notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'subscription_type': subscriptionType,
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_proof_url': paymentProofUrl,
      'transaction_reference': transactionReference,
      'status': status,
    };
  }
}