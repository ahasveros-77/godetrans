import 'payment_qr_codec.dart';

class PaymentQrHandler {
  /// Mengembalikan pesan error, atau `null` jika QR valid.
  static String? validate(String raw, PaymentQrPayload? expected) {
    final payload = PaymentQrPayload.decode(raw);
    if (payload == null) {
      return 'QR tidak valid. Gunakan QR pembayaran GodeTrans.';
    }

    if (expected != null && payload.amount != expected.amount) {
      return 'Nominal QR tidak sesuai dengan pesanan.';
    }

    return null;
  }

  static PaymentQrPayload? parse(String raw) => PaymentQrPayload.decode(raw);
}
