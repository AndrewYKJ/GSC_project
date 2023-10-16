// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';
import 'package:gsc_app/const/app_font.dart';
import 'package:gsc_app/const/constants.dart';
import 'package:gsc_app/models/json/ticket_item_model.dart';

class QuantityVariationButton extends StatefulWidget {
  final bool isAurum;
  final bool hasVariation;
  final int initialQuantity;
  final int maxQuantity;
  final int currentQuantity;
  final int? fromModal;
  final Future<int>? Function(int) onQuantityChange;
  final List<ComboChildItemModel> list;
  final List<ComboModel> selectedCombo;
  const QuantityVariationButton(
      {Key? key,
      required this.isAurum,
      required this.hasVariation,
      this.fromModal,
      required this.initialQuantity,
      required this.maxQuantity,
      required this.currentQuantity,
      required this.onQuantityChange,
      required this.list,
      required this.selectedCombo})
      : super(key: key);

  @override
  _QuantityVariationButtonState createState() => _QuantityVariationButtonState(
      quantity: initialQuantity,
      maxQty: maxQuantity,
      currentQty: currentQuantity);
}

class _QuantityVariationButtonState extends State<QuantityVariationButton> {
  int quantity;
  int maxQty;
  int currentQty;
  bool isSaving = false;
  _QuantityVariationButtonState(
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
    var totalqty = 0;
    for (var data in widget.list) {
      for (var element in widget.selectedCombo) {
        if (data.CODE == element.id) {
          totalqty += element.qty!;
        }
      }
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
        onTap: (isSaving || (widget.currentQuantity >= maxQty))
            ? null
            : () {
                if (totalqty + 1 <= maxQty) {
                  changeQuantity(quantity + 1);
                }
              },
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
