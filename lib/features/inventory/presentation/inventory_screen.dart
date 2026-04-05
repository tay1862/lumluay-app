import 'package:shadcn_flutter/shadcn_flutter.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warehouse, size: 64),
          SizedBox(height: 16),
          Text(
            'Inventory Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Phase 4 — Coming soon'),
        ],
      ),
    );
  }
}
