import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:f_clean_template/core/theme/home_colors.dart';

/// Six boxes for the emailed verification code. A single invisible text
/// field on top receives the keyboard input, so pasting and the system
/// one-time-code autofill keep working; the boxes only display it.
class VerificationCodeInput extends StatefulWidget {
  const VerificationCodeInput({
    super.key,
    required this.controller,
    required this.width,
    this.length = 6,
    this.fieldKey,
  });

  final TextEditingController controller;
  final double width;
  final int length;

  final Key? fieldKey;

  @override
  State<VerificationCodeInput> createState() => _VerificationCodeInputState();
}

class _VerificationCodeInputState extends State<VerificationCodeInput> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
    _focusNode.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    _focusNode.removeListener(_refresh);
    _focusNode.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;
    final activeIndex = text.length >= widget.length
        ? widget.length - 1
        : text.length;

    final gap = widget.width * 0.028;
    var boxWidth = (widget.width - gap * (widget.length - 1)) / widget.length;
    if (boxWidth > 54) boxWidth = 54;
    final boxHeight = boxWidth * 1.2;

    return Center(
      child: Stack(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.length, (index) {
              final char = index < text.length ? text[index] : '';
              final active = _focusNode.hasFocus && index == activeIndex;
              return Container(
                width: boxWidth,
                height: boxHeight,
                margin: EdgeInsets.only(
                  right: index == widget.length - 1 ? 0 : gap,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: active
                        ? HomeColors.flowAccent
                        : HomeColors.flowBorder,
                    width: active ? 1.6 : 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  char,
                  style: TextStyle(
                    fontSize: boxWidth * 0.46,
                    fontWeight: FontWeight.w700,
                    color: HomeColors.flowAccent,
                  ),
                ),
              );
            }),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextFormField(
                key: widget.fieldKey,
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.oneTimeCode],
                inputFormatters: [
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                showCursor: false,
                enableInteractiveSelection: false,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                  isCollapsed: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
