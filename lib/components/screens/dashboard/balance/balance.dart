import 'package:flutter/material.dart';

class Balance extends StatefulWidget {
  final String nameUser;
  final double amount;
  final DateTime dateTime;

  const Balance({
    super.key,
    required this.nameUser,
    required this.amount,
    required this.dateTime,
  });

  @override
  State<Balance> createState() => _BalanceState();
}

class _BalanceState extends State<Balance> {
  String getDayOfWeek(DateTime date) {
    const days = [
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
      'Domingo',
    ];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    String dayOfWeek = getDayOfWeek(widget.dateTime);
    String formattedDate =
        '${widget.dateTime.day.toString().padLeft(2, '0')}/${widget.dateTime.month.toString().padLeft(2, '0')}/${widget.dateTime.year}';

    return Container(
      color: Color(0xFF004d61),
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Text(
            "Olá, ${widget.nameUser}",
            style: TextStyle(fontSize: 26, color: Colors.white),
          ),
          SizedBox(height: 20),
          Text(
            '$dayOfWeek, $formattedDate',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(
                    "Saldo: ",
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
                SizedBox(height: 2, child: Container(color: Colors.white)),
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(
                    'R\$ ${widget.amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 22,
                      color: widget.amount >= 0 ? Colors.white : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
