// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_modular/flutter_modular.dart';
// import 'package:image_picker/image_picker.dart';

// class MyButton extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton(
//       onPressed: () {
//         Modular.showDialog(
//           builder: (_) => MyModal(),
//         );
//       },
//       child: Text('Open Modal'),
//     );
//   }
// }

// class MyModal extends StatefulWidget {
//   @override
//   _MyModalState createState() => _MyModalState();
// }

// class _MyModalState extends State<MyModal> {
//   File? _image;

//   Future<void> _getImage() async {
//     final picker = ImagePicker();
//     final pickedImage = await picker.getImage(source: ImageSource.gallery);

//     if (pickedImage != null) {
//       setState(() {
//         _image = File(pickedImage.path);
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       title: Text('Modal Title'),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           TextFormField(
//             decoration: InputDecoration(
//               labelText: 'Name',
//             ),
//           ),
//           TextFormField(
//             decoration: InputDecoration(
//               labelText: 'Email',
//             ),
//           ),
//           SizedBox(height: 16),
//           ElevatedButton(
//             onPressed: _getImage,
//             child: Text('Upload Image'),
//           ),
//           if (_image != null) ...[
//             SizedBox(height: 16),
//             Image.file(
//               _image!,
//               height: 100,
//               width: 100,
//             ),
//           ],
//         ],
//       ),
//       actions: [
//         TextButton(
//           onPressed: () {
//             Modular.to.pop();
//           },
//           child: Text('Close'),
//         ),
//       ],
//     );
//   }
// }