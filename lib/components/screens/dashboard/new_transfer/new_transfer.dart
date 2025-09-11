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

  bool isButtonEnabled = false;
  String selectedValue = '';

  @override
  void initState() {
    super.initState();
    _valueController.addListener(() {
      setState(() {
        isButtonEnabled = _valueController.text.isNotEmpty;
      });
    });
  }

  _createTransaction() async {
    try {
      String userId = _auth.currentUser!.uid;

      // Remove currency formatting and parse to double for comparison
      double value = double.tryParse(
        _valueController.text.replaceAll(RegExp(r'[^\d,]'), '').replaceAll(',', '.')
      ) ?? 0.0;
      if (value == 0.0) {
        ToastUtil.showToast(context, 'O valor deve ser maior que zero.');
        return;
      }

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

      FocusScope.of(context).unfocus();
      ToastUtil.showToast(context, 'Transação criada com sucesso.');

      setState(() {
        selectedValue = '';
        _valueController.text = "R\$ 0,00";
        isButtonEnabled = false;
      });
    } catch (e) {
      print('>>> Erro ao concluir transação: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> opcoes = [
      'Câmbio de moeda',
      'DOC/TED',
      'Empréstimo e Financiamento',
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const ListTile(title: Text('Criar nova transação')),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<String>(
                initialValue: opcoes.contains(selectedValue)
                    ? selectedValue
                    : null,
                hint: const Text('Selecione uma categoria'),
                items: opcoes.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Categoria'),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedValue = newValue!;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Valor'),
                controller: _valueController,
                onChanged: (text) {
                  setState(() {
                    isButtonEnabled = text.isNotEmpty;
                  });
                },
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
                  onPressed: isButtonEnabled ? _createTransaction : null,
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
