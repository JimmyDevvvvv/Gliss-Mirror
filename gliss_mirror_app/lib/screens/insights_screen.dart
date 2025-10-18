import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _insights;
  List<dynamic> _history = [];
  bool _isLoading = true;
  String? _errorMessage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final insights = await ApiService.getInsights();
      final history = await ApiService.getHistory();
      
      print('📊 Data loaded: ${history.length} scans');
      
      setState(() {
        _insights = insights;
        _history = history.reversed.toList(); // Newest first
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading data: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📊 Hair Analytics"),
        backgroundColor: Colors.pinkAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
            tooltip: 'Refresh data',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: const [
            Tab(
              icon: Icon(Icons.insights),
              text: "Insights",
            ),
            Tab(
              icon: Icon(Icons.history),
              text: "History",
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.pinkAccent),
                  SizedBox(height: 16),
                  Text('Loading data...', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : _errorMessage != null
              ? _buildErrorView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildInsightsTab(),
                    _buildHistoryTab(),
                  ],
                ),
    );
  }

  // ==================== ERROR VIEW ====================
  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== INSIGHTS TAB ====================
  Widget _buildInsightsTab() {
    if (_insights == null) {
      return const Center(child: Text("No insights available"));
    }

    final avg = _parseDouble(_insights?["average_score"]);
    final best = _parseDouble(_insights?["best_score"]);
    final worst = _parseDouble(_insights?["worst_score"]);
    final trend = _insights?["trend"]?.toString() ?? "Stable ⚪";
    final insightMsg = _insights?["insight"]?.toString() ?? "No insight available.";
    final total = _parseInt(_insights?["total_scans"]);
    final delta = _parseDouble(_insights?["delta"]);

    Color trendColor;
    IconData trendIcon;
    if (trend.contains("🟢") || trend.toLowerCase().contains("improv")) {
      trendColor = Colors.green;
      trendIcon = Icons.trending_up;
    } else if (trend.contains("🔴") || trend.toLowerCase().contains("worsen")) {
      trendColor = Colors.redAccent;
      trendIcon = Icons.trending_down;
    } else {
      trendColor = Colors.grey;
      trendIcon = Icons.trending_flat;
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Average Damage Score",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 150,
                  width: 150,
                  child: CircularProgressIndicator(
                    value: avg / 10,
                    strokeWidth: 12,
                    color: _getScoreColor(avg),
                    backgroundColor: _getScoreColor(avg).withOpacity(0.1),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      avg.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      "/ 10",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statCard("Best", best.toStringAsFixed(1), Icons.thumb_up_alt, Colors.green),
                _statCard("Worst", worst.toStringAsFixed(1), Icons.thumb_down_alt, Colors.redAccent),
                _statCard("Total", total.toString(), Icons.history, Colors.blueAccent),
              ],
            ),
            const SizedBox(height: 25),
            Card(
              color: trendColor.withOpacity(0.1),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(trendIcon, color: trendColor, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Trend: $trend",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: trendColor),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (delta != 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: delta > 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: delta > 0 ? Colors.green : Colors.red, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(delta > 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        color: delta > 0 ? Colors.green : Colors.red),
                    const SizedBox(width: 8),
                    Text(
                      delta > 0
                          ? "Improved by ${delta.abs().toStringAsFixed(1)} points!"
                          : "Worsened by ${delta.abs().toStringAsFixed(1)} points",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: delta > 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            if (delta == 0 && total > 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.horizontal_rule, color: Colors.grey),
                    SizedBox(width: 8),
                    Text("Stable results",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey)),
                  ],
                ),
              ),
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.pinkAccent, Colors.purpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pinkAccent.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lightbulb, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text("Maya's Hair Health Insight",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(insightMsg,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5)),
                ],
              ),
            ),
            if (total == 0)
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Column(
                  children: [
                    const Icon(Icons.info_outline, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text("No scan history yet", style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    const Text("Start analyzing your hair to see insights!",
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ==================== HISTORY TAB ====================
  Widget _buildHistoryTab() {
    if (_history.isEmpty) {
      return _buildEmptyHistoryView();
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.pinkAccent, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.pinkAccent.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text('Your Hair Health Journey',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${_history.length} scans tracked',
                    style: const TextStyle(color: Colors.white70, fontSize: 14)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (context, index) => _buildHistoryCard(_history[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistoryView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No scan history yet', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Start analyzing your hair to build your health timeline!',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> scan) {
    final damageScore = _parseDouble(scan['damage_score']);
    final level = scan['level']?.toString() ?? 'Unknown';
    final texture = scan['detected_texture']?.toString() ?? 'Unknown';
    final product = scan['recommended_product']?.toString() ?? 'N/A';
    final concern = scan['primary_concern']?.toString() ?? 'N/A';
    final careLevel = scan['care_level']?.toString() ?? 'N/A';
    final timestamp = scan['timestamp']?.toString() ?? '';

    String formattedDate = 'Unknown date';
    String timeAgo = '';
    if (timestamp.isNotEmpty) {
      try {
        final date = DateTime.parse(timestamp);
        formattedDate = DateFormat('MMM dd, yyyy').format(date);
        timeAgo = _getTimeAgo(date);
      } catch (e) {
        print('Error parsing date: $e');
      }
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _getScoreColor(damageScore).withOpacity(0.3), width: 2),
      ),
      child: InkWell(
        onTap: () => _showDetailDialog(scan),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getScoreColor(damageScore),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite, color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text('${damageScore.toStringAsFixed(1)}/10',
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(formattedDate,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      if (timeAgo.isNotEmpty)
                        Text(timeAgo,
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getScoreColor(damageScore).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(level,
                    style: TextStyle(
                        color: _getScoreColor(damageScore), fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildInfoChip(Icons.texture, 'Texture', texture, Colors.blue)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildInfoChip(Icons.healing, 'Care', careLevel, Colors.green)),
                ],
              ),
              const SizedBox(height: 8),
              _buildInfoRow(Icons.warning_amber, concern),
              const SizedBox(height: 6),
              _buildInfoRow(Icons.shopping_bag, product),
              const SizedBox(height: 8),
              Center(
                child: Text('Tap for details',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontStyle: FontStyle.italic)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Expanded(
          child: Text(text,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  void _showDetailDialog(Map<String, dynamic> scan) {
    final damageScore = _parseDouble(scan['damage_score']);
    final timestamp = scan['timestamp']?.toString() ?? '';
    String formattedDateTime = 'Unknown';
    if (timestamp.isNotEmpty) {
      try {
        final date = DateTime.parse(timestamp);
        formattedDateTime = DateFormat('MMMM dd, yyyy • hh:mm a').format(date);
      } catch (e) {
        print('Error parsing date: $e');
      }
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: CircularProgressIndicator(
                      value: damageScore / 10,
                      strokeWidth: 10,
                      color: _getScoreColor(damageScore),
                      backgroundColor: _getScoreColor(damageScore).withOpacity(0.1),
                    ),
                  ),
                  Text(damageScore.toStringAsFixed(1),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              Text(scan['level']?.toString() ?? 'Unknown',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: _getScoreColor(damageScore))),
              const SizedBox(height: 8),
              Text(formattedDateTime, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              _buildDetailRow('💇‍♀️ Texture', scan['detected_texture']),
              _buildDetailRow('💭 Concern', scan['primary_concern']),
              _buildDetailRow('🛡️ Care Level', scan['care_level']),
              _buildDetailRow('⭐ Product', scan['recommended_product']),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent, minimumSize: const Size(double.infinity, 44)),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ),
          Expanded(child: Text(value?.toString() ?? 'N/A', style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Color _getScoreColor(double score) {
    if (score < 3.5) return Colors.green;
    if (score < 6.5) return Colors.orange;
    return Colors.red;
  }
}