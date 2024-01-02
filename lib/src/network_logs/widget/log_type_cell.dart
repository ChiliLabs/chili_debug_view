import 'package:chili_debug_view/src/network_logs/model/network_logger_log_type.dart';
import 'package:flutter/material.dart';

class LogTypeCell extends StatelessWidget {
  final NetworkLoggerLogType type;
  final bool isSelected;
  final VoidCallback onLevelSelect;

  const LogTypeCell({
    Key? key,
    required this.type,
    required this.isSelected,
    required this.onLevelSelect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onLevelSelect,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            ),
            color: isSelected ? Colors.blue : Colors.blueGrey,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
              horizontal: 16,
            ),
            child: Center(
              child: Text(
                type.name,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
