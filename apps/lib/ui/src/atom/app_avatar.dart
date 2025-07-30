import 'dart:math' as math; // For random color generation

import 'package:cached_network_image/cached_network_image.dart';
import 'package:docu_fill/ui/ui.dart';
import 'package:flutter/material.dart';

class AppAvatar extends StatelessWidget {
  /// The URL of the avatar image.
  final String? avatarUrl;

  /// The display name of the user, used to generate initials if the image fails or is not provided.
  final String displayName;

  /// The radius of the circle avatar. Defaults to 24.0.
  final double? radius;

  /// The font size for the initials. If null, it's calculated based on the radius.
  final double? initialsFontSize;

  /// The background color for the initials placeholder. If null, a random color based on the display name is generated.
  final Color? placeholderBackgroundColor;

  /// The text color for the initials. Defaults to white.
  final Color initialsTextColor;

  /// Optional widget to display while the network image is loading.
  final Widget? loadingIndicator;

  const AppAvatar({
    super.key,
    this.avatarUrl,
    required this.displayName,
    this.radius,
    this.initialsFontSize,
    this.placeholderBackgroundColor,
    this.initialsTextColor = Colors.white,
    this.loadingIndicator,
  });

  String _getInitials(String name) {
    if (name.isEmpty) {
      return '?';
    }
    List<String> nameParts = name.trim().split(RegExp(r'\s+'));
    if (nameParts.isEmpty) {
      return '?';
    }
    if (nameParts.length == 1) {
      return nameParts[0]
          .substring(0, math.min(nameParts[0].length, 2))
          .toUpperCase();
    }
    String firstInitial = nameParts[0].isNotEmpty ? nameParts[0][0] : '';
    String secondInitial =
        nameParts.length > 1 && nameParts.last.isNotEmpty
            ? nameParts.last[0]
            : '';
    return (firstInitial + secondInitial).toUpperCase();
  }

  Color _getRandomBackgroundColor(String name) {
    // Simple hash function to get a somewhat consistent color based on the name
    final int hash = name.hashCode;
    final math.Random random = math.Random(hash);
    return Color.fromRGBO(
      random.nextInt(156) + 100,
      // Keep colors somewhat vibrant and not too dark
      random.nextInt(156) + 100,
      random.nextInt(156) + 100,
      1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final String initials = _getInitials(displayName);
    final double effectiveRadius = radius ?? Dimens.size24;
    final double effectiveFontSize =
        initialsFontSize ??
        effectiveRadius * 0.8; // Adjust multiplier as needed

    Widget buildPlaceholder() {
      return CircleAvatar(
        radius: effectiveRadius,
        backgroundColor:
            placeholderBackgroundColor ??
            _getRandomBackgroundColor(displayName),
        child: Text(
          initials,
          style: TextStyle(
            color: initialsTextColor,
            fontSize: effectiveFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (avatarUrl == null || avatarUrl!.trim().isEmpty) {
      return buildPlaceholder();
    }

    return CachedNetworkImage(
      imageUrl: avatarUrl!,
      imageBuilder:
          (context, imageProvider) => CircleAvatar(
            radius: effectiveRadius,
            backgroundImage: imageProvider,
          ),
      placeholder:
          (context, url) =>
              loadingIndicator ??
              CircleAvatar(
                radius: effectiveRadius,
                backgroundColor:
                    placeholderBackgroundColor ??
                    _getRandomBackgroundColor(displayName).withOpacity(0.7),
                // Slightly transparent during load
                child: SizedBox(
                  // You can put a CircularProgressIndicator here if desired
                  width: effectiveRadius * 0.8,
                  height: effectiveRadius * 0.8,
                  child: CircularProgressIndicator.adaptive(
                    strokeWidth: Dimens.size2,
                  ),
                ),
              ),
      errorWidget: (context, url, error) => buildPlaceholder(),
      fadeOutDuration: const Duration(milliseconds: 150),
      fadeInDuration: const Duration(milliseconds: 150),
    );
  }
}
