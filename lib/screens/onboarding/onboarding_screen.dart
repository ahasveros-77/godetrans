import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<_OnboardData> _pages = [
    _OnboardData(
      icon: Icons.directions_bus_filled_rounded,
      title: 'Perjalanan Nyaman,\nSampai Tujuan',
      subtitle: 'Layanan travel terpercaya untuk setiap perjalananmu.',
    ),
    _OnboardData(
      icon: Icons.event_available_rounded,
      title: 'Pesan Mudah\nKapan Saja',
      subtitle: 'Pesan tiket travel dengan cepat dan praktis melalui aplikasi.',
    ),
    _OnboardData(
      icon: Icons.verified_user_rounded,
      title: 'Aman & Terpercaya',
      subtitle:
          'Perjalanan aman dengan pengemudi profesional dan armada terbaik.',
    ),
  ];

  void _finishOnboarding() async {
    await AuthService.setOnboardingSeen();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.local_shipping_rounded,
                        color: AppColors.primary, size: 22),
                    const SizedBox(width: 6),
                    const Text('GodeTrans',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.textPrimary,
                        )),
                  ],
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Text(data.title,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.h1.copyWith(fontSize: 26)),
                        const SizedBox(height: 12),
                        Text(data.subtitle,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySecondary),
                        const SizedBox(height: 36),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppColors.primaryLight,
                                  AppColors.primaryLight.withOpacity(0.3),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Icon(
                              data.icon,
                              size: 110,
                              color: AppColors.primary.withOpacity(0.85),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  TextButton(
                    onPressed: _finishOnboarding,
                    child: const Text('Lewati',
                        style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  const Spacer(),
                  Row(
                    children: List.generate(_pages.length, (index) {
                      final active = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: active ? 20 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.primary
                              : AppColors.border,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      );
                    }),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      if (isLast) {
                        _finishOnboarding();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardData {
  final IconData icon;
  final String title;
  final String subtitle;

  _OnboardData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
