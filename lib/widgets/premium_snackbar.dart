import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PremiumSnackbar {
  static void show(BuildContext context, {
    required String message,
    bool isError = true,
  }) {
    // Prevent multiple snackbars stacking by hiding current one
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        padding: const EdgeInsets.only(bottom: 20, left: 16, right: 16),
        duration: const Duration(seconds: 4),
        content: Center(
          child: Animate(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E).withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isError ? Colors.redAccent.withOpacity(0.3) : Colors.greenAccent.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isError ? Colors.red : Colors.green).withOpacity(0.1),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isError ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                    color: isError ? Colors.redAccent : Colors.greenAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ).slideY(begin: 0.5, end: 0, duration: const Duration(milliseconds: 400), curve: Curves.easeOutBack).fadeIn(),
        ),
      ),
    );
  }
}
