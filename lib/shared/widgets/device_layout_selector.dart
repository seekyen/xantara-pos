import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/settings/providers/display_preferences.dart';

class DeviceLayoutSelector extends ConsumerStatefulWidget {
  const DeviceLayoutSelector({super.key});

  @override
  ConsumerState<DeviceLayoutSelector> createState() =>
      _DeviceLayoutSelectorState();
}

class _DeviceLayoutSelectorState extends ConsumerState<DeviceLayoutSelector> {
  bool _saving = false;

  Future<void> _select(DisplayDevice device) async {
    setState(() => _saving = true);
    try {
      await ref.read(displayPreferencesProvider.notifier).setDevice(device);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Could not save the device layout. Please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = ref.watch(displayPreferencesProvider).device;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Device layout', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: DisplayDevice.values
              .map((device) => ChoiceChip(
                    avatar: Icon(device.icon, size: 20),
                    label: Text(device.label),
                    tooltip: device == DisplayDevice.automatic
                        ? 'Adapt to the available screen'
                        : 'Use ${device.label.toLowerCase()} layout',
                    selected: selected == device,
                    showCheckmark: false,
                    onSelected: _saving ? null : (_) => _select(device),
                  ))
              .toList(),
        ),
      ],
    );
  }
}
