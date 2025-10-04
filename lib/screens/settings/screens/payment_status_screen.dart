// lib/screens/payment/payment_status_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/services/payment_service.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/data/models/payment/payment_request.dart';

class PaymentStatusScreen extends StatefulWidget {
  const PaymentStatusScreen({super.key});

  @override
  State<PaymentStatusScreen> createState() => _PaymentStatusScreenState();
}

class _PaymentStatusScreenState extends State<PaymentStatusScreen> {
  final PaymentService _paymentService = PaymentService();
  late Future<List<PaymentRequest>> _requestsFuture;

  @override
  void initState() {
    super.initState();
    _requestsFuture = _paymentService.getUserPaymentRequests();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(l10n.paymentStatus),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FutureBuilder<List<PaymentRequest>>(
        future: _requestsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 80.sp,
                    color: theme.iconTheme.color?.withOpacity(0.3),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    l10n.noPaymentRequests,
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(SizeApp.s16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              return _buildRequestCard(requests[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildRequestCard(PaymentRequest request) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (request.status) {
      case 'pending':
        statusColor = ColorsManager.warningFill;
        statusIcon = Icons.pending;
        statusText = l10n.pending;
        break;
      case 'approved':
        statusColor = ColorsManager.successFill;
        statusIcon = Icons.check_circle;
        statusText = l10n.approved;
        break;
      case 'rejected':
        statusColor = ColorsManager.errorFill;
        statusIcon = Icons.cancel;
        statusText = l10n.rejected;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
        statusText = request.status;
    }

    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s16),
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(SizeApp.radiusMed),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  statusIcon,
                  color: statusColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.subscriptionType == 'monthly'
                          ? l10n.monthlyPlan
                          : l10n.lifetimePlan,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${request.amount.toStringAsFixed(2)} ${l10n.egp}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Divider(),
          SizedBox(height: 12.h),
          _buildInfoRow(
            l10n.paymentMethod,
            request.paymentMethod == 'vodafone_cash'
                ? l10n.vodafoneCash
                : l10n.instaPay,
          ),
          if (request.transactionReference != null)
            _buildInfoRow(
              l10n.transactionReference,
              request.transactionReference!,
            ),
          _buildInfoRow(
            l10n.submittedAt,
            _formatDate(request.createdAt),
          ),
          if (request.reviewedAt != null)
            _buildInfoRow(
              l10n.reviewedAt,
              _formatDate(request.reviewedAt!),
            ),
          if (request.adminNotes != null) ...[
            SizedBox(height: 12.h),
            _AdminNoteCard(
              title: l10n.adminNotes,
              note: request.adminNotes!,
              accentColor: statusColor, // نفس لون حالة الطلب
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _AdminNoteCard extends StatelessWidget {
  final String title;
  final String note;
  final Color accentColor;

  const _AdminNoteCard({
    required this.title,
    required this.note,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = 12.r;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          children: [
            // الخلفية + حدود ملوّنة موحّدة (لازم تكون موحّدة مع borderRadius)
            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                border: Border.all(
                  color: accentColor.withOpacity(0.15),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // هيدر بسيط: أيقونة + عنوان (بدون أزرار)
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: accentColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.sticky_note_2_outlined,
                            size: 18.sp,
                            color: accentColor,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    // نص الملاحظة كامل بدون أسهم أو Copy
                    _NoteText(
                      note,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),

            // الشريط الملوّن على اليسار (مش جزء من الـBorder)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(width: 4.w, color: accentColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _NoteText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;

  const _NoteText(this.text, {this.style, this.maxLines});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.visible,
      textAlign: TextAlign.start,
    );
  }
}

