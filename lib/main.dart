import 'package:flutter/material.dart';
import 'package:lista_compras/ui/viewmodels/ListaCompraViewModel.dart';
import 'package:lista_compras/ui/views/TelaPrincipal.dart';
import 'package:provider/provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ListaCompraViewModel()),
      ],
      child: MaterialApp(
        title: 'Listas de Compras',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: TelaPrincipal(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}