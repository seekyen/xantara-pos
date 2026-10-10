import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../pos/fnb/providers/pos_provider.dart';
import '../../../core/auth/pos_authorization.dart';
import '../../../local/database_providers.dart';
import '../../../local/database_seed.dart';
import '../../../local/repositories/inventory_workspace_repository.dart';
import '../../../shared/providers/sync_provider.dart';
import '../../../shared/widgets/bottom_tab_bar.dart';
import '../inventory_schema.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});
  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> {
  bool _shared = false;
  String _search = '';
  String? _error;
  bool _loading = false;
  List<Map<String, dynamic>> _remote = [];
  InventoryWorkspaceRepository get repository =>
      InventoryWorkspaceRepository(ref.read(appDatabaseProvider));

  Future<void> _loadShared() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final branch = ref.read(activeBranchProvider);
      final result = await ref
          .read(cloudSyncControllerProvider)
          .inventoryRequest('?branch=$branch');
      if (mounted) {
        setState(
            () => _remote = List<Map<String, dynamic>>.from(result as List));
      }
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _edit({String? localId, Map<String, dynamic>? remote}) async {
    try {
      final schema = await InventorySchema.load();
      final branch = ref.read(activeBranchProvider);
      final document = remote ??
          (localId == null
              ? {'tier': 'basic', 'revision': 0, 'data': schema.defaults()}
              : await repository.read(localId, branchIdForCode(branch)));
      if (!mounted) return;
      await showDialog<void>(
          context: context,
          builder: (_) => _InventoryEditor(
              document: document,
              schema: schema,
              shared: _shared,
              branchCode: branch));
      if (_shared) await _loadShared();
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(productsProvider);
    final branch = ref.watch(activeBranchProvider);
    final user = ref.watch(authProvider).user;
    final canEdit = user != null &&
        user.branchIds.contains(branchIdForCode(branch)) &&
        ['owner', 'admin', 'manager', 'inventoryClerk'].contains(user.role);
    ref.listen(activeBranchProvider, (_, __) {
      if (_shared) _loadShared();
    });
    final local = products
        .where((p) =>
            '${p.name} ${p.sku}'.toLowerCase().contains(_search.toLowerCase()))
        .toList();
    final remote = _remote
        .where((p) => '${p['data']['name']} ${p['data']['sku']}'
            .toLowerCase()
            .contains(_search.toLowerCase()))
        .toList();
    return Scaffold(
      appBar: AppBar(
          title: Text('Inventory · ${retailBranchFor(branch).name}'),
          actions: [
            if (_shared)
              IconButton(
                  tooltip: 'Refresh shared inventory',
                  onPressed: _loading ? null : _loadShared,
                  icon: const Icon(Icons.refresh)),
          ]),
      bottomNavigationBar: const BottomTabBar(currentIndex: 2),
      floatingActionButton: canEdit
          ? FloatingActionButton.extended(
              onPressed: () => _edit(),
              icon: const Icon(Icons.add),
              label: const Text('Add item'))
          : null,
      body: SafeArea(
          child: Column(children: [
        Padding(
            padding: const EdgeInsets.all(16),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                        value: false,
                        label: Text('This device'),
                        icon: Icon(Icons.offline_bolt_outlined)),
                    ButtonSegment(
                        value: true,
                        label: Text('Shared backend'),
                        icon: Icon(Icons.cloud_outlined))
                  ],
                  selected: {
                    _shared
                  },
                  onSelectionChanged: (values) {
                    setState(() {
                      _shared = values.first;
                      _error = null;
                    });
                    if (_shared) _loadShared();
                  }),
              const SizedBox(height: 12),
              Text(
                  _shared
                      ? 'Shared inventory also appears in the admin frontend.'
                      : 'Offline inventory used by this register.',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 12),
              TextField(
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search inventory',
                      border: OutlineInputBorder()),
                  onChanged: (value) => setState(() => _search = value)),
            ])),
        if (_error != null)
          Padding(
              padding: const EdgeInsets.all(16),
              child: Text(_error!,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error))),
        if (_loading) const LinearProgressIndicator(),
        Expanded(
            child: (_shared ? remote.isEmpty : local.isEmpty) && !_loading
                ? const Center(child: Text('No inventory items to show.'))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    itemCount: _shared ? remote.length : local.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final data = _shared
                          ? remote[index]['data'] as Map
                          : {
                              'name': local[index].name,
                              'selling_price': local[index].price,
                              'quantity': local[index].stock,
                              'reorder_level': local[index].reorderPoint,
                              'unit': 'units'
                            };
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        leading: CircleAvatar(
                            child: Icon((num.tryParse('${data['quantity']}') ??
                                        0) <=
                                    (num.tryParse('${data['reorder_level']}') ??
                                        0)
                                ? Icons.warning_amber_rounded
                                : Icons.inventory_2_outlined)),
                        title: Text('${data['name']}',
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        subtitle: Text(
                            '₱${num.tryParse('${data['selling_price']}')?.toStringAsFixed(2) ?? '0.00'} · ${data['quantity']} ${data['unit'] ?? 'units'}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: canEdit
                            ? () => _shared
                                ? _edit(remote: remote[index])
                                : _edit(localId: local[index].id)
                            : null,
                      );
                    })),
      ])),
    );
  }
}

