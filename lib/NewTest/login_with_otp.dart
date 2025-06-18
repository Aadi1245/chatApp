import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SixDigitBoxInput extends StatefulWidget {
  final Function(String)? onCompleted;

  const SixDigitBoxInput({Key? key, this.onCompleted}) : super(key: key);

  @override
  _SixDigitBoxInputState createState() => _SixDigitBoxInputState();
}

class _SixDigitBoxInputState extends State<SixDigitBoxInput> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onTextChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < 5) {
        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
      } else {
        FocusScope.of(context).unfocus(); // Hide keyboard after last digit
        String finalInput = _controllers.map((e) => e.text).join();
        widget.onCompleted?.call(finalInput);
      }
    }
  }

  void _onKeyDown(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return SizedBox(
          width: 52,
          height: 52,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            maxLength: 1,
            textAlign: TextAlign.center,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: "",
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.grey.shade400, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.black, width: 2),
              ),
            ),
            onChanged: (value) => _onTextChanged(index, value),
            onSubmitted: (_) => _onTextChanged(index, _controllers[index].text),
          ),
        );
      }).expand((widget) => [widget, const SizedBox(width: 4)]).toList(),
    );
  }
}
