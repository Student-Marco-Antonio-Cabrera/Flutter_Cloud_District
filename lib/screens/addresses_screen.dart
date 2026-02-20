import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/address.dart';
import '../providers/user_profile_provider.dart';
import '../widgets/gradient_scaffold.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  static const String routeName = '/addresses';

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileProvider>();

    return GradientScaffold(
      appBar: AppBar(
        title: const Text('Addresses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ...profile.addresses.asMap().entries.map((entry) {
              final i = entry.key;
              final addr = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.white.withValues(alpha: 0.15),
                child: ListTile(
                  title: Text(
                    addr.label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${addr.fullAddress}, ${addr.city}${addr.postalCode != null ? ' ${addr.postalCode}' : ''}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white70),
                        onPressed: () => _showAddressForm(
                          context,
                          profile: profile,
                          index: i,
                          existing: addr,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.white70),
                        onPressed: () => profile.removeAddress(i),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _showAddressForm(context, profile: profile),
              icon: const Icon(Icons.add),
              label: const Text('Add address'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void _showAddressForm(
    BuildContext context, {
    required UserProfileProvider profile,
    int? index,
    Address? existing,
  }) {
    final labelController =
        TextEditingController(text: existing?.label ?? '');
    final fullController =
        TextEditingController(text: existing?.fullAddress ?? '');
    final cityController = TextEditingController(text: existing?.city ?? '');
    final postalController =
        TextEditingController(text: existing?.postalCode ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                existing == null ? 'Add address' : 'Edit address',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: labelController,
                decoration: const InputDecoration(
                  labelText: 'Label (e.g. Home, Office)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fullController,
                decoration: const InputDecoration(
                  labelText: 'Full address',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(labelText: 'City'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: postalController,
                decoration: const InputDecoration(labelText: 'Postal code'),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  final label = labelController.text.trim();
                  final full = fullController.text.trim();
                  final city = cityController.text.trim();
                  final postal = postalController.text.trim();
                  if (label.isEmpty || full.isEmpty || city.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please fill label, address and city')),
                    );
                    return;
                  }
                  final id = existing?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString();
                  final addr = Address(
                    id: id,
                    label: label,
                    fullAddress: full,
                    city: city,
                    postalCode: postal.isEmpty ? null : postal,
                    isDefault: profile.addresses.isEmpty,
                  );
                  if (index != null) {
                    await profile.updateAddress(index, addr);
                  } else {
                    await profile.addAddress(addr);
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
