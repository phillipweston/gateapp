import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../blocs/ticket-list-bloc.dart';
import '../../common/theme.dart';
import '../../models/guest.dart';
import '../ticket-list.dart';
import 'package:fnf_guest_list/blocs/ticket-events.dart' as TicketEvents;
import 'package:safe_device/safe_device.dart';

class NewTicketModal extends StatefulWidget {
  @override
  _NewTicketModalState createState() => _NewTicketModalState();
}

class _NewTicketModalState extends State<NewTicketModal> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  bool get isPopulated =>
      photoIdFile != null &&
      nameController.text.isNotEmpty &&
      emailController.text.isNotEmpty &&
      phoneController.text.isNotEmpty;

  File? photoIdFile;

  Future<void> _openFileExplorer() async {
    final picker = ImagePicker();
    // ignore: deprecated_member_use
    // bool isRealDevice = await SafeDevice.isRealDevice;

    XFile? pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      setState(() {
        photoIdFile = file;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Container(
          color: superPink,
          width: double.infinity,
          height: 170,
          child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(children: [
                SvgPicture.asset('assets/gearhead-heart.svg',
                    color: Colors.white,
                    height: 100,
                    width: 100,
                    semanticsLabel: 'A heart with gearheads'),
                Text('1 Friends and Family Ticket',
                    style: TextStyle(fontSize: 20, fontFamily: 'Roboto')),
              ]))),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: nameController,
            style: TextStyle(
                color: Colors.black, fontFamily: 'Roboto', fontSize: 20),
            decoration: InputDecoration(
                labelText: 'Full Name',
                labelStyle: TextStyle(
                    color: Colors.black, fontFamily: 'Roboto', fontSize: 20)),
          ),
          SizedBox(height: 16),
          TextField(
            style: TextStyle(
                color: Colors.black, fontFamily: 'Roboto', fontSize: 20),
            controller: emailController,
            decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(
                    color: Colors.black, fontFamily: 'Roboto', fontSize: 20)),
          ),
          TextField(
            style: TextStyle(
                color: Colors.black, fontFamily: 'Roboto', fontSize: 20),
            controller: phoneController,
            decoration: InputDecoration(
                labelText: 'Phone',
                labelStyle: TextStyle(
                    color: Colors.black, fontFamily: 'Roboto', fontSize: 20)),
          ),
          SizedBox(height: 16),
          MaterialButton(
              color: superPink,
              onPressed: _openFileExplorer,
              child: Text("Snap photo of their ID last to enable Create",
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto',
                      fontSize: 16))),
          Container(
            width: 800,
            child: GestureDetector(
              onTap: _openFileExplorer,
              child: Container(
                height: 300,
                width: 300,
                color: Colors.grey,
                child: photoIdFile != null
                    ? Image.file(photoIdFile!, fit: BoxFit.cover)
                    : Icon(Icons.camera_alt, color: Colors.white),
              ),
            ),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        MaterialButton(
          color: superPink,
          disabledColor: Colors.grey,
          onPressed: !isPopulated
              ? null
              : () async {
                  String name = nameController.text;
                  String email = emailController.text;
                  String phone = phoneController.text;

                  Guest guest = await createUserAndTicket(name, email, phone);
                  await uploadPhotos([photoIdFile!.path], guest.userId);

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Ticket created for $name!",
                          style: TextStyle(color: Colors.white, fontSize: 24)),
                    ),
                  );
                  final _ticketsBloc = BlocProvider.of<TicketListBloc>(context);

                  await Future<void>.delayed(const Duration(milliseconds: 100));
                  _ticketsBloc.add(TicketEvents.GetTickets());
                },
          child: Text('Create', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

Future<Guest> createUserAndTicket(
    String name, String email, String phone) async {
  final prefs = await SharedPreferences.getInstance();
  String? host = prefs.getString('host');

  var user = await Dio().post<Map<String, dynamic>>('$host/tickets',
      data: {'name': name, 'email': email, 'phone': phone});
  var guest = Guest.fromJson(user.data as Map<String, dynamic>);
  return guest;
}

Future<dynamic> uploadPhotos(List<String> paths, int userId) async {
  final prefs = await SharedPreferences.getInstance();
  String? host = prefs.getString('host');

  List<MultipartFile> files = [];
  for (var path in paths) {
    files.add(await MultipartFile.fromFile(path));
  }

  Map<String, List<MultipartFile>> map = {
    'files': files,
  };

  FormData formData = FormData.fromMap(map);

  var response = await Dio().post<Map<String, dynamic>>(
      '$host/tickets/upload/$userId',
      data: formData);
  return response.data;
}
