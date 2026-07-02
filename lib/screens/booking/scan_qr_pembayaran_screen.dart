import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../theme/app_theme.dart';
import '../../utils/payment_qr_codec.dart';
import '../../utils/payment_qr_handler.dart';
import '../../widgets/web_qr_scan_panel.dart';
import 'ewallet_pembayaran_screen.dart';

class ScanQrPembayaranScreen extends StatefulWidget {
  final PaymentQrPayload? expectedPayload;

  const ScanQrPembayaranScreen({super.key, this.expectedPayload});

  @override
  State<ScanQrPembayaranScreen> createState() => _ScanQrPembayaranScreenState();
}

class _ScanQrPembayaranScreenState extends State<ScanQrPembayaranScreen> {
  MobileScannerController? _controller;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _controller = MobileScannerController(formats: const [BarcodeFormat.qrCode]);
    }
  }

  void _handleScan(String raw) {
    if (_hasScanned) return;

    final error = PaymentQrHandler.validate(raw, widget.expectedPayload);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    final payload = PaymentQrHandler.parse(raw);
    if (payload == null) return;

    setState(() => _hasScanned = true);
    _controller?.stop();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => EwalletPembayaranScreen(payload: payload),
      ),
    );
  }

  void _continueWithoutScan() {
    final payload = widget.expectedPayload;
    if (payload == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data pembayaran tidak tersedia.')),
      );
      return;
    }
    _handleScan(payload.encode());
  }

  void _simulasiScan() => _continueWithoutScan();

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Scan QR Pembayaran (Web)')),
        body: WebQrScanPanel(
          expectedPayload: widget.expectedPayload,
          onScan: _handleScan,
          onContinueWithoutScan: _continueWithoutScan,
        ),
      );
    }

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
                    for (final barcode in capture.barcodes) {
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
