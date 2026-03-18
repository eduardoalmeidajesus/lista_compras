import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:lista_compras/ui/viewmodels/ListaCompraViewModel.dart';
import 'package:lista_compras/ui/views/TelaPrincipal.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS)) {
    sqfliteFfiInit();
  }

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