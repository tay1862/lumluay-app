import 'package:shadcn_flutter/shadcn_flutter.dart';

class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.badge, size: 64),
          SizedBox(height: 16),
          Text(
            'Employee Management',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('Phase 6 — Coming soon'),
        ],
      ),
    );
  }
}
