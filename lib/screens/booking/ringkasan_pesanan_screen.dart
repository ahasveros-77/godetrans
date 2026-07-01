import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../provider/booking_provider.dart';
import 'pembayaran_screen.dart';

class RingkasanPesananScreen extends StatelessWidget {
  const RingkasanPesananScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final armada = provider.armadaTerpilih;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Ringkasan Pesanan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('${provider.asal}   →   ${provider.tujuan}', style: AppTextStyles.h3),
          const SizedBox(height: 4),
          Text(
            '${Formatters.tanggalIndo(provider.tanggalBerangkat)} • ${provider.jamBerangkat ?? "-"}',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.airport_shuttle_rounded,
                      color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(armada?.nama ?? '-', style: AppTextStyles.h3),
                    Text('${armada?.jumlahKursi ?? 0} Kursi',
                        style: AppTextStyles.caption),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Detail Pesanan',
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          _detailRow('Kursi', provider.kursiTerpilih.join(', ')),
          _detailRow('Penumpang', '${provider.dataPenumpang.length} Dewasa'),
          _detailRow(
            'Harga Tiket',
            '${Formatters.rupiah(provider.hargaTiket)} x ${provider.kursiTerpilih.length}',
          ),
          _detailRow('Biaya Layanan', Formatters.rupiah(provider.biayaLayanan)),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Pembayaran', style: AppTextStyles.h3),
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
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentOrange),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PembayaranScreen()),
            );
          },
          child: const Text('Lanjut'),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySecondary),
          Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
