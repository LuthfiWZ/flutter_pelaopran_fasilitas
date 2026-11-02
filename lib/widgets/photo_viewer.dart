import 'package:flutter/material.dart';

class PhotoViewer extends StatelessWidget {
  final String url;

  const PhotoViewer({super.key, required this.url});

  static void show(BuildContext context, String url) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PhotoViewer(url: url)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4,
          child: Image.network(
            url,
            fit: BoxFit.contain,
            webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const CircularProgressIndicator(color: Colors.white);
            },
            errorBuilder: (_, _, error) => Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white70,
                    size: 64,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Gagal memuat foto\n$url\n$error',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
