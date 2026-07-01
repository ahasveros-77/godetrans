import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../services/booking_service.dart';
import '../../provider/booking_provider.dart';
import 'pilih_armada_screen.dart';

class PilihJadwalScreen extends StatefulWidget {
  const PilihJadwalScreen({super.key});

  @override
  State<PilihJadwalScreen> createState() => _PilihJadwalScreenState();
}

class _PilihJadwalScreenState extends State<PilihJadwalScreen> {
  List<Map<String, dynamic>> _jadwalList = [];
  bool _isLoading = true;
  String? _error;
  String? _jamTerpilih;

  // Jadwal default ditampilkan bila server belum terhubung,
  // supaya alur UI tetap bisa dicoba end-to-end.
  static const List<String> _defaultJam = [
    '06:00', '08:00', '10:00', '12:00', '14:00', '16:00', '18:00', '20:00',
  ];

  @override
  void initState() {
    super.initState();
    _loadJadwal();
  }

  Future<void> _loadJadwal() async {
    final provider = context.read<BookingProvider>();
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final jadwal = await BookingService.getJadwal(
        asal: provider.asal,
        tujuan: provider.tujuan,
        tanggal: provider.tanggalBerangkat.toIso8601String().split('T').first,
      );
      setState(() => _jadwalList = jadwal);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _jadwalList = _defaultJam
            .map((jam) => {'jam': jam, 'kursi_tersedia': 4})
            .toList();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pilih Jadwal'),
      ),
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
                  '${Formatters.tanggalIndo(provider.tanggalBerangkat)} • ${provider.jumlahPenumpang} Penumpang',
                  style: AppTextStyles.bodySecondary,
                ),
              ],
            ),
          ),
          if (_error != null)
            Container(
              width: double.infinity,
              color: AppColors.warningLight,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Server belum terhubung, menampilkan jadwal contoh.',
                style: AppTextStyles.caption.copyWith(color: AppColors.warning),
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _jadwalList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = _jadwalList[index];
                      final jam = item['jam'].toString();
                      final kursi = item['kursi_tersedia']?.toString() ?? '-';
                      final selected = jam == _jamTerpilih;
                      return GestureDetector(
                        onTap: () => setState(() => _jamTerpilih = jam),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: selected ? 1.6 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(jam, style: AppTextStyles.h3),
                              Text('$kursi kursi tersedia',
                                  style: AppTextStyles.bodySecondary),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _jamTerpilih == null
                    ? null
                    : () {
                        provider.setJadwal(_jamTerpilih!);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const PilihArmadaScreen()),
                        );
                      },
                child: const Text('Lanjut'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
