class ModelProduit {
  String id;
  String name;
  String description;
  String image;
  String price;
  String category_id;
  String quantity;
  List produitsup;
  bool isactive;
  ModelProduit(this.id, this.name, this.description, this.image, this.price,
      this.category_id, this.quantity, this.produitsup, this.isactive);
}
