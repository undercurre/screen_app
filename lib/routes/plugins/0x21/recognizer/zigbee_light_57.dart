import 'zigbee_light_interface.dart';

class ZigbeeLight57 implements ZigbeeLightInterface {
  @override
  String recognize() {
    // TODO: implement recognize
    return 'DS';
  }

  @override
  String getRoute() {
    // TODO: implement getRoute
    return '0x21_light';
  }
}