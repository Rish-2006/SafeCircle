import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/custom_button.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // App Icon / Logo Shield
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.shield,
                      size: 48,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                AppStrings.appName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                AppStrings.appTagline,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
              const Spacer(),

              // Sign in with Google Button
              CustomButton(
                text: AppStrings.signInWithGoogle,
                icon: Icons.g_mobiledata_outlined,
                isLoading: authController.isLoading,
                onPressed: () {
                  ref.read(authControllerProvider.notifier).signInWithGoogle();
                },
              ),
              const SizedBox(height: 14),

              // Continue with Demo Account Button
              CustomButton(
                text: AppStrings.continueAsGuest,
                variant: ButtonVariant.secondary,
                icon: Icons.lock_open_outlined,
                isLoading: authController.isLoading,
                onPressed: () {
                  ref.read(authControllerProvider.notifier).signInDemo();
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
