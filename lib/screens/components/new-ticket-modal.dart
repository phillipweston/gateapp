import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

import '../../common/theme.dart';
import '../../models/guest.dart';

class NewTicketModal extends StatefulWidget {
  @override
  _NewTicketModalState createState() => _NewTicketModalState();
}

class _NewTicketModalState extends State<NewTicketModal> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  File? photoIdFile;

  Future<void> _openFileExplorer() async {
    final picker = ImagePicker();
    // ignore: deprecated_member_use
    PickedFile? pickedFile = await picker.getImage(source: ImageSource.gallery);

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
                Text('New Ticket Holder Details',
                    style: TextStyle(fontSize: 20, fontFamily: 'Roboto')),
                SvgPicture.asset('assets/gearhead-heart.svg',
                    color: Colors.white,
                    height: 100,
                    width: 100,
                    semanticsLabel: 'A heart with gearheads'),
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
          SizedBox(height: 16),
          MaterialButton(
              color: superPink,
              onPressed: _openFileExplorer,
              child: Text("Snap photo of their ID",
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
          onPressed: () async {
            String name = nameController.text;
            String email = emailController.text;

            Guest guest = await createUserAndTicket(name, email);
            await uploadPhotos([photoIdFile!.path], guest.userId);

            Navigator.of(context).pop();
          },
          child: Text('Create', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

Future<Guest> createUserAndTicket(String name, String email) async {
  var user = await Dio()
      .post<Map<String, dynamic>>('http://localhost:7777/tickets', data: {
    'name': name,
    'email': email,
  });
  var guest = Guest.fromJson(user.data as Map<String, dynamic>);
  return guest;
}

Future<dynamic> uploadPhotos(List<String> paths, int userId) async {
  List<MultipartFile> files = [];
  for (var path in paths) {
    files.add(await MultipartFile.fromFile(path));
  }

  Map<String, List<MultipartFile>> map = {
    'files': files,
  };

  FormData formData = FormData.fromMap(map);

  var response = await Dio().post<Map<String, dynamic>>(
      'http://127.0.0.1:7777/tickets/upload/${userId}',
      data: formData);
  print('\n\n');
  print('RESPONSE WITH DIO');
  print(response.data);
  print('\n\n');
  return response.data;
}
