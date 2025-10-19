import 'package:flutter/material.dart';

/// Dialog shown before taking/analyzing hair photo
/// Provides important guidelines for accurate analysis
class PreAnalysisDialog extends StatefulWidget {
  final VoidCallback onProceed;

  const PreAnalysisDialog({
    super.key,
    required this.onProceed,
  });

  @override
  State<PreAnalysisDialog> createState() => _PreAnalysisDialogState();
}

class _PreAnalysisDialogState extends State<PreAnalysisDialog> {
  bool? isDyed;
  bool hasReadGuidelines = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 750),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE30613).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Color(0xFFE30613),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Before You Analyze',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Guidelines
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'For accurate analysis, please ensure:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildGuideline(
                      icon: Icons.straighten,
                      title: 'Hair Position',
                      description: 'Hair should be straight and hanging naturally',
                      color: const Color(0xFFE30613),
                    ),

                    _buildGuideline(
                      icon: Icons.water_drop_outlined,
                      title: 'Natural State',
                      description: 'No styling products, oils, or treatments applied',
                      color: const Color(0xFF00A3E0),
                    ),

                    _buildGuideline(
                      icon: Icons.wb_sunny_outlined,
                      title: 'Good Lighting',
                      description: 'Take photo in natural light, avoid harsh shadows',
                      color: const Color(0xFFFDB913),
                    ),

                    _buildGuideline(
                      icon: Icons.center_focus_strong,
                      title: 'Clear Focus',
                      description: 'Hair should be in focus, fill most of the frame',
                      color: const Color(0xFF6CC24A),
                    ),

                    const SizedBox(height: 24),
                    
                    // REFERENCE IMAGE SECTION
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE30613).withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE30613).withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.image_outlined,
                                color: Color(0xFFE30613),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Reference Example',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          // Reference image
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/hair_reference.png',
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback if image not found
                                return Container(
                                  height: 180,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Reference image',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Hair straight, natural lighting',
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          Text(
                            '✓ Straight hair, good lighting, clear focus',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                              fontStyle: FontStyle.italic,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Hair dye question
                    const Text(
                      'Is your hair currently dyed?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _buildChoiceButton(
                            label: 'Yes, it\'s dyed',
                            isSelected: isDyed == true,
                            onTap: () => setState(() => isDyed = true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildChoiceButton(
                            label: 'No, natural',
                            isSelected: isDyed == false,
                            onTap: () => setState(() => isDyed = false),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Confirmation checkbox
                    CheckboxListTile(
                      value: hasReadGuidelines,
                      onChanged: (value) => setState(() => hasReadGuidelines = value ?? false),
                      activeColor: const Color(0xFFE30613),
                      title: const Text(
                        'I understand these guidelines',
                        style: TextStyle(fontSize: 14),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF9E9E9E), width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: (isDyed != null && hasReadGuidelines)
                        ? () {
                            Navigator.of(context).pop();
                            widget.onProceed();
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE30613),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: const Color(0xFFE0E0E0),
                    ),
                    child: const Text(
                      'Continue to Photo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideline({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE30613) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFFE30613) : const Color(0xFFE0E0E0),
            width: 2,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }
}

/// Helper function to show the dialog
Future<void> showPreAnalysisDialog({
  required BuildContext context,
  required VoidCallback onProceed,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => PreAnalysisDialog(onProceed: onProceed),
  );
}