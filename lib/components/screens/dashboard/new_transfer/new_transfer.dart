import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pos_fiap_fin_mobile/components/ui/toast_util.dart';

class NewTransferScreen extends StatefulWidget {
  const NewTransferScreen({super.key});

  @override
  State<NewTransferScreen> createState() => _NewTransferScreenState();
}

class _NewTransferScreenState extends State<NewTransferScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _valueController = TextEditingController(
    text: "R\$ 0,00",
  );
  String selectedValue = 'Câmbio de moeda';

  _createTransaction() async {
    try {
      String userId = _auth.currentUser!.uid;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('transacoes')
          .add({
            'valor': _valueController.text,
            'data': DateTime.now(),
            'descricao': selectedValue,
            'imagePathUrl': null,
          });

      _valueController.text = "R\$ 0,00";

      ToastUtil.showToast(context, 'Transação criada com sucesso.');
    } catch (e) {
      print('>>> Erro ao concluir transação: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const ListTile(title: Text('Nova transação')),
            DropdownButton<String>(
              value: selectedValue,
              items:
                  <String>[
                    'Câmbio de moeda',
                    'DOC/TED',
                    'Empréstimo e Financiamento',
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedValue = newValue!;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Valor'),
                controller: _valueController,
                inputFormatters: [
                  CurrencyInputFormatter(
                    leadingSymbol: 'R\$',
                    useSymbolPadding: true,
                    thousandSeparator: ThousandSeparator.Period,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  onPressed: _createTransaction,
                  child: const Text('Concluir transação'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
