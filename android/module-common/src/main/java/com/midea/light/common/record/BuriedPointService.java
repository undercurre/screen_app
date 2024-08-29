package com.midea.light.common.record;

import org.json.JSONObject;

/**
 * 埋点上报服务接口
 */
public interface BuriedPointService {
    void reportEvent(String eventName, JSONObject value);
    void reportEvent(String eventName);
}
