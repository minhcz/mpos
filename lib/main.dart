import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/cart/cart_provider.dart';
import '../../database/app_database.dart';
import '../../database/daos/product_dao.dart';
import '../../database/daos/category_dao.dart';
import '../../ui/screens/login_screen.dart';
import '../../ui/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final db = AppDatabase();
  await db.userDao.ensureAdminUserExists(); // đảm bảo userDao có trong AppDatabase

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>(
          create: (_) => db,
          dispose: (_, db) => db.close(),
        ),
        Provider<ProductDao>(
          create: (context) => ProductDao(context.read<AppDatabase>()),
        ),
        Provider<CategoryDao>(
          create: (context) => CategoryDao(context.read<AppDatabase>()),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WePOS',
      theme: ThemeData(primarySwatch: Colors.indigo),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/home') {
          final user = settings.arguments;
          if (user != null && user is User) {
            return MaterialPageRoute(
              builder: (_) => HomeScreen(currentUser: user),
            );
          }
        }
        return null;
      },
    );
  }
}
