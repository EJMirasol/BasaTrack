import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../core/theme/app_colors.dart';

class PdfViewerScreen extends StatelessWidget {
  final String title;
  final String assetPath;

  const PdfViewerScreen({
    required this.title,
    required this.assetPath,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SfPdfViewer.asset(assetPath),
    );
  }
}
