// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fnf_guest_list/blocs/audit.dart';
import 'package:fnf_guest_list/models/audit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/theme.dart';

var searchController = TextEditingController();

void _fetchAudits(BuildContext context) {
  final auditBloc = BlocProvider.of<AuditListBloc>(context);
  auditBloc.add(GetAudits());
}

void _filterAudits(BuildContext context, String search) {
  final auditBloc = BlocProvider.of<AuditListBloc>(context);
  auditBloc.add(FilterAudits(search));
}

var auditRepository = AuditRepository();

class AuditList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuditListBloc, AuditState>(listener: (context, state) {
      if (state is AuditsInitial) {
        _fetchAudits(context);
      }
    }, builder: (context, state) {
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
                                    searchController.value =
                                        TextEditingValue(text: "");
                                    _fetchAudits(context);
                                  },
                                  child: Row(children: <Widget>[
                                    SvgPicture.asset(
                                        'assets/gearhead-heart.svg',
                                        color: Colors.white,
                                        height: 60,
                                        width: 60,
                                        semanticsLabel:
                                            'A heart with gearheads'),
                                    Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 0),
                                        child: Text('FnF Audit Log',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline6))
                                  ]))),
                        ],
                      )
                    ]),
                floating: true,
                actions: [
                  buildApiHostButton(context),
                  IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () {
                        searchController.value = TextEditingValue(text: "");
                        _fetchAudits(context);
                      },
                      color: Colors.white)
                ]),
            SliverAppBar(
                backgroundColor: Theme.of(context).dialogBackgroundColor,
                elevation: 0.0,
                automaticallyImplyLeading: false,
                pinned: true,
                floating: false,
                title: SizedBox(height: 80, child: SearchInputField())),
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
                } else {
                  return buildInitial();
                }
              },
            ),
          ],
        ),
      );
    });
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
          labelText: 'Search audit log',
        ),
      ),
    );
  }
}

class ApiHostInputField extends StatelessWidget {
  String host;
  TextEditingController controller;
  ApiHostInputField(this.host, this.controller);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: TextField(
        textAlign: TextAlign.left,
        // onChanged: (value) => _filterAudits(context, value),
        controller: controller,
        style: Theme.of(context).textTheme.caption,
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(2.0))),
          hintStyle: TextStyle(),
          labelText: 'Host',
        ),
      ),
    );
  }
}

class ApiPasswordInputField extends StatelessWidget {
  TextEditingController password;
  ApiPasswordInputField(this.password);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: TextField(
        textAlign: TextAlign.left,
        // onChanged: (value) => _filterAudits(context, value),
        controller: password,
        style: Theme.of(context).textTheme.caption,
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(2.0))),
          hintStyle: TextStyle(),
          labelText: 'Password',
        ),
      ),
    );
  }
}

IconButton buildApiHostButton(BuildContext context) {
  final _bloc = BlocProvider.of<AuditListBloc>(context);
  return IconButton(
    icon: Icon(Icons.settings),
    onPressed: () async {
      final prefs = await SharedPreferences.getInstance();
      String? host = prefs.getString('host');
      TextEditingController controller = TextEditingController(text: host);
      TextEditingController password = TextEditingController();

      return showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return AlertDialog(
              scrollable: true,
              title: Text(
                "Set API Host",
                textAlign: TextAlign.left,
                style: appTheme.textTheme.headline2,
              ),
              content: Column(children: [
                ApiHostInputField(host!, controller),
                ApiPasswordInputField(password)
              ]),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialButton(
                      child: Text("Set Host"),
                      onPressed: () async {
                        if (password.text == 'callback') {
                          await prefs.setString('host', controller.text);
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ],
            );
          });
    },
  );
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
          itemExtent: 100,
          delegate:
              SliverChildBuilderDelegate((BuildContext context, int index) {
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
                        child: Column(children: <Widget>[
                          AuditListRow(
                            audits[index],
                            key: Key(audits[index].id.toString()),
                          ),
                          Divider()
                        ]))),
              ),
            );
          })));
}

class AuditListRow extends StatefulWidget {
  final Audit audit;

  AuditListRow(this.audit, {Key? key}) : super(key: key);

  @override
  State<AuditListRow> createState() => _AuditListRowState(this.audit);
}

class _AuditListRowState extends State<AuditListRow> {
  String? host;
  final Audit audit;

  _AuditListRowState(this.audit);

  Future<void> getHost() async {
    final prefs = await SharedPreferences.getInstance();
    String? h = prefs.getString('host');
    setState(() {
      host = h;
    });
  }

  @override
  void initState() {
    getHost();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (host == null) {
      return Container();
    }
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
        child: Column(children: [
          LimitedBox(
              maxHeight: 48,
              child: Row(children: [
                Text(
                    DateFormat('EEE, MMM dd, h:mm a')
                        .format(DateTime.parse(audit.created_at).toLocal()),
                    style: Theme.of(context).textTheme.headline1,
                    overflow: TextOverflow.ellipsis),
                // ),
              ])),
          LimitedBox(
            maxWidth: double.infinity,
            maxHeight: 48,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(audit.action,
                      style: Theme.of(context).textTheme.headline2,
                      overflow: TextOverflow.ellipsis),
                  SizedBox(width: 4),
                  SizedBox(width: 4),
                  Icon(
                    audit.action == 'transfer'
                        ? Icons.arrow_right
                        : Icons.person,
                    color: superPink,
                    size: audit.action == 'transfer' ? 30.0 : 30.0,
                    semanticLabel: 'Text to announce in accessibility modes',
                  ),
                  Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: audit.action == 'transfer'
                          ? Text(
                              audit.action == 'transfer'
                                  ? "${audit.from.name} -> ${audit.to.name}"
                                  : '',
                              style: Theme.of(context).textTheme.headline1,
                              overflow: TextOverflow.ellipsis)
                          : Text(
                              audit.action != 'transfer' ? audit.to.name : '',
                              style: Theme.of(context).textTheme.headline1,
                            )),
                  audit.action == 'create'
                      ? SizedBox(
                          width: 300,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Text(audit.to.email),
                                  SizedBox(width: 10),
                                  Text(audit.to.phone!)
                                ]),
                                SizedBox(height: 2),
                                Text(audit.to.reason!,
                                    overflow: TextOverflow.ellipsis)
                              ]))
                      : Container(),
                  audit.action == 'create'
                      ? HeroAnimation('$host/${audit.to.userId}.png',
                          audit.to.name, audit.to.reason)
                      : Container(),
                ]),
          ),
        ]));
  }
}

class PhotoHero extends StatelessWidget {
  const PhotoHero(
      {required Key key,
      required this.photo,
      required this.onTap,
      required this.width})
      : super(key: key);

  final String photo;
  final VoidCallback onTap;
  final double width;

  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Hero(
        tag: photo,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Image.network(
              photo,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class HeroAnimation extends StatelessWidget {
  String image;
  String name;
  String? reason;

  HeroAnimation(this.image, this.name, this.reason);

  Widget build(BuildContext context) {
    timeDilation = 2.0; // 1.0 means normal animation speed.

    return PhotoHero(
      photo: image,
      key: Key("${image}1"),
      width: 100.0,
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(name),
            ),
            body: Container(
                // The blue background emphasizes that it's a new route.
                color: Colors.white,
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.topLeft,
                child: Column(children: [
                  PhotoHero(
                    key: Key(image),
                    photo: image,
                    width: double.infinity,
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ])),
          );
        }));
      },
    );
  }
}
