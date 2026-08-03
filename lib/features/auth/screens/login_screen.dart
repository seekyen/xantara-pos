import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../local/database_seed.dart';
import '../../../shared/providers/biometric_provider.dart';
import '../../../shared/widgets/status_banner.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref
        .read(authProvider.notifier)
        .login(_emailCtrl.text.trim(), _passwordCtrl.text);
    if (!success || !mounted) return;

    final role = ref.read(authProvider).user?.role;
    final dest = isAdminRole(role) ? '/admin' : '/cashier';

    final isAvailable = ref.read(biometricAvailableProvider).value ?? false;
    final isEnabled = ref.read(biometricEnabledProvider);
    if (isAvailable && !isEnabled) {
      _showEnableBiometricDialog(_emailCtrl.text.trim(), _passwordCtrl.text, dest);
    } else {
      context.go(dest);
    }
  }

  Future<void> _loginWithBiometric() async {
    final svc = ref.read(biometricServiceProvider);
    final authenticated = await svc.authenticate();
    if (!authenticated || !mounted) return;

    final creds = await svc.savedCredentials();
    if (creds == null || !mounted) return;

    final success = await ref
        .read(authProvider.notifier)
        .login(creds.email, creds.password);
    if (success && mounted) {
      final role = ref.read(authProvider).user?.role;
      context.go(isAdminRole(role) ? '/admin' : '/cashier');
    }
  }

  void _showEnableBiometricDialog(
      String email, String password, String dest) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.rCardLg),
        ),
        title: const Row(
          children: [
            Icon(Icons.fingerprint, color: AppColors.primary, size: 22),
            SizedBox(width: AppSizes.sm),
            Text('Quick Sign-In', style: AppTextStyles.titleMd),
          ],
        ),
        content: Text(
          'Use fingerprint or face ID to sign in faster next time?',
          style: AppTextStyles.bodyMd.copyWith(color: AppColors.gray600),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(dest);
            },
            child: const Text('Skip'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(biometricEnabledProvider.notifier)
                  .enable(email, password);
              if (mounted) {
                Navigator.pop(context);
                context.go(dest);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.rButton),
              ),
              elevation: 0,
            ),
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final bioAvailable = ref.watch(biometricAvailableProvider).value ?? false;
    final bioEnabled = ref.watch(biometricEnabledProvider);

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppColors.gray50],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.xl, vertical: AppSizes.xxl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Brand mark
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: AppShadows.md,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.asset(
                        'assets/images/xantara-logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.point_of_sale_rounded,
                          color: AppColors.primary,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.lg),
                  const Text('Xantara POS', style: AppTextStyles.displayMd),
                  const SizedBox(height: AppSizes.xs),
                  Text(
                    'Sign in to your account',
                    style: AppTextStyles.bodyMd.copyWith(color: AppColors.gray600),
                  ),
                  const SizedBox(height: AppSizes.xl),

                  const StatusBanner(
                    text: 'Training accounts — owner: $seedOwnerEmail / '
                        '$seedOwnerPassword\ncashier: $seedCashierEmail / '
                        '$seedCashierPassword',
                    tone: BannerTone.info,
                  ),
                  const SizedBox(height: AppSizes.xl),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _Label('Email'),
                          const SizedBox(height: AppSizes.xs),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'you@xantara.com',
                              prefixIcon: Icon(Icons.email_outlined,
                                  size: 18, color: AppColors.gray400),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty
                                    ? 'Enter your email'
                                    : null,
                          ),
                          const SizedBox(height: AppSizes.md),
                          const _Label('Password'),
                          const SizedBox(height: AppSizes.xs),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscure,
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              prefixIcon: const Icon(Icons.lock_outlined,
                                  size: 18, color: AppColors.gray400),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 18,
                                  color: AppColors.gray400,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            validator: (v) =>
                                v == null || v.isEmpty
                                    ? 'Enter your password'
                                    : null,
                            onFieldSubmitted: (_) => _submit(),
                          ),

                          if (auth.error != null) ...[
                            const SizedBox(height: AppSizes.md),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.md,
                                  vertical: AppSizes.sm),
                              decoration: BoxDecoration(
                                color: AppColors.errorLight,
                                borderRadius:
                                    BorderRadius.circular(AppSizes.rInput),
                                border: const Border(
                                    left: BorderSide(
                                        color: AppColors.error, width: 3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline,
                                      color: AppColors.error, size: 16),
                                  const SizedBox(width: AppSizes.sm),
                                  Expanded(
                                    child: Text(auth.error!,
                                        style: AppTextStyles.bodyMd
                                            .copyWith(color: AppColors.error)),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: AppSizes.xl),
                          SizedBox(
                            height: AppSizes.buttonHeight,
                            child: ElevatedButton(
                              onPressed: auth.isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppSizes.rButton),
                                ),
                                elevation: 0,
                              ),
                              child: auth.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white),
                                    )
                                  : Text('Sign In',
                                      style: AppTextStyles.bodyLg.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (bioAvailable && bioEnabled) ...[
                    const SizedBox(height: AppSizes.md),
                    OutlinedButton.icon(
                      onPressed: auth.isLoading ? null : _loginWithBiometric,
                      icon: const Icon(Icons.fingerprint, size: 20),
                      label: const Text('Use biometric sign-in'),
                    ),
                  ],

                  const SizedBox(height: AppSizes.xl),
                  const Text('Powered by Xantara', style: AppTextStyles.caption),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTextStyles.labelMd);
}
