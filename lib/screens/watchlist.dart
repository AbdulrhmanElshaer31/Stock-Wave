import 'package:flutter/material.dart';
import 'package:stock_wave/services/qoute_service.dart';
import 'package:stock_wave/services/company_service.dart';
import 'package:stock_wave/services/search_service.dart';
import 'package:stock_wave/models/qoute/quote_model.dart';
import 'package:stock_wave/models/company/company_profile_model.dart';
import 'package:stock_wave/screens/analysis.dart';

class Watchlist extends StatefulWidget {
  const Watchlist({super.key});

  @override
  State<Watchlist> createState() => _WatchlistState();
}

class _WatchlistState extends State<Watchlist> {
  final QouteService _qouteService = QouteService();
  final CompanyService _companyService = CompanyService();
  final SearchService _searchService = SearchService();

  static const Color gold = Color(0xFFC9A84C);
  static const Color green = Color(0xFF00C853);
  static const Color red = Color(0xFFFF4B4B);
  static const Color cardDark = Color(0xFF141414);
  static const Color bgDark = Color(0xFF0F0F0F);

 final List<Map<String, dynamic>> _watchlist = [
    {'symbol': 'AAPL', 'name': 'Apple Inc.'},
    {'symbol': 'TSLA', 'name': 'Tesla Inc.'},
    {'symbol': 'NVDA', 'name': 'NVIDIA Corp.'},
  ];

  Map<String, QuoteModel> _quotes = {};
  Map<String, CompanyProfileModel> _profiles = {};
  bool _isLoading = true;
  bool _showStocks = true;
 final Map<String, Map<String, dynamic>> _alerts = {};

  final List<String> _avatarColors = [
    '#C9A84C',
    '#00C853',
    '#2196F3',
    '#FF4B4B',
    '#9C27B0',
    '#FF9800',
    '#00BCD4',
  ];

  String _getInitials(String text) {
    if (text.isEmpty) return '';
    return text.length >= 2 ? text.substring(0, 2) : text;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() => _isLoading = true);

    Map<String, QuoteModel> quotes = {};
    Map<String, CompanyProfileModel> profiles = {};

    for (var item in _watchlist) {
      String symbol = item['symbol'];
      try {
        final quoteRes = await _qouteService.getQuote(symbol: symbol);
        if (quoteRes.data != null) {
          quotes[symbol] = quoteRes.data!;
        }
        final profileRes = await _companyService.getCompanyProfile(
          symbol: symbol,
        );
        if (profileRes.data != null) {
          profiles[symbol] = profileRes.data!;
        }
      } catch (e) {
        //
      }
    }

