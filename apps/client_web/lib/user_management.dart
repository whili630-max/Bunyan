import 'package:flutter/material.dart';

class UserManagementPage extends StatelessWidget {
  const UserManagementPage({super.key});

  // بيانات وهمية للمستخدمين
  static final List<Map<String, String>> _users = List.generate(
    15,
    (index) => {
      'name': 'مستخدم رقم ${index + 1}',
      'email': 'user${index + 1}@example.com',
      'role': (index % 4 == 0)
          ? 'مدير'
          : (index % 3 == 0)
              ? 'مورد'
              : 'عميل',
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'),
        backgroundColor: Colors.purple,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          int crossAxisCount;
          double childAspectRatio;

          if (width > 1200) {
            crossAxisCount = 4;
            childAspectRatio = 2.8;
          } else if (width > 800) {
            crossAxisCount = 3;
            childAspectRatio = 2.6;
          } else if (width > 500) {
            crossAxisCount = 2;
            childAspectRatio = 2.5;
          } else {
            crossAxisCount = 1;
            childAspectRatio = 5.0;
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _users.length,
            itemBuilder: (context, index) {
              final user = _users[index];
              return Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.purple.shade100,
                        child: const Icon(Icons.person_outline,
                            color: Colors.purple),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              user['name']!,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              user['email']!,
                              style: TextStyle(
                                  color: Colors.grey[600], fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user['role']!,
                              style: const TextStyle(
                                color: Colors.purple,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert),
                        onPressed: () {
                          // TODO: Implement user actions (edit, delete, etc.)
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
