import 'package:screen_app/common/adapter/midea_data_adapter.dart';
import 'package:screen_app/common/adapter/select_family_data_adapter.dart';

import '../homlux/api/homlux_user_api.dart';
import '../meiju/api/meiju_user_api.dart';
import '../system.dart';

///
/// 接口业务适配层
/// 功能描述：
///        检查当前用户是否有权限登录当前家庭 （不包含对网关是否绑定的检查）
/// 结果：
///         null 未检查出结果
///         true 有权限登录
///         false 无权限登录
class CheckAuthAdapter extends MideaDataAdapter {

  CheckAuthAdapter(super.platform);


  Future<bool?> check() async {
    String? familyId = System.familyInfo?.familyId;
    if(familyId == null) return null;
    if(platform.inHomlux()) {
      var res = await HomluxUserApi.queryHouseAuth(familyId);
      return !(res.isSuccess && (res.data?.isTourist() == true || res.data?.isNoRelationship() == true));
    } else if(platform.inMeiju()) {
      var res = await MeiJuUserApi.getHomeListFromMidea();
      if (res.isSuccess && res.data != null && res.data!.homeList != null) {
        var familyListEntity = SelectFamilyListEntity.fromMeiJu(res.data?.homeList ?? []);
        if(familyListEntity.familyList.isNotEmpty) {
          var finder = familyListEntity.familyList.any((element) => element.familyId == familyId);
          return finder;
        }
      }
    }
    return null;
  }



}