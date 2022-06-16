import 'package:fnf_guest_list/models/ticket.dart';

class Record {
  final Ticket ticket;
  String name;
  bool valid = false;
  bool shoudRedeem = false;
  bool waiverReady = false;
  bool healthReady = false;

  Map<String, dynamic> toJson() {
    return <String,dynamic>{
       "name" : name, 
       "ticket_id" : ticket.ticketId
    };
  }

  void setName (String name) {
    this.name = name;
    this.valid = false;

    var names = name.trim().split(" ");
    if (names.length == 2) {
      var first = names.elementAt(0);
      var last = names.elementAt(1);
      this.valid = (first.length > 1 && last.length > 1);
    }
    else if (names.length == 3) {
      var first = names.elementAt(0);
      var middle = names.elementAt(1);
      var last = names.elementAt(2);
      this.valid = (first.length > 1 && last.length > 1);
    }
    else if (names.length > 3) {
      this.valid = true;
    }
  }

  void setShouldRedeem(bool shouldRedeem) {
    this.shoudRedeem = shouldRedeem;
  }

  bool willCall;
  Record(this.ticket);
}