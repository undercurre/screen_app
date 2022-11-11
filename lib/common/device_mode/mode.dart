class Mode {
  String key;
  String name;
  String icon;
  bool selected;

  Mode(this.key, this.name, this.icon, this.selected);

  void select() {
    selected = true;
  }
}