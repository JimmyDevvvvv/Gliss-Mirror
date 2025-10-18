import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/maya_service.dart';
import '../screens/maya_analysis_modal.dart';

class AnalyzeScreen extends StatefulWidget {
  const AnalyzeScreen({super.key});

  @override
  State<AnalyzeScreen> createState() => _AnalyzeScreenState();
}

class _AnalyzeScreenState extends State<AnalyzeScreen> {
  File? _imageFile;
  Uint8List? _webImage;
  Map<String, dynamic>? _result;
  bool isLoading = false;

  final ImagePicker _picker = ImagePicker();

  // Pick image from gallery (works for web + mobile)
  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _webImage = bytes;
          _imageFile = null;
          _result = null; // Clear previous results
        });
      } else {
        setState(() {
          _imageFile = File(picked.path);
          _webImage = null;
          _result = null; // Clear previous results
        });
      }
    }
  }

  // Call backend for analysis
  Future<void> _analyze() async {
    if (_imageFile == null && _webImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image first!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await ApiService.analyzeHair(
        webImage: _webImage,
        file: _imageFile,
      );

      setState(() {
        _result = {
          'score': result['score'] ?? result['damage_score'] ?? 0.0,
          'detected_texture': result['detected_texture'] ?? 'Unknown',
          'primary_concern': result['primary_concern'] ?? 'N/A',
          'recommended_product': result['recommended_product'] ?? 'N/A',
          'level': result['level'] ?? 'Unknown',
          'care_level': result['care_level'] ?? 'Gentle'
        };
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hair analyzed successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error analyzing image: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Save scan and trigger Maya analysis
  Future<void> _saveScan() async {
    if (_result == null) return;

    try {
      final scanData = {
        'score': _result!['score'],
        'damage_score': _result!['score'],
        'detected_texture': _result!['detected_texture'],
        'primary_concern': _result!['primary_concern'],
        'recommended_product': _result!['recommended_product'],
        'level': _result!['level'],
        'care_level': _result!['care_level'],
      };

      // Save to backend
      await ApiService.saveScan(scanData);

      // Notify Maya about the new scan
      if (mounted) {
        final mayaService = Provider.of<MayaService>(context, listen: false);
        await mayaService.onScanCompleted(scanData);

        // Show Maya's beautiful analysis modal
        showMayaAnalysisModal(
          context: context,
          scanData: scanData,
          mayaMessage: mayaService.currentMessage,
          onChatWithMaya: () {
            // Maya's floating avatar will already be glowing
            // User just needs to tap it to continue
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save scan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            const Text(
              'Hair Analysis',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upload a photo to analyze your hair health',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),

            // Image preview
            _buildImagePreview(),

            const SizedBox(height: 20),

            // Action buttons
            _buildActionButtons(),

            const SizedBox(height: 24),

            // Results
            if (isLoading) _buildLoadingState(),
            if (_result != null && !isLoading) _buildResults(),

            const SizedBox(height: 100), // Space for floating Maya
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: _imageFile != null || _webImage != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: kIsWeb
                  ? Image.memory(_webImage!, fit: BoxFit.cover)
                  : Image.file(_imageFile!, fit: BoxFit.cover),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No image selected',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Pick Image Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.photo_library, size: 22),
            label: const Text(
              'Select Hair Photo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Analyze Button
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: (_imageFile != null || _webImage != null) && !isLoading
                ? _analyze
                : null,
            icon: const Icon(Icons.science, size: 22),
            label: const Text(
              'Analyze Hair',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 2,
              disabledBackgroundColor: Colors.grey.shade300,
            ),
          ),
        ),

        if (_result != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _saveScan,
              icon: const Icon(Icons.save, size: 22),
              label: const Text(
                'Save Scan & Get Maya\'s Advice',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            color: Colors.pinkAccent,
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            'Analyzing your hair...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final score = _parseDouble(_result!['score']);
    final level = _result!['level']?.toString() ?? 'Unknown';
    final texture = _result!['detected_texture']?.toString() ?? 'Unknown';
    final concern = _result!['primary_concern']?.toString() ?? 'N/A';
    final product = _result!['recommended_product']?.toString() ?? 'N/A';
    final careLevel = _result!['care_level']?.toString() ?? 'N/A';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getScoreColor(score).withOpacity(0.1),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getScoreColor(score).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assessment, color: Colors.pinkAccent, size: 28),
              const SizedBox(width: 12),
              const Text(
                'Analysis Results',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Score circle
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 140,
                  height: 140,
                  child: CircularProgressIndicator(
                    value: score / 10,
                    strokeWidth: 14,
                    color: _getScoreColor(score),
                    backgroundColor: _getScoreColor(score).withOpacity(0.2),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      score.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(score),
                      ),
                    ),
                    Text(
                      '/ 10',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Level badge
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _getScoreColor(score),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                level,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Details
          _buildDetailRow(Icons.texture, 'Texture', texture),
          _buildDetailRow(Icons.warning_amber, 'Concern', concern),
          _buildDetailRow(Icons.healing, 'Care Level', careLevel),
          _buildDetailRow(Icons.shopping_bag, 'Product', product),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.pinkAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.pinkAccent, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Color _getScoreColor(double score) {
    if (score < 3.5) return Colors.green;
    if (score < 6.5) return Colors.orange;
    return Colors.red;
  }
}