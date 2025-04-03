import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart' as ffi_web;
import 'bloc/employee_cubit.dart';
import 'services/db_helper.dart';
import 'screens/employee_list_screen.dart';
import 'screens/add_employee_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // Instead of calling sqfliteFfiWebInit(), assign the web factory.
    databaseFactory = ffi_web.databaseFactoryFfiWeb;
  }
  runApp(
    BlocProvider(
      create: (_) => EmployeeCubit(DBHelper())..fetchEmployees(),
      child: const EmployeeApp(),
    ),
  );
}

class EmployeeApp extends StatelessWidget {
  const EmployeeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF1DA1F2),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const EmployeeListScreen(),
        '/add': (context) => const AddEmployeeScreen(),
      },
    );
  }
}
