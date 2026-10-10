import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/pos_authorization.dart';
import '../../local/database.dart';
import '../../local/database_connection.dart';
import '../../local/database_providers.dart';
import '../../local/repositories/business_profile_repository.dart';
import '../../local/repositories/staff_auth_repository.dart';
import '../auth/providers/auth_provider.dart';
import 'business_profile.dart';
import 'business_profile_providers.dart';

class BusinessProfilesTile extends ConsumerWidget {
  const BusinessProfilesTile({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(activeBusinessProfileProvider);
    if (profile == null) return const SizedBox.shrink();
    final type = ref.watch(businessCheckoutTypeProvider);
    return ListTile(
        leading: const Icon(Icons.business),
        title: Text(profile.name),
        subtitle: Text(type?.label ?? 'Owner: choose a checkout type'),
        trailing: const Icon(Icons.swap_horiz),
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => const BusinessProfilesScreen())));
  }
}

class BusinessProfilesScreen extends ConsumerStatefulWidget {
  const BusinessProfilesScreen({super.key});
  @override
  ConsumerState<BusinessProfilesScreen> createState() =>
      _BusinessProfilesState();
}

class _BusinessProfilesState extends ConsumerState<BusinessProfilesScreen> {
  final _name = TextEditingController(), _password = TextEditingController();
  BusinessCheckoutType _type = BusinessCheckoutType.fnb;
  bool _busy = false;
  String? _error;
  @override
  void dispose() {
    _name.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _authorizeOwner() async {
    final user = ref.read(authProvider).user;
    if (user == null) {
      throw StateError('Sign in as the current business owner.');
    }
    final actor = await StaffAuthRepository(ref.read(appDatabaseProvider))
        .authenticate(
            email: user.email, password: _password.text, now: DateTime.now());
    if (actor.role != StaffRole.owner || actor.id != user.id) {
      throw const AuthorizationException(
          'Only the owner can create a business profile.');
    }
  }

  Future<void> _create() async {
    ref.read(ensureBusinessSwitchAllowedProvider)();
    await _authorizeOwner();
    // Check before persisting the catalog or opening another database.
    final switcher = ref.read(switchBusinessProvider);
    // The switcher's guard is also applied after creation, before leaving.
    final profile =
        await ref.read(businessProfileCatalogProvider).add(_name.text);
    final db = AppDatabase(
        await openAppDatabaseExecutor(name: profile.databaseName),
        requireRegistration: true,
        requireBusinessProfile: true);
    try {
      await BusinessProfileRepository(db).initializeEmpty(_type);
    } finally {
      await db.close();
    }
    await switcher(profile.id);
  }

  @override
  Widget build(BuildContext context) {
    final active = ref.watch(activeBusinessProfileProvider);
    final type = ref.watch(businessCheckoutTypeProvider);
    final user = ref.watch(authProvider).user;
    final profiles = ref.read(businessProfileCatalogProvider).profiles;
    return PopScope(
        canPop: !_busy,
        child: Scaffold(
            appBar: AppBar(title: const Text('Business profiles')),
            body: Center(
                child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 650),
                    child:
                        ListView(padding: const EdgeInsets.all(20), children: [
                      const Text(
                          'One checkout type per business. Switch profiles to work with another business; sign in with its own staff account.'),
                      const SizedBox(height: 12),
                      for (final profile in profiles)
                        Card(
                            child: ListTile(
                                title: Text(profile.name),
                                subtitle: Text(profile.id == active?.id
                                    ? 'Current business${type == null ? '' : ' - ${type.label}'}'
                                    : (profile.demo
                                        ? 'Training data'
                                        : 'Separate business records')),
                                trailing: profile.id == active?.id
                                    ? const Icon(Icons.check_circle)
                                    : null,
                                onTap: _busy || profile.id == active?.id
                                    ? null
                                    : () => _run(() => ref.read(
                                        switchBusinessProvider)(profile.id)))),
                      if (user?.role == 'owner') ...[
                        const Divider(height: 32),
                        Text(
                            type == null
                                ? 'Choose this business\'s checkout type'
                                : 'Create another business',
                            style: Theme.of(context).textTheme.titleLarge),
                        const Text(
                            'The type is fixed once saved. Existing sales remain unchanged. Restaurant is not available yet.'),
                        const SizedBox(height: 16),
                        if (type != null)
                          TextField(
                              controller: _name,
                              enabled: !_busy,
                              decoration: const InputDecoration(
                                  labelText: 'Business profile name')),
                        DropdownButtonFormField<BusinessCheckoutType>(
                            initialValue: _type,
                            isExpanded: true,
                            decoration: const InputDecoration(
                                labelText: 'Checkout type'),
                            items: BusinessCheckoutType.values
                                .map((t) => DropdownMenuItem(
                                    value: t, child: Text(t.label)))
                                .toList(),
                            onChanged: _busy
                                ? null
                                : (v) => setState(() => _type = v!)),
                        TextField(
                            controller: _password,
                            obscureText: true,
                            enabled: !_busy,
                            decoration: const InputDecoration(
                                labelText: 'Current owner password')),
                        const SizedBox(height: 16),
                        FilledButton(
                            onPressed: _busy
                                ? null
                                : () => _run(() async {
                                      if (type == null) {
                                        await ref
                                            .read(
                                                businessTypeRepositoryProvider)
                                            .assign(
                                                type: _type,
                                                email: user!.email,
                                                password: _password.text);
                                        ref
                                            .read(businessCheckoutTypeProvider
                                                .notifier)
                                            .state = _type;
                                        _password.clear();
                                      } else {
                                        await _create();
                                      }
                                    }),
                            child: Text(type == null
                                ? 'Save checkout type'
                                : 'Create business and continue setup')),
                      ],
                      if (_busy) const LinearProgressIndicator(),
                      if (_error != null)
                        Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(_error!,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.error))),
                    ])))));
  }
}
