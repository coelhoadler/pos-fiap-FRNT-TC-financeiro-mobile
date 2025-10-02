import 'package:flutter/material.dart';
import 'package:pos_fiap_fin_mobile/components/ui/firebase_logout_util.dart';
import 'package:pos_fiap_fin_mobile/components/ui/header/avatar-header.dart';
import '../components/screens/dashboard/extract/extract.dart';
import '../components/ui/header/header.dart' show Header;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pos_fiap_fin_mobile/utils/routes.dart';

enum TransferFilterType { month, year, range, none }

class TransfersScreen extends StatefulWidget {
  const TransfersScreen({super.key});

  @override
  State<TransfersScreen> createState() => _TransfersScreenState();
}

class _TransfersScreenState extends State<TransfersScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ---- ESTADOS DOS FILTROS
  TransferFilterType _filterType = TransferFilterType.none;
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;
  DateTimeRange? _selectedRange;

  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_auth.currentUser == null) {
        Navigator.pushReplacementNamed(context, Routes.login);
        return;
      }
    });
    _applyFilter();
  }

  // ------ HELPERS DOS FILTROS
  void _applyFilter() {
    switch (_filterType) {
      case TransferFilterType.month:
        final first = DateTime(_selectedYear, _selectedMonth, 1);
        final nextMonth = DateTime(_selectedYear, _selectedMonth + 1, 1);
        setState(() {
          _startDate = first;
          _endDate = nextMonth;
        });
        break;

      case TransferFilterType.year:
        final first = DateTime(_selectedYear, 1, 1);
        final nextYear = DateTime(_selectedYear + 1, 1, 1);
        setState(() {
          _startDate = first;
          _endDate = nextYear;
        });
        break;

      case TransferFilterType.range:
        if (_selectedRange != null) {
          final start = DateTime(
            _selectedRange!.start.year,
            _selectedRange!.start.month,
            _selectedRange!.start.day,
          );
          final endExclusive = DateTime(
            _selectedRange!.end.year,
            _selectedRange!.end.month,
            _selectedRange!.end.day,
          ).add(const Duration(days: 1));
          setState(() {
            _startDate = start;
            _endDate = endExclusive;
          });
        }
        break;

      case TransferFilterType.none:
        setState(() {
          _startDate = null;
          _endDate = null;
        });
        break;
    }
  }

  List<DropdownMenuItem<int>> _monthItems() {
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
    return List.generate(12, (i) {
      final m = i + 1;
      return DropdownMenuItem<int>(value: m, child: Text('${months[i]} ($m)'));
    });
  }

  List<DropdownMenuItem<int>> _yearItems() {
    final current = DateTime.now().year;
    final years = List.generate(6, (i) => current - i);
    return years
        .map((y) => DropdownMenuItem<int>(value: y, child: Text(y.toString())))
        .toList();
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final firstDay = DateTime(now.year - 5, 1, 1);
    final lastDay = DateTime(now.year + 1, 12, 31);

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDay,
      lastDate: lastDay,
      initialDateRange:
          _selectedRange ??
          DateTimeRange(start: DateTime(now.year, now.month, 1), end: now),
      saveText: 'Aplicar',
      helpText: 'Selecione o período',
    );

    if (picked != null) {
      setState(() {
        _filterType = TransferFilterType.range;
        _selectedRange = picked;
      });
      _applyFilter();
    }
  }

  void _clearFilters() {
    setState(() {
      _filterType = TransferFilterType.none;
      _selectedRange = null;
    });
    _applyFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        context: context,
        displayName: _auth.currentUser?.displayName ?? 'Usuário Desconhecido',
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // ---------------- FILTRO ----------------
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Filtros do Extrato',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          DropdownButton<TransferFilterType>(
                            value: _filterType,
                            items: const [
                              DropdownMenuItem(
                                value: TransferFilterType.none,
                                child: Text('Sem filtro'),
                              ),
                              DropdownMenuItem(
                                value: TransferFilterType.month,
                                child: Text('Por mês'),
                              ),
                              DropdownMenuItem(
                                value: TransferFilterType.year,
                                child: Text('Por ano'),
                              ),
                              DropdownMenuItem(
                                value: TransferFilterType.range,
                                child: Text('Por período'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val == null) return;
                              setState(() => _filterType = val);
                              if (val != TransferFilterType.range) {
                                _selectedRange = null;
                              }
                              _applyFilter();
                            },
                          ),

                          if (_filterType == TransferFilterType.month) ...[
                            DropdownButton<int>(
                              value: _selectedMonth,
                              items: _monthItems(),
                              onChanged: (m) {
                                if (m == null) return;
                                setState(() => _selectedMonth = m);
                                _applyFilter();
                              },
                            ),
                            DropdownButton<int>(
                              value: _selectedYear,
                              items: _yearItems(),
                              onChanged: (y) {
                                if (y == null) return;
                                setState(() => _selectedYear = y);
                                _applyFilter();
                              },
                            ),
                          ],

                          if (_filterType == TransferFilterType.year) ...[
                            DropdownButton<int>(
                              value: _selectedYear,
                              items: _yearItems(),
                              onChanged: (y) {
                                if (y == null) return;
                                setState(() => _selectedYear = y);
                                _applyFilter();
                              },
                            ),
                          ],

                          if (_filterType == TransferFilterType.range) ...[
                            ElevatedButton.icon(
                              onPressed: _pickRange,
                              icon: const Icon(Icons.calendar_month),
                              label: Text(
                                _selectedRange == null
                                    ? 'Selecionar período'
                                    : 'Período: '
                                          '${_selectedRange!.start.day.toString().padLeft(2, '0')}/'
                                          '${_selectedRange!.start.month.toString().padLeft(2, '0')}/'
                                          '${_selectedRange!.start.year} → '
                                          '${_selectedRange!.end.day.toString().padLeft(2, '0')}/'
                                          '${_selectedRange!.end.month.toString().padLeft(2, '0')}/'
                                          '${_selectedRange!.end.year}',
                              ),
                            ),
                          ],

                          TextButton.icon(
                            onPressed: _clearFilters,
                            icon: const Icon(Icons.clear),
                            label: const Text('Limpar'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ---------------- EXTRACT COM FILTRO ----------------
            Extract(
              uploadImage: true,
              titleComponent: 'Minhas transferências',
              startDate: _startDate,
              endDate: _endDate,
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF004D61)),
              child: AvatarHeader(),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Início'),
              onTap: () {
                Navigator.pushNamed(context, Routes.dashboard);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () async {
                FirebaseLogoutUtil.logout(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
