import 'package:flutter/material.dart';

class Extract extends StatefulWidget {
  final String nameTransaction;
  final DateTime dateTransaction;
  final double valueTransaction;

  const Extract({
    super.key,
    required this.nameTransaction,
    required this.dateTransaction,
    required this.valueTransaction,
  });

  @override
  State<Extract> createState() => _ExtractState();
}

class _ExtractState extends State<Extract> {
  String getMonthName(DateTime date) {
    const months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];
    return months[date.month];
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Card(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                children: [
                  const ListTile(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    title: Text(
                      'Extrato',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, color: Color(0xFF004d61)),
                        SizedBox(width: 8),
                        Icon(Icons.delete, color: Color(0xFF004d61)),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                    title: Text(
                      widget.nameTransaction,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      '${widget.dateTransaction.day} de ${getMonthName(widget.dateTransaction)} de ${widget.dateTransaction.year}',
                      style: TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    trailing: Text(
                      'R\$ ${widget.valueTransaction.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: widget.valueTransaction >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
