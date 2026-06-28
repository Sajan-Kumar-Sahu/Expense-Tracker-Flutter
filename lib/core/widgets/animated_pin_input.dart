import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'pin_box.dart';

class AnimatedPinInput extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;

  const AnimatedPinInput({
    super.key,
    this.length = 4,
    this.onChanged,
    this.onCompleted,
  });

  @override
  State<AnimatedPinInput> createState() => _AnimatedPinInputState();
}

class _AnimatedPinInputState extends State<AnimatedPinInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController();
    _focusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void clear() {
    _controller.clear();
    setState(() {});
  }

  void showError() {
    setState(() => _hasError = true);

    Future.delayed(
      const Duration(milliseconds: 500),
          () {
        if (!mounted) return;

        _controller.clear();

        setState(() {
          _hasError = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0,
            child: SizedBox(
              width: 1,
              height: 1,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: true,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                maxLength: widget.length,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: const InputDecoration(
                  counterText: "",
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {});

                  widget.onChanged?.call(value);

                  if (value.length == widget.length) {
                    widget.onCompleted?.call(value);
                  }
                },
              ),
            ),
          ),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                widget.length,
                    (index) => Padding(
                  padding: EdgeInsets.only(
                    right: index == widget.length - 1 ? 0 : 12.w,
                  ),
                  child: PinBox(
                    isFilled: index < _controller.text.length,
                    isActive: index == _controller.text.length &&
                        _controller.text.length < widget.length,
                    hasError: _hasError,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}