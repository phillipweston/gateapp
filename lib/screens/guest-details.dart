// Copyright 2019 The Flutter team. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: close_sinks

import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import 'package:fnf_guest_list/models/assigned-ticket.dart';
import 'package:fnf_guest_list/models/guest.dart';
import 'package:fnf_guest_list/blocs/guest.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fnf_guest_list/common/theme.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fnf_guest_list/models/record.dart';
import 'package:fnf_guest_list/models/ticket.dart';
import '../models/contract.dart';
import 'package:fnf_guest_list/string-constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void _fetchGuest (BuildContext context, int userId) {
  final _bloc = BlocProvider.of<GuestDetailsBloc>(context);
  _bloc.add(GetGuest(userId));
}

Future<List<Guest>> _filterGuestsByName (BuildContext context, String search) {
  final _bloc = BlocProvider.of<GuestDetailsBloc>(context);
  return _bloc.guestRepository.filterGuestsByName(search);
}

class GuestDetails extends StatefulWidget {
  final Guest guest;

  GuestDetails({Key key,  @required this.guest }) : super(key: key);

  @override
  _GuestDetailsState createState() => _GuestDetailsState(guest);
}

class _GuestDetailsState extends State<GuestDetails> {
  GuestRepository guestRepository;
  final Guest guest;

  _GuestDetailsState(this.guest);

  @override
  void didChangeDependencies() {
    final _bloc = BlocProvider.of<GuestDetailsBloc>(context);
    _bloc.add(GetGuest(guest.userId));
    super.didChangeDependencies();
  }

  @override
    Widget build(BuildContext context) {
        return BlocBuilder<GuestDetailsBloc, GuestState>(
          builder: (context, state) {
            final _bloc = BlocProvider.of<GuestDetailsBloc>(context);
            if(state is TransferSuccessful) {

              _bloc.add(GetGuest(state.owner.userId));
            }
            else if(state is TicketRedeemed) {
              _bloc.add(GetGuest(state.ticket.userId));
            }
            var guestName = guest.name ?? "";
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
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                    child: Text(guestName, style: appTheme.textTheme.button)
                                  )
                                ),
                                 SvgPicture.asset('assets/gearhead-heart.svg',
                                    color: Colors.white,
                                    height: 60,
                                    width: 60,
                                    semanticsLabel: 'A heart with gearheads')
                            ]
                          )
                        ]
                      ),
                      floating: true,
                      actions: [
                        IconButton(
                            icon: Icon(Icons.refresh),
                            onPressed: () => _fetchGuest(context, guest.userId),
                            color: Colors.white
                        )
                      ],
                    ),
                    (state is GuestLoaded || state is TicketReadyToRedeem) ? mustAssignTicketsText() : SliverToBoxAdapter(child: SizedBox(height: 30)),
                    BlocBuilder<GuestDetailsBloc, GuestState>(
                      builder: (context, state) {
                        if (state is GuestLoaded) {
                          return buildGuestTickets(context, state.guest);
                        }
                        else if (state is TicketReadyToRedeem) {
                          return buildGuestTickets(context, state.guest);
                        }
                        else if (state is GuestsError) {
                          return buildError();
                        }
                        else {
                          return buildLoading();
                        }
                      },
                    ),
                  ]
                ),
                bottomNavigationBar: BlocBuilder<GuestDetailsBloc, GuestState>(
                  builder: (context, state) {
                    if (state is TicketReadyToRedeem) {
                      return buildCheckInButton(context, state.ticket, state.guest);
                    }
                    else {
                      return buildDisabledButton();
                    }
                  }
                )
              );
          }
        );
  }
}


MaterialButton buildDisabledButton () {
  return MaterialButton(
          onPressed: null,
          height: 80,
          disabledColor: Colors.black12,
          textColor: Colors.white,
          child: Text('Confirm Tickets', style: appTheme.textTheme.button)
  );
}

