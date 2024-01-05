import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:noted/data/add_data.dart';

class CircularSegmentEntry {
  final double value;
  final Color color;
  final String rankKey;

  CircularSegmentEntry(this.value, this.color, {required this.rankKey});
}

class CircularChartPainter extends CustomPainter {
  final List<CircularSegmentEntry> entries;
  final double strokeWidth;

  CircularChartPainter(this.entries, {this.strokeWidth = 20});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    double startAngle = -pi / 2;
    final total = entries.fold(
        0, (int sum, CircularSegmentEntry entry) => sum + entry.value.toInt());

    for (var entry in entries) {
      final sweepAngle = (2 * pi * (entry.value / total));
      paint.color = entry.color;

      canvas.drawArc(
          Rect.fromCircle(
              center: size.center(Offset.zero), radius: size.width / 2),
          startAngle,
          sweepAngle,
          false,
          paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(CircularChartPainter oldDelegate) => false;
}

class AnimatedCircularChart extends StatelessWidget {
  final List<CircularSegmentEntry> entries;
  final Duration duration;
  final double size;

  AnimatedCircularChart(
      {required this.entries,
      this.duration = const Duration(milliseconds: 800),
      required this.size});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      builder: (context, value, child) {
        return CustomPaint(
          size: Size(size, size),
          painter: CircularChartPainter(
              entries
                  .map((entry) => CircularSegmentEntry(
                      value * entry.value, entry.color,
                      rankKey: entry.rankKey))
                  .toList(),
              strokeWidth: size / 10),
        );
      },
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;

  StatCard({required this.title, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: <Widget>[
          Text(title,
              style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          Text(amount,
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class StatisticPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Box<AddData> transactionsBox = Hive.box<AddData>('data');
    List<AddData> transactions = transactionsBox.values.toList();
    double screenWidth = MediaQuery.of(context).size.width;
    double chartSize = screenWidth * 0.6;
    double incomeTotal = transactions
        .where((transaction) => transaction.IN == 'Income')
        .fold(0.0, (sum, item) => sum + double.parse(item.amount));
    double expenseTotal = transactions
        .where((transaction) => transaction.IN == 'Expense')
        .fold(0.0, (sum, item) => sum + double.parse(item.amount));
    double availableBalance = incomeTotal - expenseTotal;
    final Color gradientStartColor = Color(0xFF398AE5);
    final Color gradientEndColor = Color(0xff1DA1F2);
    final double appBarHeight = AppBar().preferredSize.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final double topPadding = appBarHeight + statusBarHeight;
    final chartData = [
      CircularSegmentEntry(incomeTotal, Colors.green, rankKey: 'Income'),
      CircularSegmentEntry(expenseTotal, Colors.red, rankKey: 'Expense'),
      CircularSegmentEntry(availableBalance, Colors.blue, rankKey: 'Available'),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff1DA1F2),
        title: Text('Card Stats', style: TextStyle(color: Colors.white)),
      ),
      extendBodyBehindAppBar: true,
      body: Column(
        children: <Widget>[
          SizedBox(height: topPadding + 20),
          AnimatedCircularChart(size: chartSize, entries: chartData),
          SizedBox(height: 20),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      StatCard(
                          title: 'Received',
                          amount: '\$${incomeTotal.toStringAsFixed(2)}',
                          color: Colors.green),
                      StatCard(
                          title: 'Expenses',
                          amount: '\$${expenseTotal.toStringAsFixed(2)}',
                          color: Colors.red),
                      StatCard(
                          title: 'Available',
                          amount: '\$${availableBalance.toStringAsFixed(2)}',
                          color: Colors.blue),
                    ],
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: 10,
                                barGroups: [
                                  BarChartGroupData(
                                    x: 0,
                                    barRods: [
                                      BarChartRodData(toY: 8),
                                    ],
                                    showingTooltipIndicators: [0],
                                  ),
                                  BarChartGroupData(
                                    x: 1,
                                    barRods: [
                                      BarChartRodData(toY: 3),
                                    ],
                                    showingTooltipIndicators: [0],
                                  ),
                                ],
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles:
                                          false, // false jika Anda tidak ingin menampilkan judul di sisi kiri
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      getTitlesWidget: (value, meta) {
                                        switch (value.toInt()) {
                                          case 0:
                                            return Text('Received',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14));
                                          case 1:
                                            return Text('Expenses',
                                                style: TextStyle(
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14));
                                          default:
                                            return Text('');
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                gridData: FlGridData(show: false),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(show: false),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles:
                                          false, // Sesuaikan berdasarkan kebutuhan
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30, // Sesuaikan ukuran
                                      getTitlesWidget:
                                          (double value, TitleMeta meta) {
                                        String text;
                                        switch (value.toInt()) {
                                          case 0:
                                            text = 'Received';
                                            break;
                                          case 1:
                                            text = 'Expenses';
                                            break;
                                          default:
                                            text = '';
                                            break;
                                        }
                                        return Text(
                                          text,
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(show: false),
                                minX: 0,
                                maxX: 3,
                                minY: 0,
                                maxY: 4,
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: [
                                      FlSpot(0, 3),
                                      FlSpot(1, 2),
                                      FlSpot(2, 5),
                                      FlSpot(3, 3.5),
                                    ],
                                    isCurved: true,
                                    barWidth: 4,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(show: false),
                                    belowBarData: BarAreaData(show: false),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  final String time;
  final double value;
  ChartData(this.time, this.value);
}
