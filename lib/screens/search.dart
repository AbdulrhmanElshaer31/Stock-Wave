import 'package:flutter/material.dart';
import 'package:stock_wave/services/search_service.dart';
import 'package:stock_wave/services/qoute_service.dart';
import 'package:stock_wave/models/search/search_item_model.dart';
import 'package:stock_wave/models/qoute/quote_model.dart';
import 'package:stock_wave/screens/analysis.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final SearchService _searchService = SearchService();
  final QouteService _qouteService = QouteService();
  final TextEditingController _searchController = TextEditingController();

  static const Color gold = Color(0xFFC9A84C);
  static const Color green = Color(0xFF00C853);
  static const Color red = Color(0xFFFF4B4B);
  static const Color cardDark = Color(0xFF141414);
  static const Color bgDark = Color(0xFF0F0F0F);

  List<SearchItemModel> _results = [];
 final Map<String, QuoteModel> _quotes = {};
  Map<String, QuoteModel> _trendingQuotes = {};
  bool _isSearching = false;
  bool _hasSearched = false;

  final List<String> _trending = [
    'AAPL',
    'TSLA',
    'NVDA',
    'META',
    'GOOGL',
    'MSFT',
    'AMZN',
    'AMD',
  ];

  final Map<String, String> _trendingNames = {
    'AAPL': 'Apple Inc.',
    'TSLA': 'Tesla Inc.',
    'NVDA': 'NVIDIA Corp.',
    'META': 'Meta Platforms',
    'GOOGL': 'Alphabet Inc.',
    'MSFT': 'Microsoft Corp.',
    'AMZN': 'Amazon.com',
    'AMD': 'Advanced Micro Devices',
  };

  final List<String> _avatarColors = [
    '#C9A84C',
    '#00C853',
    '#2196F3',
    '#FF4B4B',
    '#9C27B0',
    '#FF9800',
    '#00BCD4',
    '#E91E63',
  ];

  @override
  void initState() {
    super.initState();
    _loadTrending();
  }

  void _loadTrending() async {
    Map<String, QuoteModel> quotes = {};

    for (String symbol in _trending) {
      try {
        final res = await _qouteService.getQuote(symbol: symbol);
        if (res.data != null) {
          quotes[symbol] = res.data!;
        }
      } catch (e) {
        //
      }
    }

    if (mounted) {
      setState(() => _trendingQuotes = quotes);
    }
  }

  void _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final res = await _searchService.getSearchResultFN(query: query);
      if (res.data != null) {
        List<SearchItemModel> filtered = res.data!.result
            .where((r) => r.type == 'Common Stock' && !r.symbol.contains('.'))
            .take(10)
            .toList();

        setState(() {
          _results = filtered;
          _isSearching = false;
        });

        for (var item in filtered.take(5)) {
          if (!_quotes.containsKey(item.symbol)) {
            try {
              final quoteRes = await _qouteService.getQuote(
                symbol: item.symbol,
              );
              if (quoteRes.data != null) {
                setState(() => _quotes[item.symbol] = quoteRes.data!);
              }
            } catch (e) {
              //
            }
          }
        }
      }
    } catch (e) {
      setState(() => _isSearching = false);
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool showTrending = !_hasSearched && _searchController.text.isEmpty;

    return Scaffold(
      backgroundColor: bgDark,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator(color: gold))
                : _hasSearched && _results.isEmpty && !showTrending
                ? _buildEmptyState()
                : showTrending
                ? _buildTrendingList()
                : _buildResultsList(),
          ),
        ],
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
            'Find stocks',
            style: TextStyle(
              color: Color(0xFF888888),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Text(
            'Search',
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: _searchController.text.isNotEmpty
                ? const Color(0x59C9A84C)
                : const Color(0x12FFFFFF),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            if (_isSearching)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(color: gold, strokeWidth: 2),
              )
            else
              const Icon(Icons.search, color: Color(0xFF888888), size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                autofocus: false,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                onSubmitted: _performSearch,
                decoration: const InputDecoration(
                  hintText: 'Stocks, ETFs, indices...',
                  hintStyle: TextStyle(color: Color(0xFF555555), fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isCollapsed: true,
                ),
                onChanged: (value) {
                  setState(() {});
                  if (value.isEmpty) {
                    setState(() {
                      _results = [];
                      _hasSearched = false;
                    });
                  }
                },
              ),
            ),
            if (_searchController.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() {
                      _results = [];
                      _hasSearched = false;
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFF333333),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(36),
            ),
            child: const Icon(Icons.search, color: Color(0xFF555555), size: 32),
          ),
          const SizedBox(height: 16),
          const Text(
            'No results',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try a different ticker or company name',
            style: TextStyle(color: Color(0xFF666666), fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Trending',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x0FFFFFFF)),
          ),
          child: Column(
            children: _trending.asMap().entries.map((entry) {
              int index = entry.key;
              String symbol = entry.value;
              QuoteModel? quote = _trendingQuotes[symbol];
              double price = quote?.currentPrice ?? 0;
              double changePct = quote?.percentChange ?? 0;
              bool isPos = changePct >= 0;
              Color color = isPos ? green : red;
              Color avatarColor = _parseColor(
                _avatarColors[index % _avatarColors.length],
              );
              String name = _trendingNames[symbol] ?? symbol;

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
                          if (quote != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
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
                  ),
                  if (index < _trending.length - 1)
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
      ],
    );
  }

  Widget _buildResultsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            '${_results.length} result${_results.length != 1 ? 's' : ''} for "${_searchController.text}"',
            style: const TextStyle(
              color: Color(0xFF888888),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0x0FFFFFFF)),
          ),
          child: Column(
            children: _results.asMap().entries.map((entry) {
              int index = entry.key;
              SearchItemModel item = entry.value;
              QuoteModel? quote = _quotes[item.symbol];
              double price = quote?.currentPrice ?? 0;
              double changePct = quote?.percentChange ?? 0;
              bool isPos = changePct >= 0;
              Color color = isPos ? green : red;
              Color avatarColor = _parseColor(
                _avatarColors[index % _avatarColors.length],
              );

              return Column(
                children: [
                  GestureDetector(
                    onTap: () => _goToAnalysis(item.symbol),
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
                                item.displaySymbol.substring(0, 2),
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
                                      item.displaySymbol,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
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
                                      child: const Text(
                                        'Stock',
                                        style: TextStyle(
                                          color: gold,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.description,
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
                          if (quote != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '\$${price.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
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
                  ),
                  if (index < _results.length - 1)
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
      ],
    );
  }
}
