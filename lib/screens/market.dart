import 'package:flutter/material.dart';
import 'package:stock_wave/services/qoute_service.dart';
import 'package:stock_wave/services/company_service.dart';
import 'package:stock_wave/services/stock_service.dart';
import 'package:stock_wave/models/qoute/quote_model.dart';
import 'package:stock_wave/models/company/company_profile_model.dart';
import 'package:stock_wave/models/stock/market_status_model.dart';
import 'package:stock_wave/screens/analysis.dart';

class Market extends StatefulWidget {
  const Market({super.key});

  @override
  State<Market> createState() => _MarketState();
}

class _MarketState extends State<Market> {
  final QouteService _qouteService = QouteService();
  final CompanyService _companyService = CompanyService();
  final StockService _stockService = StockService();

  static const Color gold = Color(0xFFC9A84C);
  static const Color green = Color(0xFF00C853);
  static const Color red = Color(0xFFFF4B4B);
  static const Color cardDark = Color(0xFF141414);
  static const Color bgDark = Color(0xFF0F0F0F);

  final List<Map<String, String>> _indices = [
    {'symbol': 'SPY', 'label': 'S&P 500', 'desc': 'SPDR S&P 500 ETF'},
    {'symbol': 'QQQ', 'label': 'NASDAQ', 'desc': 'Invesco QQQ Trust'},
    {'symbol': 'DIA', 'label': 'Dow Jones', 'desc': 'SPDR Dow Jones ETF'},
  ];

  final List<String> _stocks = [
    'NVDA',
    'AMD',
    'META',
    'MSFT',
    'AMZN',
    'GOOGL',
    'AAPL',
    'TSLA',
    'NFLX',
    'COIN',
  ];

  Map<String, QuoteModel> _indexQuotes = {};
  Map<String, QuoteModel> _stockQuotes = {};
  Map<String, CompanyProfileModel> _profiles = {};
  MarketStatusModel? _marketStatus;
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _showGainers = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    if (silent) setState(() => _isRefreshing = true);

    Map<String, QuoteModel> indexQuotes = {};
    Map<String, QuoteModel> stockQuotes = {};
    Map<String, CompanyProfileModel> profiles = {};

    Set<String> allSymbols = {..._indices.map((i) => i['symbol']!), ..._stocks};

