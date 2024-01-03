import 'package:chili_debug_view/src/network_logs/model/network_log.dart';
import 'package:chili_debug_view/src/network_logs/model/network_logger_log_type.dart';
import 'package:chili_debug_view/src/theme/typography/app_typography.dart';
import 'package:chili_debug_view/src/time/time_provider.dart';
import 'package:flutter/material.dart';

class NetworkLogsItem extends StatelessWidget {
  final NetworkLog item;
  final bool isSelected;
  final bool isSelectableMode;
  final VoidCallback onTap;

  const NetworkLogsItem({
    super.key,
    required this.item,
    required this.isSelected,
    required this.isSelectableMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final responseTime = item.responseTime;

    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 4,
          horizontal: 16,
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              width: isSelectableMode ? 56 : 0,
              child: IconButton(
                onPressed: onTap,
                icon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.circle_outlined,
                    color: isSelected ? Colors.blue : Colors.white,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(10),
                  ),
                  color: _logTypeColor(item.type),
                ),
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.type.name.toUpperCase(),
                              style: AppTypography.bodyBold,
                            ),
                            if (responseTime != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                TimeProvider.prettyDuration(
                                  responseTime.difference(item.requestTime),
                                ),
                              )
                            ],
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          item.uri,
                          maxLines: 3,
                          style: AppTypography.body,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Color _logTypeColor(NetworkLoggerLogType type) {
    switch (type) {
      case NetworkLoggerLogType.success:
        return Colors.green;
      case NetworkLoggerLogType.error:
        return Colors.red;
      case NetworkLoggerLogType.started:
        return Colors.blue;
    }
  }
}
