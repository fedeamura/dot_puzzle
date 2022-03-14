import 'package:dot_puzzle/core/color.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Function()? onPressed;
  final Color? color;
  final EdgeInsets? margin;
  final Color? textColor;

  const CustomButton({
    Key? key,
    this.text = "",
    this.onPressed,
    this.color,
    this.margin,
    this.textColor,
  }) : super(key: key);

  Color _color(BuildContext context) {
    return color ?? Theme.of(context).dividerColor;
  }

  Color _textColor(BuildContext context) {
    return textColor ?? Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: RawMaterialButton(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: _textColor(context)),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.0),
        ),
        fillColor: _color(context),
        elevation: 0,
        onPressed: onPressed,
      ),
    );
  }
}
