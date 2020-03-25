import './ticket.dart';

class Record {
  final Ticket ticket;
  String name;
  bool valid = false;

  void setName (String name) {
    this.name = name;

    var names = name.trim().split(" ");

    if (names.length > 1) {
      var first = names.elementAt(0);
      var last = names.elementAt(1);
      if (first.length > 1 && last.length > 1) {
        this.valid = true;
      }
    }
  }

  bool willCall;
  Record(this.ticket);
}

class Contract {
  final List<Record> records;
  Contract(this.records);

  bool valid () {
    List<Record> validRecords = records.where((record) {
      return record.valid;
    }).toList();
    print("records ${records.length} == valid ${validRecords.length} = ${records.length == validRecords.length}");
    return records.length == validRecords.length;
  }
}