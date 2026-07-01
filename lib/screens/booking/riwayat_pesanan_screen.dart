import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/booking_model.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';

class RiwayatPesananScreen extends StatefulWidget {
  final bool embedded;
  const RiwayatPesananScreen({super.key, this.embedded = false});

  @override
  State<RiwayatPesananScreen> createState() => _RiwayatPesananScreenState();
}

class _RiwayatPesananScreenState extends State<RiwayatPesananScreen> {
  List<BookingModel> _list = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = await AuthService.getCurrentUser();
      final list = await BookingService.getTiketSaya(user?.id ?? '');
      setState(() => _list = list);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = RefreshIndicator(
      onRefresh: _load,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null && _list.isEmpty
              ? ListView(
                  children: [
                    const SizedBox(height: 80),
                    const Icon(Icons.cloud_off_rounded,
                        size: 40, color: AppColors.textSecondary),
                    const SizedBox(height: 12),
                    Center(
                      child: Text('Belum terhubung ke server',
                          style: AppTextStyles.bodySecondary),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: TextButton(
                          onPressed: _load, child: const Text('Coba Lagi')),
                    ),
                  ],
                )
              : _list.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 100),
                        Center(
                          child: Text('Belum ada riwayat pesanan',
                              style: AppTextStyles.bodySecondary),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: _list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _list[index];
                        final selesai = item.status == 'Selesai';
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${item.asal} → ${item.tujuan}',
                                  style: AppTextStyles.h3),
                              const SizedBox(height: 4),
                              Text(
                                '${item.tanggalBerangkat} • ${item.jamBerangkat}',
                                style: AppTextStyles.bodySecondary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.armadaNama} • Kursi ${item.kursi.join(", ")}',
                                style: AppTextStyles.caption,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: selesai
                                      ? AppColors.border
                                      : AppColors.successLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item.status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: selesai
                                        ? AppColors.textSecondary
                                        : AppColors.success,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
    );

    if (widget.embedded) {
      return Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Riwayat Pesanan', style: AppTextStyles.h2),
            ),
          ),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Riwayat Pesanan')),
      body: SafeArea(child: body),
    );
  }
}
