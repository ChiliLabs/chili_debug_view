import 'package:chili_debug_view/src/theme/button/small_icon_button.dart';
import 'package:chili_debug_view/src/theme/typography/app_typography.dart';
import 'package:flutter/material.dart';

class NetworkLogsProxyPage extends StatefulWidget {
  final ValueChanged<String> onSaveProxy;
  final String? proxyUrl;

  const NetworkLogsProxyPage({
    super.key,
    required this.onSaveProxy,
    this.proxyUrl,
  });

  @override
  State<NetworkLogsProxyPage> createState() => _NetworkLogsProxyPageState();
}

class _NetworkLogsProxyPageState extends State<NetworkLogsProxyPage> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController()..text = widget.proxyUrl ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
        title: const Text(
          'Proxy',
          style: AppTypography.headline,
        ),
        actions: [],
      ),
      body: Column(
        children: [
          TextFormField(
            style: const TextStyle(color: Colors.white),
            controller: _controller,
            cursorColor: Colors.white,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              hintText: 'Input proxy',
              hintStyle: const TextStyle(color: Colors.white54),
              focusedBorder: _border,
              enabledBorder: _border,
              border: _border,
              suffixIcon: _controller.text.isNotEmpty
                  ? SmallIconButton(
                      icon: Icons.cancel_outlined,
                      onTap: _controller.clear,
                    )
                  : null,
            ),
          ),
          MaterialButton(
            child: Text('Save', style: const TextStyle(color: Colors.black)),
            color: Colors.white,
            onPressed: () => widget.onSaveProxy(_controller.text),
          )
        ],
      ),
    );
  }

  OutlineInputBorder get _border => const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.white24,
          width: 0,
        ),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      );

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }
}
