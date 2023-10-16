class AurumEcomboModel {
  String? name;
  int? quantity;
  String? bundleCode;
  bool? isComplete;
  int? selectedFood;
  int? selectedDrink;
  List<String>? selectedItmCode;

  AurumEcomboModel(
      {this.name,
      this.quantity,
      this.bundleCode,
      this.isComplete,
      this.selectedFood,
      this.selectedDrink,
      this.selectedItmCode});
}
