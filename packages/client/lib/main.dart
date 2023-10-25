import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:client/WalletConnect.dart';
import 'package:client/TodoList.dart';
import 'package:client/TodoListModel.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TodoListModel(),
      child: MaterialApp(
        title: 'Flutter TODO',
        // home: TodoList(),
        home: WalletConnect(),
        routes: {
          '/todoList': (context) => const TodoList(),
        },
      ),
    );
  }
}
