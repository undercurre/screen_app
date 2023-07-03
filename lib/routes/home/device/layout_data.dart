import 'grid_container.dart';

class Layout {
  String deviceId;
  String type;
  CardType cardType;
  int pageIndex;
  double left;
  double top;
  dynamic data;

  Layout(this.deviceId, this.type, this.cardType, this.pageIndex, this.left, this.top, this.data);
}