import 'package:flutter/material.dart';
import '../theme/xantara_theme.dart';

/// Login screen — option 1a ("Refined Material"). Email/password with
/// biometric quick sign-in and the training-accounts credential hint,
/// rebuilt on the named type scale.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: XantaraColors.gray50,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(XantaraSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: XantaraColors.primary,
                      borderRadius: BorderRadius.circular(XantaraRadius.cardLg),
                    ),
                    alignment: Alignment.center,
                    child: const Text('X', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: XantaraSpacing.lg),
                  Text('Xantara POS', style: XantaraType.displayMd),
                  const SizedBox(height: XantaraSpacing.xs),
                  Text('Sign in to continue', style: XantaraType.bodyMd.copyWith(color: XantaraColors.gray600)),
                  const SizedBox(height: XantaraSpacing.xxl),

                  // Training-accounts hint box — now a real component, not a
                  // plain colored Container.
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(XantaraSpacing.md),
                    decoration: BoxDecoration(
                      color: XantaraColors.primaryLight,
                      borderRadius: BorderRadius.circular(XantaraRadius.input),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Training accounts', style: XantaraType.labelMd.copyWith(color: XantaraColors.primaryDark)),
                        const SizedBox(height: XantaraSpacing.xs),
                        Text('admin@xantara.test / cashier@xantara.test — password "training123"',
                            style: XantaraType.bodySm.copyWith(color: XantaraColors.primaryDark)),
                      ],
                    ),
                  ),
                  const SizedBox(height: XantaraSpacing.xl),

                  TextField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    style: XantaraType.bodyLg,
                  ),
                  const SizedBox(height: XantaraSpacing.md),
                  TextField(
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    style: XantaraType.bodyLg,
                  ),
                  const SizedBox(height: XantaraSpacing.xl),

                  ElevatedButton(onPressed: () {}, child: const Text('Sign in')),
                  const SizedBox(height: XantaraSpacing.md),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.fingerprint, size: 20),
                    label: const Text('Use biometric sign-in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
