import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerButton extends StatefulWidget {
  final Function(Color) onColorSelected;
  final bool showColor;

  const ColorPickerButton({
    super.key,
    required this.onColorSelected,
    required this.showColor,
  });

  @override
  State<ColorPickerButton> createState() => _ColorPickerButtonState();
}

class _ColorPickerButtonState extends State<ColorPickerButton> {
  Color selectedColor = Colors.blue;

  Future<void> _pickColor() async {
    Color tempColor = selectedColor;
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Seleziona Colore"),
            content: ColorPicker(
              pickerColor: tempColor,
              onColorChanged: (color) => tempColor = color,
            ),
            actions: [
              TextButton(
                child: Text("Annulla"),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: Text("OK"),
                onPressed: () {
                  setState(() {
                    selectedColor = tempColor;
                  });
                  widget.onColorSelected(selectedColor);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(onPressed: _pickColor, child: Text("Seleziona Colore")),
        if (widget.showColor)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: selectedColor,
              shape: BoxShape.circle,
            ),
          ),
      ],
    );
  }
}
