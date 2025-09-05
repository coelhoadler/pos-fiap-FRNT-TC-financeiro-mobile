import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Balance extends StatefulWidget {
  const Balance({super.key});

  @override
  State<Balance> createState() => _BalanceState();
}

class _BalanceState extends State<Balance> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _obscure = true;

  Stream<QuerySnapshot> _getTransactionsStream() {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }
      final userId = user.uid;

      return _firestore
          .collection('users')
          .doc(userId)
          .collection('transacoes')
          .orderBy('data', descending: true)
          .snapshots();
    } catch (e) {
      print('>>> Erro ao configurar stream de transações: $e');
      rethrow;
    }
  }

  double _parseValorToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^0-9,\.\-]'), '');
      final normalized = cleaned.contains(',')
          ? cleaned.replaceAll('.', '').replaceAll(',', '.')
          : cleaned;
      return double.tryParse(normalized) ?? 0.0;
    }
    return 0.0;
  }

  String _formatCurrency(num n) {
    return toCurrencyString(
      n.toString(),
      mantissaLength: 2,
      leadingSymbol: 'R\$ ',
      useSymbolPadding: true,
      thousandSeparator: ThousandSeparator.Period,
      shorteningPolicy: ShorteningPolicy.NoShortening,
    );
  }

  String getDayOfWeek(DateTime date) {
    const days = [
      'Domingo',
      'Segunda-feira',
      'Terça-feira',
      'Quarta-feira',
      'Quinta-feira',
      'Sexta-feira',
      'Sábado',
    ];
    return days[date.weekday];
  }

  @override
  Widget build(BuildContext context) {
    String dayOfWeek = getDayOfWeek(DateTime.now());
    String formattedDate =
        '${(DateTime.now().day - 1).toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}';

    return Container(
      color: Color(0xFF004d61),
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Text(
            "Olá, ${_auth.currentUser?.displayName?.split(' ')[0] ?? 'Usuário'}",
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
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          "Saldo",
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _obscure ? Icons.visibility_off : Icons.visibility,
                        ),
                        color: Colors.white,
                        onPressed: () {
                          setState(() {
                            _obscure = !_obscure;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2, child: Container(color: Colors.white)),
                Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _getTransactionsStream(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text(
                          _obscure ? '*******' : 'Erro ao carregar o saldo',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                            color: Colors.white,
                            decoration: _obscure
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        );
                      }
                      if (!snapshot.hasData) {
                        return Text(
                          _obscure ? '*******' : 'Carregando...',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 22,
                            color: Colors.white,
                            decoration: _obscure
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        );
                      }

                      final docs = snapshot.data!.docs;
                      final total = docs.fold<double>(0.0, (acc, d) {
                        final data = (d.data() as Map<String, dynamic>?) ?? {};
                        return acc + _parseValorToDouble(data['valor']);
                      });

                      final text = _obscure
                          ? '*******'
                          : _formatCurrency(total);

                      return Text(
                        text,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                          color: Colors.white,
                          decoration: _obscure
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      );
                    },
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
