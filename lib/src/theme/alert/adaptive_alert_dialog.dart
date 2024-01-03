import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class AdaptiveAlertDialog {
  factory AdaptiveAlertDialog(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.iOS:
        return const _IOSAlert();
      case TargetPlatform.android:
        return const _AndroidAlert();
      default:
        return const _AndroidAlert();
    }
  }

  Widget build(
    BuildContext context, {
    required String title,
    required String description,
    required String buttonTitle,
    required VoidCallback onButtonTap,
  });
}

final class _IOSAlert implements AdaptiveAlertDialog {
  const _IOSAlert();

  @override
  Widget build(
    BuildContext context, {
    required String title,
    required String description,
    required String buttonTitle,
    required VoidCallback onButtonTap,
  }) {
    return Theme(
      // Disable app theme for cupertino alert and use default color.
      data: ThemeData(),
      child: CupertinoAlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          CupertinoDialogAction(
            onPressed: Navigator.of(context).pop,
            isDefaultAction: true,
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            onPressed: onButtonTap,
            isDestructiveAction: true,
            child: Text(buttonTitle),
          ),
        ],
      ),
    );
  }
}

final class _AndroidAlert implements AdaptiveAlertDialog {
  const _AndroidAlert();

  @override
  Widget build(
    BuildContext context, {
    required String title,
    required String description,
    required String buttonTitle,
    required VoidCallback onButtonTap,
  }) =>
      AlertDialog(
        backgroundColor: const Color(0xFF343434),
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: onButtonTap,
            child: Text(
              buttonTitle,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      );
}
