import 'package:shadcn_flutter/shadcn_flutter.dart';

class ShiftsScreen extends StatelessWidget {
  const ShiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time, size: 64),
          SizedBox(height: 16),
          Text(
            'Cash Management & Shifts',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Phase 7 — Coming soon'),
        ],
      ),
    );
  }
}
