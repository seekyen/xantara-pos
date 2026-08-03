import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/pos_authorization.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_sizes.dart';
import '../../local/database_providers.dart';
import '../../local/repositories/staff_auth_repository.dart';

/// Prompts a supervisor to authenticate with their own credentials and
/// checks they hold [permission] at [branchId]. Returns the authorized
/// [StaffPrincipal], or null if cancelled. Replaces the previous shared
/// static void PIN (flagged in docs/STAFF_AUTH_SECURITY.md as not approved
/// for production use).
Future<StaffPrincipal?> showSupervisorAuthorizationDialog(
  BuildContext context, {
  required String title,
  required String message,
  required PosPermission permission,
  required String branchId,
}) {
  return showDialog<StaffPrincipal>(
    context: context,
    builder: (_) => _SupervisorAuthorizationDialog(
      title: title,
      message: message,
      permission: permission,
      branchId: branchId,
    ),
  );
}

class _SupervisorAuthorizationDialog extends ConsumerStatefulWidget {
  const _SupervisorAuthorizationDialog({
    required this.title,
    required this.message,
    required this.permission,
    required this.branchId,
  });

  final String title;
  final String message;
  final PosPermission permission;
  final String branchId;

  @override
  ConsumerState<_SupervisorAuthorizationDialog> createState() =>
      _SupervisorAuthorizationDialogState();
}

class _SupervisorAuthorizationDialogState
    extends ConsumerState<_SupervisorAuthorizationDialog> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final principal = await ref.read(staffAuthRepositoryProvider).authenticate(
            email: _emailCtrl.text.trim(),
            password: _passwordCtrl.text,
            now: DateTime.now(),
          );
      final authorized = const PosAuthorizationPolicy().allows(
        principal,
        widget.permission,
        branchId: widget.branchId,
      );
      if (!authorized) {
        setState(() {
          _submitting = false;
          _error = 'This account is not authorized for this action here.';
        });
        return;
      }
      if (!mounted) return;
      Navigator.pop(context, principal);
    } on AuthenticationLockedException {
      setState(() {
        _submitting = false;
        _error = 'Account temporarily locked. Try again later.';
      });
    } on AuthenticationException catch (error) {
      setState(() {
        _submitting = false;
        _error = error.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.admin_panel_settings_outlined,
              color: AppColors.error, size: 22),
          const SizedBox(width: AppSizes.sm),
          Text(widget.title),
        ],
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.rCardLg)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.message,
              style: const TextStyle(fontSize: 13, color: AppColors.gray600),
            ),
            const SizedBox(height: AppSizes.lg),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Supervisor email',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSizes.sm),
            TextField(
              controller: _passwordCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                errorText: _error,
                suffixIcon: IconButton(
                  icon: Icon(_obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              onSubmitted: (_) => _submitting ? null : _confirm(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitting ? null : _confirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.rButton)),
          ),
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Authorize'),
        ),
      ],
    );
  }
}
