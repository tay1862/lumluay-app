import 'package:shadcn_flutter/shadcn_flutter.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people, size: 64),
          SizedBox(height: 16),
          Text(
            'Customers & Loyalty',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Phase 5 — Coming soon'),
        ],
      ),
    );
  }
}
