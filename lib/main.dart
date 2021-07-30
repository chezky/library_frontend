import 'package:flutter/material.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:library_frontend/app.dart';
import 'package:library_frontend/models/books_scanned.dart';
import 'package:provider/provider.dart';

import 'models/book_list.dart';


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalConfiguration().loadFromAsset("config.json");
  
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => BookList()),
      ChangeNotifierProvider(create: (context) => BooksScanned()),
    ],
    child: Library(),
  ));
}