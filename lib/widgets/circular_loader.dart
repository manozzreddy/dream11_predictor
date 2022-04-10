import 'package:flutter/material.dart';

/// Circular CircularLoader Widget
class CircularLoader extends StatefulWidget {
  final Color? color;
  final Color? accentColor;
  final Decoration? decoration;
  final double? size;
  final double? value;
  final Animation<Color?>? valueColor;

  const CircularLoader({
    Key? key,
    this.color,
    this.decoration,
    this.size,
    this.value,
    this.valueColor,
    this.accentColor,
  }) : super(key: key);

  @override
  LoaderState createState() => LoaderState();
}

class LoaderState extends State<CircularLoader> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {}

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(10),
        height: widget.size != null ? widget.size! : 40.0,
        width: widget.size != null ? widget.size! : 40.0,
        decoration: widget.decoration ??
            BoxDecoration(
              color: widget.color ?? Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4.0,
                  spreadRadius: 1.0,
                  offset: const Offset(0.0, 0.0),
                )
              ],
            ),
        //Progress color uses accentColor from ThemeData
        child: CircularProgressIndicator(
          strokeWidth: 2,
          value: widget.value,
          valueColor: widget.valueColor,
        ),
      ),
    );
  }
}
