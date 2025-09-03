import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Extract extends StatefulWidget {
  const Extract({super.key});

  @override
  State<Extract> createState() => _ExtractState();
}

class _ExtractState extends State<Extract> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<QuerySnapshot> _getTransactionsStream() {
    try {
      String userId = _auth.currentUser!.uid;
      
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

  
  Widget _buildTransactionsList(QuerySnapshot snapshot) {
    if (snapshot.docs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Nenhuma transação encontrada',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    return Container(
      height: 300, 
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: snapshot.docs.length,
        itemBuilder: (context, index) {
          return _buildTransactionItem(snapshot.docs[index]);
        },
      ),
    );
  }

  
  Widget _buildTransactionItem(DocumentSnapshot doc) {
    try {
      var dados = doc.data() as Map<String, dynamic>;
      String descricao = dados['descricao'] ?? '';
      String valor = dados['valor'] ?? '';
      DateTime data = (dados['data'] as Timestamp).toDate();
      
      return ListTile(
        contentPadding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
        title: Text(
          descricao,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          _formatDate(data),
          style: TextStyle(color: Colors.black, fontSize: 14),
        ),
        trailing: Text(
          'R\$ $valor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.green,
          ),
        ),
      );
    } catch (e) {
      print('>>> Erro ao processar transação: $e');
      return ListTile(
        contentPadding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
        title: Text(
          'Erro ao carregar transação',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.green,
          ),
        ),
      );
    }
  }

    Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Carregando transações...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildErrorState(String error) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          SizedBox(height: 16),
          Text(
            'Erro ao carregar transações',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
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
              // Cabeçalho do extrato
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
              
              StreamBuilder<QuerySnapshot>(
                stream: _getTransactionsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildErrorState(snapshot.error.toString());
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingState();
                  }

                  if (!snapshot.hasData) {
                    return _buildErrorState('Dados não disponíveis');
                  }

                  return _buildTransactionsList(snapshot.data!);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    String day = date.day.toString().padLeft(2, '0');
    String month = date.month.toString().padLeft(2, '0');
    String year = date.year.toString();
    String hour = date.hour.toString().padLeft(2, '0');
    String minute = date.minute.toString().padLeft(2, '0');
    
    return '$day/$month/$year às $hour:$minute';
  }

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
    return months[date.month - 1];
  }
}
