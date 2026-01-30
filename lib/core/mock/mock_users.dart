// Local mock users used for development and tests (no network calls).

final List<Map<String, dynamic>> mockUsers = [
  {
    'id': 'admin_1',
    'name': 'Admin User',
    'role': 'admin',
    'email': 'admin@example.com',
    'phone': '+1-555-0100',
    // Local-only password for development (no backend)
    'password': 'admin123'
  },
  {
    'id': 'family_1',
    'name': 'Family Member',
    'role': 'member',
    'email': 'member@example.com',
    'phone': '+1-555-0101',
    'password': 'member123'
  }
];
