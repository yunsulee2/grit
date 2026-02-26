import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/fund_detail_screen.dart';
import 'screens/payment_complete_screen.dart';
import 'screens/login_screen.dart';
import 'screens/seller_dashboard_screen.dart';
import 'screens/seller_fund_form_screen.dart';
import 'screens/seller_apply_screen.dart';
import 'app_shell.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GRIT',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final name = settings.name ?? '/';

        final completeMatch =
            RegExp(r'^/fund/([^/]+)/complete$').firstMatch(name);
        if (completeMatch != null) {
          final fundId = completeMatch.group(1)!;
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => PaymentCompleteScreen(fundId: fundId),
          );
        }

        final fundMatch = RegExp(r'^/fund/([^/]+)$').firstMatch(name);
        if (fundMatch != null) {
          final fundId = fundMatch.group(1)!;
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => FundDetailScreen(fundId: fundId),
          );
        }

        switch (name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const AppShell());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/seller':
            return MaterialPageRoute(
                builder: (_) => const SellerDashboardScreen());
          case '/seller/fund/new':
            return MaterialPageRoute(
                builder: (_) => const SellerFundFormScreen());
          case '/seller/apply':
            return MaterialPageRoute(
                builder: (_) => const SellerApplyScreen());
          default:
            return MaterialPageRoute(builder: (_) => const AppShell());
        }
      },
    );
  }
}
