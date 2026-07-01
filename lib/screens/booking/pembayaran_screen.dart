import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../models/booking_model.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../provider/booking_provider.dart';
import '../../widgets/primary_button.dart';
import 'pembayaran_berhasil_screen.dart';

class PembayaranScreen extends StatefulWidget {
  const PembayaranScreen({super.key});

  @override
  State<PembayaranScreen> createState() => _PembayaranScreenState();
}

class _PembayaranScreenState extends State<PembayaranScreen> {
  String _metodeTerpilih = 'Transfer Bank';
  bool _isProcessing = false;
  String? _error;

  final _metodeList = const [
    {'label': 'Transfer Bank', 'icon': Icons.account_balance_outlined},
    {'label': 'E-Wallet (OVO/GoPay/Dana)', 'icon': Icons.account_balance_wallet_outlined},
    {'label': 'Kartu Kredit/Debit', 'icon': Icons.credit_card_outlined},
  ];

  Future<void> _bayarSekarang() async {
    setState(() {
      _isProcessing = true;
      _error = null;
    });
    final provider = context.read<BookingProvider>();
    final user = await AuthService.getCurrentUser();

    final booking = BookingModel(
      id: Formatters.generateKodeBooking(),
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
      // Simulasi proses pembayaran (tanpa gateway nyata).
      await Future.delayed(const Duration(seconds: 1));
      final saved = await BookingService.createBooking(booking);
      provider.reset();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => PembayaranBerhasilScreen(kodeBooking: saved.id),
        ),
        (route) => route.isFirst,
      );
    } catch (e) {
      // Tetap tampilkan sukses secara lokal walau server belum terhubung,
      // supaya alur pemesanan tetap bisa dicoba end-to-end saat development.
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
      provider.reset();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => PembayaranBerhasilScreen(kodeBooking: booking.id),
        ),
        (route) => route.isFirst,
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
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
                      color: selected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            );
          }),
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
        child: PrimaryButton(
          label: 'Bayar Sekarang',
          isLoading: _isProcessing,
          onPressed: _bayarSekarang,
        ),
      ),
    );
  }
}
