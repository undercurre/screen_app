package com.midea.light.common.record;

import org.json.JSONObject;

import java.util.function.Supplier;

/**
 * 埋点工具
 */
public class MideaBuriedPoint {

    private static BuriedPointService buriedPointService;
    private static Supplier<BuriedPointService> lazyService;

    public static void init(Supplier<BuriedPointService> lazyService) {
        MideaBuriedPoint.lazyService = lazyService;
    }

    public static void init(BuriedPointService buriedPointService) {
        MideaBuriedPoint.buriedPointService = buriedPointService;
    }

    public static void reportEvent(String eventName, String name1, Object value1, String name2, Object value2,
                                   String name3, Object value3, String name4, Object value4, String name5, Object value5)
    {
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put(name1, value1);
            jsonObject.put(name2, value2);
            jsonObject.put(name3, value3);
            jsonObject.put(name4, value4);
            jsonObject.put(name5, value5);
            reportEvent(eventName, jsonObject);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void reportEvent(String eventName, String name1, Object value1, String name2, Object value2,
                                   String name3, Object value3, String name4, Object value4)
    {
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put(name1, value1);
            jsonObject.put(name2, value2);
            jsonObject.put(name3, value3);
            jsonObject.put(name4, value4);
            reportEvent(eventName, jsonObject);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void reportEvent(String eventName, String name1, Object value1, String name2, Object value2, String name3, Object value3)
    {
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put(name1, value1);
            jsonObject.put(name2, value2);
            jsonObject.put(name3, value3);
            reportEvent(eventName, jsonObject);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void reportEvent(String eventName, String name1, Object value1, String name2, Object value2)
    {
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put(name1, value1);
            jsonObject.put(name2, value2);
            reportEvent(eventName, jsonObject);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void reportEvent(String eventName, String name, String value)
    {
        try {
            JSONObject jsonObject = new JSONObject();
            jsonObject.put(name, value);
            reportEvent(eventName, jsonObject);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void reportEvent(String eventName, JSONObject value) {
        ensureInit();
        buriedPointService.reportEvent(eventName, value);
    }

    public static void reportEvent(String eventName) {
        ensureInit();
        buriedPointService.reportEvent(eventName);
    }

    static void ensureInit() {
        if(lazyService == null && buriedPointService == null) throw new RuntimeException("请先调用init方法");
        if(buriedPointService == null) {
            buriedPointService = lazyService.get();
        }
    }

}