MaterialButton buildCheckInButton (BuildContext context, Ticket ticket, Guest guest) {
  final _bloc = BlocProvider.of<GuestDetailsBloc>(context);
  final bool waiver = guest.waiver != null;
  return MaterialButton(
      onPressed: () async {
        if(!waiver) {
          return showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              scrollable: true,
              title: Text(
                Strings.WaiverTitle,
                textAlign: TextAlign.left,
                style: appTheme.textTheme.headline2,
              ),
              content: Text(
                Strings.WaiverComplete,
                textAlign: TextAlign.left,
                style: appTheme.textTheme.headline1,
              ),
              actions: [
                Row(
                  mainAxisAlignment:MainAxisAlignment.center,
                  children: [
                    Text(
                      guest.name, 
                      style: appTheme.textTheme.headline2,
                    ),
                    Checkbox(
                      value: waiver,
                      activeColor: Color.fromRGBO(243,2,211, 1),
                      onChanged: (bool value) async {
                        final _bloc = BlocProvider.of<GuestDetailsBloc>(context);
                        _bloc.add(SignWaiver(guest, ticket, value));
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      "(Agree and Redeem Ticket)", 
                      style: appTheme.textTheme.headline1,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            );          
          });
        }
        else {
          _bloc.add(RedeemTicket(ticket));
        }
      },
      height: 80,
      color: superPink,
      disabledColor: Colors.black12,
      textColor: Colors.white,
      child: Text('Click here to continue', style: appTheme.textTheme.button)
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
        child: Text("Error in Guest bloc"),
      ));
}

AnimationLimiter buildGuestTickets (BuildContext context, Guest guest) {
  return AnimationLimiter(

      child: SliverFixedExtentList(
        itemExtent: 80.0,
        delegate: SliverChildBuilderDelegate((BuildContext context, int index) {

          if (index > guest.tickets.length - 1) return SizedBox(height: 0);

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 120),
            child: SlideAnimation(
              horizontalOffset: -10.0,
              verticalOffset: 0.0,
              child: FadeInAnimation(
                child: Container(
                    alignment: Alignment.center,
                    child: Column(
                        children: <Widget>[
                          TicketListRow(guest, index),
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

SliverToBoxAdapter buildTransferSuccess (BuildContext context, List<AssignedTicket> tickets) {

  return SliverToBoxAdapter(
    child: Container(
      height: 700,
      width: 400,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: 2),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                    child: SvgPicture.asset(
                        'assets/gearhead-pink.svg',
                        height: 300,
                        width: 300,
                        semanticsLabel: 'An FnF Ticket'
                    ),
                )
              ]
          ),
          Padding(
              padding: const EdgeInsets.all(8),
              child: Text("Success!", style: appTheme.textTheme.subtitle1)
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,

              children: <Widget>[

                ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 30.0,
                    maxHeight: 800.0,
                    minWidth: 30.0,
                    maxWidth: 300.0
                  ),
                  child: ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      itemCount: tickets.length,
                      itemExtent: 36.0,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          height: 35,
                          width: 300,
                          child: Center(child: Text('Ticket ${tickets[index].ticketId} => ${tickets[index].owner.name}')),
                        );
                      }
                  )
                )
              ]
          ),
        ]
      )
    )
  );
}

SliverToBoxAdapter mustAssignTicketsText () {
  return SliverToBoxAdapter(
      child: Container(
          height: 80,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center,
                    crossAxisAlignment: CrossAxisAlignment
                        .center,
                    children: <Widget>[
                      Container(
                        width: 150,
                        child: TextButton(
                          child: Text("Purchaser", style: TextStyle(color: Colors.black)) 
                        )
                      ),
                      Container(
                        width: 250,
                        child: TextButton(
                          child: Text("Name", style: TextStyle(color: Colors.black)) 
                        )
                      ),
                      Container(
                        width: 100,
                        child: TextButton(
                          child: Text("Arrived", style: TextStyle(color: Colors.black)) 
                        )
                      ),
                    ]
                )
              ]
          )
      )
  );
}

