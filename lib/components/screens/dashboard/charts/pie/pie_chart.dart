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
  double totalValueOfTransactions = 0;
  Map<dynamic, List<QueryDocumentSnapshot<Map<String, dynamic>>>> myCategories =
      {};

  @override
  void initState() {
    super.initState();

    totalValueOfTransactions = widget.transactionsData.fold(0, (total, item) {
      String onlyNumbers = item.data()['valor'].toString().replaceAll(
        RegExp(r'\D'),
        '',
      );
      double valorDouble = double.tryParse(onlyNumbers) ?? 0;
      return total + valorDouble;
    });

    myCategories = groupBy(
      widget.transactionsData,
      (item) => item.data()['descricao'],
    );
  }

  double getTotalValueOfGroup(
    MapEntry<dynamic, List<QueryDocumentSnapshot<Map<String, dynamic>>>>
    groupEntry,
  ) {
    double groupTotal = groupEntry.value.fold(0, (total, item) {
      String onlyNumbers = item.data()['valor'].toString().replaceAll(
        RegExp(r'\D'),
        '',
      );
      double valorDouble = double.tryParse(onlyNumbers) ?? 0;
      return total + valorDouble;
    });

    return groupTotal;
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
                text: 'DOC/TED',
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
    return List.generate(myCategories.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      switch (i) {
        case 0:
          double group0Total = getTotalValueOfGroup(
            myCategories.entries.elementAt(0),
          );

          return PieChartSectionData(
            color: Colors.blueAccent,
            value: group0Total,
            title:
                '${(group0Total / totalValueOfTransactions * 100).toStringAsFixed(2)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: shadows,
            ),
          );
        case 1:
          double group1Total = getTotalValueOfGroup(
            myCategories.entries.elementAt(1),
          );

          return PieChartSectionData(
            color: Colors.yellowAccent,
            value: group1Total,
            title:
                '${(group1Total / totalValueOfTransactions * 100).toStringAsFixed(2)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              shadows: shadows,
            ),
          );
        case 2:
          double group2Total = getTotalValueOfGroup(
            myCategories.entries.elementAt(2),
          );

          return PieChartSectionData(
            color: Colors.purpleAccent,
            value: group2Total,
            title:
                '${(group2Total / totalValueOfTransactions * 100).toStringAsFixed(2)}%',
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
