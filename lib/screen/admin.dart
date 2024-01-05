import 'dart:convert';
import 'dart:typed_data';

import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:noted/bloc/authentication/authentication_event.dart';
import 'package:noted/bloc/authentication/authentication_state.dart';
import 'package:noted/data/add_data.dart';
import 'package:noted/main.dart';
import 'package:noted/widget/authentication_bloc.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({Key? key});

  Future<Uint8List> aesEncrypt(String data, SecretKey key) async {
    final cipher = AesCbc.with128bits(macAlgorithm: MacAlgorithm.empty);
    final nonce = cipher.newNonce();
    final secretBox = await cipher.encrypt(
      utf8.encode(data),
      secretKey: key,
      nonce: nonce,
    );
    return Uint8List.fromList(nonce + secretBox.concatenation());
  }

  Future<String> aesDecrypt(Uint8List encryptedData, SecretKey key) async {
    final cipher = AesCbc.with128bits(macAlgorithm: MacAlgorithm.empty);
    final nonce = encryptedData.sublist(0, 12);
    final encryptedContent = encryptedData.sublist(12);
    final secretBox = SecretBox.fromConcatenation(
      encryptedContent,
      nonceLength: 12,
      macLength: 0,
    );
    final clearText = await cipher.decrypt(
      secretBox,
      secretKey: key,
    );
    return utf8.decode(clearText);
  }

  @override
  Widget build(BuildContext context) {
    final secretKeyBytes = <int>[
      188,
      191,
      104,
      222,
      206,
      181,
      105,
      250,
      220,
      190,
      92,
      81,
      151,
      77,
      69,
      127,
      74,
      105,
      89,
      128,
      177,
      55,
      179,
      11,
      55,
      24,
      235,
      2,
      218,
      142,
      157,
      42
    ];
    final key = SecretKey(secretKeyBytes);

    return FutureBuilder(
      future: Hive.openBox<AddData>('data'),
      builder: (BuildContext context, AsyncSnapshot<Box<AddData>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final Box<AddData> dataBox = snapshot.data!;
            final List<AddData> dataList = dataBox.values.toList();

            return BlocListener<AuthenticationBloc, AuthenticationState>(
              listener: (context, state) {
                if (state is Authenticated) {
                  showSnackBar(context, 'Selamat datang, admin!',
                      AnimatedSnackBarType.success);
                } else if (state is Unauthenticated) {
                  showSnackBar(
                      context, 'Login admin gagal', AnimatedSnackBarType.error);
                }
              },
              child: Scaffold(
                appBar: AppBar(
                  title: Text('Admin Data Table'),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.exit_to_app),
                      onPressed: () {
                        BlocProvider.of<AuthenticationBloc>(context)
                            .add(LogoutRequested());
                      },
                    ),
                  ],
                ),
                body: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    child: DataTable(
                      columns: const <DataColumn>[
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Amount')),
                        DataColumn(label: Text('IN')),
                        DataColumn(label: Text('Date')),
                        DataColumn(label: Text('Selected Item')),
                        DataColumn(label: Text('Username')),
                      ],
                      rows: dataList.map((data) {
                        final encryptedNameFuture = aesEncrypt(data.name, key);
                        final encryptedAmountFuture =
                            aesEncrypt(data.amount, key);
                        final encryptedINFuture = aesEncrypt(data.IN, key);
                        final encryptedDateFuture =
                            aesEncrypt(data.datetime.toString(), key);
                        final encryptedSelectedItemFuture =
                            aesEncrypt(data.selectedItem, key);
                        final encryptedUsernameFuture =
                            aesEncrypt(data.username, key);
                        return DataRow(
                          cells: <DataCell>[
                            DataCell(FutureBuilder<String>(
                              future: encryptedNameFuture.then(
                                (encrypted) => aesDecrypt(encrypted, key),
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return Text(snapshot.data ?? 'Error');
                                }
                                return CircularProgressIndicator();
                              },
                            )),
                            DataCell(FutureBuilder<String>(
                              future: encryptedAmountFuture.then(
                                (encrypted) => aesDecrypt(encrypted, key),
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return Text(snapshot.data ?? 'Error');
                                }
                                return CircularProgressIndicator();
                              },
                            )),
                            DataCell(FutureBuilder<String>(
                              future: encryptedINFuture.then(
                                (encrypted) => aesDecrypt(encrypted, key),
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return Text(snapshot.data ?? 'Error');
                                }
                                return CircularProgressIndicator();
                              },
                            )),
                            DataCell(FutureBuilder<String>(
                              future: encryptedDateFuture.then(
                                (encrypted) => aesDecrypt(encrypted, key),
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return Text(snapshot.data ?? 'Error');
                                }
                                return CircularProgressIndicator();
                              },
                            )),
                            DataCell(FutureBuilder<String>(
                              future: encryptedSelectedItemFuture.then(
                                (encrypted) => aesDecrypt(encrypted, key),
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return Text(snapshot.data ?? 'Error');
                                }
                                return CircularProgressIndicator();
                              },
                            )),
                            DataCell(FutureBuilder<String>(
                              future: encryptedUsernameFuture.then(
                                (encrypted) => aesDecrypt(encrypted, key),
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return Text(snapshot.data ?? 'Error');
                                }
                                return CircularProgressIndicator();
                              },
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            );
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
