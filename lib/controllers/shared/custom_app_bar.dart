import 'package:flutter/material.dart';
import '../../app_localizations.dart';
import '../../constants.dart';

class CustomAppBar extends StatelessWidget {
  final String titleKey;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSharePressed;
  final bool isLiked;
  final VoidCallback? onLikePressed;
  
  const CustomAppBar({
    super.key,
    required this.titleKey,
    this.onBackPressed,
    this.onSharePressed,
    this.isLiked = false,
    this.onLikePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: kMainBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(26),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () {
              if (onBackPressed != null) {
                onBackPressed!();
              } else {
                Navigator.pop(context);
              }
            },
          ),

          // Title
          Expanded(
            child: Text(
              AppLocalizations.of(context).get(titleKey),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Share Button
              IconButton(
                icon: const Icon(
                  Icons.share_outlined,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: onSharePressed,
              ),
              // Like Button
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? kBrandPrimary : Colors.white,
                  size: 20,
                ),
                onPressed: onLikePressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
