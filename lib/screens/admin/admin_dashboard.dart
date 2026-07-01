import 'package:flutter/material.dart';
import 'manage_bookings_screen.dart';
import 'manage_routes_screen.dart';
import 'manage_schedules_screen.dart';
import 'list_routes_screen.dart';
import 'list_schedules_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageBookingsScreen()),
                );
              },
              child: const Text('Manage Bookings'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ListRoutesScreen()),
                );
              },
              child: const Text('Daftar Rute'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageRoutesScreen()),
                );
              },
              child: const Text('Tambah Rute Baru'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ListSchedulesScreen()),
                );
              },
              child: const Text('Daftar Jadwal'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageSchedulesScreen()),
                );
              },
              child: const Text('Tambah Jadwal Baru'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Penjelasan singkat sistem:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              '1. User memilih rute yang tersedia di aplikasi.\n'
              '2. Admin bisa menambah, edit, dan hapus rute dan jadwal.\n'
              '3. Setelah booking, tiket tersimpan di sheet Booking.\n'
              '4. Admin bisa mengubah status tiket menjadi Dikonfirmasi atau Selesai.\n'
              '5. User bisa membatalkan tiket mereka sendiri.\n',
            ),
          ],
        ),
      ),
    );
  }
}
