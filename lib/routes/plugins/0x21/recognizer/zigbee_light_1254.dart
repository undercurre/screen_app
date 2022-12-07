import 'zigbee_light_interface.dart';

class ZigbeeLight1254 implements ZigbeeLightInterface {
  @override
  String recognize() {
    // TODO: implement recognize
    return 'DG';
  }

  @override
  String getRoute() {
    // TODO: implement getRoute
    return '0x21_light';
  }
}