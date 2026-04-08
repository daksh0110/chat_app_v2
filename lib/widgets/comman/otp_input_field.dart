import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/colors/defaullt_color_sheet.dart';

class OtpInputField extends StatefulWidget {
  final TextEditingController controller;
  final int length;
  final Function(String)? onChanged;

  const OtpInputField({
    super.key,
    required this.controller,
    this.length = 4,
    this.onChanged,
  });

  @override
  State<OtpInputField> createState() => _OtpInputFieldState();
}

class _OtpInputFieldState extends State<OtpInputField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
  }

  void _onChange() {
    setState(() {});
    widget.onChanged?.call(widget.controller.text);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.controller.text;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(_focusNode);
      },
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(widget.length, (index) {
              bool isActive = text.length == index;
              bool isFilled = text.length > index;

              String char = isFilled ? text[index] : "";

              return Container(
                width: 50,
                height: 55,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isActive ? DefaultColorSheet.green400 : Colors.grey,
                    width: isActive ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(char, style: const TextStyle(fontSize: 20)),
              );
            }),
          ),

          SizedBox(
            height: 0,
            width: 0,
            child: TextField(
              focusNode: _focusNode,
              controller: widget.controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              maxLength: widget.length,
              autofocus: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: "",
              ),
            ),
          ),
        ],
      ),
    );
  }
}
