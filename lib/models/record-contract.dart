import './ticket.dart';

class Record {
  final Ticket ticket;
  String name;
  bool valid = false;

  void setName (String name) {
    this.name = name;
    if (name.split(" ").length > 1) this.valid = true;
  }

  bool willCall;
  Record(this.ticket);
}

//class RecordModel with ChangeNotifier {
//  notifyListeners();
//
//  Record getByIndex(int index) {
//
//  }
//}

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