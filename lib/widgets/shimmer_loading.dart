import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/constants.dart';

/// A shimmer skeleton placeholder shown while rates are loading.
class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF2A2A3E) : Colors.grey.shade200,
      highlightColor: isDark ? const Color(0xFF3A3A54) : Colors.grey.shade100,
      child: Column(
        children: [
          _shimmerBox(height: 56),
          const SizedBox(height: 12),
          _shimmerBox(height: 70),
          const SizedBox(height: 10),
          _shimmerBox(height: 70),
          const SizedBox(height: 12),
          _shimmerBox(height: 100),
        ],
      ),
    );
  }

  Widget _shimmerBox({required double height}) => Container(
        width: double.infinity,
        height: height,
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(kBorderRadius),
        ),
      );
}
