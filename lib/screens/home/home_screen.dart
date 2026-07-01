import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/rute_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../utils/formatters.dart';
import '../../provider/booking_provider.dart';
import '../../widgets/primary_button.dart';
import '../admin/list_routes_screen.dart';
import '../admin/list_schedules_screen.dart';
import '../admin/manage_bookings_screen.dart';
import '../admin/manage_routes_screen.dart';
import '../admin/manage_schedules_screen.dart';
import '../booking/pilih_jadwal_screen.dart';
import '../tickets/tiket_saya_screen.dart';
import '../account/akun_screen.dart';
import '../booking/riwayat_pesanan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  UserModel? _user;
  List<RuteModel> _rutePopuler = [];
  bool _isLoadingRute = true;
  String? _errorRute;

  bool get _isAdmin => _user?.role == 'admin';

  // Variabel untuk menyimpan daftar pilihan dropdown & item yang terpilih
  List<String> _listAsal = [];
  List<String> _listTujuan = [];
  String? _selectedAsal;
  String? _selectedTujuan;

  DateTime _tanggal = DateTime.now();
  int _jumlahPenumpang = 1;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadRutePopuler();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUser();
    setState(() => _user = user);
  }

  Future<void> _loadRutePopuler() async {
    setState(() {
      _isLoadingRute = true;
      _errorRute = null;
    });
    try {
      final rute = await BookingService.getRutePopuler();

      // Mengambil daftar nama kota asal & tujuan yang unik (tidak duplikat) dari database
      final unikAsal = rute.map((e) => e.asal).toSet().toList();
      final unikTujuan = rute.map((e) => e.tujuan).toSet().toList();

      setState(() {
        _rutePopuler = rute;
        _listAsal = unikAsal;
        _listTujuan = unikTujuan;

        // Set nilai default dropdown asal jika tersedia di database
        if (unikAsal.contains('Terminal Bekasi')) {
          _selectedAsal = 'Terminal Bekasi';
        } else if (unikAsal.isNotEmpty) {
          _selectedAsal = unikAsal.first;
        }

        // Set nilai default dropdown tujuan jika tersedia di database
        if (unikTujuan.contains('Terminal Karawang')) {
          _selectedTujuan = 'Terminal Karawang';
        } else if (unikTujuan.isNotEmpty) {
          _selectedTujuan = unikTujuan.first;
        }
      });
    } catch (e) {
      setState(() => _errorRute = e.toString().replaceAll('Exception: ', ''));
    } finally {
      setState(() => _isLoadingRute = false);
    }
  }

  void _onCariTiket({String? asalOverride, String? tujuanOverride}) {
    if (_isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Akun admin tidak dapat memesan tiket.'),
      ));
      return;
    }

    final provider = context.read<BookingProvider>();
    provider.setRute(
      asal: asalOverride ?? _selectedAsal ?? '',
      tujuan: tujuanOverride ?? _selectedTujuan ?? '',
    );
    provider.setTanggal(_tanggal);
    provider.setJumlahPenumpang(_jumlahPenumpang);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PilihJadwalScreen()),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  Future<void> _pickJumlahPenumpang() async {
    final result = await showModalBottomSheet<int>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        int temp = _jumlahPenumpang;
        return StatefulBuilder(builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Jumlah Penumpang', style: AppTextStyles.h3),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed:
                          temp > 1 ? () => setModalState(() => temp--) : null,
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text('$temp', style: AppTextStyles.h1),
                    ),
                    IconButton(
                      onPressed:
                          temp < 10 ? () => setModalState(() => temp++) : null,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: 'Simpan',
                  onPressed: () => Navigator.pop(context, temp),
                ),
              ],
            ),
          );
        });
      },
    );
    if (result != null) setState(() => _jumlahPenumpang = result);
  }

  @override
  Widget build(BuildContext context) {
    // 1. KONDISIKAN DAFTAR HALAMAN BERDASARKAN ROLE
    final pages = [
      _buildHomeContent(),
      if (!_isAdmin) ...[
        const RiwayatPesananScreen(embedded: true),
        const TiketSayaScreen(embedded: true),
      ],
      const AkunScreen(embedded: true),
    ];

    // Amankan indeks navigasi agar tidak melebihi panjang array halaman yang aktif
    final int safeIndex = _navIndex >= pages.length ? 0 : _navIndex;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 204, 193, 240),
      body: SafeArea(child: pages[safeIndex]),
      // 2. KONDISIKAN TOMBOL NAVIGASI BERDASARKAN ROLE
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: safeIndex,
        onTap: (i) => setState(() => _navIndex = i),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: const Color.fromARGB(255, 47, 35, 126),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          if (!_isAdmin) ...[
            const BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment_rounded),
              label: 'Pesanan',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.confirmation_num_outlined),
              activeIcon: Icon(Icons.confirmation_num_rounded),
              label: 'Tiket Saya',
            ),
          ],
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Akun',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: _loadRutePopuler,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Row(
            children: [
              const Icon(Icons.local_shipping_rounded,
                  color: AppColors.primary, size: 24),
              const SizedBox(width: 6),
              const Text('GobeTrans',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textPrimary)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.notifications_outlined, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Halo, ${_user?.nama.split(' ').first ?? 'Pengguna'} 👋',
              style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text(
            _isAdmin
                ? 'Selamat bertugas di panel manajemen!'
                : 'Mau ke mana hari ini?',
            style: AppTextStyles.bodySecondary,
          ),
          if (!_isAdmin) ...[
            const SizedBox(height: 16),
            _buildBannerDiskon(),
            const SizedBox(height: 16),
            _buildFormPencarian(),
          ] else ...[
            const SizedBox(height: 16),
            _buildAdminPanelIfNeeded(),
            const SizedBox(height: 16),
            _buildFormPencarian(), // Tetap menampilkan info penolakan form untuk admin
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Rute Populer', style: AppTextStyles.h3),
              GestureDetector(
                onTap: _loadRutePopuler,
                child: const Text('Lihat Semua',
                    style: TextStyle(
                        color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRutePopulerList(),
        ],
      ),
    );
  }

  Widget _buildBannerDiskon() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 86, 61, 148), AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('DISKON 20%',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Untuk semua rute',
                    style: TextStyle(color: Colors.white, fontSize: 13)),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => _onCariTiket(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size(0, 38),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Pesan Sekarang',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ],
            ),
          ),
          const Icon(Icons.airport_shuttle_rounded,
              color: Colors.white, size: 56),
        ],
      ),
    );
  }

  Widget _buildAdminPanelIfNeeded() {
    if (!_isAdmin) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.admin_panel_settings, color: AppColors.primary),
              const SizedBox(width: 10),
              const Text('Mode Admin', style: AppTextStyles.h3),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Akses cepat fitur admin langsung di halaman utama.',
            style: AppTextStyles.bodySecondary,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _buildAdminActionCard(
                icon: Icons.confirmation_num_outlined,
                label: 'Kelola Booking',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ManageBookingsScreen()),
                ),
              ),
              _buildAdminActionCard(
                icon: Icons.route,
                label: 'Daftar Rute',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ListRoutesScreen()),
                ),
              ),
              _buildAdminActionCard(
                icon: Icons.add_road,
                label: 'Tambah Rute',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageRoutesScreen()),
                ),
              ),
              _buildAdminActionCard(
                icon: Icons.schedule,
                label: 'Daftar Jadwal',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ListSchedulesScreen()),
                ),
              ),
              _buildAdminActionCard(
                icon: Icons.add_circle_outline,
                label: 'Tambah Jadwal',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ManageSchedulesScreen()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 26, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildFormPencarian() {
    if (_isAdmin) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Mode Admin Beranda', style: AppTextStyles.h3),
            SizedBox(height: 8),
            Text(
              'Akun admin tidak dapat memesan tiket. Gunakan Admin Dashboard untuk mengelola aplikasi.',
              style: AppTextStyles.bodySecondary,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildFieldRow(
            icon: Icons.trip_origin,
            label: 'Dari',
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedAsal,
                hint: const Text('Pilih Asal',
                    style: AppTextStyles.bodySecondary),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down,
                    color: AppColors.textSecondary),
                items: _listAsal.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: AppTextStyles.h3),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedAsal = newValue;
                  });
                },
              ),
            ),
          ),
          const Divider(height: 20),
          _buildFieldRow(
            icon: Icons.location_on_outlined,
            label: 'Ke',
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedTujuan,
                hint: const Text('Pilih Tujuan',
                    style: AppTextStyles.bodySecondary),
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down,
                    color: AppColors.textSecondary),
                items: _listTujuan.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: AppTextStyles.h3),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedTujuan = newValue;
                  });
                },
              ),
            ),
          ),
          const Divider(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _pickDate,
                  child: _buildFieldRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Tanggal Berangkat',
                    child: Text(Formatters.tanggalIndo(_tanggal),
                        style: AppTextStyles.h3),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _pickJumlahPenumpang,
                child: _buildFieldRow(
                  icon: Icons.people_outline,
                  label: 'Penumpang',
                  child: Text('$_jumlahPenumpang Penumpang',
                      style: AppTextStyles.h3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Cari Tiket',
            color: const Color.fromARGB(255, 65, 30, 161),
            onPressed: () => _onCariTiket(),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldRow({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
        const SizedBox(height: 4),
        child,
      ],
    );
  }

  Widget _buildRutePopulerList() {
    if (_isLoadingRute) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_errorRute != null) {
      return _buildErrorRute();
    }
    if (_rutePopuler.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text('Belum ada rute populer',
              style: AppTextStyles.bodySecondary),
        ),
      );
    }
    return Column(
      children: _rutePopuler.map((rute) => _buildRuteCard(rute)).toList(),
    );
  }

  Widget _buildErrorRute() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Belum terhubung ke server',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(_errorRute ?? '', style: AppTextStyles.caption),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _loadRutePopuler,
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildRuteCard(RuteModel rute) {
    return GestureDetector(
      onTap: _isAdmin
          ? () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Akun admin tidak dapat memesan tiket.'),
              ))
          : () => _onCariTiket(
              asalOverride: rute.asal, tujuanOverride: rute.tujuan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
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
              child: const Icon(Icons.directions_bus_rounded,
                  color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${rute.asal} → ${rute.tujuan}',
                      style: AppTextStyles.h3),
                  const SizedBox(height: 2),
                  Text(
                    '${rute.jamBerangkat}   ${rute.kursiTersedia} kursi tersedia',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            Text(Formatters.rupiah(rute.harga),
                style: const TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
