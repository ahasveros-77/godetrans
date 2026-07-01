import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/sheets_api_service.dart';
import '../../widgets/primary_button.dart';

class ListRoutesScreen extends StatefulWidget {
  const ListRoutesScreen({Key? key}) : super(key: key);

  @override
  State<ListRoutesScreen> createState() => _ListRoutesScreenState();
}

class _ListRoutesScreenState extends State<ListRoutesScreen> {
  List<dynamic> _routes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    setState(() => _loading = true);
    try {
      final data = await SheetsApiService.get('getRutePopuler');
      setState(() {
        _routes = data ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal ambil rute: $e')));
    }
  }

  Future<void> _deleteRoute(String id) async {
    try {
      await SheetsApiService.post('deleteRute', {'id': id});
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rute dihapus')));
      _loadRoutes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal hapus rute: $e')));
    }
  }

  void _editRoute(dynamic route) {
    final asalController = TextEditingController(text: route['asal']);
    final tujuanController = TextEditingController(text: route['tujuan']);
    final jamController = TextEditingController(text: route['jam_berangkat']);
    final kursiController = TextEditingController(
        text: route['kursi_tersedia'].toString());
    final hargaController = TextEditingController(
        text: route['harga'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Rute'),
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
                decoration: const InputDecoration(labelText: 'Kursi'),
              ),
              TextField(
                controller: hargaController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga'),
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
                await SheetsApiService.post('updateRute', {
                  'id': route['id'],
                  'asal': asalController.text,
                  'tujuan': tujuanController.text,
                  'jam_berangkat': jamController.text,
                  'kursi_tersedia': int.tryParse(kursiController.text) ?? 0,
                  'harga': double.tryParse(hargaController.text) ?? 0,
                });
                Navigator.pop(context);
                _loadRoutes();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Rute diupdate')));
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal update rute: $e')));
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
      appBar: AppBar(title: const Text('Daftar Rute')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRoutes,
              child: _routes.isEmpty
                  ? const Center(child: Text('Tidak ada rute'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _routes.length,
                      itemBuilder: (context, index) {
                        final route = _routes[index];
                        return Card(
                          child: ListTile(
                            title: Text('${route['asal']} → ${route['tujuan']}'),
                            subtitle: Text(
                                'Jam: ${route['jam_berangkat']} | Kursi: ${route['kursi_tersedia']} | Harga: ${route['harga']}'),
                            trailing: PopupMenuButton(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _editRoute(route);
                                } else if (value == 'delete') {
                                  _deleteRoute(route['id']);
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
