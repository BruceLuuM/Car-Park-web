import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

enum RegistrationType { teacher, monthly }

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController cardIdController = TextEditingController();
  final TextEditingController numberPlateController = TextEditingController();

  RegistrationType _registrationType = RegistrationType.teacher;

  Future<void> registerHuman() async {
    const url =
        'http://localhost:3000/parking/register'; // Replace with your backend URL

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': nameController.text,
        'code': codeController.text,
        'cardId': cardIdController.text,
        'numberPlate': numberPlateController.text,
        'type': _registrationType == RegistrationType.teacher
            ? 'teacher'
            : 'monthly',
      }),
    );

    if (response.statusCode == 200) {
      // Registration successful
      print('Registration successful');
      // Handle navigation or show success message
    } else {
      // Registration failed
      print('Registration failed');
      // Handle error scenario
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(labelText: 'Code'),
            ),
            TextField(
              controller: cardIdController,
              decoration: const InputDecoration(labelText: 'Card ID'),
            ),
            TextField(
              controller: numberPlateController,
              decoration: const InputDecoration(labelText: 'Number Plate'),
            ),
            const SizedBox(height: 20),
            Text('Select Registration Type:'),
            RadioListTile<RegistrationType>(
              title: const Text('Teacher'),
              value: RegistrationType.teacher,
              groupValue: _registrationType,
              onChanged: (RegistrationType? value) {
                setState(() {
                  _registrationType = value!;
                });
              },
            ),
            RadioListTile<RegistrationType>(
              title: const Text('Monthly'),
              value: RegistrationType.monthly,
              groupValue: _registrationType,
              onChanged: (RegistrationType? value) {
                setState(() {
                  _registrationType = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: registerHuman,
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
