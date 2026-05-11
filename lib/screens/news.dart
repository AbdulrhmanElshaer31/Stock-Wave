import 'package:flutter/material.dart';
import 'package:stock_wave/services/news_service.dart';
import 'package:stock_wave/models/news/news_model.dart';

class News extends StatefulWidget {
  const News({super.key});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {
  final NewsService _newsService = NewsService();

  static const Color gold = Color(0xFFC9A84C);
  static const Color cardDark = Color(0xFF141414);
  static const Color bgDark = Color(0xFF0F0F0F);

  List<Newsmodel> _news = [];
 final  List<Newsmodel> _savedNews = [];
  bool _isLoading = true;
  String _activeCategory = 'general';
  bool _showFeed = true;

  final List<String> _categories = ['general', 'forex', 'crypto', 'merger'];

  final Map<String, String> _categoryLabels = {
    'general': 'Markets',
    'forex': 'Forex',
    'crypto': 'Crypto',
    'merger': 'M&A',
  };

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  void _loadNews() async {
    setState(() => _isLoading = true);

    try {
      final response = await _newsService.getAllNews(category: _activeCategory);
      if (response.data != null) {
        setState(() => _news = response.data!.take(20).toList());
      }
    } catch (e) {
      //
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _toggleSave(Newsmodel article) {
    setState(() {
      if (_isSaved(article.id)) {
        _savedNews.removeWhere((a) => a.id == article.id);
      } else {
        _savedNews.add(article);
      }
    });
  }

  bool _isSaved(int id) => _savedNews.any((a) => a.id == id);

  String _timeAgo(int timestamp) {
    int diff =
        (DateTime.now().millisecondsSinceEpoch / 1000).toInt() - timestamp;
    if (diff < 3600) return '${(diff / 60).floor()}m ago';
    if (diff < 86400) return '${(diff / 3600).floor()}h ago';
    return '${(diff / 86400).floor()}d ago';
  }

  void _showNewsDetail(Newsmodel article) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: cardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (article.image.isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: Image.network(
                      article.image,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 180,
                          color: const Color(0xFF1A1A1A),
                          child: const Center(
                            child: Icon(
                              Icons.newspaper,
                              color: Color(0xFF333333),
                              size: 48,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0x1AC9A84C),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _categoryLabels[article.category] ??
                                  article.category,
                              style: const TextStyle(
                                color: gold,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(ctx),
                            child: const Icon(
                              Icons.close,
                              color: Color(0xFF888888),
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        article.headline,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0x1AC9A84C),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                article.source[0].toUpperCase(),
                                style: const TextStyle(
                                  color: gold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            article.source,
                            style: const TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.access_time,
                            color: Color(0xFF555555),
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _timeAgo(article.datetime),
                            style: const TextStyle(
                              color: Color(0xFF555555),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                      if (article.summary.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(height: 1, color: const Color(0x1AFFFFFF)),
                        const SizedBox(height: 16),
                        Text(
                          article.summary,
                          style: const TextStyle(
                            color: Color(0xFFAAAAAA),
                            fontSize: 14,
                            height: 1.6,
                          ),
                        ),
                      ],
                      if (article.related.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(height: 1, color: const Color(0x1AFFFFFF)),
                        const SizedBox(height: 16),
                        const Text(
                          'Related',
                          style: TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: article.related.split(',').map((stock) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                stock.trim(),
                                style: const TextStyle(
                                  color: Color(0xFF888888),
                                  fontSize: 11,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
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
              onRefresh: () async => _loadNews(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTabs(),
                  const SizedBox(height: 16),
                  if (_showFeed) ...[
                    _buildCategories(),
                    const SizedBox(height: 16),
                    _buildNewsList(),
                  ] else
                    _buildSavedList(),
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
            'Latest updates',
            style: TextStyle(
              color: Color(0xFF888888),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Text(
            'News',
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

  Widget _buildTabs() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _showFeed = true),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: _showFeed ? const Color(0x26C9A84C) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _showFeed
                      ? const Color(0x4DC9A84C)
                      : Colors.transparent,
                ),
              ),
              child: const Center(
                child: Text(
                  'Live Feed',
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
            onTap: () => setState(() => _showFeed = false),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: !_showFeed
                    ? const Color(0x26C9A84C)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: !_showFeed
                      ? const Color(0x4DC9A84C)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_savedNews.isNotEmpty)
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
                          '${_savedNews.length}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  const Text(
                    'Saved',
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

  Widget _buildCategories() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((cat) {
          bool isActive = _activeCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() => _activeCategory = cat);
                _loadNews();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? const Color(0x26C9A84C)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? const Color(0x59C9A84C)
                        : const Color(0x1AFFFFFF),
                  ),
                ),
                child: Row(
                  children: [
                    if (isActive)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: const BoxDecoration(
                          color: gold,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      _categoryLabels[cat] ?? cat,
                      style: TextStyle(
                        color: isActive ? gold : const Color(0xFF888888),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNewsList() {
    if (_news.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0x0FFFFFFF)),
        ),
        child: const Center(
          child: Text(
            'No news available',
            style: TextStyle(color: Color(0xFF555555), fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      children: _news.asMap().entries.map((entry) {
        int index = entry.key;
        Newsmodel article = entry.value;
        bool saved = _isSaved(article.id);

        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () => _showNewsDetail(article),
              child: Container(
                decoration: BoxDecoration(
                  color: cardDark,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0x0FFFFFFF)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                          child: article.image.isNotEmpty
                              ? Image.network(
                                  article.image,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 180,
                                      color: const Color(0xFF1A1A1A),
                                      child: Center(
                                        child: Text(
                                          article.source[0],
                                          style: const TextStyle(
                                            color: Color(0xFF333333),
                                            fontSize: 40,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  height: 180,
                                  color: const Color(0xFF1A1A1A),
                                  child: Center(
                                    child: Text(
                                      article.source[0],
                                      style: const TextStyle(
                                        color: Color(0xFF333333),
                                        fontSize: 40,
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        Container(
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                const Color(0xD9141414),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xD9C9A84C),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _categoryLabels[article.category] ??
                                  article.category,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () => _toggleSave(article),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0x66000000),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                saved ? Icons.bookmark : Icons.bookmark_border,
                                color: saved ? gold : Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.headline,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: const Color(0x1FC9A84C),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: Text(
                                        article.source[0],
                                        style: const TextStyle(
                                          color: gold,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    article.source,
                                    style: const TextStyle(
                                      color: Color(0xFF888888),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: Color(0xFF555555),
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _timeAgo(article.datetime),
                                    style: const TextStyle(
                                      color: Color(0xFF555555),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
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
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _showNewsDetail(article),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0x0FFFFFFF)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: article.image.isNotEmpty
                        ? Image.network(
                            article.image,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: const Color(0xFF1A1A1A),
                                child: const Center(
                                  child: Text(
                                    'NEWS',
                                    style: TextStyle(
                                      color: Color(0xFF333333),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            color: const Color(0xFF1A1A1A),
                            child: const Center(
                              child: Text(
                                'NEWS',
                                style: TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            _categoryLabels[article.category] ??
                                article.category,
                            style: const TextStyle(
                              color: gold,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          article.headline,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              article.source,
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: Color(0xFF555555),
                                  size: 11,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  _timeAgo(article.datetime),
                                  style: const TextStyle(
                                    color: Color(0xFF555555),
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _toggleSave(article),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: saved
                                          ? const Color(0x1FC9A84C)
                                          : const Color(0xFF222222),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      saved
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      color: saved
                                          ? gold
                                          : const Color(0xFF888888),
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
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
      }).toList(),
    );
  }

  Widget _buildSavedList() {
    if (_savedNews.isEmpty) {
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
                Icons.bookmark_border,
                color: Color(0xFF555555),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No saved articles',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Bookmark articles from the feed to read later',
              style: TextStyle(color: Color(0xFF666666), fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _savedNews.map((article) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _showNewsDetail(article),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0x0FFFFFFF)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: article.image.isNotEmpty
                        ? Image.network(
                            article.image,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 80,
                                height: 80,
                                color: const Color(0xFF1A1A1A),
                                child: const Center(
                                  child: Text(
                                    'NEWS',
                                    style: TextStyle(
                                      color: Color(0xFF333333),
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 80,
                            height: 80,
                            color: const Color(0xFF1A1A1A),
                            child: const Center(
                              child: Text(
                                'NEWS',
                                style: TextStyle(
                                  color: Color(0xFF333333),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
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
                          article.headline,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              article.source,
                              style: const TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _toggleSave(article),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: const Color(0x1FC9A84C),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.bookmark,
                                  color: gold,
                                  size: 14,
                                ),
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
      }).toList(),
    );
  }
}
