import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Displays a slim animated banner at the top of the screen when offline,
/// and hides smoothly when back online.
class OfflineBanner extends StatelessWidget {
  final bool isOnline;
  final String? cacheAge; // e.g. "2h ago"

  const OfflineBanner({
    super.key,
    required this.isOnline,
    this.cacheAge,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: isOnline ? const Offset(0, -1) : Offset.zero,
      duration: kAnimDurationMedium,
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: isOnline ? 0 : 1,
        duration: kAnimDurationMedium,
        child: Container(
          width: double.infinity,
          color: kOffline.withValues(alpha: 0.92),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 14),
              const SizedBox(width: 6),
              Text(
                cacheAge != null
                    ? '📡 Offline — using cached rates from $cacheAge'
                    : '📡 Offline — using fallback rates',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
