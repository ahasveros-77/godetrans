import 'package:flutter_test/flutter_test.dart';
import 'package:godetrans/utils/payment_qr_codec.dart';
import 'package:godetrans/utils/payment_qr_handler.dart';

void main() {
  test('PaymentQrPayload encode/decode roundtrip', () {
    const payload = PaymentQrPayload(
      amount: 65000,
      merchant: 'GodeTrans',
      ref: 'GDT2506264362',
      description: 'Terminal Bekasi → Terminal Karawang',
    );

    final decoded = PaymentQrPayload.decode(payload.encode());
    expect(decoded, isNotNull);
    expect(decoded!.amount, 65000);
    expect(decoded.merchant, 'GodeTrans');
    expect(decoded.ref, 'GDT2506264362');
    expect(decoded.description, payload.description);
  });

  test('PaymentQrPayload rejects invalid QR', () {
    expect(PaymentQrPayload.decode('not-json'), isNull);
    expect(PaymentQrPayload.decode('{"type":"other"}'), isNull);
  });

  test('PaymentQrHandler validates amount against expected payload', () {
    const payload = PaymentQrPayload(
      amount: 65000,
      merchant: 'GodeTrans',
      ref: 'GDT123',
      description: 'Test',
    );
    const expected = PaymentQrPayload(
      amount: 65000,
      merchant: 'GodeTrans',
      ref: 'GDT123',
      description: 'Test',
    );

    expect(PaymentQrHandler.validate(payload.encode(), expected), isNull);
    expect(
      PaymentQrHandler.validate(
        payload.encode(),
        const PaymentQrPayload(
          amount: 70000,
          merchant: 'GodeTrans',
          ref: 'GDT123',
          description: 'Test',
        ),
      ),
      isNotNull,
    );
  });
}
