import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/sheets_api_service.dart';
import '../../widgets/primary_button.dart';

class ManageRoutesScreen extends StatefulWidget {
  const ManageRoutesScreen({Key? key}) : super(key: key);

  @override
  State<ManageRoutesScreen> createState() => _ManageRoutesScreenState();
}

class _ManageRoutesScreenState extends State<ManageRoutesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _asalController = TextEditingController();
  final _tujuanController = TextEditingController();
  final _jamController = TextEditingController();
  final _kursiController = TextEditingController(text: '4');
  final _hargaController = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      await SheetsApiService.post('addRute', {
        'asal': _asalController.text.trim(),
        'tujuan': _tujuanController.text.trim(),
        'jam_berangkat': _jamController.text.trim(),
        'kursi_tersedia': int.tryParse(_kursiController.text.trim()) ?? 0,
        'harga': double.tryParse(_hargaController.text.trim()) ?? 0,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Rute berhasil ditambahkan')));
      _formKey.currentState?.reset();
      _kursiController.text = '4';
      _hargaController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Gagal menambahkan rute: ${e.toString()}')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Rute Baru')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Text('Asal', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _asalController,
                  decoration: const InputDecoration(hintText: 'Contoh: Terminal Bekasi'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Asal wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                const Text('Tujuan', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _tujuanController,
                  decoration: const InputDecoration(hintText: 'Contoh: Terminal Karawang'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Tujuan wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                const Text('Jam Berangkat', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _jamController,
                  decoration: const InputDecoration(hintText: 'Contoh: 10:00'),
                  validator: (value) => (value == null || value.trim().isEmpty)
                      ? 'Jam wajib diisi'
                      : null,
                ),
                const SizedBox(height: 16),
                const Text('Kursi Tersedia', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _kursiController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Contoh: 4'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Kursi wajib diisi';
                    }
                    if (int.tryParse(value.trim()) == null) {
                      return 'Masukkan angka valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Harga', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _hargaController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Contoh: 75000'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Harga wajib diisi';
                    }
                    if (double.tryParse(value.trim()) == null) {
                      return 'Masukkan angka valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Simpan Rute',
                  isLoading: _loading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
