import 'package:flutter/material.dart';

class CustomProgressBar extends StatelessWidget {
  final String title;
  final String subTitle;
  final double percent;
  final Size dimensione;
  final Color? fontColor;
  final Color? progressColor;

  const CustomProgressBar({
    super.key,
    required this.title,
    required this.percent,
    required this.subTitle,
    required this.dimensione,
    this.fontColor,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    Color getProgressColor() {
      if (progressColor != null) return progressColor!;
      if (percent > 1.0) return Colors.red;
      if (percent > 0.95) return Colors.orange;
      return Colors.green;
    }

    Color color = fontColor ?? Colors.black;

    double testoTitolo = 14.0;
    double testoSottoTitolo = 12.0;
    double altezzaBarra = 12.0;
    double padding = 10.0;
    switch (dimensione) {
      case Size.titolo:
        testoTitolo = 18.0;
        testoSottoTitolo = 14.0;
        altezzaBarra = 20.0;
        padding = 16.0;
      case Size.sottoTitolo:
        testoTitolo = 14;
        testoSottoTitolo = 12;
        altezzaBarra = 14;
        padding = 18.0;
      case Size.dettaglio:
        testoTitolo = 12;
        testoSottoTitolo = 10;
        altezzaBarra = 12;
        padding = 25.0;
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: padding,
      ), // Imposta il padding su tutti i lati
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Allinea gli elementi a sinistra
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Distribuisce gli estremi
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: testoTitolo,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                subTitle,
                style: TextStyle(fontSize: testoSottoTitolo, color: color),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percent,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(getProgressColor()),
            minHeight: altezzaBarra,
          ),
        ],
      ),
    );
  }
}

enum Size { titolo, sottoTitolo, dettaglio }
