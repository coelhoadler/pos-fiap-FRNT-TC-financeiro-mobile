import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pos_fiap_fin_mobile/components/screens/dashboard/charts/pie/pie_indicator.dart';

class TransactionsPieChart extends StatefulWidget {
  const TransactionsPieChart({super.key, required this.transactionsData});

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> transactionsData;

  @override
  State<StatefulWidget> createState() => PieChartState();
}

class PieChartState extends State<TransactionsPieChart> {
  int touchedIndex = -1;
  double totalValue = 0;
  Map<dynamic, List<QueryDocumentSnapshot<Map<String, dynamic>>>> grouped = {};

  @override
  void initState() {
    super.initState();

    // Calcular o valor total das transações
    for (var transaction in widget.transactionsData) {
      String onlyNumbers = transaction.data()['valor'].toString().replaceAll(
        RegExp(r'\D'),
        '',
      );
      double valorDouble = double.tryParse(onlyNumbers) ?? 0;
      totalValue += valorDouble;
    }

    print('>>> total value: ${totalValue / 100}');

    grouped = groupBy(
      widget.transactionsData,
      (item) => item.data()['descricao'],
    );

    print('>>> grouped: $grouped');
    print('>>> grouped 1: ${grouped[0]?.first}');
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.6,
      child: Row(
        children: <Widget>[
          const SizedBox(height: 18),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: PieChart(
                PieChartData(
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse
                            .touchedSection!
                            .touchedSectionIndex;
                      });
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  sectionsSpace: 5,
                  centerSpaceRadius: 30,
                  sections: showingSections(),
                ),
              ),
            ),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Indicator(
                color: Colors.blueAccent,
                text: 'TED/DOC',
                isSquare: true,
              ),
              SizedBox(height: 4),
              Indicator(
                color: Colors.yellowAccent,
                text: 'Câmbio de moeda',
                isSquare: true,
              ),
              SizedBox(height: 4),
              Indicator(
                color: Colors.purpleAccent,
                text: 'Empréstimo e fin...',
                isSquare: true,
              ),
              SizedBox(height: 18),
            ],
          ),
          const SizedBox(width: 28),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return List.generate(grouped.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:

          // posso pegar os valores do grupo 0 e somar
          double group0Total =
              grouped[0]?.fold(0, (sum, item) {
                print('>>> $sum');
                String onlyNumbers = item.data()['valor'].toString().replaceAll(
                  RegExp(r'\D'),
                  '',
                );
                double valorDouble = double.tryParse(onlyNumbers) ?? 0;
                return sum! + valorDouble;
              }) ??
              0;

          print('>>> group0Total: $group0Total');

          return PieChartSectionData(
            color: Colors.blueAccent,
            value: group0Total,
            title: '${(group0Total / totalValue * 100).toStringAsFixed(2)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: shadows,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.yellowAccent,
            value: 30,
            title: '30%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: shadows,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.purpleAccent,
            value: 30,
            title: '30%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: shadows,
            ),
          );
        default:
          throw Error();
      }
    });
  }
}
