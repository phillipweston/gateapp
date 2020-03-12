// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_shopper/models/user.dart';


class AllUsers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserModel>(
      create: (context) => UserModel(),
      child: Consumer<UserModel>(
        builder: (context, users, child) {
          if (users.getByPosition(0) == null) {
            return Container();
          }
          else {
            return Scaffold(
              body: CustomScrollView(
                slivers: [
                 _MyAppBar(),
                  SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _MyListItem(users.getByPosition(index))
                    ),
                  ),
                ],
              ),
            );
          }
        }
    )
    );
  }
}

class _MyAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      title: Text('Guests', style: Theme.of(context).textTheme.display2),
      floating: true,
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ],
    );
  }
}

class _MyListItem extends StatelessWidget {
  final User user;

  _MyListItem(this.user, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme.title;

    return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: LimitedBox(
                maxHeight: 48,
                child: Row(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
          //                color: user.color,
                      ),
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      child: Text(user.name, style: textTheme),
                    ),
                    SizedBox(width: 24)
          //            _AddButton(user: user),
                  ],
                )
          )
    );
  }
}
