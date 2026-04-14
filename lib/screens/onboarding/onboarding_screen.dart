import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/primary_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _current = 0;

  final _pages = const [
    _OnboardingData(
      icon: Icons.swap_horiz_rounded,
      title: 'ProofOfSkill',
      subtitle:
          'Exchange Skills and Earn NFTs. Trade your expertise with others in a fair barter system.',
      accentIcon: Icons.link_rounded,
    ),
    _OnboardingData(
      icon: Icons.verified_rounded,
      title: 'Proof of Skill.\nNot Just Words.',
      subtitle:
          'Build a verifiable track record. Every session, every rating, every achievement — on the blockchain.',
      accentIcon: Icons.token_rounded,
    ),
    _OnboardingData(
      icon: Icons.emoji_events_rounded,
      title: 'Earn Recognition,\nUnlock Growth',
      subtitle:
          'Collect NFT badges, climb the leaderboard, and let your skills speak for themselves.',
      accentIcon: Icons.hexagon_rounded,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              // Skip
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                        context, '/login'),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _current = i),
                  itemCount: _pages.length,
                  itemBuilder: (context, i) => _OnboardingPage(data: _pages[i]),
                ),
              ),
              // Indicator
              SmoothPageIndicator(
                controller: _controller,
                count: _pages.length,
                effect: WormEffect(
                  activeDotColor: AppColors.primary,
                  dotColor: AppColors.border,
                  dotHeight: 8,
                  dotWidth: 8,
                  spacing: 8,
                ),
              ),
              const SizedBox(height: 40),
              // Button
              PrimaryButton(
                text: _current == _pages.length - 1
                    ? 'Get Started'
                    : 'Continue',
                icon: _current == _pages.length - 1
                    ? Icons.arrow_forward_rounded
                    : null,
                onPressed: () {
                  if (_current == _pages.length - 1) {
                    Navigator.pushReplacementNamed(context, '/login');
                  } else {
                    _controller.nextPage(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  final IconData icon;
  final String title;
  final String subtitle;
  final IconData? accentIcon;
  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.accentIcon,
  });
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;
  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon circle with blockchain accent
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring for blockchain feel
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(data.icon, size: 52, color: AppColors.primary),
              ),
              // Blockchain accent icon
              if (data.accentIcon != null)
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(data.accentIcon,
                        size: 16, color: AppColors.primary),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 48),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.2,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
