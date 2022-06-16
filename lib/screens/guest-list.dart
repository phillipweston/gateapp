// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:fnf_guest_list/blocs/navigator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fnf_guest_list/models/guest.dart';
import 'package:fnf_guest_list/screens/guest-details.dart';
import 'package:fnf_guest_list/blocs/guest.dart';

import '../common/theme.dart';

var searchController = new TextEditingController();

void _fetchGuests (BuildContext context) {
  final guestBloc = BlocProvider.of<GuestListBloc>(context);
  guestBloc.add(GetGuests());
}

void _filterGuests (BuildContext context, String search) {
  final guestBloc = BlocProvider.of<GuestListBloc>(context);
  guestBloc.add(FilterGuests(search));
}

var guestRepository = GuestRepository();

class GuestList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
        return BlocConsumer<GuestListBloc, GuestState>(
            listener: (context, state) {
              if (state is GuestsInitial) {
                _fetchGuests(context);
              }
            },
            builder: (context, state) {
              return Scaffold(
                body: CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                                onPressed: () {
                                  // Navigate to the second screen using a named route.
                                  Navigator.pushNamed(context, '/audit');
                                },
                                icon: Icon(
                                  Icons.settings,
                                  color: Colors.white,
                                  size: 30.0,
                                  semanticLabel: 'Look at the audit list',
                                ),
                              ),
                              Center(
                                child: GestureDetector(
                                    onTap: () {
                                      searchController.value = TextEditingValue(
                                          text: "");
                                      _fetchGuests(context);
                                    },
                                    child: Row(children: <Widget>[
                                      SvgPicture.asset('assets/gearhead-heart.svg',
                                          color: Colors.white,
                                          height: 60,
                                          width: 60,
                                          semanticsLabel: 'A heart with gearheads'),
                                      Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 0),
                                          child: Text('FnF Guest List',
                                              style: Theme
                                                  .of(context)
                                                  .textTheme
                                                  .headline6))
                                    ])
                                )
                              )
                            ],
                        )]),
                        floating: true,
                        actions: [
                          IconButton(
                              icon: Icon(Icons.refresh),
                              onPressed: () {
                                searchController.value = TextEditingValue(
                                    text: "");
                                _fetchGuests(context);
                              },
                              color: Colors.white
                          )
                        ]
                    ),
                    SliverAppBar(
                        backgroundColor: Theme
                            .of(context)
                            .dialogBackgroundColor,
                        elevation: 0.0,
                        automaticallyImplyLeading: false,
                        pinned: true,
                        floating: false,
                        title: SizedBox(
                            height: 80,
                            child: SearchInputField()
                        ),
                      actions: [
                        Text("hi")
                      ]
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 12)),
                    BlocBuilder<GuestListBloc, GuestState>(
                      builder: (context, state) {
                        if (state is GuestsInitial) {
                          return buildLoading();
                        } else if (state is GuestsLoading) {
                          return buildLoading();
                        } else if (state is GuestsLoaded) {
                          return buildGuestList(context, state.guests);
                        } else if (state is NoGuestsMatchSearch) {
                          return buildNoGuests();
                        } else if (state is GuestsError) {
                          return buildError();
                        }
                        return Container();
                      },
                    ),
                  ],
                ),
              );
            }
          );
    }
}

class SearchInputField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: TextField(
        textAlign: TextAlign.left,

        onChanged: (value) => _filterGuests(context, value),
        controller: searchController,
        style: Theme.of(context).textTheme.caption,
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          suffixIcon: Icon(Icons.search),
          hintStyle: TextStyle(),
          labelText:'Search by guest name',
//          hintText: 'Search by name, email, or phone (possibly)',
        ),
      ),
    );
  }
}

SliverToBoxAdapter buildInitial() {
  return SliverToBoxAdapter(
      child: Center(
    child: Text("buildInitial state"),
  ));
}

SliverToBoxAdapter buildLoading() {
  return SliverToBoxAdapter(
      child: Center(
    child: CircularProgressIndicator(),
  ));
}

SliverToBoxAdapter buildError() {
  return SliverToBoxAdapter(
      child: Center(
    child: Text("Error in Guest bloc"),
  ));
}

SliverToBoxAdapter buildNoGuests() {
  return SliverToBoxAdapter(
      child: Center(
        child: Text("No guests match this search."),
      ));
}

AnimationLimiter buildGuestList(BuildContext context, List<Guest> guests) {
  return AnimationLimiter(
    child: SliverFixedExtentList(
      itemExtent: 80.0,
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        if (index > guests.length - 1) return null;

        return AnimationConfiguration.staggeredList(
          position: index,
          duration: const Duration(milliseconds: 175),
          child: SlideAnimation(
//            verticalOffset: -50.0,
            horizontalOffset: -30.0,

            child: FadeInAnimation(
              child: Container(
                  alignment: Alignment.center,
                  child: Column(
                      children: <Widget>[
                        GuestListRow(guests[index]),
                        Divider()
                      ]
                  )
              )
            ),
          ),
        );
      })
    )
  );
}

class GuestListRow extends StatelessWidget {
  final Guest guest;

  GuestListRow(this.guest, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: GestureDetector(
            onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (context) => GuestDetails(guest: guest),
                  ),
                ),
            child: LimitedBox(
                maxHeight: 48,
                child: Row(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                          //                color: guest.color,
                          ),
                    ),
                    SizedBox(width: 24),
                    Expanded(
                      child: Text(guest.name,
                          style: Theme.of(context).textTheme.headline1),
                    ),
                    SizedBox(width: 24),
                    Row(
                      children: guest.tickets
                          .map((ticket) => 
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                              child: SvgPicture.asset(
                                'assets/gearhead-pink.svg',
                                height: 40,
                                width: 40,
                                semanticsLabel: 'An FnF Ticket')
                            )
                          ).toList())
                  ],
                ))));
  }
}
