import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/payment_qr_codec.dart';

/// Panel scan QR yang ramah web: kamera browser, tempel data, atau lanjut tanpa scan.
class WebQrScanPanel extends StatefulWidget {
  final PaymentQrPayload? expectedPayload;
  final ValueChanged<String> onScan;
  final VoidCallback onContinueWithoutScan;

  const WebQrScanPanel({
    super.key,
    required this.expectedPayload,
    required this.onScan,
    required this.onContinueWithoutScan,
  });

  @override
  State<WebQrScanPanel> createState() => _WebQrScanPanelState();
}

class _WebQrScanPanelState extends State<WebQrScanPanel> {
  final TextEditingController _pasteController = TextEditingController();
  final MobileScannerController _controller = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );

  bool _cameraAvailable = kIsWeb;

  @override
  void initState() {
    super.initState();
    if (widget.expectedPayload != null) {
      _pasteController.text = widget.expectedPayload!.encode();
    }
  }

  @override
  void dispose() {
    _pasteController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _processPastedQr() {
    final raw = _pasteController.text.trim();
    if (raw.isEmpty) {
      _showMessage('Tempel data QR terlebih dahulu.');
      return;
    }
    widget.onScan(raw);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expected = widget.expectedPayload;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.language_rounded, color: AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Mode Web Preview: gunakan kamera browser, tempel data QR, '
                  'atau lanjutkan langsung ke e-wallet.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (expected != null) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Text('Total Pembayaran', style: AppTextStyles.caption),
                const SizedBox(height: 4),
                Text(
                  Formatters.rupiah(expected.amount),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(expected.description, style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        const Text('Scan via Kamera Browser', style: AppTextStyles.h3),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 260,
            child: _cameraAvailable
                ? MobileScanner(
                    controller: _controller,
                    onDetect: (capture) {
                      for (final barcode in capture.barcodes) {
                        final raw = barcode.rawValue;
                        if (raw != null && raw.isNotEmpty) {
                          _controller.stop();
                          widget.onScan(raw);
                          break;
                        }
                      }
                    },
                    errorBuilder: (context, error, child) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) setState(() => _cameraAvailable = false);
                      });
                      return _cameraFallback(error.errorCode.name);
                    },
                  )
                : _cameraFallback('Kamera tidak tersedia'),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Atau Tempel Data QR', style: AppTextStyles.h3),
        const SizedBox(height: 8),
        TextField(
          controller: _pasteController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Tempel JSON QR pembayaran GodeTrans di sini...',
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: _processPastedQr,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            side: const BorderSide(color: AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text(
            'Proses Data QR',
            style: TextStyle(color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: widget.onContinueWithoutScan,
          child: const Text('Lanjutkan ke E-Wallet'),
        ),
      ],
    );
  }

  Widget _cameraFallback(String reason) {
    return Container(
      color: AppColors.textPrimary,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam_off_outlined, color: Colors.white70, size: 40),
          const SizedBox(height: 12),
          Text(
            'Kamera browser tidak aktif ($reason).',
            style: AppTextStyles.caption.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Izinkan akses kamera di browser, atau gunakan tempel data QR di bawah.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