class _InventoryEditor extends ConsumerStatefulWidget {
  const _InventoryEditor(
      {required this.document,
      required this.schema,
      required this.shared,
      required this.branchCode});
  final Map<String, dynamic> document;
  final InventorySchema schema;
  final bool shared;
  final String branchCode;
  @override
  ConsumerState<_InventoryEditor> createState() => _InventoryEditorState();
}

class _InventoryEditorState extends ConsumerState<_InventoryEditor> {
  final _form = GlobalKey<FormState>();
  final _reason = TextEditingController();
  late final Map<String, dynamic> _data = Map<String, dynamic>.from(
      jsonDecode(jsonEncode(widget.document['data'])) as Map);
  late String _tier = widget.document['tier'] as String;
  bool _busy = false;
  String? _error;
  List<Map<String, dynamic>>? _history;
  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      widget.schema.validate(_data);
      final expected =
          (num.tryParse('${widget.document['data']['quantity']}') ?? 0).toInt();
      final document = {...widget.document, 'tier': _tier, 'data': _data};
      if (widget.shared) {
        final id = document['id'];
        await ref.read(cloudSyncControllerProvider).inventoryRequest(
            id == null ? '' : '$id/',
            method: id == null ? 'POST' : 'PUT',
            data: {
              ...document,
              'branch': widget.branchCode,
              'reason': _reason.text.trim(),
              'expected_quantity': expected
            });
      } else {
        final user = ref.read(authProvider).user!;
        final actor = StaffPrincipal(
            id: user.id,
            displayName: user.name,
            email: user.email,
            role: StaffRole.values.byName(user.role),
            branchIds: user.branchIds);
        await InventoryWorkspaceRepository(ref.read(appDatabaseProvider)).save(
            document: document,
            branchId: branchIdForCode(widget.branchCode),
            actor: actor,
            reason: _reason.text,
            schema: widget.schema,
            expectedQuantity: expected);
      }
      if (mounted) Navigator.pop(context);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _loadHistory() async {
    try {
      List<Map<String, dynamic>> history;
      if (widget.shared) {
        final result = await ref
            .read(cloudSyncControllerProvider)
            .inventoryRequest('${widget.document['id']}/history/');
        history = List<Map<String, dynamic>>.from(result as List);
      } else {
        final rows =
            await InventoryWorkspaceRepository(ref.read(appDatabaseProvider))
                .history(widget.document['local_id'] as String,
                    branchIdForCode(widget.branchCode));
        history = rows
            .map((row) => <String, dynamic>{
                  'date': row.createdAt.toIso8601String(),
                  'actor': row.actorId,
                  'reason': row.reason,
                  'before': jsonDecode(row.beforeJson),
                  'after': jsonDecode(row.afterJson)
                })
            .toList();
      }
      if (mounted) setState(() => _history = history);
    } catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tierIndex = widget.schema.tiers.indexWhere((t) => t['key'] == _tier);
    final fields = widget.schema.fields
        .where((f) => (f['tier'] as int) <= tierIndex)
        .toList();
    final sections = fields.map((f) => f['section'] as String).toSet();
    final existing =
        widget.document['id'] != null || widget.document['local_id'] != null;
    final price = num.tryParse('${_data['selling_price']}') ?? 0;
    final cost = (num.tryParse('${_data['cost_price']}') ?? 0) +
        ((_data['landed_costs'] ?? []) as List).fold<num>(
            0, (sum, row) => sum + (num.tryParse('${row['amount']}') ?? 0));
    return Dialog(
        insetPadding: const EdgeInsets.all(12),
        child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    const Icon(Icons.inventory_2_outlined),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Text(
                            existing
                                ? 'Edit inventory item'
                                : 'New inventory item',
                            style: Theme.of(context).textTheme.titleLarge)),
                    IconButton(
                        onPressed: _busy ? null : () => Navigator.pop(context),
                        icon: const Icon(Icons.close))
                  ])),
              const Divider(height: 1),
              Flexible(
                  child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                          key: _form,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (_error != null)
                                  Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: Text(_error!,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error))),
                                DropdownButtonFormField<String>(
                                    isExpanded: true,
                                    initialValue: _tier,
                                    decoration: const InputDecoration(
                                        labelText: 'Inventory tier',
                                        border: OutlineInputBorder()),
                                    items: widget.schema.tiers
                                        .map((tier) => DropdownMenuItem(
                                            value: tier['key'] as String,
                                            child: Text('${tier['label']}')))
                                        .toList(),
                                    onChanged: _busy
                                        ? null
                                        : (tier) =>
                                            setState(() => _tier = tier!)),
                                const SizedBox(height: 8),
                                Text(
                                    '${widget.schema.tiers[tierIndex]['description']}'),
                                for (final section in sections) ...[
                                  Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      child: Text(section,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium)),
                                  for (final field in fields
                                      .where((f) => f['section'] == section))
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 14),
                                        child: _InventoryField(
                                            key: ValueKey(field['key']),
                                            field: field,
                                            value: _data[field['key']],
                                            disabled: _busy ||
                                                (existing &&
                                                    field['key'] == 'sku'),
                                            onChanged: (value) => setState(() =>
                                                _data[field['key'] as String] =
                                                    value))),
                                ],
                                if (tierIndex >= 2)
                                  Text(
                                      'Landed unit cost: ₱${cost.toStringAsFixed(2)}  ·  Gross margin: ${price == 0 ? '—' : '${((price - cost) / price * 100).toStringAsFixed(1)}%'}'),
                                const SizedBox(height: 16),
                                TextFormField(
                                    controller: _reason,
                                    maxLength: 255,
                                    enabled: !_busy,
                                    decoration: const InputDecoration(
                                        labelText: 'Change reason',
                                        hintText:
                                            'PO reference, opening stock, price update',
                                        border: OutlineInputBorder()),
                                    validator: (value) =>
                                        value == null || value.trim().isEmpty
                                            ? 'Required'
                                            : null),
                                if (existing)
                                  TextButton.icon(
                                      onPressed: _loadHistory,
                                      icon: const Icon(Icons.history),
                                      label: const Text(
                                          'Price, purchase cost and stock history')),
                                if (_history != null && _history!.isEmpty)
                                  const Text(
                                      'No tiered inventory changes yet. Existing stock movements remain in the stock ledger.'),
                                for (final entry
                                    in _history ?? <Map<String, dynamic>>[])
                                  ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Text('${entry['reason']}'),
                                      subtitle: Text(
                                          '${entry['date']} · User ${entry['actor']}\nStock: ${entry['before']['data']['quantity']} → ${entry['after']['data']['quantity']}\nCost: ${entry['before']['data']['cost_price'] ?? '—'} → ${entry['after']['data']['cost_price']} · Price: ${entry['before']['data']['selling_price'] ?? '—'} → ${entry['after']['data']['selling_price']}')),
                              ])))),
              const Divider(height: 1),
              Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                      alignment: WrapAlignment.end,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        TextButton(
                            onPressed:
                                _busy ? null : () => Navigator.pop(context),
                            child: const Text('Cancel')),
                        FilledButton(
                            onPressed: _busy ? null : _save,
                            child: Text(_busy
                                ? 'Saving…'
                                : widget.shared
                                    ? 'Save to backend'
                                    : 'Save on device'))
                      ])),
            ])));
  }
}

