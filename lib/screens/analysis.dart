import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Analysis());
}

class Analysis extends StatelessWidget {
  const Analysis({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StockDetailsPage(),
    );
  }
}

class StockDetailsPage extends StatefulWidget {
  const StockDetailsPage({super.key});

  @override
  State<StockDetailsPage> createState() => _StockDetailsPageState();
}

class _StockDetailsPageState extends State<StockDetailsPage> {
  final PageController controller = PageController(
    viewportFraction: 0.35,
  );

  int currentIndex = 0;

  final List<Map<String, String>> companies = [
    {
      "symbol": "AAPL",
      "price": "\$287.44",
      "sector": "Technology",
      "change": "-0.07 (-0.02%)",
    },
    {
      "symbol": "TSLA",
      "price": "\$198.11",
      "sector": "Automotive",
      "change": "+1.20 (0.61%)",
    },
    {
      "symbol": "MSFT",
      "price": "\$412.09",
      "sector": "Software",
      "change": "+0.90 (0.21%)",
    },
    {
      "symbol": "NVDA",
      "price": "\$901.77",
      "sector": "AI",
      "change": "+4.55 (1.11%)",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final company = companies[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xff050505),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // top card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: const Color(0xff111214),
                    borderRadius: BorderRadius.circular(24),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // slider
                      SizedBox(
                        height: 40,

                        child: PageView.builder(
                          controller: controller,
                          itemCount: companies.length,

                          onPageChanged: (index) {
                            setState(() {
                              currentIndex = index;
                            });
                          },

                          itemBuilder: (context, index) {
                            final isActive =
                                index == currentIndex;

                            return AnimatedContainer(
                              duration: const Duration(
                                milliseconds: 250,
                              ),

                              alignment:
                                  Alignment.centerLeft,

                              child: Text(
                                companies[index]["symbol"]!,

                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : Colors.grey.shade600,

                                  fontSize:
                                      isActive ? 32 : 24,

                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // price
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,

                        children: [

                          Text(
                            company["price"]!,

                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),

                            decoration: BoxDecoration(
                              color:
                                  const Color(0xff341417),

                              borderRadius:
                                  BorderRadius.circular(20),
                            ),

                            child: Text(
                              company["change"]!,

                              style: const TextStyle(
                                color:
                                    Color(0xffFF4D57),
                                fontSize: 14,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // sector
                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),

                        decoration: BoxDecoration(
                          color: const Color(0xff1a1b1f),

                          borderRadius:
                              BorderRadius.circular(18),
                        ),

                        child: Text(
                          company["sector"]!,

                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // chart
                Container(
                  width: double.infinity,
                  height: 320,
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: const Color(0xff111214),
                    borderRadius: BorderRadius.circular(24),
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      Text(
                        company["symbol"]!,

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        company["price"]!,

                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                        ),
                      ),

                      const SizedBox(height: 25),

                      Expanded(
                        child: LineChart(
                          LineChartData(
                            backgroundColor:
                                Colors.transparent,

                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,

                              getDrawingHorizontalLine:
                                  (value) {
                                return FlLine(
                                  color:
                                      Colors.white10,
                                  strokeWidth: 1,
                                );
                              },
                            ),

                            borderData:
                                FlBorderData(show: false),

                            titlesData:
                                FlTitlesData(
                              leftTitles:
                                  const AxisTitles(
                                sideTitles:
                                    SideTitles(
                                  showTitles: false,
                                ),
                              ),

                              topTitles:
                                  const AxisTitles(
                                sideTitles:
                                    SideTitles(
                                  showTitles: false,
                                ),
                              ),

                              rightTitles:
                                  const AxisTitles(
                                sideTitles:
                                    SideTitles(
                                  showTitles: false,
                                ),
                              ),

                              bottomTitles:
                                  AxisTitles(
                                sideTitles:
                                    SideTitles(
                                  showTitles: true,
                                  reservedSize: 25,

                                  getTitlesWidget:
                                      (value, meta) {
                                    switch (
                                        value.toInt()) {
                                      case 0:
                                        return const Text(
                                          "Mon",
                                          style: TextStyle(
                                            color:
                                                Colors.grey,
                                            fontSize: 12,
                                          ),
                                        );

                                      case 2:
                                        return const Text(
                                          "Wed",
                                          style: TextStyle(
                                            color:
                                                Colors.grey,
                                            fontSize: 12,
                                          ),
                                        );

                                      case 4:
                                        return const Text(
                                          "Fri",
                                          style: TextStyle(
                                            color:
                                                Colors.grey,
                                            fontSize: 12,
                                          ),
                                        );
                                    }

                                    return const SizedBox();
                                  },
                                ),
                              ),
                            ),

                            minX: 0,
                            maxX: 5,

                            minY: 0,
                            maxY: 6,

                            lineBarsData: [

                              LineChartBarData(
                                spots: const [
                                  FlSpot(0, 2),
                                  FlSpot(1, 3),
                                  FlSpot(2, 2.5),
                                  FlSpot(3, 4),
                                  FlSpot(4, 3.8),
                                  FlSpot(5, 5),
                                ],

                                isCurved: true,

                                color:
                                    const Color(
                                  0xffE4B84C,
                                ),

                                barWidth: 4,

                                dotData:
                                    const FlDotData(
                                  show: false,
                                ),

                                belowBarData:
                                    BarAreaData(
                                  show: true,

                                  gradient:
                                      LinearGradient(
                                    begin:
                                        Alignment
                                            .topCenter,

                                    end: Alignment
                                        .bottomCenter,

                                    colors: [
                                      const Color(
                                        0xffE4B84C,
                                      ).withOpacity(
                                        0.4,
                                      ),

                                      Colors
                                          .transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // metrics title
                const Text(
                  "Key Metrics",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // metrics cards
                GridView.count(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),

                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.1,

                  children: const [

                    MetricCard(
                      title: "52W High",
                      value: "\$288.62",
                    ),

                    MetricCard(
                      title: "52W Low",
                      value: "\$193.25",
                    ),

                    MetricCard(
                      title: "Market Cap",
                      value: "\$4219.1B",
                    ),

                    MetricCard(
                      title: "P/E Ratio",
                      value: "37.67",
                    ),

                    MetricCard(
                      title: "EPS",
                      value: "\$7.46",
                    ),

                    MetricCard(
                      title: "Beta",
                      value: "1.07",
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // about card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),

                  decoration: BoxDecoration(
                    color: const Color(0xff0d0b08),

                    borderRadius:
                        BorderRadius.circular(28),

                    border: Border.all(
                      color: const Color(0xff2b2110),
                    ),
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,

                    children: [

                      const Text(
                        "About Apple Inc",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 28),

                      const Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [

                          Expanded(
                            child: InfoItem(
                              title: "Exchange",
                              value:
                                  "NASDAQ NMS -\nGLOBAL MARKET",
                            ),
                          ),

                          Expanded(
                            child: InfoItem(
                              title: "Currency",
                              value: "USD",
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 26),

                      const Row(
                        children: [

                          Expanded(
                            child: InfoItem(
                              title: "Country",
                              value: "US",
                            ),
                          ),

                          Expanded(
                            child: InfoItem(
                              title: "IPO",
                              value: "1980-12-12",
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      Row(
                        children: [

                          const Icon(
                            Icons.language,
                            color:
                                Color(0xffd4a62a),
                            size: 20,
                          ),

                          const SizedBox(width: 10),

                          Text(
                            "www.apple.com/",

                            style: const TextStyle(
                              color:
                                  Color(0xffd4a62a),

                              fontSize: 18,

                              fontWeight:
                                  FontWeight.w600,
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
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String title;
  final String value;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: const Color(0xff0f1013),

        borderRadius: BorderRadius.circular(24),

        border: Border.all(
          color: const Color(0xff1d1f24),
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          Text(
            title,

            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            value,

            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoItem extends StatelessWidget {
  final String title;
  final String value;

  const InfoItem({
    super.key,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        Text(
          title,

          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 15,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          value,

          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}