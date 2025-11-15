import 'package:exp_trace/utils/utils.dart';
import 'package:flutter/material.dart';

class CalculatorKeyboard extends StatefulWidget {
  final Function(String) onValueSelected;

  const CalculatorKeyboard({super.key, required this.onValueSelected});

  @override
  State<CalculatorKeyboard> createState() => _CalculatorKeyboardState();
}

class _CalculatorKeyboardState extends State<CalculatorKeyboard> {
  String inputText = "";

  void _onKeyPressed(String value) {
    setState(() {
      inputText += value;
    });
  }

  void _calculateResult() {
    try {
      final result = inputText.isNotEmpty ? evalExpression(inputText) : "";
      setState(() {
        inputText = result.toString();
      });
    } catch (e) {
      setState(() {
        inputText = "Errore";
      });
    }
  }

  void _submit() {
    widget.onValueSelected(inputText);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width:
          350, //MediaQuery.of(context).size.width * 0.8, // Larghezza definita
      height: 400, // Altezza fissa
      child: Column(
        children: [
          Text(inputText, style: TextStyle(fontSize: 24)),
          Expanded(
            child: GridView.count(
              shrinkWrap: true,
              padding: EdgeInsets.all(0.0),
              crossAxisCount: 4,
              children: [
                ...["7", "8", "9", "/"].map((e) => _buildKey(e)),
                ...["4", "5", "6", "*"].map((e) => _buildKey(e)),
                ...["1", "2", "3", "-"].map((e) => _buildKey(e)),
                _buildKey("C", isClear: true),
                _buildKey("0"),
                _buildKey(".", isOperator: true),
                _buildKey("+"),
                _buildKey("=", isEquals: true),
                _buildKey("OK", isSubmit: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKey(
    String label, {
    bool isClear = false,
    bool isOperator = false,
    bool isEquals = false,
    bool isSubmit = false,
  }) {
    return GestureDetector(
      onTap:
          isClear
              ? () => setState(() => inputText = "")
              : isEquals
              ? _calculateResult
              : isSubmit
              ? _submit
              : () => _onKeyPressed(label),
      child: Container(
        margin: EdgeInsets.all(1.0),
        padding: EdgeInsets.symmetric(vertical: 1.0, horizontal: 1.0),
        decoration: BoxDecoration(
          color: isOperator || isEquals ? Colors.orange : Colors.grey[300],
          borderRadius: BorderRadius.circular(6.0),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
