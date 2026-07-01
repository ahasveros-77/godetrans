import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/sheets_api_service.dart';

class ListSchedulesScreen extends StatefulWidget {
  const ListSchedulesScreen({Key? key}) : super(key: key);

  @override
  State<ListSchedulesScreen> createState() => _ListSchedulesScreenState();
}

class _ListSchedulesScreenState extends State<ListSchedulesScreen> {
  List<dynamic> _schedules = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedules();
  }

  Future<void> _loadSchedules() async {
    setState(() => _loading = true);
    try {
      final data = await SheetsApiService.get('getAllJadwal');
      setState(() {
        _schedules = data ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal ambil jadwal: $e')));
    }
  }

  Future<void> _deleteSchedule(String id) async {
    try {
      await SheetsApiService.post('deleteJadwal', {'id': id});
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jadwal dihapus')));
      _loadSchedules();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal hapus jadwal: $e')));
    }
  }

  void _editSchedule(dynamic schedule) {
    final asalController = TextEditingController(text: schedule['asal']);
    final tujuanController = TextEditingController(text: schedule['tujuan']);
    final jamController = TextEditingController(text: schedule['jam']);
    final kursiController = TextEditingController(
        text: schedule['kursi_tersedia'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Jadwal'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: asalController,
                decoration: const InputDecoration(labelText: 'Asal'),
              ),
              TextField(
                controller: tujuanController,
                decoration: const InputDecoration(labelText: 'Tujuan'),
              ),
              TextField(
                controller: jamController,
                decoration: const InputDecoration(labelText: 'Jam'),
              ),
              TextField(
                controller: kursiController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Kursi Tersedia'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await SheetsApiService.post('updateJadwal', {
                  'id': schedule['id'],
                  'asal': asalController.text,
                  'tujuan': tujuanController.text,
                  'jam': jamController.text,
                  'kursi_tersedia': int.tryParse(kursiController.text) ?? 0,
                });
                Navigator.pop(context);
                _loadSchedules();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Jadwal diupdate')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal update jadwal: $e')));
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Jadwal')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadSchedules,
              child: _schedules.isEmpty
                  ? const Center(child: Text('Tidak ada jadwal'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = _schedules[index];
                        return Card(
                          child: ListTile(
                            title:
                                Text('${schedule['asal']} → ${schedule['tujuan']}'),
                            subtitle: Text(
                                'Jam: ${schedule['jam']} | Kursi: ${schedule['kursi_tersedia']}'),
                            trailing: PopupMenuButton(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editSchedule(schedule);
                                } else if (value == 'delete') {
                                  _deleteSchedule(schedule['id']);
                                }
                              },
                              itemBuilder: (_) => [
                                const PopupMenuItem(
                                    value: 'edit', child: Text('Edit')),
                                const PopupMenuItem(
                                    value: 'delete', child: Text('Hapus')),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
