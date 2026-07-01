import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../admin/admin_dashboard.dart';
import '../auth/login_screen.dart';

class AkunScreen extends StatefulWidget {
  final bool embedded;
  const AkunScreen({super.key, this.embedded = false});

  @override
  State<AkunScreen> createState() => _AkunScreenState();
}

class _AkunScreenState extends State<AkunScreen> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUser();
    setState(() => _user = user);
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await AuthService.logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (widget.embedded) ...[
          const Text('Akun Saya', style: AppTextStyles.h2),
          const SizedBox(height: 20),
        ],
        Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.person, color: AppColors.primary, size: 32),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_user?.nama ?? '-', style: AppTextStyles.h3),
                Text(_user?.email ?? '-', style: AppTextStyles.bodySecondary),
                if (_user != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Role: ${_user!.role}',
                    style: AppTextStyles.caption,
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 28),
        if (_user?.role == 'admin')
          _menuItem(Icons.admin_panel_settings, 'Admin Dashboard', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
            );
          }),
        _menuItem(Icons.person_outline, 'Profile', () {}),
        _menuItem(Icons.badge_outlined, 'Nama', () {}, value: _user?.nama),
        _menuItem(Icons.email_outlined, 'Email', () {}, value: _user?.email),
        _menuItem(Icons.settings_outlined, 'Pengaturan', () {}),
        const SizedBox(height: 8),
        const Divider(),
        const SizedBox(height: 8),
        _menuItem(Icons.logout_rounded, 'Keluar', _logout, isDanger: true),
      ],
    );

    if (widget.embedded) return body;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Akun Saya')),
      body: SafeArea(child: body),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap,
      {String? value, bool isDanger = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: isDanger ? AppColors.danger : AppColors.textPrimary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isDanger ? AppColors.danger : AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (value != null && value.isNotEmpty)
                    Text(value, style: AppTextStyles.bodySecondary),
                ],
              ),
            ),
            if (!isDanger)
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