    if (mounted) {
      setState(() {
        _quotes = quotes;
        _profiles = profiles;
        _isLoading = false;
      });
    }
  }

  void _addToWatchlist(String symbol, String name) {
    if (_watchlist.any((w) => w['symbol'] == symbol)) return;
    setState(() => _watchlist.add({'symbol': symbol, 'name': name}));
    _loadData();
  }

  void _removeFromWatchlist(String symbol) {
    setState(() {
      _watchlist.removeWhere((w) => w['symbol'] == symbol);
      _quotes.remove(symbol);
      _profiles.remove(symbol);
    });
  }

  void _goToAnalysis(String symbol) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => Analysis(symbol: symbol)));
  }

  void _setAlert(String symbol, double targetPrice, String condition) {
    setState(() {
      _alerts[symbol] = {
        'targetPrice': targetPrice,
        'condition': condition,
        'active': true,
      };
    });
  }

  void _removeAlert(String symbol) {
    setState(() => _alerts.remove(symbol));
  }

  bool _hasAlert(String symbol) =>
      _alerts.containsKey(symbol) && _alerts[symbol]!['active'] == true;

  double _getTotalValue() {
    double total = 0;
    for (var item in _watchlist) {
      String symbol = item['symbol'];
      if (_quotes.containsKey(symbol)) total += _quotes[symbol]!.currentPrice;
    }
    return total;
  }

  int _getGainingCount() {
    return _watchlist.where((w) {
      String symbol = w['symbol'];
      return _quotes.containsKey(symbol) && _quotes[symbol]!.percentChange >= 0;
    }).length;
  }

  Color _parseColor(String hex) {
    String colorStr = hex.replaceFirst('#', '');
    return Color(int.parse('FF$colorStr', radix: 16));
  }

  void _showAddSheet() {
    final searchCtrl = TextEditingController();
    List<dynamic> results = [];
    bool searching = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: cardDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add to Watchlist',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0x14FFFFFF)),
                    ),
                    child: Row(
                      children: [
                        if (searching)
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              color: gold,
                              strokeWidth: 2,
                            ),
                          )
                        else
                          const Icon(
                            Icons.search,
                            color: Color(0xFF888888),
                            size: 16,
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: searchCtrl,
                            autofocus: true,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Search ticker or company...',
                              hintStyle: TextStyle(
                                color: Color(0xFF555555),
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                            onChanged: (value) async {
                              if (value.trim().isEmpty) {
                                setSheetState(() => results = []);
                                return;
                              }
                              setSheetState(() => searching = true);
                              try {
                                final res = await _searchService
                                    .getSearchResultFN(query: value);
                                if (res.data != null) {
                                  setSheetState(() {
                                    results = res.data!.result
                                        .where(
                                          (r) =>
                                              r.type == 'Common Stock' &&
                                              !r.symbol.contains('.'),
                                        )
                                        .take(8)
                                        .toList();
                                    searching = false;
                                  });
                                }
                              } catch (e) {
                                setSheetState(() => searching = false);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (results.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...results.map((r) {
                      bool inList = _watchlist.any(
                        (w) => w['symbol'] == r.displaySymbol,
                      );
                      String displayText = r.displaySymbol.length >= 2
                          ? r.displaySymbol.substring(0, 2)
                          : r.displaySymbol;

                      return GestureDetector(
                        onTap: () {
                          if (!inList) {
                            _addToWatchlist(r.displaySymbol, r.description);
                            Navigator.pop(ctx);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0x1AC9A84C),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Center(
                                  child: Text(
                                    displayText,
                                    style: const TextStyle(
                                      color: gold,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      r.displaySymbol,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      r.description,
                                      style: const TextStyle(
                                        color: Color(0xFF666666),
                                        fontSize: 12,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: inList
                                      ? const Color(0x1FC9A84C)
                                      : const Color(0x26C9A84C),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0x40C9A84C),
                                  ),
                                ),
                                child: Text(
                                  inList ? 'Added' : '+ Add',
                                  style: const TextStyle(
                                    color: gold,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAlertDialog(String symbol, double currentPrice) {
    String condition = 'above';
    final priceCtrl = TextEditingController(
      text: currentPrice.toStringAsFixed(2),
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              backgroundColor: cardDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Set Alert · $symbol',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Current price: \$${currentPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setDialogState(() => condition = 'above'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: condition == 'above'
                                    ? const Color(0x2600C853)
                                    : const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: condition == 'above'
                                      ? const Color(0x4D00C853)
                                      : const Color(0x14FFFFFF),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Rises above',
                                  style: TextStyle(
                                    color: Color(0xFF00C853),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setDialogState(() => condition = 'below'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: condition == 'below'
                                    ? const Color(0x26FF4B4B)
                                    : const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: condition == 'below'
                                      ? const Color(0x4DFF4B4B)
                                      : const Color(0x14FFFFFF),
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Falls below',
                                  style: TextStyle(
                                    color: Color(0xFFFF4B4B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'TARGET PRICE (USD)',
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: priceCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        double? target = double.tryParse(priceCtrl.text);
                        if (target != null && target > 0) {
                          _setAlert(symbol, target, condition);
                          Navigator.pop(ctx);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFC9A84C), Color(0xFF8B6914)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            'Set Alert',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: gold))
          : RefreshIndicator(
              color: gold,
              backgroundColor: cardDark,
              onRefresh: () async => _loadData(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTabs(),
                  const SizedBox(height: 16),
                  if (_showStocks) ...[
                    _buildSummaryCard(),
                    const SizedBox(height: 16),
                    _buildStocksList(),
                  ] else
                    _buildAlertsList(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF111111),
      elevation: 0,
      titleSpacing: 20,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Your watchlist',
            style: TextStyle(
              color: Color(0xFF888888),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: _showAddSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFC9A84C), Color(0xFF8B6914)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: Colors.black, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Add',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Watchlist',
                style: TextStyle(
                  color: gold,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: SizedBox(height: 1, child: ColoredBox(color: Color(0x0FFFFFFF))),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _showStocks = true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: _showStocks
                    ? const Color(0x26C9A84C)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _showStocks
                      ? const Color(0x4DC9A84C)
                      : Colors.transparent,
                ),
              ),
              child: const Center(
                child: Text(
                  'Stocks',
                  style: TextStyle(
                    color: Color(0xFFC9A84C),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _showStocks = false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: !_showStocks
                    ? const Color(0x26C9A84C)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: !_showStocks
                      ? const Color(0x4DC9A84C)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_alerts.isNotEmpty)
                    Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: gold,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${_alerts.length}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  const Text(
                    'Alerts',
                    style: TextStyle(
                      color: Color(0xFFC9A84C),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    double totalValue = _getTotalValue();
    int gaining = _getGainingCount();
    int declining = _watchlist.length - gaining;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x0FFFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Watchlist Total',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0x1AC9A84C),
                  borderRadius: BorderRadius.circular(23),
                ),
                child: const Icon(Icons.pie_chart, color: gold, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${totalValue.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: const Color(0x0FFFFFFF)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSummaryItem('Stocks', '${_watchlist.length}'),
              _buildSummaryItem('Gaining', '$gaining', green),
              _buildSummaryItem('Declining', '$declining', red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, [Color? color]) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF666666), fontSize: 10),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStocksList() {
    if (_watchlist.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 60),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x0FFFFFFF)),
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(36),
              ),
              child: const Icon(
                Icons.show_chart,
                color: Color(0xFF555555),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Watchlist empty',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap Add to track your favorite stocks',
              style: TextStyle(color: Color(0xFF666666), fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x0FFFFFFF)),
      ),
      child: Column(
        children: _watchlist.asMap().entries.map((entry) {
          int index = entry.key;
          var item = entry.value;
          String symbol = item['symbol'];
          String name = _profiles[symbol]?.name ?? item['name'];
          QuoteModel? quote = _quotes[symbol];
          double price = quote?.currentPrice ?? 0;
          double changePct = quote?.percentChange ?? 0;
          bool isPos = changePct >= 0;
          Color color = isPos ? green : red;
          Color avatarColor = _parseColor(
            _avatarColors[index % _avatarColors.length],
          );
          bool hasAlert = _hasAlert(symbol);

          return Column(
            children: [
              GestureDetector(
                onTap: () => _goToAnalysis(symbol),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: avatarColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(symbol),
                            style: TextStyle(
                              color: avatarColor,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  symbol,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (hasAlert) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.notifications_active,
                                    color: gold,
                                    size: 12,
                                  ),
                                ],
                              ],
                            ),
                            Text(
                              name,
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      if (_quotes.containsKey(symbol))
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isPos
                                      ? const Color(0x1A00C853)
                                      : const Color(0x1AFF4B4B),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isPos
                                          ? Icons.trending_up
                                          : Icons.trending_down,
                                      color: color,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${isPos ? "+" : ""}${changePct.toStringAsFixed(2)}%',
                                      style: TextStyle(
                                        color: color,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _showAlertDialog(symbol, price),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: hasAlert
                                    ? const Color(0x1FC9A84C)
                                    : const Color(0xFF222222),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                hasAlert
                                    ? Icons.notifications_active
                                    : Icons.notifications_outlined,
                                color: hasAlert
                                    ? gold
                                    : const Color(0xFF666666),
                                size: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () => _removeFromWatchlist(symbol),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFF222222),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: red,
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (index < _watchlist.length - 1)
                Container(
                  height: 1,
                  margin: const EdgeInsets.only(left: 60, right: 16),
                  color: const Color(0x0AFFFFFF),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAlertsList() {
    if (_alerts.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 60),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x0FFFFFFF)),
        ),
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(36),
              ),
              child: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFF555555),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No price alerts',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Set alerts from the Watchlist',
              style: TextStyle(color: Color(0xFF666666), fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x0FFFFFFF)),
      ),
      child: Column(
        children: _alerts.entries.map((entry) {
          String symbol = entry.key;
          var alert = entry.value;
          double targetPrice = alert['targetPrice'];
          String condition = alert['condition'];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0x1FC9A84C),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: gold,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        symbol,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: condition == 'above'
                              ? const Color(0x1A00C853)
                              : const Color(0x1AFF4B4B),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${condition == 'above' ? 'Above' : 'Below'} \$${targetPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: condition == 'above' ? green : red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _removeAlert(symbol),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF222222),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: red,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
