import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:noted/data/add_data.dart';

Future<void> addDataToFirestore(AddData data) async {
  final url =
      'https://console.firebase.google.com/u/0/project/noted-cc64a/firestore/data/';

  final response = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      // Jika menggunakan token auth
      // 'Authorization': 'Bearer YOUR_AUTH_TOKEN',
    },
    body: jsonEncode({
      'fields': {
        'name': {'stringValue': data.name},
        'amount': {'stringValue': data.amount},
        'IN': {'stringValue': data.IN},
        'datetime': {'timestampValue': data.datetime.toIso8601String()},
        'selectedItem': {'stringValue': data.selectedItem},
        'username': {'stringValue': data.username},
        'password': {'stringValue': data.password},
      },
    }),
  );

  if (response.statusCode == 200) {
    // Data berhasil ditambahkan
    print('Data added to Firestore');
  } else {
    // Terjadi kesalahan
    print('Failed to add data to Firestore: ${response.body}');
  }
}
