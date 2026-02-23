// Based on the colored_json package by Manthan Khandale.
// Copyright 2022 Manthan Khandale. BSD 3-Clause License.
// https://pub.dev/packages/colored_json
//
// Redistributed with modifications under the same BSD 3-Clause License.
// Copyright 2026 ChiliLabs. All rights reserved.

import 'package:flutter/material.dart';
import 'dart:convert';

/// Global indent length in spaces used by all widgets in a single render pass.
late int _globalTabLength;

/// Global comma color used by all widgets in a single render pass.
late Color _globalCommaColor;

/// Global JSON key color used by all widgets in a single render pass.
late Color _globalKeyColor;

/// Global colon color used by all widgets in a single render pass.
late Color _globalColonColor;

/// A widget that renders a JSON string with syntax-highlighted colors.
///
/// Each JSON value type (string, int, double, bool, null) is rendered in a
/// configurable color. Nested objects and arrays are indented automatically.
///
/// Example:
/// ```dart
/// ColoredJson(data: '{"key": "value"}')
/// ```
class ColoredJson extends StatelessWidget {
  /// Creates a [ColoredJson] widget.
  ///
  /// [data] must be a valid JSON string representing either a JSON object or
  /// a JSON array. All color parameters default to sensible values but can be
  /// overridden to match your app's theme.
  ColoredJson({
    Key? key,
    required this.data,
    this.backgroundColor = Colors.transparent,
    this.stringColor = Colors.green,
    this.nullColor = Colors.red,
    this.intColor = Colors.purple,
    this.boolColor = Colors.pink,
    this.doubleColor = Colors.deepPurple,
    this.curlyBracketColor = Colors.black,
    this.squareBracketColor = Colors.black,
    this.textStyle = const TextStyle(),
    this.indentLength = 4,
    this.keyColor = Colors.blue,
    this.commaColor = Colors.black,
    this.colonColor = Colors.deepPurple,
  }) : super(key: key) {
    _globalTabLength = indentLength;
    _globalCommaColor = commaColor;
    _globalColonColor = colonColor;
    _globalKeyColor = keyColor;
  }

  /// JSON String
  final String data;

  /// Background color of the Widget
  final Color backgroundColor;

  /// Color of value of type [String]
  final Color stringColor;

  /// Color of value of type null
  final Color nullColor;

  /// Color of value of type [int]
  final Color intColor;

  /// Color of value of type [bool]
  final Color boolColor;

  /// Color of value of type [double]
  final Color doubleColor;

  /// Color of Curly brackets
  final Color curlyBracketColor;

  /// Color of Square brackets
  final Color squareBracketColor;

  /// Textstyle of parsed json data
  final TextStyle textStyle;

  /// Indent length in spaces, default to 4
  final int indentLength;

  /// Color of JSON Color Key
  final Color keyColor;

  /// Color of comma
  final Color commaColor;

