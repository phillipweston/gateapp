// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fnf_guest_list/common/theme.dart';
import 'package:fnf_guest_list/models/cart.dart';
import 'package:fnf_guest_list/models/catalog.dart';
import 'package:fnf_guest_list/models/Guest.dart';
import 'package:fnf_guest_list/screens/cart.dart';
import 'package:fnf_guest_list/screens/GuestList.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // Using MultiProvider is convenient when providing multiple objects.
    return MultiProvider(
      providers: [
        // In this sample app, CatalogModel never changes, so a simple Provider
        // is sufficient.
        Provider(create: (context) => CatalogModel()),
        Provider(create: (context) => GuestModel()),

        // CartModel is implemented as a ChangeNotifier, which calls for the use
        // of ChangeNotifierProvider. Moreover, CartModel depends
        // on CatalogModel, so a ProxyProvider is needed.
        ChangeNotifierProxyProvider<CatalogModel, CartModel>(
          create: (context) => CartModel(),
          update: (context, catalog, cart) {
            cart.catalog = catalog;
            return cart;
          },
        ),
      ],
      child: MaterialApp(
        title: 'FNF GATE',
        theme: appTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => GuestList(),
//          '/guest': (context) => GuestDetails(gu),
//          '/cart': (context) => MyCart()
        },
      ),
    );
  }
}
