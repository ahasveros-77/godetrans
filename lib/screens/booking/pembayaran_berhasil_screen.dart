import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../tickets/tiket_saya_screen.dart';

class PembayaranBerhasilScreen extends StatelessWidget {
  final String kodeBooking;

  const PembayaranBerhasilScreen({super.key, required this.kodeBooking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 48),
              ),
              const SizedBox(height: 24),
              const Text('Pembayaran Berhasil!',
                  style: AppTextStyles.h1, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              const Text('Tiket kamu telah berhasil dibayar.',
                  style: AppTextStyles.bodySecondary,
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              const Text('Kode Booking', style: AppTextStyles.caption),
              const SizedBox(height: 4),
              Text(kodeBooking,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary)),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) =>
                              const TiketSayaScreen(embedded: false)),
                      (route) => false,
                    );
                  },
                  child: const Text('Lihat Tiket Saya'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Kembali ke Beranda',
                    style: TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
