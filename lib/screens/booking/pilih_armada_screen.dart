import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/armada_model.dart';
import '../../utils/formatters.dart';
import '../../services/booking_service.dart';
import '../../provider/booking_provider.dart';
import 'pilih_kursi_screen.dart';

class PilihArmadaScreen extends StatefulWidget {
  const PilihArmadaScreen({super.key});

  @override
  State<PilihArmadaScreen> createState() => _PilihArmadaScreenState();
}

class _PilihArmadaScreenState extends State<PilihArmadaScreen> {
  List<ArmadaModel> _armadaList = [];
  bool _isLoading = true;
  String? _error;
  ArmadaModel? _terpilih;

  static final List<ArmadaModel> _defaultArmada = [
    ArmadaModel(id: 'A', nama: 'Hiace A', jumlahKursi: 4, harga: 60000, status: 'Tersedia'),
    ArmadaModel(id: 'B', nama: 'Hiace B', jumlahKursi: 6, harga: 75000, status: 'Tersedia'),
    ArmadaModel(id: 'C', nama: 'Hiace C', jumlahKursi: 12, harga: 85000, status: 'Tersedia'),
    ArmadaModel(id: 'D', nama: 'Hiace D', jumlahKursi: 16, harga: 95000, status: 'Tersedia'),
  ];

  @override
  void initState() {
    super.initState();
    _loadArmada();
  }

  Future<void> _loadArmada() async {
    final provider = context.read<BookingProvider>();
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final armada = await BookingService.getArmada(
        asal: provider.asal,
        tujuan: provider.tujuan,
        jam: provider.jamBerangkat ?? '',
      );
      setState(() => _armadaList = armada);
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _armadaList = _defaultArmada;
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
      appBar: AppBar(title: const Text('Pilih Armada')),
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
                  '${Formatters.tanggalIndo(provider.tanggalBerangkat)} • ${provider.jamBerangkat ?? "-"}',
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
                'Server belum terhubung, menampilkan armada contoh.',
                style: AppTextStyles.caption.copyWith(color: AppColors.warning),
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _armadaList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final armada = _armadaList[index];
                      final selected = _terpilih?.id == armada.id;
                      return GestureDetector(
                        onTap: armada.status == 'Tersedia'
                            ? () => setState(() => _terpilih = armada)
                            : null,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: selected ? 1.6 : 1,
                            ),
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
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(armada.nama, style: AppTextStyles.h3),
                                    const SizedBox(height: 2),
                                    Text('${armada.jumlahKursi} Kursi',
                                        style: AppTextStyles.caption),
                                    Text(
                                      armada.status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: armada.status == 'Tersedia'
                                            ? AppColors.success
                                            : AppColors.danger,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(Formatters.rupiah(armada.harga),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary)),
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
                onPressed: _terpilih == null
                    ? null
                    : () {
                        provider.setArmada(_terpilih!);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const PilihKursiScreen()),
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
