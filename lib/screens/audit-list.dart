// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fnf_guest_list/blocs/audit.dart';
import 'package:fnf_guest_list/models/audit.dart';

var searchController = new TextEditingController();

void _fetchAudits (BuildContext context) {
  final auditBloc = BlocProvider.of<AuditListBloc>(context);
  auditBloc.add(GetAudits());
}

void _filterAudits (BuildContext context, String search) {
  final auditBloc = BlocProvider.of<AuditListBloc>(context);
  auditBloc.add(FilterAudits(search));
}

var auditRepository = AuditRepository();

class AuditList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuditListBloc, AuditState>(
        listener: (context, state) {
          if (state is AuditsInitial) {
            _fetchAudits(context);
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
                              Center(
                                  child: GestureDetector(
                                      onTap: () {
                                        searchController.value = TextEditingValue(
                                            text: "");
                                        _fetchAudits(context);
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
                                            child: Text('FnF Audit Log',
                                                style: Theme
                                                    .of(context)
                                                    .textTheme
                                                    .headline6))
                                      ])
                                  )
                              ),
                            ],
                          )]),
                    floating: true,
                    actions: [
                      IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () {
                            searchController.value = TextEditingValue(
                                text: "");
                            _fetchAudits(context);
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
                    )
                ),
                SliverToBoxAdapter(child: SizedBox(height: 12)),
//                    BlocListener<AuditBloc, AuditState>(
//                      listener: (context, state) {
//                        if (state is AuditsError) {
//                          return Scaffold.of(context).showSnackBar(
//                            SnackBar(
//                              content: Text(state.message),
//                            ),
//                          );
//                        }
//                      }
//                    ),
                BlocBuilder<AuditListBloc, AuditState>(
                  builder: (context, state) {
                    if (state is AuditsInitial) {
                      return buildLoading();
                    } else if (state is AuditsLoading) {
                      return buildLoading();
                    } else if (state is AuditsLoaded) {
                      return buildAuditList(context, state.audits);
                    } else if (state is NoAuditsMatchSearch) {
                      return buildNoAudits();
                    } else if (state is AuditsError) {
                      return buildError();
                    }
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

        onChanged: (value) => _filterAudits(context, value),
        controller: searchController,
        style: Theme.of(context).textTheme.caption,
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          suffixIcon: Icon(Icons.search),
          hintStyle: TextStyle(),
          labelText:'Search audit log',
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
        child: Text("Error in Audit bloc"),
      ));
}

SliverToBoxAdapter buildNoAudits() {
  return SliverToBoxAdapter(
      child: Center(
        child: Text("No audits match this search."),
      ));
}

AnimationLimiter buildAuditList(BuildContext context, List<Audit> audits) {
  return AnimationLimiter(
      child: SliverFixedExtentList(
          itemExtent: 80.0,
          delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
            if (index > audits.length - 1) return null;

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
                              AuditListRow(audits[index]),
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

class AuditListRow extends StatelessWidget {
  final Audit audit;

  AuditListRow(this.audit, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // child: GestureDetector(
        //     onTap: () => Navigator.push(
        //       context,
        //       MaterialPageRoute<void>(
        //         builder: (context) => AuditDetails(guest: guest),
        //       ),
        //     ),
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
                      child: Text(audit.action,
                          style: Theme.of(context).textTheme.headline1),
                    ),
                    SizedBox(width: 24),
                //     Row(
                //         children: guest.tickets
                //             .map((ticket) => new Padding(
                //             padding: const EdgeInsets.symmetric(
                //                 horizontal: 4, vertical: 8),
                //             child: SvgPicture.asset(
                //                 'assets/gearhead-pink.svg',
                //                 height: 40,
                //                 width: 40,
                //                 semanticsLabel: 'An FnF Ticket')))
                //             .toList())
                //   ],
                // )
            ])));
  }
}
