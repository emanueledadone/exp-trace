import 'package:exp_trace/utils/app_icons.dart';
import 'package:flutter/material.dart';

class IconPickerButton extends StatefulWidget {
  final Function(IconData?) onIconSelected;
  final bool showIcon;

  const IconPickerButton({
    super.key,
    required this.onIconSelected,
    required this.showIcon,
  });

  @override
  State<IconPickerButton> createState() => _IconPickerButtonState();
}

class _IconPickerButtonState extends State<IconPickerButton> {
  IconData? selectedIcon;

  Future<void> _pickIcon() async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Seleziona Icona"),
            content: SizedBox(
              width: 300,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                ),
                itemCount: AppIcons.iconMapping.length,
                itemBuilder: (context, index) {
                  return IconButton(
                    icon: Icon(AppIcons.iconMapping[index], size: 24),
                    padding: EdgeInsets.all(2),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          8,
                        ), // Angoli meno arrotondati
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedIcon = AppIcons.iconMapping[index];
                      });
                      widget.onIconSelected(selectedIcon);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(onPressed: _pickIcon, child: Text("Seleziona Icona")),
        if (selectedIcon != null && widget.showIcon)
          Icon(selectedIcon, size: 24),
      ],
    );
  }
}
