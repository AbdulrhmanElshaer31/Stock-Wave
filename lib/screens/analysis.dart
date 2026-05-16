import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stock_wave/services/qoute_service.dart';
import 'package:stock_wave/services/company_service.dart';
import 'package:stock_wave/services/stock_service.dart';
import 'package:stock_wave/services/search_service.dart';
import 'package:stock_wave/models/qoute/quote_model.dart';
import 'package:stock_wave/models/company/company_profile_model.dart';
import 'package:stock_wave/models/stock/metrics_model.dart';
import 'package:stock_wave/models/stock/recommendation_model.dart';

class Analysis extends StatefulWidget {
  final String symbol;
  final bool showBackButton;

  const Analysis({super.key, this.symbol = 'AAPL', this.showBackButton = true});

  @override
  State<Analysis> createState() => _AnalysisState();
}

class _AnalysisState extends State<Analysis> {
  final QouteService _qouteService = QouteService();
  final CompanyService _companyService = CompanyService();
  final StockService _stockService = StockService();
  final SearchService _searchService = SearchService();

  late String _symbol;

  QuoteModel? _quote;
  CompanyProfileModel? _profile;
  MetricsModel? _metrics;
  List<RecommendationModel> _recommendations = [];
  bool _isLoading = true;

  static const Color gold = Color(0xFFC9A84C);
  static const Color red = Color(0xFFFF4B4B);
  static const Color cardDark = Color(0xFF141414);
  static const Color bgDark = Color(0xFF0F0F0F);

  String _getInitials(String text) {
    if (text.isEmpty) return '';
    return text.length >= 2 ? text.substring(0, 2) : text;
  }

  String _getFirstChar(String text) {
    if (text.isEmpty) return '';
    return text.substring(0, 1);
  }

  @override
  void initState() {
    super.initState();
    _symbol = widget.symbol;
    _loadData();
  }

