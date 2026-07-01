import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/booking_model.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';

class TiketSayaScreen extends StatefulWidget {
  final bool embedded;
  const TiketSayaScreen({super.key, this.embedded = false});

  @override
  State<TiketSayaScreen> createState() => _TiketSayaScreenState();
}

class _TiketSayaScreenState extends State<TiketSayaScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<BookingModel> _tiketList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTiket();
  }

  Future<void> _loadTiket() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final user = await AuthService.getCurrentUser();
      final list = await BookingService.getTiketSaya(user?.id ?? '');
      setState(() => _tiketList = list);
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final akanDatang = _tiketList
        .where((t) => t.status == 'Akan Berangkat')
        .toList();
    final selesai = _tiketList.where((t) => t.status == 'Selesai').toList();

    final body = Column(
      children: [
        if (!widget.embedded)
          const SizedBox.shrink()
        else
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Tiket Saya', style: AppTextStyles.h2),
            ),
          ),
        TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Akan Datang'),
            Tab(text: 'Selesai'),
          ],
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTiketList(akanDatang, isAkanDatang: true),
                    _buildTiketList(selesai, isAkanDatang: false),
                  ],
                ),
        ),
      ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tiket Saya')),
      body: SafeArea(child: body),
    );
  }

  Widget _buildTiketList(List<BookingModel> list, {required bool isAkanDatang}) {
    if (_error != null && _tiketList.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 40, color: AppColors.textSecondary),
              const SizedBox(height: 12),
              Text('Belum terhubung ke server',
                  style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              TextButton(onPressed: _loadTiket, child: const Text('Coba Lagi')),
            ],
          ),
        ),
      );
    }
    if (list.isEmpty) {
      return Center(
        child: Text(
          isAkanDatang ? 'Belum ada tiket akan datang' : 'Belum ada tiket selesai',
          style: AppTextStyles.bodySecondary,
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadTiket,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildTiketCard(list[index]),
      ),
    );
  }

  Widget _buildTiketCard(BookingModel tiket) {
    final statusColor =
        tiket.status == 'Selesai' ? AppColors.textSecondary : AppColors.success;
    final statusBg =
        tiket.status == 'Selesai' ? AppColors.border : AppColors.successLight;
    final canCancel = tiket.status != 'Selesai' && tiket.status != 'Dibatalkan';

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
          Text(tiket.id, style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text('${tiket.tanggalBerangkat} • ${tiket.jamBerangkat}',
              style: AppTextStyles.bodySecondary),
          const SizedBox(height: 8),
          Text('${tiket.asal}   →   ${tiket.tujuan}', style: AppTextStyles.h3),
          const SizedBox(height: 6),
          Text(
            '${tiket.armadaNama} • Kursi ${tiket.kursi.join(", ")}',
            style: AppTextStyles.caption,
          ),
          Text(
            tiket.penumpang.map((p) => p.namaLengkap).join(', '),
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tiket.status,
                  style: TextStyle(
                      color: statusColor, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              if (canCancel)
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Batalkan Tiket?'),
                        content: const Text('Apakah Anda yakin ingin membatalkan tiket ini?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Tidak'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              try {
                                await BookingService.cancelBooking(tiket.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Tiket dibatalkan')));
                                _loadTiket();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Gagal batalkan tiket: $e')));
                              }
                            },
                            child: const Text('Batalkan',
                                style: TextStyle(color: AppColors.danger)),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Batalkan', style: TextStyle(color: AppColors.danger, fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
