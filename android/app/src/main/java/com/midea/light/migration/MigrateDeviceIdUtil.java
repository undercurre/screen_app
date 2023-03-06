package com.midea.light.migration;

import android.content.Context;
import android.telephony.TelephonyManager;
import android.text.TextUtils;

import com.midea.light.log.LogUtil;
import com.midea.smart.open.common.auth.MD5;

import java.util.UUID;

/**
 * 获取设备ID
 * deviceID的组成为：渠道标志+识别符来源标志+hash后的终端识别符
 */
public class MigrateDeviceIdUtil {

    private static final boolean debug = false;

    /**
     * 渠道标志为：
     * 1，andriod（a）
     * <p>
     * 识别符来源标志：
     * 1， wifi mac地址（wifi）；
     * 2， IMEI（imei）；
     * 3， 序列号（sn）；
     * 4， id：随机码。若前面的都取不到时，则随机生成一个随机码，需要缓存。
     *
     * @param context
     * @return
     */
    public static String getDeviceId(Context context) {


        StringBuilder deviceId = new StringBuilder();
        // 渠道标志
        try {
            //IMEI（imei）
            TelephonyManager tm = (TelephonyManager) context.getSystemService(Context.TELEPHONY_SERVICE);
            String imei = tm.getDeviceId();
            if (!TextUtils.isEmpty(imei)) {
                deviceId.append("imei");
                deviceId.append(imei);
                String id = MD5.encrypt(deviceId.toString());
                LogUtil.enable(debug).msg("getDeviceId : " + id);
                return id;
            }
            //序列号（sn）
            String sn = tm.getSimSerialNumber();
            if (!TextUtils.isEmpty(sn)) {
                deviceId.append("sn");
                deviceId.append(sn);
                String id = MD5.encrypt(deviceId.toString());
                LogUtil.enable(debug).msg("getDeviceId : " + id);
                return id;
            }
            //如果上面都没有， 则生成一个id：随机码
            String uuid = getUUID();
            if (!TextUtils.isEmpty(uuid)) {
                deviceId.append("id");
                deviceId.append(uuid);
                String id = MD5.encrypt(deviceId.toString());
                LogUtil.enable(debug).msg("getDeviceId : " + id);
                return id;
            }
        } catch (Exception e) {
            e.printStackTrace();
            deviceId.append("id").append(getUUID());
        }
        try {
            String id = MD5.encrypt(deviceId.toString());
            LogUtil.enable(debug).msg("getDeviceId : " + id);
            return id;
        } catch (Exception e) {
            e.printStackTrace();
            return deviceId.toString();
        }
    }

    /**
     * 得到全局唯一UUID
     */
    public static String getUUID() {
        String uuid = null;
        uuid = MigrateTokenCache.getInstance().getDevicesId();
        if (TextUtils.isEmpty(uuid)) {
            uuid = UUID.randomUUID().toString();
            MigrateTokenCache.getInstance().saveDevicesId(uuid);
        }
        return uuid;
    }
}