import './ticket.dart';

class Record {
  final Ticket ticket;
  String name;
  bool valid = false;

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

  bool willCall;
  Record(this.ticket);
}

class Contract {
  final List<Record> records;
  Contract(this.records);


  // method
  Map<String, dynamic> toJson() {
    var recordz = List<Map<String,dynamic>>();

    records.forEach((record) {
      var json = Map<String,dynamic>();
      json.addAll(<String,dynamic>{ "name" : record.name, "ticket_id" : record.ticket.ticketId });
      recordz.add(json);
    });

    var contract = Map<String,dynamic>();
    contract.addAll(<String,dynamic>{ "records" : recordz });
    return contract;
  }

  bool valid () {
    List<Record> validRecords = records.where((record) {
      return record.valid;
    }).toList();
    print("records ${records.length} == valid ${validRecords.length} = ${records.length == validRecords.length}");
    return records.length == validRecords.length;
  }
}