class TicketListItem extends StatelessWidget {
  
  final Guest owner;
  final int index;

  TicketListItem(this.owner, this.index, {Key key}) : super(key: key);
  Widget build(BuildContext context) {
  
  }
}

class TicketListRow extends StatelessWidget {
  final Guest owner;
  final int index;

  TicketListRow(this.owner, this.index, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
      
      Record record = owner.contract.records.elementAt(index);
      final String ticketLabel = "${owner.firstName()}'s ticket (#$index)";
      final String ticketName = record.ticket.redeemed ? owner.name : record.name ?? "Assign Ticket";
      final bool canReassign = owner.name != record.name;
      final GuestDetailsBloc bloc = BlocProvider.of<GuestDetailsBloc>(context);
      return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center, 
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[  
                  Container(
                    width: 150,
                    child: Text(owner.name)
                  ), 
                  Container(
                    width: 250,
                    child: TextButton(
                        child: Center(
                          child: Text(
                            ticketName, 
                            style: ticketName != "Assign Ticket" ? appTheme.textTheme.headline2 : appTheme.textTheme.headline1,
                            textAlign: TextAlign.center,)
                          ),
                        onPressed: () async {
                          if(canReassign) {
                            await showDialog<ReassignModal>(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return ReassignModal(
                                owner: owner,
                                record: record,
                                inputDecoration: ticketLabel
                              );
                            },
                            );
                          } 
                        },
                      )
                  ),
                  Container(
                    width: 100,
                    child: Switch(
                    value: record.shoudRedeem || record.ticket.redeemed,
                    activeColor: record.ticket.redeemed ? Colors.grey : Color.fromRGBO(243,2,211, 1),
                    onChanged: (bool value) async {
                      if(record.valid) {
                        final _bloc = BlocProvider.of<GuestDetailsBloc>(context);
                        _bloc.add(PrepareToRedeem(owner, owner.tickets[index], value));
                      }
                    },
                  ),
                  ), 
                  ]
                )
              ]
          );
  }
}


class ReassignModal extends StatefulWidget {
  const ReassignModal({Key key, this.owner, this.record, this.inputDecoration
});
  final Guest owner;
  final Record record;
  final String inputDecoration;

  @override
  _ReassignModalState createState() => _ReassignModalState();
}

class _ReassignModalState extends State<ReassignModal> {
  final textFieldController = TextEditingController();

  Widget build(BuildContext context) {
    return Dialog(
      // backgroundColor: Color(0XFF232426),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        width: 300,
        height: 150,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child:TypeAheadField(
                hideOnEmpty: true,
                textFieldConfiguration: TextFieldConfiguration<Guest>(
                    controller: textFieldController,
                    style: appTheme.textTheme.headline1,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: widget.inputDecoration,
                    )
                ),
                suggestionsCallback: (search) async {
                  return _filterGuestsByName(context, search);
                },
                itemBuilder: (context,
                    Guest guest) {
                      return ListTile(
                      title: Text(guest.name,
                          style: appTheme.textTheme
                              .headline3)
                    );
                },
                onSuggestionSelected: (Guest guest) {
                    widget.record.setName(guest.name);
                    textFieldController.text = guest.name;
                },
              ),
            ),
            Container(
              width: 150,
              child: 
              TextButton(
                child: Text("Transfer", style: TextStyle(color: Colors.black)),
                onPressed: () async {
                  widget.record.setName(textFieldController.text);
                  if(widget.record.valid) {
                      final _bloc = BlocProvider.of<GuestDetailsBloc>(context);
                      final List<Record> records = <Record>[widget.record];
                      _bloc.add(TransferTicket(widget.owner, widget.record));
                    Navigator.pop(context);
                  } 
                },
              )
            ),
      
          ],
        ) 
        
      )
    );
  }
}