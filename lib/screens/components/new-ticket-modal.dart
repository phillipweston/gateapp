import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
    PickedFile? pickedFile = await picker.getImage(source: ImageSource.camera);

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
      title: Text('Fill out the details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          SizedBox(height: 16),
          TextField(
            controller: emailController,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          SizedBox(height: 16),
          GestureDetector(
            onTap: _openFileExplorer,
            child: Container(
              height: 100,
              width: 100,
              color: Colors.grey,
              child: photoIdFile != null
                  ? Image.file(photoIdFile!, fit: BoxFit.cover)
                  : Icon(Icons.upload),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Access the entered values
            String name = nameController.text;
            String email = emailController.text;
            // Perform further processing or save the data
            // ...

            Navigator.of(context).pop();
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
