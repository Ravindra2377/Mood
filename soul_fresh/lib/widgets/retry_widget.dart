import 'package:flutter/material.dart';
import '../core/colors.dart';

/// Retry button widget with loading state
class RetryWidget extends StatefulWidget {
  final VoidCallback onRetry;
  final String? message;
  final String buttonText;
  final IconData icon;

  const RetryWidget({
    super.key,
    required this.onRetry,
    this.message,
    this.buttonText = 'Retry',
    this.icon = Icons.refresh,
  });

  @override
  State<RetryWidget> createState() => _RetryWidgetState();
}

class _RetryWidgetState extends State<RetryWidget> {
  bool _isRetrying = false;

  Future<void> _handleRetry() async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
    });

    try {
      widget.onRetry();
      // Wait a bit to show the loading state
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.message != null) ...[
              Text(
                widget.message!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
            ],
            ElevatedButton.icon(
              onPressed: _isRetrying ? null : _handleRetry,
              icon: _isRetrying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(widget.icon),
              label: Text(_isRetrying ? 'Retrying...' : widget.buttonText),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact retry button (for inline use)
class CompactRetryButton extends StatefulWidget {
  final VoidCallback onRetry;
  final String? label;

  const CompactRetryButton({
    super.key,
    required this.onRetry,
    this.label,
  });

  @override
  State<CompactRetryButton> createState() => _CompactRetryButtonState();
}

class _CompactRetryButtonState extends State<CompactRetryButton> {
  bool _isRetrying = false;

  Future<void> _handleRetry() async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
    });

    try {
      widget.onRetry();
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: _isRetrying ? null : _handleRetry,
      icon: _isRetrying
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.refresh, size: 16),
      label: Text(
        _isRetrying ? 'Retrying...' : (widget.label ?? 'Retry'),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

/// Icon retry button (minimal design)
class IconRetryButton extends StatefulWidget {
  final VoidCallback onRetry;
  final double size;
  final Color? color;

  const IconRetryButton({
    super.key,
    required this.onRetry,
    this.size = 24,
    this.color,
  });

  @override
  State<IconRetryButton> createState() => _IconRetryButtonState();
}

class _IconRetryButtonState extends State<IconRetryButton>
    with SingleTickerProviderStateMixin {
  bool _isRetrying = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRetry() async {
    if (_isRetrying) return;

    setState(() {
      _isRetrying = true;
    });

    _controller.repeat();

    try {
      widget.onRetry();
      await Future.delayed(const Duration(milliseconds: 500));
    } finally {
      _controller.stop();
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _isRetrying ? null : _handleRetry,
      icon: RotationTransition(
        turns: _controller,
        child: Icon(
          Icons.refresh,
          size: widget.size,
          color: widget.color ?? AppColors.primary,
        ),
      ),
    );
  }
}

/// Error card with retry button
class ErrorCard extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final IconData icon;

  const ErrorCard({
    super.key,
    required this.title,
    this.message,
    this.onRetry,
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.errorLight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.error,
                        ),
                  ),
                ),
              ],
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: CompactRetryButton(onRetry: onRetry!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
