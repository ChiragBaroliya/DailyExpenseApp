import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/pages/login_page.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/expense_provider.dart';
import 'features/expense/add_expense_page.dart';
import 'features/expense/expense_list_screen.dart';
import 'features/reports/reports_page.dart';
import 'features/family/family_management_page.dart';
import 'features/dashboard/dashboard_page.dart';

void main() {
  runApp(const DailyExpenseApp());
}

class DailyExpenseApp extends StatelessWidget {
  const DailyExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: MaterialApp(
        title: 'Daily Expense App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        ),
        // Named routes
        initialRoute: '/',
        routes: {
          '/': (_) => const LoginPage(),
          '/dashboard': (_) => const DashboardPage(),
          '/add_expense': (_) => const AddExpensePage(),
          '/expenses': (_) => const ExpenseListScreen(),
          '/reports': (_) => const ReportsPage(),
          '/family': (_) => const FamilyManagementPage(),
        },
      ),
    );
  }
}
