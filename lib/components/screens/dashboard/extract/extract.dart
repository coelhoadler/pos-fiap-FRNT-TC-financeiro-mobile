import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pos_fiap_fin_mobile/components/ui/format_date_util.dart';
import 'package:pos_fiap_fin_mobile/components/ui/format_valor_util.dart';
import 'package:pos_fiap_fin_mobile/components/ui/toast_util.dart';
import 'dart:io';

import 'package:pos_fiap_fin_mobile/utils/routes.dart';

class Extract extends StatefulWidget {
  final bool uploadImage;
  final String titleComponent;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? limit;

  const Extract({
    super.key,
    this.uploadImage = false,
    this.titleComponent = '',
    this.startDate,
    this.endDate,
    this.limit,
  });

  @override
  State<Extract> createState() => _ExtractState();
}

class _ExtractState extends State<Extract> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  final List<DocumentSnapshot<Map<String, dynamic>>> _docs = [];
  DocumentSnapshot<Map<String, dynamic>>? _lastDoc;
  bool _hasMore = true;
  bool _isLoading = false;
  String? _error;
  late int _pageSize;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_auth.currentUser == null) {
        Navigator.pushReplacementNamed(context, Routes.login);
        return;
      }
      _resetAndFetch();
    });

    _pageSize = widget.limit ?? 5;
  }

  // Reconstrói a query base considerando filtros e ordenação
  Query<Map<String, dynamic>> _baseQuery() {
    final user = _auth.currentUser;
    if (user == null) {
      // Retorna uma referência qualquer; o chamador deve checar usuário antes de usar.
      return _firestore
          .collection('users')
          .doc('none')
          .collection('transacoes');
    }

    Query<Map<String, dynamic>> q = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('transacoes')
        .orderBy('data', descending: true)
        .limit(8);

    // Aplica filtros de período, se vieram do Dashboard
    if (widget.startDate != null) {
      q = q.where('data', isGreaterThanOrEqualTo: widget.startDate);
    }
    if (widget.endDate != null) {
      q = q.where('data', isLessThan: widget.endDate);
    }

    return q;
  }

  Future<void> _resetAndFetch() async {
    setState(() {
      _docs.clear();
      _lastDoc = null;
      _hasMore = true;
      _error = null;
      _isLoading = true; // evita flicker do estado vazio antes do primeiro load
    });

    await _fetchNextPage();
  }

  Future<void> _fetchNextPage() async {
    if (_auth.currentUser == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      Query<Map<String, dynamic>> q = _baseQuery().limit(_pageSize);
      if (_lastDoc != null) {
        q = q.startAfterDocument(_lastDoc!);
      }

      final snapshot = await q.get();
      if (snapshot.docs.isNotEmpty) {
        if (mounted) {
          setState(() {
            _docs.addAll(snapshot.docs);
            _lastDoc = snapshot.docs.last;
            if (snapshot.docs.length < _pageSize) {
              _hasMore = false;
            }
          });
        }
      } else {
        setState(() {
          _hasMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void didUpdateWidget(covariant Extract oldWidget) {
    super.didUpdateWidget(oldWidget);
    final limitChanged = (oldWidget.limit ?? 5) != (widget.limit ?? 5);
    final startChanged = oldWidget.startDate != widget.startDate;
    final endChanged = oldWidget.endDate != widget.endDate;
    if (limitChanged) {
      _pageSize = widget.limit ?? 5;
    }
    if (limitChanged || startChanged || endChanged) {
      _resetAndFetch();
    }
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

      if (mounted) {
        ToastUtil.showToast(context, 'O upload da imagem foi concluído.');
      }
      _resetAndFetch();
    } catch (e) {
      if (mounted) {
        ToastUtil.showToast(context, 'Erro ao realizar upload da imagem.');
      }
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

  Widget _buildTransactionsList() {
    if (_docs.isEmpty && _isLoading) {
      return _buildLoadingState();
    }

    if (_docs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Nenhuma transação encontrada',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: _docs.length,
      itemBuilder: (context, index) {
        return _buildTransactionItem(_docs[index]);
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

  Widget _buildLoadingState() {
    return Padding(
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
    );
  }

  Widget _buildErrorState(String error) {
    return Padding(
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
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _resetAndFetch,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  /// ---------- Ações: Editar / Excluir ----------
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
        try {
          await _storage.ref(imagePathUrl).delete();
        } catch (e) {
          if (mounted) {
            ToastUtil.showToast(
              context,
              'Erro ao excluir imagem associada: $e',
            );
          }
        }
      }

      if (mounted) {
        ToastUtil.showToast(context, 'Transação excluída com sucesso.');
        // Remove localmente para manter a lista consistente
        setState(() {
          _docs.removeWhere((d) => d.id == id);
        });
      }
    }
  }

  Future<void> _editarTransacao(String id, Map<String, dynamic> dados) async {
    final userId = _auth.currentUser!.uid;

    // opções de categorias de transação
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Card(
          color: const Color.fromARGB(226, 255, 255, 255),
          margin: EdgeInsets.all(0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                    title: Text(
                      widget.titleComponent,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Divider(
                    color: Color(0xFF004d61),
                    thickness: 1.5,
                    indent: 20,
                    endIndent: 20,
                  ),
                ],
              ),
              if (_error != null) _buildErrorState(_error!),
              if (_error == null) _buildTransactionsList(),

              // Footer de paginação
              Padding(
                padding: const EdgeInsets.only(top: 0, bottom: 8.0),
                child: Column(
                  children: [
                    if (!_isLoading &&
                        _hasMore &&
                        _error == null &&
                        widget.limit == null)
                      TextButton.icon(
                        onPressed: _fetchNextPage,
                        icon: const Icon(Icons.expand_more),
                        label: const Text('Carregar mais'),
                      ),
                    if (!_hasMore && _docs.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                        child: Text(
                          'Fim do extrato',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