    for (String symbol in allSymbols) {
      try {
        final quoteRes = await _qouteService.getQuote(symbol: symbol);
        if (quoteRes.data != null) {
          if (_indices.any((i) => i['symbol'] == symbol)) {
            indexQuotes[symbol] = quoteRes.data!;
          } else {
            stockQuotes[symbol] = quoteRes.data!;
          }
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

    try {
      final statusRes = await _stockService.marketStatus(exchange: 'US');
      if (statusRes.data != null) {
        _marketStatus = statusRes.data!;
      }
    } catch (e) {
      //
    }

    if (mounted) {
      setState(() {
        _indexQuotes = indexQuotes;
        _stockQuotes = stockQuotes;
        _profiles = profiles;
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  void _goToAnalysis(String symbol) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => Analysis(symbol: symbol)));
  }

  Color _parseColor(String hex) {
    String colorStr = hex.replaceFirst('#', '');
    return Color(int.parse('FF$colorStr', radix: 16));
  }

  List<Map<String, dynamic>> _getSortedStocks() {
    List<Map<String, dynamic>> sorted = _stockQuotes.entries.map((entry) {
      return {'symbol': entry.key, 'quote': entry.value};
    }).toList();

    sorted.sort((a, b) {
      double aPct = (a['quote'] as QuoteModel).percentChange;
      double bPct = (b['quote'] as QuoteModel).percentChange;
      return bPct.compareTo(aPct);
    });

    if (_showGainers) {
      return sorted
          .where((s) => (s['quote'] as QuoteModel).percentChange > 0)
          .take(5)
          .toList();
    } else {
      return sorted
          .where((s) => (s['quote'] as QuoteModel).percentChange < 0)
          .take(5)
          .toList();
    }
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
              onRefresh: () async => _loadData(silent: true),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildIndicesSection(),
                  const SizedBox(height: 28),
                  _buildTabs(),
                  const SizedBox(height: 16),
                  _buildStocksList(),
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
          Row(
            children: [
              const Text(
                'Market',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              if (_marketStatus != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _marketStatus!.isOpen
                        ? const Color(0x1F00C853)
                        : const Color(0x1FFF4B4B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _marketStatus!.isOpen ? green : red,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _marketStatus!.isOpen ? 'OPEN' : 'CLOSED',
                        style: TextStyle(
                          color: _marketStatus!.isOpen ? green : red,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          GestureDetector(
            onTap: () => _loadData(silent: true),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(19),
              ),
              child: Center(
                child: _isRefreshing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: gold,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.refresh, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: SizedBox(height: 1, child: ColoredBox(color: Color(0x0FFFFFFF))),
      ),
    );
  }

  Widget _buildIndicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Major Indices',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._indices.map((index) {
          String symbol = index['symbol']!;
          QuoteModel? quote = _indexQuotes[symbol];
          double price = quote?.currentPrice ?? 0;
          double change = quote?.change ?? 0;
          double changePct = quote?.percentChange ?? 0;
          bool isPos = change >= 0;
          Color color = isPos ? green : red;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => _goToAnalysis(symbol),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0x0FFFFFFF)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              index['label']!,
                              style: const TextStyle(
                                color: Color(0xFF888888),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0x1AC9A84C),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                symbol,
                                style: const TextStyle(
                                  color: gold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '\$${price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isPos
                            ? const Color(0x1400C853)
                            : const Color(0x14FF4B4B),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isPos
                                  ? const Color(0x2600C853)
                                  : const Color(0x26FF4B4B),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Icon(
                                isPos ? Icons.trending_up : Icons.trending_down,
                                color: color,
                                size: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${isPos ? "+" : ""}${change.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _showGainers = true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: _showGainers
                    ? const Color(0x2600C853)
                    : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _showGainers
                      ? const Color(0x4D00C853)
                      : const Color(0x0FFFFFFF),
                ),
              ),
              child: const Center(
                child: Text(
                  'Top Gainers',
                  style: TextStyle(
                    color: Color(0xFF00C853),
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
            onTap: () => setState(() => _showGainers = false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: !_showGainers
                    ? const Color(0x26FF4B4B)
                    : const Color(0xFF1A1A1A),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: !_showGainers
                      ? const Color(0x4DFF4B4B)
                      : const Color(0x0FFFFFFF),
                ),
              ),
              child: const Center(
                child: Text(
                  'Top Losers',
                  style: TextStyle(
                    color: Color(0xFFFF4B4B),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStocksList() {
    List<Map<String, dynamic>> items = _getSortedStocks();

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x0FFFFFFF)),
        ),
        child: const Center(
          child: Text(
            'No data available',
            style: TextStyle(color: Color(0xFF555555), fontSize: 13),
          ),
        ),
      );
    }

    List<String> colors = [
      '#C9A84C',
      '#00C853',
      '#2196F3',
      '#FF4B4B',
      '#9C27B0',
      '#FF9800',
      '#00BCD4',
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x0FFFFFFF)),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          int index = entry.key;
          var item = entry.value;
          String symbol = item['symbol'];
          QuoteModel quote = item['quote'];
          double price = quote.currentPrice;
          double changePct = quote.percentChange;
          bool isPos = changePct >= 0;
          Color color = isPos ? green : red;
          String name = _profiles[symbol]?.name ?? symbol;
          Color avatarColor = _parseColor(colors[index % colors.length]);

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
                            symbol.substring(0, 2),
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
                            Text(
                              symbol,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
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
                      Column(
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
                    ],
                  ),
                ),
              ),
              if (index < items.length - 1)
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
}
