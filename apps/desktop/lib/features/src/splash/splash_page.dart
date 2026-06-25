import 'package:design/ui.dart';
import 'package:docu_fill/core/core.dart';
import 'package:docu_fill/features/src/splash/view_model/splash_view_model.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

/// Full-screen Splash entry point widget of the application.
class SplashPage extends BaseView<SplashViewModel> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, SplashViewModel viewModel) {
    return const Scaffold(
      body: _SplashBackground(
        child: Stack(
          alignment: Alignment.center,
          children: [
            _SplashContent(),
            Positioned(
              bottom: 32, // Standard visual padding offset
              child: _SplashCopyright(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Provides a premium RadialGradient background blending context.colorScheme.surface with primary glow accents.
class _SplashBackground extends StatelessWidget {
  final Widget child;

  const _SplashBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    final primaryGlow = context.colorScheme.primary.withOpacity(0.12);
    final surfaceColor = context.colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.4,
          colors: [
            primaryGlow,
            surfaceColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          _buildGlowCircle(
            top: -Dimens.size100,
            left: -Dimens.size100,
            color: context.colorScheme.primary.withOpacity(0.15),
            radius: Dimens.size300,
          ),
          _buildGlowCircle(
            bottom: -Dimens.size150,
            right: -Dimens.size100,
            color: context.colorScheme.secondary.withOpacity(0.12),
            radius: Dimens.size400,
          ),
          child,
        ],
      ),
    );
  }

  Widget _buildGlowCircle({
    double? top,
    double? left,
    double? bottom,
    double? right,
    required Color color,
    required double radius,
  }) {
    return Positioned(
      top: top,
      left: left,
      bottom: bottom,
      right: right,
      child: Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 100,
              spreadRadius: 10,
            ),
          ],
        ),
      ),
    );
  }
}

/// Combines logo, title, and loading indicator under a single cubic scale/fade animation.
class _SplashContent extends StatelessWidget {
  const _SplashContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 1200),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.scale(
              scale: 0.85 + (0.15 * value),
              child: child,
            ),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const _SplashLogo(),
            SizedBox(height: Dimens.size32),
            const _SplashTitleAndTagline(),
            SizedBox(height: Dimens.size48),
            const _SplashLoader(),
          ],
        ),
      ),
    );
  }
}

/// Renders the rounded brand logo with drop shadows reflecting the primary theme color.
class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Dimens.size120,
      height: Dimens.size120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.primary.withOpacity(0.4),
            blurRadius: 30,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimens.size60),
        child: Image.asset(
          "assets/images/app_icon.png",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

/// Renders the application name and the localized tagline text.
class _SplashTitleAndTagline extends StatelessWidget {
  const _SplashTitleAndTagline();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLang.appName.tr(),
          style: context.textTheme.displayMedium?.copyWith(
            color: context.colorScheme.onSurface,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: Dimens.size12),
        Text(
          AppLang.messagesSplashTagline.tr(),
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colorScheme.onSurface.withOpacity(0.7),
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

/// Displays the custom glowing circular loading indicator using primary theme color.
class _SplashLoader extends StatelessWidget {
  const _SplashLoader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Dimens.size48,
      height: Dimens.size48,
      child: CircularProgressIndicator(
        strokeWidth: Dimens.size2,
        valueColor: AlwaysStoppedAnimation<Color>(
          context.colorScheme.primary,
        ),
        backgroundColor: context.colorScheme.onSurface.withOpacity(0.08),
      ),
    );
  }
}

/// Renders the copyright text at the bottom.
class _SplashCopyright extends StatelessWidget {
  const _SplashCopyright();

  @override
  Widget build(BuildContext context) {
    return Text(
      "© 2026 DocuFill. All rights reserved.",
      style: context.textTheme.bodySmall?.copyWith(
        color: context.colorScheme.onSurface.withOpacity(0.38),
        letterSpacing: 0.5,
      ),
    );
  }
}
