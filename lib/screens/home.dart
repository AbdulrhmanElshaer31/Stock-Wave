import 'package:flutter/material.dart';
import 'package:stock_wave/services/qoute_service.dart';
import 'package:stock_wave/services/company_service.dart';
import 'package:stock_wave/models/qoute/quote_model.dart';
import 'package:stock_wave/models/company/company_profile_model.dart';
import 'package:stock_wave/screens/market.dart';
import 'package:stock_wave/screens/analysis.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final QouteService _qouteService = QouteService();
  final CompanyService _companyService = CompanyService();

  static const Color bgDark = Color(0xFF0F0F0F);
  static const Color cardDark = Color(0xFF141414);
  static const Color textSecond = Color(0xFF888888);
  static const Color green = Color(0xFF00C853);
  static const Color red = Color(0xFFFF4B4B);
  static const Color gold = Color(0xFFC9A84C);

  final List<Map<String, dynamic>> _positions = [
    {'symbol': 'AAPL', 'shares': 10, 'avgPrice': 168.50},
    {'symbol': 'MSFT', 'shares': 5, 'avgPrice': 355.20},
    {'symbol': 'NVDA', 'shares': 3, 'avgPrice': 460.00},
    {'symbol': 'GOOGL', 'shares': 8, 'avgPrice': 135.00},
  ];

  final List<String> _topSymbols = [
    'AAPL',
    'TSLA',
    'GOOGL',
    'MSFT',
    'AMZN',
    'NVDA',
  ];

  Map<String, QuoteModel> _quotes = {};
  Map<String, CompanyProfileModel> _profiles = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    setState(() => _isLoading = true);

    Map<String, QuoteModel> quotes = {};
    Map<String, CompanyProfileModel> profiles = {};

    Set<String> allSymbols = {
      ..._positions.map((p) => p['symbol'] as String),
      ..._topSymbols,
    };

    for (String symbol in allSymbols) {
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

  void _addPosition(
    String symbol,
    int shares,
    double avgPrice,
    double currentPrice,
  ) {
    setState(() {
      _positions.add({
        'symbol': symbol,
        'shares': shares,
        'avgPrice': avgPrice,
      });
      if (_quotes[symbol] == null) {
        _quotes[symbol] = QuoteModel(
          currentPrice: currentPrice,
          change: 0,
          percentChange: 0,
          highPriceOfTheDay: currentPrice,
          lowPriceOfTheDay: currentPrice,
          openPriceOfTheDay: currentPrice,
          previousClosePrice: currentPrice,
        );
      }
    });
  }

  void _showAddDialog() {
    final tickerCtrl = TextEditingController();
    final sharesCtrl = TextEditingController();
    final avgCtrl = TextEditingController();
    String? name;
    bool isLooking = false;
    String? errorText;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              backgroundColor: const Color(0xFF141414),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Position',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'TICKER SYMBOL',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: tickerCtrl,
                            textCapitalization: TextCapitalization.characters,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g. AAPL',
                              hintStyle: const TextStyle(
                                color: Color(0xFF444444),
                                fontWeight: FontWeight.normal,
                              ),
                              filled: true,
                              fillColor: const Color(0xFF1E1E1E),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0x14FFFFFF),
                                ),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () async {
                            String ticker = tickerCtrl.text
                                .trim()
                                .toUpperCase();
                            if (ticker.isEmpty) return;
                            setDialogState(() {
                              isLooking = true;
                              errorText = null;
                            });
                            try {
                              final quoteRes = await _qouteService.getQuote(
                                symbol: ticker,
                              );
                              final profileRes = await _companyService
                                  .getCompanyProfile(symbol: ticker);
                              if (quoteRes.data != null) {
                                setDialogState(() {
                                  name = profileRes.data?.name ?? ticker;
                                  avgCtrl.text = quoteRes.data!.currentPrice
                                      .toStringAsFixed(2);
                                  isLooking = false;
                                  errorText = null;
                                });
                              } else {
                                setDialogState(() {
                                  isLooking = false;
                                  errorText = 'Ticker not found';
                                });
                              }
                            } catch (e) {
                              setDialogState(() {
                                isLooking = false;
                                errorText = 'Failed to load data';
                              });
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0x26C9A84C),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0x40C9A84C),
                              ),
                            ),
                            child: Text(
                              isLooking ? '...' : 'Lookup',
                              style: const TextStyle(
                                color: gold,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (name != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        name!,
                        style: const TextStyle(color: gold, fontSize: 12),
                      ),
                    ],
                    if (errorText != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        errorText!,
                        style: const TextStyle(color: red, fontSize: 12),
                      ),
                    ],
                    const SizedBox(height: 20),
                    const Text(
                      'NUMBER OF SHARES',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: sharesCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: const TextStyle(color: Color(0xFF444444)),
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0x14FFFFFF),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'AVG. PURCHASE PRICE (USD)',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: avgCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: const TextStyle(color: Color(0xFF444444)),
                        filled: true,
                        fillColor: const Color(0xFF1E1E1E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0x14FFFFFF),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () {
                        String ticker = tickerCtrl.text.trim().toUpperCase();
                        int? shares = int.tryParse(sharesCtrl.text.trim());
                        double? avg = double.tryParse(avgCtrl.text.trim());
                        if (ticker.isEmpty ||
                            shares == null ||
                            shares <= 0 ||
                            avg == null ||
                            avg <= 0) {
                          return;
                        }
                        _addPosition(ticker, shares, avg, avg);
                        Navigator.pop(ctx);
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
                            'Add Position',
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

  void _goToAnalysis(String symbol) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => Analysis(symbol: symbol)));
  }

  void _goToMarket() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const Market()));
  }

  double _getTotalValue() {
    double total = 0;
    for (var pos in _positions) {
      String symbol = pos['symbol'];
      int shares = pos['shares'];
      double price = _quotes[symbol]?.currentPrice ?? pos['avgPrice'];
      total += shares * price;
    }
    return total;
  }

  double _getTotalInvested() {
    double total = 0;
    for (var pos in _positions) {
      total += (pos['shares'] as int) * (pos['avgPrice'] as double);
    }
    return total;
  }

  double _getTotalPnL() => _getTotalValue() - _getTotalInvested();

  String _formatNumber(double num) {
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(1)}K';
    return num.toStringAsFixed(2);
  }

  Color _parseColor(String hex) {
    String colorStr = hex.replaceFirst('#', '');
    return Color(int.parse('FF$colorStr', radix: 16));
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
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  const SizedBox(height: 20),
                  _buildPortfolioCard(),
                  const SizedBox(height: 28),
                  _buildSectionWithButton(
                    title: 'My Positions',
                    buttonText: 'Add',
                    onTap: _showAddDialog,
                  ),
                  const SizedBox(height: 12),
                  _buildPositionsList(),
                  const SizedBox(height: 28),
                  _buildSectionWithButton(
                    title: 'Top Stocks',
                    buttonText: 'Market',
                    onTap: _goToMarket,
                  ),
                  const SizedBox(height: 12),
                  _buildTopStocksList(),
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
            'Good morning',
            style: TextStyle(
              color: textSecond,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Text(
            'Home',
            style: TextStyle(
              color: gold,
              fontSize: 20,
              fontWeight: FontWeight.bold,
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

  Widget _buildSectionWithButton({
    required String title,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0x1FC9A84C),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0x33C9A84C)),
              ),
              child: Row(
                children: [
                  Icon(
                    buttonText == 'Add' ? Icons.add : Icons.chevron_right,
                    color: gold,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    buttonText,
                    style: const TextStyle(
                      color: gold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioCard() {
    double totalValue = _getTotalValue();
    double totalPnL = _getTotalPnL();
    double totalInvested = _getTotalInvested();
    double pnlPct = totalInvested > 0 ? (totalPnL / totalInvested) * 100 : 0;
    bool isPositive = totalPnL >= 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFFC9A84C), Color(0xFF6B4E0E), Color(0xFFC9A84C)],
          ),
        ),
        padding: const EdgeInsets.all(1.5),
        child: Container(
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(22.5),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0x1FC9A84C),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: gold,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Portfolio Value',
                        style: TextStyle(color: textSecond, fontSize: 13),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? const Color(0x1F00C853)
                          : const Color(0x1FFF4B4B),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isPositive ? Icons.trending_up : Icons.trending_down,
                          color: isPositive ? green : red,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${isPositive ? "+" : ""}${pnlPct.toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: isPositive ? green : red,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                '\$${totalValue.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    color: isPositive ? green : red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${isPositive ? "+" : "-"}\$${totalPnL.abs().toStringAsFixed(2)} all-time',
                    style: TextStyle(
                      color: isPositive ? green : red,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(height: 1, color: const Color(0x0FFFFFFF)),
              const SizedBox(height: 18),
              Row(
                children: [
                  _buildStatItem('Positions', '${_positions.length}'),
                  _buildStatItem(
                    'Invested',
                    '\$${_formatNumber(_getTotalInvested())}',
                  ),
                  _buildStatItem('Alerts', '0'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPositionsList() {
    if (_positions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 40),
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x0FFFFFFF)),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Color(0xFF555555),
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'No positions yet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tap Add to track your investments',
                style: TextStyle(color: Color(0xFF666666), fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x0FFFFFFF)),
        ),
        child: Column(
          children: _positions.asMap().entries.map((entry) {
            int index = entry.key;
            var pos = entry.value;
            String symbol = pos['symbol'];
            int shares = pos['shares'];
            double avgPrice = pos['avgPrice'];
            QuoteModel? quote = _quotes[symbol];
            double currentPrice = quote?.currentPrice ?? avgPrice;
            double value = shares * currentPrice;
            double pnl = shares * (currentPrice - avgPrice);
            double pnlPct = ((currentPrice - avgPrice) / avgPrice) * 100;
            bool isPos = pnl >= 0;

            List<String> colors = [
              '#C9A84C',
              '#00C853',
              '#2196F3',
              '#FF4B4B',
              '#9C27B0',
              '#FF9800',
              '#00BCD4',
            ];
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
                                '$shares shares · avg \$${avgPrice.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Color(0xFF666666),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '\$${value.toStringAsFixed(2)}',
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
                                    color: isPos ? green : red,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${isPos ? "+" : ""}\$${pnl.abs().toStringAsFixed(2)} (${isPos ? "+" : ""}${pnlPct.toStringAsFixed(2)}%)',
                                    style: TextStyle(
                                      color: isPos ? green : red,
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
                if (index < _positions.length - 1)
                  Container(
                    height: 1,
                    margin: const EdgeInsets.only(left: 60, right: 16),
                    color: const Color(0x0AFFFFFF),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildTopStocksList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x0FFFFFFF)),
        ),
        child: Column(
          children: _topSymbols.asMap().entries.map((entry) {
            int index = entry.key;
            String symbol = entry.value;
            QuoteModel? quote = _quotes[symbol];
            CompanyProfileModel? profile = _profiles[symbol];
            double price = quote?.currentPrice ?? 0;
            double changePct = quote?.percentChange ?? 0;
            bool isPos = changePct >= 0;
            String name = profile?.name ?? symbol;

            List<String> colors = [
              '#C9A84C',
              '#00C853',
              '#2196F3',
              '#FF4B4B',
              '#9C27B0',
              '#FF9800',
              '#00BCD4',
            ];
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
                                    color: isPos ? green : red,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${isPos ? "+" : ""}${changePct.toStringAsFixed(2)}%',
                                    style: TextStyle(
                                      color: isPos ? green : red,
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
                if (index < _topSymbols.length - 1)
                  Container(
                    height: 1,
                    margin: const EdgeInsets.only(left: 60, right: 16),
                    color: const Color(0x0AFFFFFF),
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
