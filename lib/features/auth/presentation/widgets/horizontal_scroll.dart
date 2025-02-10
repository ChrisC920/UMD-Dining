import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:numberpicker/numberpicker.dart';

class HorizontalScroll extends StatefulWidget {
  const HorizontalScroll({super.key});

  @override
  State<HorizontalScroll> createState() => _HorizontalScrollState();
}

class _HorizontalScrollState extends State<HorizontalScroll> {
  int value = 18;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: NumberPicker(
        haptics: true,
        itemHeight: 110,
        itemWidth: 160,
        minValue: 0,
        maxValue: 99,
        value: value,
        axis: Axis.horizontal,
        textMapper: (numberText) => numberText.padRight(4, ' ').padLeft(3, ' '),
        textStyle: GoogleFonts.poppins(
          fontSize: 100,
          height: 1,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.1,
          color: const Color.fromARGB(105, 0, 0, 0),
        ),
        selectedTextStyle: GoogleFonts.poppins(
          height: 1,
          fontSize: 100,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.1,
          color: const Color.fromARGB(255, 56, 56, 56),
        ),
        onChanged: (value) {
          setState(() {
            this.value = value;
          });
        },
      ),
    );
  }
}
