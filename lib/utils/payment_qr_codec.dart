import 'dart:convert';


class PaymentQrPayload {
  static const typeKey = 'godetrans_payment';

  final double amount;
  final String merchant;
  final String ref;
  final String description;

  const PaymentQrPayload({
    required this.amount,
    required this.merchant,
    required this.ref,
    required this.description,
  });

  String encode() => jsonEncode({
        'type': typeKey,
        'amount': amount,
        'merchant': merchant,
        'ref': ref,
        'description': description,
      });

  static PaymentQrPayload? decode(String raw) {
    try {
      final map = jsonDecode(raw.trim());
      if (map is! Map) return null;
      if (map['type']?.toString() != typeKey) return null;

      final amount = double.tryParse(map['amount']?.toString() ?? '');
      if (amount == null) return null;

      return PaymentQrPayload(
        amount: amount,
        merchant: map['merchant']?.toString() ?? 'GodeTrans',
        ref: map['ref']?.toString() ?? '',
        description: map['description']?.toString() ?? '',
      );
    } catch (_) {
      return null;
    }
  }
}
