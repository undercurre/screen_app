package com.midea.light.common.utils;

import androidx.annotation.NonNull;
import org.json.JSONArray;
import org.json.JSONException;

/**
 * @ClassName JSONArrayUtils
 * @Description
 * @Author weinp1
 * @Date 2023/1/5 13:26
 * @Version 1.0
 */
public class JSONArrayUtils {
    private JSONArrayUtils(){}

    public static int[] toIntArray(@NonNull JSONArray jsonArray) {
        final int[] result = new int[jsonArray.length()];
        for (int i = 0; i < jsonArray.length(); i++) {
            try {
                result[i] = jsonArray.getInt(i);
            } catch (JSONException e) {
                throw new RuntimeException(e);
            }
        }
        return result;
    }

    public static String[] toStringArray(@NonNull JSONArray jsonArray) {
        final String[] result = new String[jsonArray.length()];
        for (int i = 0; i < jsonArray.length(); i++) {
            try {
                result[i] = jsonArray.getString(i);
            } catch (JSONException e) {
                throw new RuntimeException(e);
            }
        }
        return result;
    }

    public static boolean[] toBooleanArray(@NonNull JSONArray jsonArray) {
        final boolean[] result = new boolean[jsonArray.length()];
        for (int i = 0; i < jsonArray.length(); i++) {
            try {
                result[i] = jsonArray.getBoolean(i);
            } catch (JSONException e) {
                throw new RuntimeException(e);
            }
        }
        return result;
    }

    public static double[] toDoubleArray(@NonNull JSONArray jsonArray) {
        final double[] result = new double[jsonArray.length()];
        for (int i = 0; i < jsonArray.length(); i++) {
            try {
                result[i] = jsonArray.getDouble(i);
            } catch (JSONException e) {
                throw new RuntimeException(e);
            }
        }
        return result;
    }

    public static long[] toLongArray(@NonNull JSONArray jsonArray) {
        final long[] result = new long[jsonArray.length()];
        for (int i = 0; i < jsonArray.length(); i++) {
            try {
                result[i] = jsonArray.getLong(i);
            } catch (JSONException e) {
                throw new RuntimeException(e);
            }
        }
        return result;
    }


}
