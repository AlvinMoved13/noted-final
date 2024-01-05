import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:noted/data/add_data.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<void> _openBoxFuture;

  @override
  void initState() {
    super.initState();
    _openBoxFuture = hiveOpenBox();
  }

  Future<void> hiveOpenBox() async {
    await Hive.openBox<AddData>('data');
  }

  IconData getIconForCategory(String category) {
    switch (category) {
      case 'shopping':
        return EneftyIcons.shopping_cart_outline;
      case 'Transfer':
        return EneftyIcons.convert_card_outline;
      case 'transportation':
        return EneftyIcons.bus_bold;
      case 'Education':
        return EneftyIcons.teacher_outline;
      default:
        return EneftyIcons.arrow_square_down_bold;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _openBoxFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return buildHomePage();
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget buildHomePage() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<AddData>('data').listenable(),
      builder: (context, Box<AddData> box, _) {
        final transactions = box.values.toList().cast<AddData>();

        double totalBalance = transactions.fold(0.0, (sum, item) {
          double amount = double.tryParse(item.amount) ?? 0.0;
          return sum + (item.IN == 'Income' ? amount : -amount);
        });

        return Scaffold(
          backgroundColor: Color(0xff1DA1F2).withOpacity(0.0),
          appBar: AppBar(
            title: Text('Home'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    colors: [Color(0xff1DA1F2), Color(0xff7360DF)],
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    Text(
                      'Total Balance',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '\$$totalBalance',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Card(
                  margin: EdgeInsets.all(8),
                  color: Color(0xFFD9D9D9),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      AddData transaction = transactions[index];
                      // Memanggil fungsi getCategory dan getIconForCategory
                      IconData icon =
                          getIconForCategory(transaction.selectedItem);

                      return Card(
                        color: Color(0xFFFBFBFB),
                        elevation: 1,
                        margin:
                            EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: ListTile(
                          leading: Icon(icon),
                          title: Text(transaction.name),
                          subtitle: Text('\$${transaction.amount}'),
                          trailing: Text(
                            DateFormat('hh:mm a').format(transaction.datetime),
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