  /// Color of colon
  final Color colonColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      textStyle: textStyle,
      child: _coloredView(
        jsonString: data,
        indent: 0,
      ),
    );
  }

  /// Decodes [jsonString] and delegates rendering to [_parseMap] or
  /// [_parseList] depending on the root type. Throws if the root value is
  /// neither a Map nor a List.
  Widget _coloredView({
    required String jsonString,
    required int indent,
  }) {
    final decodedData = jsonDecode(jsonString);
    if (decodedData is Map) {
      return _parseMap(
        data: decodedData,
        indent: indent,
        showComma: false,
      );
    } else if (decodedData is List) {
      return _parseList(
        data: decodedData,
        indent: indent,
        showComma: false,
      );
    } else {
      throw 'Not Correct type only List or Map allowed';
    }
  }

  /// Recursively renders a JSON [Map] as a column of syntax-highlighted rows.
  ///
  /// [indent] controls the current nesting depth, [showComma] appends a
  /// trailing comma after the closing brace, and the optional [jkey] is the
  /// parent key when this map is a nested value.
  Widget _parseMap({
    required Map data,
    required int indent,
    required bool showComma,
    String? jkey,
  }) {
    if (data.entries.isEmpty) {
      if (jkey != null) {
        return _KeyValueWidget(
          indent: indent,
          jsonKey: jkey,
          jsonValue: '{}',
          valueColor: curlyBracketColor,
          showComma: showComma,
        );
      } else {
        return Text(
          '{}',
          style: TextStyle(color: curlyBracketColor),
        );
      }
    } else {
      final wigs = <Widget>[];

      if (jkey == null) {
        wigs.add(Text('${_spaces(indent)}{',
            style: TextStyle(color: curlyBracketColor)));
      } else {
        wigs.add(_KeyValueWidget(
          indent: indent,
          jsonKey: jkey,
          jsonValue: '{',
          valueColor: curlyBracketColor,
          showComma: false,
        ));
      }

      final int newIndent = indent + 1;

      for (int i = 0; i < data.entries.length; i++) {
        final jKey = data.entries.toList()[i].key;
        final value = data.entries.toList()[i].value;

        final bool showComma = i != data.entries.length - 1;

        if (value is String) {
          wigs.add(
            _KeyValueWidget(
                indent: newIndent,
                jsonKey: jKey,
                jsonValue: '"$value"',
                valueColor: stringColor,
                showComma: showComma),
          );
        } else if (value is int) {
          wigs.add(
            _KeyValueWidget(
                indent: newIndent,
                jsonKey: jKey,
                jsonValue: value.toString(),
                valueColor: intColor,
                showComma: showComma),
          );
        } else if (value is double) {
          wigs.add(
            _KeyValueWidget(
              indent: newIndent,
              jsonKey: jKey,
              jsonValue: value.toString(),
              valueColor: doubleColor,
              showComma: showComma,
            ),
          );
        } else if (value is bool) {
          wigs.add(
            _KeyValueWidget(
              indent: newIndent,
              jsonKey: jKey,
              jsonValue: value.toString(),
              valueColor: boolColor,
              showComma: showComma,
            ),
          );
        } else if (value is List) {
          wigs.add(_parseList(
            data: value,
            indent: newIndent,
            jkey: jKey,
            showComma: showComma,
          ));
        } else if (value is Map) {
          wigs.add(_parseMap(
            data: (value),
            indent: newIndent,
            jkey: jKey,
            showComma: showComma,
          ));
        } else if (value == null) {
          wigs.add(
            _KeyValueWidget(
              indent: newIndent,
              jsonKey: jKey,
              jsonValue: 'null',
              valueColor: nullColor,
              showComma: showComma,
            ),
          );
        }
      }
      wigs.add(Text.rich(TextSpan(children: [
        TextSpan(text: _spaces(indent)),
        TextSpan(text: '}', style: TextStyle(color: curlyBracketColor)),
        if (showComma)
          TextSpan(text: ',', style: TextStyle(color: _globalCommaColor))
      ])));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: wigs,
      );
    }
  }

  /// Recursively renders a JSON [List] as a column of syntax-highlighted rows.
  ///
  /// [indent] controls the current nesting depth, [showComma] appends a
  /// trailing comma after the closing bracket, and the optional [jkey] is the
  /// parent key when this list is a nested value.
  Widget _parseList({
    required List<dynamic> data,
    required int indent,
    required bool showComma,
    String? jkey,
  }) {
    if (data.isEmpty) {
      if (jkey != null) {
        return _KeyValueWidget(
          indent: indent,
          jsonKey: jkey,
          jsonValue: '[]',
          valueColor: squareBracketColor,
          showComma: showComma,
        );
      } else {
        return Text('[]', style: TextStyle(color: squareBracketColor));
      }
    } else {
      final wigs = <Widget>[];

      if (jkey == null) {
        wigs.add(Text('${_spaces(indent)}[',
            style: TextStyle(color: squareBracketColor)));
      } else {
        wigs.add(_KeyValueWidget(
          indent: indent,
          jsonKey: jkey,
          jsonValue: '[',
          valueColor: squareBracketColor,
          showComma: false,
        ));
      }

      final int newIndent = indent + 1;

      for (int j = 0; j < data.length; j++) {
        final i = data[j];
        final showComma = j != data.length - 1;

        if (i is String) {
          wigs.add(_KeyValueWidget(
            indent: newIndent,
            jsonValue: '"$i"',
            valueColor: stringColor,
            showComma: showComma,
          ));
        } else if (i is int) {
          wigs.add(_KeyValueWidget(
            indent: newIndent,
            jsonValue: i.toString(),
            valueColor: intColor,
            showComma: showComma,
          ));
        } else if (i is double) {
          wigs.add(_KeyValueWidget(
            indent: newIndent,
            jsonValue: i.toString(),
            valueColor: doubleColor,
            showComma: showComma,
          ));
        } else if (i is bool) {
          wigs.add(_KeyValueWidget(
            indent: newIndent,
            jsonValue: i.toString(),
            valueColor: boolColor,
            showComma: showComma,
          ));
        } else if (i is List) {
          wigs.add(_parseList(
            data: i,
            indent: newIndent,
            showComma: showComma,
          ));
        } else if (i is Map) {
          wigs.add(_parseMap(
              data: i as Map<String, dynamic>,
              indent: newIndent,
              showComma: showComma));
        } else if (i == null) {
          wigs.add(_KeyValueWidget(
            indent: newIndent,
            jsonValue: 'null',
            valueColor: nullColor,
            showComma: showComma,
          ));
        }
      }

      wigs.add(Text.rich(TextSpan(children: [
        TextSpan(text: _spaces(indent)),
        TextSpan(text: ']', style: TextStyle(color: squareBracketColor)),
        if (showComma)
          TextSpan(text: ',', style: TextStyle(color: _globalCommaColor))
      ])));

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: wigs,
      );
    }
  }
}

/// A private widget that renders a single JSON key-value (or bare value) row.
///
/// Renders optional leading [jsonKey] followed by [jsonValue] in their
/// respective colors, indented by [indent] levels, with an optional trailing
/// comma when [showComma] is `true`.
class _KeyValueWidget extends StatelessWidget {
  /// Creates a [_KeyValueWidget].
  _KeyValueWidget({
    Key? key,
    required this.indent,
    this.jsonKey,
    required this.jsonValue,
    required this.valueColor,
    required this.showComma,
  }) : super(key: key);

  /// Nesting depth; controls leading whitespace.
  final int indent;

  /// The JSON key name, or `null` when rendering a bare list element.
  final String? jsonKey;

  /// The string representation of the JSON value.
  final String jsonValue;

  /// The color used to render [jsonValue].
  final Color valueColor;

  /// The color used to render [jsonKey], sourced from the global key color.
  final Color keyColor = _globalKeyColor;

  /// Whether to append a trailing comma after the value.
  final bool showComma;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          child: Text(_spaces(indent)),
        ),
        Flexible(
          child: Text.rich(TextSpan(
            children: [
              if (jsonKey != null)
                TextSpan(text: '"$jsonKey"', style: TextStyle(color: keyColor)),
              if (jsonKey != null)
                TextSpan(
                    text: ': ', style: TextStyle(color: _globalColonColor)),
              TextSpan(text: jsonValue, style: TextStyle(color: valueColor)),
              if (showComma)
                TextSpan(text: ',', style: TextStyle(color: _globalCommaColor)),
            ],
          )),
        ),
      ],
    );
  }
}

/// Required to create indents
String _spaces(int multiple) {
  return ' ' * _globalTabLength * multiple;
}
