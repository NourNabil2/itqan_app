// lib/core/services/payment_service.dart
import 'dart:io';
import 'package:itqan_gym/data/models/payment/payment_request.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentService {
  final SupabaseClient _supabase = Supabase.instance.client;
  static const String paymentProofBucket = 'payment-proofs';

  /// Submit payment request (without proof image)
  /// Used when user contacts via email - proof will be sent externally
  Future<PaymentRequest> submitPaymentRequest({
    required String subscriptionType,
    required double amount,
    required String paymentMethod, // 'instapay' | 'vodafone_cash'
    String? transactionReference,
    String? note, // هيتم تخزينها في admin_notes (اختياري)
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception('User not logged in');

    final payload = {
      'user_id': userId,
      'subscription_type': subscriptionType,
      'amount': amount,
      'payment_method': paymentMethod,           // لازم تكون قيمة مسموح بها
      'payment_proof_url': '',                   // بدل null عشان NOT NULL
      if (transactionReference?.isNotEmpty == true)
        'transaction_reference': transactionReference,
      if (note?.isNotEmpty == true)
        'admin_notes': note,                     // العمود الموجود فعليًا
      'status': 'pending',
    };

    final row = await _supabase
        .from('payment_requests')
        .insert(payload)
        .select()
        .single();

    return PaymentRequest.fromJson(row);
  }

  /// Upload payment proof image
  Future<String> _uploadPaymentProof(File image, String fileName) async {
    try {
      final bytes = await image.readAsBytes();

      await _supabase.storage
          .from(paymentProofBucket)
          .uploadBinary(fileName, bytes);

      final url = _supabase.storage
          .from(paymentProofBucket)
          .getPublicUrl(fileName);

      return url;
    } catch (e) {
      throw Exception('Failed to upload payment proof: ${e.toString()}');
    }
  }

  /// Get user's payment requests
  Future<List<PaymentRequest>> getUserPaymentRequests() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      final response = await _supabase
          .from('payment_requests')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => PaymentRequest.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get payment requests: ${e.toString()}');
    }
  }

  /// Check if user has pending request
  Future<PaymentRequest?> getPendingRequest() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return null;

      final response = await _supabase
          .from('payment_requests')
          .select()
          .eq('user_id', userId)
          .eq('status', 'pending')
          .maybeSingle();

      if (response == null) return null;
      return PaymentRequest.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}