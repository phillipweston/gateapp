// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider_shopper/models/user.dart';
import 'package:flutter_svg/flutter_svg.dart';

final String gearheadHeart = 'assets/gearhead-heart.svg';

class GuestList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<UserModel>(
      create: (context) => UserModel(),
      child: Consumer<UserModel>(
        builder: (context, users, child) {
            return Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    title: Center(
                      child: Row(
                        children: <Widget>[
                          SvgPicture.asset(
                              gearheadHeart,
                              color: Colors.white,
                              height: 60,
                              width: 60,
                              semanticsLabel: 'A heart with gearheads'
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            child: Text('FnF Guest List', style: Theme.of(context).textTheme.title)
                          )
                        ]
                      )
                    ),
                    floating: true,
                    actions: [

                      IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () => users.fetchUsers()
                      )
                    ],
                  ),
                  SliverAppBar(
                    backgroundColor: Theme.of(context).dialogBackgroundColor,
                    elevation: 0.0,
                    automaticallyImplyLeading: false,
                    pinned: true,
                    floating: false,
                    title: TextField(

                      onChanged: (value) => users.filterUsers(value),
                      style: Theme.of(context).textTheme.caption,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8.0))),
                        suffixIcon: Icon(Icons.search),
                        hintText: 'Search by name, email, or phone (possibly)',
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 12)),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (users.size() == -1 && index == 0) return Center(child: CircularProgressIndicator());
                        if (index > users.size()) return null;
                        return _MyListItem(users.getByPosition(index));
                      }
                    )
                  ),
                ],
              ),
            );
          }
      )
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
                      child: Text(user.name, style: Theme.of(context).textTheme.display2),
                    ),
                    SizedBox(width: 24)
          //            _AddButton(user: user),
                  ],
                )
          )
    );
  }
}
