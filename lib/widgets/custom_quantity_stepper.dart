// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/constants.dart';

class QuantityButton extends StatefulWidget {
  final bool isAurum;
  final bool hasVariation;
  final int initialQuantity;
  final int maxQuantity;
  final int currentQuantity;
  final int? fromModal;
  final Future<int>? Function(int) onQuantityChange;
  const QuantityButton(
      {Key? key,
      required this.isAurum,
      required this.hasVariation,
      this.fromModal,
      required this.initialQuantity,
      required this.maxQuantity,
      required this.currentQuantity,
      required this.onQuantityChange})
      : super(key: key);

  @override
  _QuantityButtonState createState() => _QuantityButtonState(
      quantity: initialQuantity,
      maxQty: maxQuantity,
      currentQty: currentQuantity);
}

class _QuantityButtonState extends State<QuantityButton> {
  int quantity;
  int maxQty;
  int currentQty;
  bool isSaving = false;
  _QuantityButtonState(
      {required this.quantity, required this.maxQty, required this.currentQty});

  void changeQuantity(int newQuantity) async {
    if (!widget.hasVariation) {
      setState(() {
        isSaving = true;
      });

      newQuantity = await widget.onQuantityChange(newQuantity) ?? newQuantity;

      setState(() {
        if (newQuantity <= maxQty) {
          quantity = newQuantity;
        }
        isSaving = false;
      });
    } else {
      newQuantity = await widget.onQuantityChange(0) ?? 0;
      setState(() {
        if (newQuantity <= maxQty) {
          quantity = newQuantity;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fromModal != null && widget.hasVariation) {
      quantity = widget.fromModal!;
    }
    return Row(children: [
      InkWell(
        onTap: (isSaving || quantity < 1)
            ? null
            : () {
                if (quantity - 1 >= 0) {
                  changeQuantity(quantity - 1);
                }
              },
        child: SizedBox(
          height: 24,
          width: 24,
          child: widget.isAurum
              ? (isSaving || quantity < 1)
                  ? Image.asset(
                      Constants.ASSET_IMAGES + 'grey-minus-button.png')
                  : Image.asset(
                      Constants.ASSET_IMAGES + 'aurum-minus-button.png')
              : (isSaving || quantity < 1)
                  ? Image.asset(
                      Constants.ASSET_IMAGES + 'grey-minus-button.png')
                  : Image.asset(Constants.ASSET_IMAGES + 'minus-button.png'),
        ),
      ),
      SizedBox(
        width: 50,
        child: Text(
          quantity.toString(),
          textAlign: TextAlign.center,
          maxLines: 1,
          style: AppFont.poppinsRegular(16, color: Colors.white),
        ),
      ),
      InkWell(
        onTap: (isSaving || widget.currentQuantity >= maxQty)
            ? null
            : () => changeQuantity(quantity + 1),
        child: SizedBox(
          height: 24,
          width: 24,
          child: widget.isAurum
              ? Image.asset(Constants.ASSET_IMAGES + 'aurum-plus-button.png')
              : Image.asset(Constants.ASSET_IMAGES + 'plus-button.png'),
        ),
      ),
    ]);
  }
}