  void _loadData() async {
    setState(() => _isLoading = true);

    try {
      final quoteRes = await _qouteService.getQuote(symbol: _symbol);
      if (mounted && quoteRes.data != null) {
        setState(() => _quote = quoteRes.data);
      }
    } catch (e) {
      //
    }

    try {
      final profileRes = await _companyService.getCompanyProfile(
        symbol: _symbol,
      );
      if (mounted && profileRes.data != null) {
        setState(() => _profile = profileRes.data);
      }
    } catch (e) {
      //
    }

    try {
      final metricsRes = await _stockService.getMtrcs(
        symbol: _symbol,
        metric: 'all',
      );
      if (mounted && metricsRes.data != null) {
        setState(() => _metrics = metricsRes.data);
      }
    } catch (e) {
      //
    }

    try {
      final recRes = await _stockService.getRecmdtions(symbol: _symbol);
      if (mounted && recRes.data != null && recRes.data!.isNotEmpty) {
        setState(() => _recommendations = recRes.data!);
      }
    } catch (e) {
      //
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _changeSymbol(String newSymbol) {
    setState(() => _symbol = newSymbol);
    _loadData();
  }

  void _showSymbolSelector() {
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
                    'Select Stock',
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
                              hintText: 'Search symbol...',
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
                  if (searchCtrl.text.isEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'QUICK PICKS',
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          [
                            'AAPL',
                            'TSLA',
                            'MSFT',
                            'GOOGL',
                            'NVDA',
                            'META',
                            'AMZN',
                            'AMD',
                          ].map((sym) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.pop(ctx);
                                _changeSymbol(sym);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E1E),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0x14FFFFFF),
                                  ),
                                ),
                                child: Text(
                                  sym,
                                  style: const TextStyle(
                                    color: gold,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                  if (results.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ...results.map((r) {
                      String initials = r.displaySymbol.length >= 2
                          ? r.displaySymbol.substring(0, 2).toUpperCase()
                          : r.displaySymbol.toUpperCase();

                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(ctx);
                          _changeSymbol(r.displaySymbol);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 4),
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
                                    initials,
                                    style: const TextStyle(
                                      color: gold,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
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
                                    r.description ?? '',
                                    style: const TextStyle(
                                      color: Color(0xFF666666),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
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

  void _showAlertDialog() {
    String condition = 'above';
    final priceCtrl = TextEditingController(
      text: (_quote?.currentPrice ?? 0).toStringAsFixed(2),
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
                      'Price Alert · $_symbol',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Current price: \$${(_quote?.currentPrice ?? 0).toStringAsFixed(2)}',
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
                      onTap: () => Navigator.pop(ctx),
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

  double _getPrice() => _quote?.currentPrice ?? 0;
  double _getChange() => _quote?.change ?? 0;
  double _getChangePct() => _quote?.percentChange ?? 0;
  bool _isPositive() => _getChange() >= 0;

  String _formatLargeNum(double num) {
    if (num >= 100000000000) {
      return '${(num / 1000000000000).toStringAsFixed(1)}T';
    }
    if (num >= 1000000000) {
      return '${(num / 1000000000).toStringAsFixed(1)}B';
    }
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    }
    return num.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF888888)),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        automaticallyImplyLeading: widget.showBackButton,
        titleSpacing: 0,
        title: const Text(
          'Analysis',
          style: TextStyle(
            color: gold,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: SizedBox(
            height: 1,
            child: ColoredBox(color: Color(0x0FFFFFFF)),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: gold))
          : RefreshIndicator(
              color: gold,
              backgroundColor: cardDark,
              onRefresh: () async => _loadData(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildPriceRow(),
                    const SizedBox(height: 12),
                    _buildActionRow(),
                    const SizedBox(height: 20),
                    _buildChartCard(),
                    const SizedBox(height: 20),
                    _buildMetricsGrid(),
                    const SizedBox(height: 20),
                    _buildAboutCard(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return GestureDetector(
      onTap: _showSymbolSelector,
      child: Row(
        children: [
          if (_profile?.logo != null && _profile!.logo.isNotEmpty)
            ClipOval(
              child: Image.network(
                _profile!.logo,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildAvatarPlaceholder();
                },
              ),
            )
          else
            _buildAvatarPlaceholder(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _symbol,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF888888),
                      size: 22,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _profile?.name ?? _symbol,
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    String initials = _getInitials(_symbol).toUpperCase();

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0x1AC9A84C),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x33C9A84C)),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            color: gold,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '\$${_getPrice().toStringAsFixed(2)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.arrow_drop_down, color: red, size: 20),
            Text(
              '${_getChange().toStringAsFixed(2)} (${_isPositive() ? "+" : ""}${_getChangePct().toStringAsFixed(2)}%)',
              style: const TextStyle(
                color: red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionRow() {
    return Row(
      children: [
        GestureDetector(
          onTap: _showAlertDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0x26C9A84C),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0x4DC9A84C)),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_outlined, color: gold, size: 14),
                const SizedBox(width: 6),
                const Text(
                  'Set Alert',
                  style: TextStyle(
                    color: gold,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x14FFFFFF)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.business_center,
                color: Color(0xFF888888),
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                _profile?.finnhubIndustry ?? 'N/A',
                style: const TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x0FFFFFFF)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: const Color(0x0AFFFFFF), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                minX: 0,
                maxX: 5,
                minY: 0,
                maxY: 6,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 2.5),
                      FlSpot(1, 3.2),
                      FlSpot(2, 2.2),
                      FlSpot(3, 3.8),
                      FlSpot(4, 3.0),
                      FlSpot(5, 4.5),
                    ],
                    isCurved: true,
                    color: const Color(0xffE4B84C),
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xffE4B84C).withOpacity(0.4),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    if (_metrics == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0x0FFFFFFF)),
        ),
        child: const Center(
          child: Text(
            'No metrics data available',
            style: TextStyle(color: Color(0xFF888888), fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Metrics',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0x0FFFFFFF)),
          ),
          child: Column(
            children: [
              _buildMetricRow(
                '52W High',
                '\$${_metrics!.high.toStringAsFixed(2)}',
              ),
              Container(height: 1, color: const Color(0x0FFFFFFF)),
              _buildMetricRow(
                '52W Low',
                '\$${_metrics!.low.toStringAsFixed(2)}',
              ),
              Container(height: 1, color: const Color(0x0FFFFFFF)),
              _buildMetricRow(
                'Market Cap',
                '\$${_formatLargeNum(_metrics!.marketCapitalization)}',
              ),
              Container(height: 1, color: const Color(0x0FFFFFFF)),
              _buildMetricRow(
                'P/E Ratio',
                _metrics!.peNormalizedAnnual.toStringAsFixed(2),
              ),
              Container(height: 1, color: const Color(0x0FFFFFFF)),
              _buildMetricRow(
                'EPS',
                '\$${_metrics!.epsNormalizedAnnual.toStringAsFixed(2)}',
              ),
              Container(height: 1, color: const Color(0x0FFFFFFF)),
              _buildMetricRow('Beta', _metrics!.beta.toStringAsFixed(2)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF888888), fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    if (_profile == null) return const SizedBox();

    String firstChar = _getFirstChar(_symbol).toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0B08),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFF2B2110)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_profile!.logo.isNotEmpty)
                ClipOval(
                  child: Image.network(
                    _profile!.logo,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0x1AC9A84C),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            firstChar,
                            style: const TextStyle(
                              color: gold,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0x1AC9A84C),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      firstChar,
                      style: const TextStyle(
                        color: gold,
                        fontSize: 16,
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
                      'About ${_profile!.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _symbol,
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(height: 1, color: const Color(0x1AFFFFFF)),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Exchange',
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _profile!.exchange.isEmpty ? 'N/A' : _profile!.exchange,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Currency',
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _profile!.currency.isEmpty ? 'N/A' : _profile!.currency,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Country',
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _profile!.country.isEmpty ? 'N/A' : _profile!.country,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'IPO',
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _profile!.ipo.isEmpty ? 'N/A' : _profile!.ipo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_profile!.weburl.isNotEmpty) ...[
            const SizedBox(height: 24),
            Container(height: 1, color: const Color(0x1AFFFFFF)),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.language, color: gold, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _profile!.weburl.replaceAll('https://', ''),
                    style: const TextStyle(
                      color: gold,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.open_in_new, color: gold, size: 16),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
