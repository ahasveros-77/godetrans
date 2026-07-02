import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../theme/app_theme.dart';
import '../../utils/payment_qr_codec.dart';
import 'ewallet_pembayaran_screen.dart';

class ScanQrPembayaranScreen extends StatefulWidget {
  final PaymentQrPayload? expectedPayload;

  const ScanQrPembayaranScreen({super.key, this.expectedPayload});

  @override
  State<ScanQrPembayaranScreen> createState() => _ScanQrPembayaranScreenState();
}

class _ScanQrPembayaranScreenState extends State<ScanQrPembayaranScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _hasScanned = false;

  void _handleScan(String raw) {
    if (_hasScanned) return;

    final payload = PaymentQrPayload.decode(raw);
    if (payload == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR tidak valid. Gunakan QR pembayaran GodeTrans.')),
      );
      return;
    }

    if (widget.expectedPayload != null &&
        payload.amount != widget.expectedPayload!.amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal QR tidak sesuai dengan pesanan.')),
      );
      return;
    }

    setState(() => _hasScanned = true);
    _controller.stop();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => EwalletPembayaranScreen(payload: payload),
      ),
    );
  }

  void _simulasiScan() {
    final payload = widget.expectedPayload;
    if (payload == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data pembayaran tidak tersedia.')),
      );
      return;
    }
    _handleScan(payload.encode());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan QR Pembayaran'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: (capture) {
                    final barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      final raw = barcode.rawValue;
                      if (raw != null && raw.isNotEmpty) {
                        _handleScan(raw);
                        break;
                      }
                    }
                  },
                ),
                Center(
                  child: Container(
                    width: 240,
                    height: 240,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary, width: 3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 24,
                  child: Text(
                    'Arahkan kamera ke QR pembayaran GodeTrans',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            color: AppColors.background,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.expectedPayload != null) ...[
                  Text(
                    'Total: Rp ${widget.expectedPayload!.amount.toStringAsFixed(0)}',
                    style: AppTextStyles.h3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],
                OutlinedButton(
                  onPressed: _simulasiScan,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Simulasi Scan QR (Demo)',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
