package com.midea.light.common.utils;

import com.midea.light.utils.GsonUtils;

import org.json.JSONException;
import org.json.JSONObject;

/**
 * @ClassName JSONObjectUtils
 * @Description
 * @Author weinp1
 * @Date 2023/1/5 14:13
 * @Version 1.0
 */
public class JSONObjectUtils {

    private JSONObjectUtils() {}

    public static JSONObject objectToJson(Object object) {
        String json = GsonUtils.stringify(object);
        try {
            return new JSONObject(json);
        } catch (JSONException e) {
            throw new RuntimeException(e);
        }
    }

}
