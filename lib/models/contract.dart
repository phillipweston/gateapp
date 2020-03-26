import 'package:fnf_guest_list/models/record.dart';

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