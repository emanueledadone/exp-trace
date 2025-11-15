import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final bool isWide;
  final Widget? body;

  const CustomButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    this.text,
    this.body,
    this.isWide = false, // Opzione per renderlo largo
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width:
          isWide
              ? MediaQuery.of(context).size.width * 0.5
              : 200, // Definisci larghezza dinamica
      height: 60, // Imposta un'altezza fissa per evitare problemi

      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            SizedBox(height: 4),
            if (body == null) // Mostra solo se progress è definito
              Text(text ?? '', style: TextStyle(color: Colors.white)),
            if (body != null) ...[body!],
          ],
        ),
      ),
    );
  }
}
