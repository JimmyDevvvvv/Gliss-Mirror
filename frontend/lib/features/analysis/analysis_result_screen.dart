import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../core/services/ai_service.dart';
import '../../core/services/product_service.dart';

class AnalysisResultScreen extends ConsumerStatefulWidget {
  final List<dynamic> photos;

  const AnalysisResultScreen({super.key, required this.photos});

  @override
  ConsumerState<AnalysisResultScreen> createState() =>
      _AnalysisResultScreenState();
}

class _AnalysisResultScreenState extends ConsumerState<AnalysisResultScreen> {
  late Future<Map<String, dynamic>> analysisResult;
  late Future<List<Product>> recommendedProducts;

  @override
  void initState() {
    super.initState();
    final aiService = AIService();
    final productService = ProductService();
    analysisResult = aiService.analyzeHairDamage(widget.photos.cast<File>());
    analysisResult.then((result) {
      recommendedProducts = productService.getRecommendedProducts(
        result['damageScore'].toDouble(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analysis Results')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: analysisResult,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'Hair Damage Score',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${data['damageScore']}/10',
                          style: const TextStyle(fontSize: 48),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Identified Issues:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ...List.generate(
                  (data['issues'] as List).length,
                  (index) => ListTile(
                    leading: const Icon(Icons.warning),
                    title: Text(data['issues'][index]),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Recommended Products:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                FutureBuilder<List<Product>>(
                  future: recommendedProducts,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return Column(
                      children: snapshot.data!
                          .map(
                            (product) => Card(
                              child: ListTile(
                                title: Text(product.name),
                                subtitle: Text(product.description),
                                trailing: Text('\$${product.price}'),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
