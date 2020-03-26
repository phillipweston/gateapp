// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';


Map<int, Color> color =
{
  50:Color.fromRGBO(243,2,211, .1),
  100:Color.fromRGBO(243,2,211, .2),
  200:Color.fromRGBO(243,2,211, .3),
  300:Color.fromRGBO(243,2,211, .4),
  400:Color.fromRGBO(243,2,211, .5),
  500:Color.fromRGBO(243,2,211, .6),
  600:Color.fromRGBO(243,2,211, .7),
  700:Color.fromRGBO(243,2,211, .8),
  800:Color.fromRGBO(243,2,211, .9),
  900:Color.fromRGBO(243,2,211, 1),
};

MaterialColor superPink = MaterialColor(0xFFf302d3, color);


final appTheme = ThemeData(
  primarySwatch: superPink,
  textTheme: TextTheme(
    display3: TextStyle(
        fontFamily: '',
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: Colors.white
    ),
    display4: TextStyle(
      fontFamily: '',
      fontWeight: FontWeight.w700,
      fontSize: 20,
      color: Colors.black
    ),
    display2: TextStyle(
        fontFamily: '',
        fontWeight: FontWeight.w400,
        fontSize: 18,
        color: Colors.black
    ),
    caption: TextStyle(
        fontFamily: '',
        fontWeight: FontWeight.w400,
        fontSize: 18,
        color: Colors.black
    ),
    button: TextStyle(
        fontFamily: 'RedRock',
        fontWeight: FontWeight.w700,
        fontSize: 28,
        color: Colors.white
    ),
    title: TextStyle(
      fontFamily: 'RedRock',
      fontWeight: FontWeight.w700,
      fontSize: 40,
      color: Colors.white
    ),
    subhead: TextStyle(
      fontFamily: 'RedRock',
      fontWeight: FontWeight.w700,
      fontSize: 40,
      color: superPink
    )
  )
);
