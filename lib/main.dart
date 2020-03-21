// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fnf_guest_list/common/theme.dart';
import 'package:fnf_guest_list/models/guest.dart';
import 'package:fnf_guest_list/screens/guest-list.dart';
import 'package:battery/battery.dart';
import 'package:fnf_guest_list/blocs/guest.dart';
import 'package:fnf_guest_list/blocs/navigator.dart' as navigator;
import 'package:flutter_bloc/flutter_bloc.dart';


void main() {
  runApp(MyApp());
}



class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey();


  @override
  Widget build(BuildContext context) {
    return BlocProvider<navigator.NavigatorBloc>(
      create: (BuildContext context) => navigator.NavigatorBloc(navigatorKey: _navigatorKey),
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: appTheme,
        title: 'FnF Guest List',
        home: GuestList()
      )
    );


//    return MultiProvider(
//      providers: [
//        Provider(create: (context) => GuestModel())
//      ],
//      child: MaterialApp(
//        title: 'FNF GATE',
//        debugShowCheckedModeBanner: false,
//        theme: appTheme,
//        initialRoute: '/',
//        routes: {
//          '/': (context) => GuestList(),
//        }
//      ),
//    );
  }
}
