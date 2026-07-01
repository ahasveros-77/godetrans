import 'package:flutter/material.dart';
import '../../services/sheets_api_service.dart';

class ManageBookingsScreen extends StatefulWidget {
  const ManageBookingsScreen({Key? key}) : super(key: key);

  @override
  State<ManageBookingsScreen> createState() => _ManageBookingsScreenState();
}

class _ManageBookingsScreenState extends State<ManageBookingsScreen> {
  List<dynamic> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      setState(() => _loading = true);
      final data = await SheetsApiService.get('getAllBookings');
      setState(() {
        _bookings = data ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal ambil bookings: $e')));
    }
  }

  Future<void> _changeStatus(String id, String status) async {
    try {
      await SheetsApiService.post(
          'updateBookingStatus', {'id': id, 'status': status});
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Status diubah')));
      _fetchBookings();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal ubah status: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Bookings')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchBookings,
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: _bookings.length,
                itemBuilder: (context, index) {
                  final b = _bookings[index];
                  return Card(
                    child: ListTile(
                      title: Text(
                          '${b['nama_penumpang'] ?? '—'} — ${b['kursi'] ?? ''}'),
                      subtitle: Text(
                          '${b['asal'] ?? ''} → ${b['tujuan'] ?? ''}\nStatus: ${b['status'] ?? ''}'),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (val) => _changeStatus(b['id'], val),
                        itemBuilder: (_) => [
                          const PopupMenuItem(
                              value: 'Dikonfirmasi',
                              child: Text('Dikonfirmasi')),
                          const PopupMenuItem(
                              value: 'Dibatalkan', child: Text('Dibatalkan')),
                          const PopupMenuItem(
                              value: 'Selesai', child: Text('Selesai')),
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
