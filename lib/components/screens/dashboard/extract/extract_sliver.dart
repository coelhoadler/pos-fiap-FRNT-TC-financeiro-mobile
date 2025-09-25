import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos_fiap_fin_mobile/components/ui/format_date_util.dart';
import 'package:pos_fiap_fin_mobile/components/ui/format_valor_util.dart';
import 'package:pos_fiap_fin_mobile/components/ui/toast_util.dart';
import 'package:pos_fiap_fin_mobile/utils/routes.dart';

class ExtractSliver extends StatefulWidget {
  final bool uploadImage;
  final String titleComponent;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? limit;

  const ExtractSliver({
    super.key,
    this.uploadImage = false,
    this.titleComponent = '',
    this.startDate,
    this.endDate,
    this.limit,
  });

  @override
  State<ExtractSliver> createState() => _ExtractSliverState();
}

class _ExtractSliverState extends State<ExtractSliver> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_auth.currentUser == null) {
        Navigator.pushReplacementNamed(context, Routes.login);
        return;
      }
    });
  }

  Stream<QuerySnapshot> _getTransactionsStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    final base = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transacoes')
        .limit(widget.limit ?? 20);

    Query q = base;

    if (widget.startDate != null) {
      q = q.where('data', isGreaterThanOrEqualTo: widget.startDate);
    }
    if (widget.endDate != null) {
      q = q.where('data', isLessThan: widget.endDate);
    }

    q = q.orderBy('data', descending: true);

    return q.snapshots();
  }

  void _pickImage({required DocumentSnapshot currentTransfer}) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      _uploadImageToFirebase(pickedFile.path, id: currentTransfer.id);
    }
  }

  void _uploadImageToFirebase(String filePath, {required String id}) async {
    try {
      File file = File(filePath);
      String fileName = file.path.split('/').last;

      final userId = _auth.currentUser!.uid;
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('transacoes')
          .doc(id)
          .update({'imagePathUrl': 'uploads/$fileName'});

      await FirebaseStorage.instance.ref('uploads/$fileName').putFile(file);

      ToastUtil.showToast(context, 'O upload da imagem foi concluído.');
    } catch (e) {
      ToastUtil.showToast(context, 'Erro ao realizar upload da imagem.');
    }
  }

  void _goToImageGallery(String? transactionId, String imagePathUrl) {
    Navigator.pushNamed(
      context,
      Routes.imageGallery,
      arguments: {
        'imagePathUrl': '/$imagePathUrl',
        'transactionId': transactionId,
      },
    );
  }

  Widget _buildTransactionItem(DocumentSnapshot doc) {
    try {
      final dados = (doc.data() as Map<String, dynamic>?) ?? {};
      final imagePathUrl = dados['imagePathUrl'] ?? '';
      final transactionId = doc.id;
      final descricao = (dados['descricao'] ?? '').toString();
      final valorFmt = FormatValorUtil.formatValor(dados['valor']);
      final dataFmt = FormatDateUtil.formatDate(dados['data']);

      return ListTile(
        contentPadding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
        titleAlignment: ListTileTitleAlignment.top,
        leading: const Icon(
          Icons.receipt_long,
          color: Color(0xFF004d61),
          size: 25,
        ),
        title: Text(
          descricao.isEmpty ? 'Sem descrição' : descricao,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '$dataFmt\n$valorFmt',
          style: const TextStyle(color: Colors.black, fontSize: 14),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF004d61)),
              tooltip: 'Editar',
              onPressed: () => _editarTransacao(doc.id, dados),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.redAccent),
              tooltip: 'Excluir',
              onPressed: () => _confirmarExcluirTransacao(doc.id, imagePathUrl),
            ),
            if (widget.uploadImage)
              IconButton(
                style: ButtonStyle(
                  iconColor: WidgetStateProperty.all(
                    imagePathUrl.isNotEmpty ? Colors.blueAccent : Colors.green,
                  ),
                ),
                onPressed: () => imagePathUrl.isNotEmpty
                    ? _goToImageGallery(transactionId, imagePathUrl)
                    : _pickImage(currentTransfer: doc),
                icon: Icon(
                  imagePathUrl.isNotEmpty ? Icons.image : Icons.upload,
                ),
                tooltip: imagePathUrl.isNotEmpty
                    ? 'Visualizar imagem'
                    : 'Enviar imagem',
              ),
          ],
        ),
      );
    } catch (e) {
      return const ListTile(
        title: Text(
          'Erro ao carregar transação',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.red,
          ),
        ),
      );
    }
  }

  Future<void> _confirmarExcluirTransacao(
    String id,
    String imagePathUrl,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir transação'),
        content: const Text('Tem certeza que deseja excluir esta transação?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (ok == true) {
      final userId = _auth.currentUser!.uid;
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('transacoes')
          .doc(id)
          .delete();

      if (imagePathUrl.isNotEmpty) {
        await _storage.ref(imagePathUrl).delete();
      }

      if (mounted) {
        ToastUtil.showToast(context, 'Transação excluída com sucesso.');
      }
    }
  }

  Future<void> _editarTransacao(String id, Map<String, dynamic> dados) async {
    final userId = _auth.currentUser!.uid;

    final List<String> opcoes = [
      'Câmbio de moeda',
      'DOC/TED',
      'Empréstimo e Financiamento',
    ];

    String selectedDescricao = (dados['descricao'] ?? '').toString();
    final valorCtrl = TextEditingController(
      text: (dados['valor'] ?? '').toString(),
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Editar transação',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: opcoes.contains(selectedDescricao)
                  ? selectedDescricao
                  : null,
              decoration: const InputDecoration(labelText: 'Categoria'),
              items: opcoes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue != null) {
                  selectedDescricao = newValue;
                }
              },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: valorCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [
                CurrencyInputFormatter(
                  leadingSymbol: 'R\$ ',
                  thousandSeparator: ThousandSeparator.Period,
                  mantissaLength: 2,
                  useSymbolPadding: true,
                ),
              ],
              decoration: const InputDecoration(labelText: 'Valor'),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _firestore
                        .collection('users')
                        .doc(userId)
                        .collection('transacoes')
                        .doc(id)
                        .update({
                          'descricao': selectedDescricao,
                          'valor': valorCtrl.text.trim(),
                        });
                    if (context.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Salvar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        color: const Color.fromARGB(226, 255, 255, 255),
        margin: EdgeInsets.zero,
        child: Column(
          children: const [
            ListTile(
              contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
              title: Text(
                'Transações',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 22,
                  color: Colors.black,
                ),
              ),
            ),
            Divider(
              color: Color(0xFF004d61),
              thickness: 1.5,
              indent: 20,
              endIndent: 20,
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildLoadingSliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Carregando transações...',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildErrorSliver(String error) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFFF5031), size: 48),
            const SizedBox(height: 16),
            const Text(
              'Erro ao carregar transações',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildEmptySliver() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Nenhuma transação encontrada',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _getTransactionsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorSliver(snapshot.error.toString());
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingSliver();
        }
        if (!snapshot.hasData) {
          return _buildErrorSliver('Dados não disponíveis');
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return SliverList(
            delegate: SliverChildListDelegate([
              _header(),
              const SizedBox(height: 8),
              _buildEmptySliver().child!,
            ]),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            if (index == 0) {
              return _header();
            }
            final doc = docs[index - 1];
            return _buildTransactionItem(doc);
          }, childCount: docs.length + 1),
        );
      },
    );
  }
}
