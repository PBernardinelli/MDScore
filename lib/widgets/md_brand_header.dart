import 'package:flutter/material.dart';

import '../core/app_theme.dart';

class MDBrandHeader extends StatelessWidget {
  const MDBrandHeader({
    super.key,
    this.compact = false,
  });

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: compact ? 46 : 64,
          height: compact ? 46 : 64,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(compact ? 14 : 20),
          ),
          child: Icon(
            Icons.train_rounded,
            color: const Color(0xFF042F2E),
            size: compact ? 26 : 36,
          ),
        ),
        SizedBox(width: compact ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MD Score',
                style: compact
                    ? Theme.of(context).textTheme.titleLarge
                    : Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 2),
              Text(
                'Mexican Dominoes Score',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Tooltip(
          message: 'Don Minó',
          child: Container(
            width: compact ? 42 : 52,
            height: compact ? 42 : 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.accent.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              'DM',
              style: TextStyle(
                color: AppTheme.accent,
                fontWeight: FontWeight.w800,
                fontSize: compact ? 13 : 15,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
