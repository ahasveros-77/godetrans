import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/booking_service.dart';
import '../../provider/booking_provider.dart';
import 'data_penumpang_screen.dart';

class PilihKursiScreen extends StatefulWidget {
  const PilihKursiScreen({super.key});

  @override
  State<PilihKursiScreen> createState() => _PilihKursiScreenState();
}

class _PilihKursiScreenState extends State<PilihKursiScreen> {
  List<String> _kursiTerisi = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadKursi();
  }

  Future<void> _loadKursi() async {
    final provider = context.read<BookingProvider>();
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final kursi = await BookingService.getKursi(
        armadaId: provider.armadaTerpilih?.id ?? '',
        tanggal: provider.tanggalBerangkat.toIso8601String().split('T').first,
        jam: provider.jamBerangkat ?? '',
      );
      setState(() {
        _kursiTerisi = kursi
            .where((k) => k['status'] == 'Terisi')
            .map((k) => k['no_kursi'].toString())
            .toList();
      });
    } catch (e) {
      // Bila server belum terhubung, anggap semua kursi tersedia
      // agar alur tetap bisa dicoba.
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  List<String> _generateNomorKursi(int jumlahKursi) {
    return List.generate(jumlahKursi, (i) {
      final n = i + 1;
      return n < 10 ? '0$n' : '$n';
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final armada = provider.armadaTerpilih;
    final nomorKursi = _generateNomorKursi(armada?.jumlahKursi ?? 12);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Pilih Kursi')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${provider.asal}   →   ${provider.tujuan}',
                    style: AppTextStyles.h3),
                const SizedBox(height: 4),
                Text(
                  '${provider.jamBerangkat ?? "-"} • ${armada?.nama ?? "-"} • Pilih ${provider.jumlahPenumpang} kursi',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legend(AppColors.successLight, AppColors.success, 'Tersedia'),
              const SizedBox(width: 20),
              _legend(AppColors.primaryLight, AppColors.primary, 'Terpilih'),
              const SizedBox(width: 20),
              _legend(AppColors.border, AppColors.textSecondary, 'Terisi'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: GridView.builder(
                      itemCount: nomorKursi.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      itemBuilder: (context, index) {
                        final noKursi = nomorKursi[index];
                        final terisi = _kursiTerisi.contains(noKursi);
                        final terpilih = provider.kursiTerpilih.contains(noKursi);
                        return GestureDetector(
                          onTap: terisi
                              ? null
                              : () => provider.toggleKursi(noKursi),
                          child: Container(
                            decoration: BoxDecoration(
                              color: terisi
                                  ? AppColors.border
                                  : terpilih
                                      ? AppColors.primary
                                      : AppColors.successLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: terpilih
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                noKursi,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: terpilih
                                      ? Colors.white
                                      : terisi
                                          ? AppColors.textSecondary
                                          : AppColors.success,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Mode contoh: server belum terhubung',
                style: AppTextStyles.caption.copyWith(color: AppColors.warning),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    provider.kursiTerpilih.isEmpty
                        ? 'Kursi Terpilih\n-'
                        : 'Kursi Terpilih\n${provider.kursiTerpilih.join(", ")}',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: provider.kursiTerpilih.length ==
                            provider.jumlahPenumpang
                        ? () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const DataPenumpangScreen()),
                            );
                          }
                        : null,
                    child: const Text('Lanjut'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(Color bg, Color border, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}
