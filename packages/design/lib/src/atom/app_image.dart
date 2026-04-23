import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart' as svg;
import 'package:path/path.dart' as p; // For path manipulation

enum _ImageType { network, file, asset, svgNetwork, svgFile, svgAsset }

class SmartImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? svgColor; // Optional: For tinting SVG
  final String? semanticLabel; // For accessibility

  const SmartImage({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.svgColor,
    this.semanticLabel,
  });

  _ImageType _getImageType(String imagePath) {
    final String lowerPath = imagePath.toLowerCase();
    final String extension = p.extension(lowerPath); // Using path package

    final bool isSvg = extension == '.svg';

    if (lowerPath.startsWith('http://') || lowerPath.startsWith('https://')) {
      return isSvg ? _ImageType.svgNetwork : _ImageType.network;
    } else if (lowerPath.startsWith('assets/')) {
      // Conventionally, project assets are referenced like this in Flutter
      return isSvg ? _ImageType.svgAsset : _ImageType.asset;
    } else if (lowerPath.startsWith('/')) {
      // Absolute file path
      return isSvg ? _ImageType.svgFile : _ImageType.file;
    } else {
      // This could be a relative file path OR an asset path without the "assets/" prefix
      // For simplicity, if it's not network or absolute file, we'll try it as an asset first.
      // A more robust solution for file paths might involve checking `File(path).existsSync()`
      // but that's synchronous and can be slow if done frequently during build.
      // For this example, we'll assume non-HTTP/HTTPS and non-absolute paths without "assets/"
      // might be assets. If that fails, it's likely a file path intended by the user.

      // A common pattern is to just pass asset keys like "images/my_icon.png"
      // If `pubspec.yaml` declares "assets/images/", then "images/my_icon.png" is valid.
      // Let's refine this to be more explicit for assets if they don't have the full "assets/" prefix.
      // For this example, we'll assume if it's not starting with known prefixes, and is SVG, try svgAsset.
      // Otherwise, if not SVG and not starting with known prefixes, try as a regular asset.
      // This part can be tricky without more context on how asset paths are provided.
      // A common convention is that asset paths are relative to the project root or specified in pubspec.

      // Let's assume paths NOT starting with http, https, or / are assets
      // (This is a simplification; in a real app, you might have stricter rules or pass an `ImageType` enum)
      if (isSvg) {
        return _ImageType
            .svgAsset; // Or potentially _ImageType.svgFile if relative paths are expected
      } else {
        return _ImageType.asset; // Or potentially _ImageType.file
      }
      // For a truly robust file detection for relative paths, you'd need more context or an explicit type.
    }
    // Return _ImageType.unsupported if none of the above match, though the logic above is quite broad.
  }

  @override
  Widget build(BuildContext context) {
    final imageType = _getImageType(path);

    Widget imageContent;

    switch (imageType) {
      case _ImageType.network:
        imageContent = CachedNetworkImage(
          imageUrl: path,
          width: width,
          height: height,
          fit: fit,
          placeholder:
              placeholder != null
                  ? (context, url) => placeholder!
                  : (context, url) =>
                      const Center(child: CircularProgressIndicator.adaptive()),
          errorWidget:
              errorWidget != null
                  ? (context, url, error) => errorWidget!
                  : (context, url, error) =>
                      const Icon(Icons.error_outline, size: 40),
          fadeOutDuration: const Duration(milliseconds: 300),
          fadeInDuration: const Duration(milliseconds: 300),
        );
        break;
      case _ImageType.file:
        imageContent = Image.file(
          File(path), // Create a File object
          width: width,
          height: height,
          fit: fit,
          errorBuilder:
              errorWidget != null
                  ? (context, error, stackTrace) => errorWidget!
                  : (context, error, stackTrace) =>
                      const Icon(Icons.broken_image_outlined, size: 40),
        );
        break;
      case _ImageType.asset:
        imageContent = Image.asset(
          path,
          width: width,
          height: height,
          fit: fit,
          errorBuilder:
              errorWidget != null
                  ? (context, error, stackTrace) => errorWidget!
                  : (context, error, stackTrace) =>
                      const Icon(Icons.image_not_supported_outlined, size: 40),
        );
        break;
      case _ImageType.svgNetwork:
        imageContent = svg.SvgPicture.network(
          path,
          width: width,
          height: height,
          fit: fit,
          colorFilter:
              svgColor != null
                  ? ColorFilter.mode(svgColor!, BlendMode.srcIn)
                  : null,
          placeholderBuilder:
              placeholder != null
                  ? (context) => placeholder!
                  : (context) =>
                      const Center(child: CircularProgressIndicator.adaptive()),
          semanticsLabel: semanticLabel,
        );
        break;
      // case _ImageType.svgFile:
      //   imageContent = svg.SvgPicture.file(
      //     File(path), // Create a File object
      //     width: width,
      //     height: height,
      //     fit: fit,
      //     colorFilter:
      //         svgColor != null
      //             ? ColorFilter.mode(svgColor!, BlendMode.srcIn)
      //             : null,
      //     placeholderBuilder:
      //         placeholder != null
      //             ? (context) => placeholder!
      //             : (context) => const Center(
      //               child: CircularProgressIndicator.adaptive(),
      //             ), // SvgPicture.file doesn't have a direct error builder like Image.file
      //     semanticsLabel: semanticLabel,
      //   );
      //   break;`
      case _ImageType.svgAsset:
        imageContent = svg.SvgPicture.asset(
          path,
          width: width,
          height: height,
          fit: fit,
          colorFilter:
              svgColor != null
                  ? ColorFilter.mode(svgColor!, BlendMode.srcIn)
                  : null,
          placeholderBuilder:
              placeholder != null
                  ? (context) => placeholder!
                  : (context) =>
                      const Center(child: CircularProgressIndicator.adaptive()),
          semanticsLabel: semanticLabel,
        );
        break;
      default:
        imageContent =
            errorWidget ??
            const Icon(
              Icons.help_outline,
              size: 40,
              semanticLabel: 'Unsupported image type',
            );
    }

    // Apply semantic label if not already handled by SvgPicture and imageContent is the primary display
    if (semanticLabel != null &&
        imageType != _ImageType.svgNetwork &&
        imageType != _ImageType.svgFile &&
        imageType != _ImageType.svgAsset) {
      return Semantics(label: semanticLabel, image: true, child: imageContent);
    }

    return imageContent;
  }
}
