import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../utils/payment_qr_codec.dart';
import '../../models/booking_model.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../provider/booking_provider.dart';
import '../../widgets/primary_button.dart';
import 'pembayaran_berhasil_screen.dart';
import 'scan_qr_pembayaran_screen.dart';
import 'ewallet_pembayaran_screen.dart';

class PembayaranScreen extends StatefulWidget {
  const PembayaranScreen({super.key});

  @override
  State<PembayaranScreen> createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends State<PembayaranScreen> {
  static const _metodeEwallet = 'E-Wallet (OVO/GoPay/Dana)';

  String _metodeTerpilih = 'Transfer Bank';
  bool _isProcessing = false;
  String? _error;
  late String _kodeBooking;

  final _metodeList = const [
    {'label': 'Transfer Bank', 'icon': Icons.account_balance_outlined},
    {'label': _metodeEwallet, 'icon': Icons.account_balance_wallet_outlined},
    {'label': 'Kartu Kredit/Debit', 'icon': Icons.credit_card_outlined},
  ];

  @override
  void initState() {
    super.initState();
    _kodeBooking = Formatters.generateKodeBooking();
  }

  bool get _isEwallet => _metodeTerpilih == _metodeEwallet;

  PaymentQrPayload _buildQrPayload(BookingProvider provider) {
    return PaymentQrPayload(
      amount: provider.totalBayar,
      merchant: 'GodeTrans',
      ref: _kodeBooking,
      description: '${provider.asal} → ${provider.tujuan}',
    );
  }

  Future<void> _bayarSekarang() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });
    final provider = context.read<BookingProvider>();
    final user = await AuthService.getCurrentUser();

    final booking = BookingModel(
      id: _kodeBooking,
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
      totalBayar: provider.totalBayar,
      status: 'Akan Berangkat',
      createdAt: DateTime.now().toIso8601String(),
    );

    try {
      await Future.delayed(const Duration(seconds: 1));
      final saved = await BookingService.createBooking(booking);
      provider.reset();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => PembayaranBerhasilScreen(
            kodeBooking: saved.id,
            metodePembayaran: _metodeTerpilih,
          ),
        ),
        (route) => route.isFirst,
      );
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
      provider.reset();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => PembayaranBerhasilScreen(
            kodeBooking: booking.id,
            metodePembayaran: _metodeTerpilih,
          ),
        ),
        (route) => route.isFirst,
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  void _bukaScannerQr() {
    final provider = context.read<BookingProvider>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScanQrPembayaranScreen(
          expectedPayload: _buildQrPayload(provider),
        ),
      ),
    );
  }

  void _lanjutKeEwallet() {
    final provider = context.read<BookingProvider>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EwalletPembayaranScreen(
          payload: _buildQrPayload(provider),
        ),
      ),
    );
  }

  Widget _buildQrSection(BookingProvider provider) {
    final payload = _buildQrPayload(provider);
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 1.2),
      ),
      child: Column(
        children: [
          const Text('QR Pembayaran', style: AppTextStyles.h3),
          const SizedBox(height: 4),
          const Text(
            'Scan QR ini dengan e-wallet untuk melihat nominal dan menyelesaikan pembayaran.',
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
          if (kIsWeb) ...[
            const SizedBox(height: 8),
            Text(
              'Web Preview: QR dapat discan via kamera browser atau lanjutkan langsung ke e-wallet.',
              style: AppTextStyles.caption.copyWith(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: QrImageView(
              data: payload.encode(),
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.textPrimary,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            Formatters.rupiah(provider.totalBayar),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text('Ref: $_kodeBooking', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pembayaran')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Pembayaran', style: AppTextStyles.body),
                Text(
                  Formatters.rupiah(provider.totalBayar),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Pilih Metode Pembayaran', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          ..._metodeList.map((metode) {
            final label = metode['label'] as String;
            final icon = metode['icon'] as IconData;
            final selected = _metodeTerpilih == label;
            return GestureDetector(
              onTap: () => setState(() => _metodeTerpilih = label),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: selected ? 1.6 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(icon, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(child: Text(label, style: AppTextStyles.body)),
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            );
          }),
          if (_isEwallet) _buildQrSection(provider),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              'Catatan: data belum tersimpan ke server ($_error). Tiket tetap dibuat secara lokal untuk simulasi.',
              style: AppTextStyles.caption.copyWith(color: AppColors.warning),
            ),
          ],
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: _isEwallet
            ? (kIsWeb
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PrimaryButton(
                        label: 'Scan QR & Bayar',
                        isLoading: _isProcessing,
                        onPressed: _bukaScannerQr,
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: _isProcessing ? null : _lanjutKeEwallet,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Bayar Langsung via E-Wallet (Web)',
                          style: TextStyle(color: AppColors.primary),
                        ),
                      ),
                    ],
                  )
                : PrimaryButton(
                    label: 'Scan QR & Bayar',
                    isLoading: _isProcessing,
                    onPressed: _bukaScannerQr,
                  ))
            : PrimaryButton(
                label: 'Bayar Sekarang',
                isLoading: _isProcessing,
                onPressed: _bayarSekarang,
              ),
      ),
    );
  }
}
