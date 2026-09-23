import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/common.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding.complete', true);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Dialog.fullscreen(
      backgroundColor: scheme.surface,
      child: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -70,
              child: _Orb(
                color: scheme.primary.withValues(alpha: .12),
                size: 240,
              ),
            ),
            Positioned(
              bottom: -120,
              left: -90,
              child: _Orb(
                color: scheme.secondary.withValues(alpha: .1),
                size: 280,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 34, 24, 20),
              child: Column(
                children: [
                  const BrandLogo(size: 112, borderRadius: 30),
                  const SizedBox(height: 20),
                  Text(
                    'RIGEL SPACE SAVER',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: .8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'YOUR STORAGE, BACK IN ORBIT',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const _BenefitRow(
                    icon: Icons.bolt_rounded,
                    title: 'Compress without the cloud',
                    message: 'Fast, format-safe compression for your media.',
                  ),
                  const SizedBox(height: 12),
                  const _BenefitRow(
                    icon: Icons.shield_rounded,
                    title: 'Private by design',
                    message: 'Your files stay on this device, always.',
                  ),
                  const SizedBox(height: 12),
                  const _BenefitRow(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Clean up with confidence',
                    message: 'Preview savings before anything is replaced.',
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      4,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: index == 0 ? 22 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: index == 0
                              ? scheme.primary
                              : scheme.outlineVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _finish,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('Enter the control room'),
                    ),
                  ),
                  TextButton(
                    onPressed: _finish,
                    child: const Text('Skip intro'),
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

class _Orb extends StatelessWidget {
  const _Orb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => SpaceCard(
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        GlowIcon(icon, size: 48),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text(
                message,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
