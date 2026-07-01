import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/penumpang_model.dart';
import '../../provider/booking_provider.dart';
import 'ringkasan_pesanan_screen.dart';

class DataPenumpangScreen extends StatefulWidget {
  const DataPenumpangScreen({super.key});

  @override
  State<DataPenumpangScreen> createState() => _DataPenumpangScreenState();
}

class _DataPenumpangScreenState extends State<DataPenumpangScreen> {
  final _formKey = GlobalKey<FormState>();

  late List<TextEditingController> _namaControllers;
  late List<TextEditingController> _hpControllers;
  late List<String> _jenisKelamin;

  @override
  void initState() {
    super.initState();

    final provider = context.read<BookingProvider>();
    final jumlah = provider.jumlahPenumpang;

    _namaControllers =
        List.generate(jumlah, (_) => TextEditingController());

    _hpControllers =
        List.generate(jumlah, (_) => TextEditingController());

    _jenisKelamin =
        List.generate(jumlah, (_) => 'Laki-laki');
  }

  @override
  void dispose() {
    for (final controller in _namaControllers) {
      controller.dispose();
    }

    for (final controller in _hpControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final provider = context.read<BookingProvider>();

    final penumpang = List.generate(
      provider.jumlahPenumpang,
      (index) => PenumpangModel(
        namaLengkap: _namaControllers[index].text.trim(),
        noHp: _hpControllers[index].text.trim(),
        jenisKelamin: _jenisKelamin[index],
        noKursi: provider.kursiTerpilih.length > index
            ? provider.kursiTerpilih[index]
            : '',
      ),
    );

    provider.setDataPenumpang(penumpang);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const RingkasanPesananScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Data Penumpang'),
      ),
      body: Form(
        key: _formKey,
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: provider.jumlahPenumpang,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Penumpang ${index + 1}',
                      style: AppTextStyles.h3,
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      'Nama Lengkap',
                      style: AppTextStyles.bodySecondary,
                    ),

                    const SizedBox(height: 6),

                    TextFormField(
                      controller: _namaControllers[index],
                      decoration: const InputDecoration(
                        hintText: 'Masukkan nama lengkap',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama wajib diisi';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Nomor HP',
                      style: AppTextStyles.bodySecondary,
                    ),

                    const SizedBox(height: 6),

                    TextFormField(
                      controller: _hpControllers[index],
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan nomor HP',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nomor HP wajib diisi';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Jenis Kelamin',
                      style: AppTextStyles.bodySecondary,
                    ),

                    const SizedBox(height: 6),

                    DropdownButtonFormField<String>(
                      initialValue: _jenisKelamin[index],
                      decoration: const InputDecoration(),
                      items: const [
                        DropdownMenuItem(
                          value: 'Laki-laki',
                          child: Text('Laki-laki'),
                        ),
                        DropdownMenuItem(
                          value: 'Perempuan',
                          child: Text('Perempuan'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _jenisKelamin[index] =
                              value ?? 'Laki-laki';
                        });
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _submit,
              child: const Text('Lanjut'),
            ),
          ),
        ),
      ),
    );
  }
}