class _InventoryField extends StatefulWidget {
  const _InventoryField(
      {super.key,
      required this.field,
      required this.value,
      required this.onChanged,
      this.disabled = false});
  final Map<String, dynamic> field;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;
  final bool disabled;
  @override
  State<_InventoryField> createState() => _InventoryFieldState();
}

class _InventoryFieldState extends State<_InventoryField> {
  late final _controller = TextEditingController(text: '${widget.value ?? ''}');
  int _rowVersion = 0;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final field = widget.field;
    final label = '${field['label']}${field['required'] == true ? ' *' : ''}';
    if (field['type'] == 'rows') {
      final rows = List<Map<String, dynamic>>.from(widget.value as List? ?? []);
      return Card(
          margin: EdgeInsets.zero,
          child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.titleSmall),
                    if (field['hint'] != null)
                      Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('${field['hint']}',
                              style: Theme.of(context).textTheme.bodySmall)),
                    if (rows.isEmpty)
                      const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('No records added.')),
                    for (var index = 0; index < rows.length; index++)
                      Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Column(children: [
                            for (final child in List<Map<String, dynamic>>.from(
                                field['fields'] as List))
                              Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _InventoryField(
                                      key: ValueKey(
                                          '$_rowVersion-$index-${child['key']}'),
                                      field: child,
                                      value: rows[index][child['key']],
                                      disabled: widget.disabled,
                                      onChanged: (value) {
                                        rows[index] = {
                                          ...rows[index],
                                          child['key'] as String: value
                                        };
                                        widget.onChanged(rows);
                                      })),
                            TextButton.icon(
                                onPressed: widget.disabled
                                    ? null
                                    : () {
                                        rows.removeAt(index);
                                        setState(() => _rowVersion++);
                                        widget.onChanged(rows);
                                      },
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Remove row')),
                            const Divider(),
                          ])),
                    TextButton.icon(
                        onPressed: widget.disabled
                            ? null
                            : () => widget.onChanged([
                                  ...rows,
                                  <String, dynamic>{
                                    for (final child in field['fields'] as List)
                                      if (child['default'] != null)
                                        child['key'] as String: child['default']
                                  }
                                ]),
                        icon: const Icon(Icons.add),
                        label: const Text('Add row')),
                  ])));
    }
    if (field['type'] == 'boolean') {
      return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          value: widget.value == true,
          onChanged: widget.disabled ? null : widget.onChanged);
    }
    if (field['type'] == 'select') {
      return DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: (field['options'] as List).contains(widget.value)
              ? widget.value as String
              : field['default'] as String?,
          decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              helperText: field['hint'] as String?,
              helperMaxLines: 3),
          items: (field['options'] as List)
              .map((option) => DropdownMenuItem(
                  value: '$option',
                  child: Text('$option'.replaceAll('_', ' '))))
              .toList(),
          onChanged: widget.disabled ? null : widget.onChanged);
    }
    return TextFormField(
        controller: _controller,
        enabled: !widget.disabled,
        keyboardType: ['integer', 'money', 'decimal'].contains(field['type'])
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            helperText: field['hint'] as String? ??
                (field['type'] == 'date' ? 'YYYY-MM-DD' : null),
            helperMaxLines: 3),
        validator: (value) => InventorySchema.validateValue(field, value),
        onChanged: (value) => widget.onChanged(
            field['type'] == 'integer' && int.tryParse(value) != null
                ? int.parse(value)
                : value));
  }
}
