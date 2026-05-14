import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'dart:io' as io;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PremiumImageViewer extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const PremiumImageViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Blurred Backdrop
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(color: Colors.black.withOpacity(0.85)),
            ),
          ),

          // Image Gallery
          PhotoViewGallery.builder(
            scrollPhysics: const BouncingScrollPhysics(),
            builder: (BuildContext context, int index) {
              final url = imageUrls[index];
              return PhotoViewGalleryPageOptions(
                imageProvider: kIsWeb
                    ? NetworkImage(url)
                    : FileImage(io.File(url)) as ImageProvider,
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 4.1,
                heroAttributes: PhotoViewHeroAttributes(tag: url),
              );
            },
            itemCount: imageUrls.length,
            loadingBuilder: (context, event) => const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            ),
            pageController: PageController(initialPage: initialIndex),
            backgroundDecoration:
                const BoxDecoration(color: Colors.transparent),
          ),

          // Controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (imageUrls.length > 1)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Text(
                      '${initialIndex + 1} / ${imageUrls.length}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
