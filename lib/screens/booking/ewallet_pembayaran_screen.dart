import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../utils/payment_qr_codec.dart';
import '../../models/booking_model.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../provider/booking_provider.dart';
import 'pembayaran_berhasil_screen.dart';

class EwalletPembayaranScreen extends StatefulWidget {
  final PaymentQrPayload payload;

  const EwalletPembayaranScreen({super.key, required this.payload});

  @override
  State<EwalletPembayaranScreen> createState() =>
      _EwalletPembayaranScreenState();
}

class _EwalletPembayaranScreenState extends State<EwalletPembayaranScreen> {
  bool _isProcessing = false;
  String? _ewalletTerpilih;

  final _ewalletList = const [
    {'id': 'ovo', 'label': 'OVO', 'color': Color(0xFF4C3494)},
    {'id': 'gopay', 'label': 'GoPay', 'color': Color(0xFF00AA5B)},
    {'id': 'dana', 'label': 'DANA', 'color': Color(0xFF108EE9)},
  ];

  Future<void> _bayarViaEwallet(String ewalletLabel) async {
    setState(() {
      _isProcessing = true;
      _ewalletTerpilih = ewalletLabel;
    });

    final provider = context.read<BookingProvider>();
    final user = await AuthService.getCurrentUser();

    final booking = BookingModel(
      id: widget.payload.ref,
      userId: user?.id ?? '',
      asal: provider.asal,
      tujuan: provider.tujuan,
      tanggalBerangkat: Formatters.tanggalIndo(provider.tanggalBerangkat),
      jamBerangkat: provider.jamBerangkat ?? '',
      armadaId: provider.armadaTerpilih?.id ?? '',
      armadaNama: provider.armadaTerpilih?.nama ?? '',
      penumpang: provider.dataPenumpang,
      kursi: provider.kursiTerpilih,
      hargaTiket: provider.hargaTiket,
      biayaLayanan: provider.biayaLayanan,
      totalBayar: widget.payload.amount,
      status: 'Akan Berangkat',
      createdAt: DateTime.now().toIso8601String(),
    );

    try {
      
      await Future.delayed(const Duration(seconds: 2));
      final saved = await BookingService.createBooking(booking);
      provider.reset();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => PembayaranBerhasilScreen(
            kodeBooking: saved.id,
            metodePembayaran: ewalletLabel,
          ),
        ),
        (route) => route.isFirst,
      );
    } catch (e) {
      provider.reset();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => PembayaranBerhasilScreen(
            kodeBooking: booking.id,
            metodePembayaran: ewalletLabel,
          ),
        ),
        (route) => route.isFirst,
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Konfirmasi Pembayaran')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Icon(Icons.qr_code_scanner_rounded,
                    size: 48, color: AppColors.primary),
                const SizedBox(height: 12),
                const Text('QR Berhasil Discan',
                    style: AppTextStyles.h2, textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(widget.payload.merchant,
                    style: AppTextStyles.bodySecondary),
                const SizedBox(height: 16),
                Text(
                  Formatters.rupiah(widget.payload.amount),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(widget.payload.description,
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text('Ref: ${widget.payload.ref}',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Pilih E-Wallet', style: AppTextStyles.h3),
          const SizedBox(height: 4),
          const Text(
            'Kamu akan diarahkan ke aplikasi e-wallet untuk menyelesaikan pembayaran (simulasi).',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 16),
          ..._ewalletList.map((ew) {
            final label = ew['label'] as String;
            final color = ew['color'] as Color;
            final selected = _ewalletTerpilih == label && _isProcessing;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _isProcessing
                      ? null
                      : () => _bayarViaEwallet(label),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              label.substring(0, 1),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: color,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bayar dengan $label',
                                  style: AppTextStyles.h3),
                              Text('Simulasi redirect ke $label',
                                  style: AppTextStyles.caption),
                            ],
                          ),
                        ),
                        if (selected)
                          const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.4),
                          )
                        else
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 16, color: color),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
