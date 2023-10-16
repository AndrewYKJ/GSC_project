import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class CustomSlidableMotion extends StatefulWidget {
  final Function? onOpen;
  final Function? onClose;
  final Widget? motionWidget;

  const CustomSlidableMotion(
      {Key? key, this.onOpen, this.onClose, this.motionWidget})
      : super(key: key);

  @override
  _CustomSlidableMotion createState() => _CustomSlidableMotion();
}

class _CustomSlidableMotion extends State<CustomSlidableMotion> {
  static SlidableController? controller;

  bool isClosed = true;

  void animationListener() {
    if ((controller!.ratio == (-0.0)) && widget.onClose != null && !isClosed) {
      isClosed = true;
      widget.onClose!();
    }

    if ((controller!.ratio == (-0.2)) && widget.onOpen != null && isClosed) {
      isClosed = false;
      widget.onOpen!();
    }
  }

  @override
  void dispose() {
    controller!.animation.removeListener(animationListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller = Slidable.of(context)!;

    controller!.animation.addListener(animationListener);

    return widget.motionWidget!;
  }
}
