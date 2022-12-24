package com.midea.light.device.explore.api;

import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;
import com.midea.light.device.explore.Portal;
import com.midea.light.device.explore.api.entity.ApplianceBean;
import com.midea.light.device.explore.api.entity.HttpResult;
import com.midea.light.device.explore.api.entity.SearchZigbeeDeviceResult;
import com.midea.light.utils.GsonUtils;
import com.midea.light.utils.TimeUtil;
import com.midea.smart.open.common.exception.AuthException;

import java.io.IOException;
import java.lang.reflect.Type;
import java.util.List;
import java.util.UUID;

import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;
import okhttp3.logging.HttpLoggingInterceptor;

/**
 * @ClassName ApiService
 * @Description
 * @Author weinp1
 * @Date 2022/12/21 14:29
 * @Version 1.0
 */
class HttpClient {
    // 构建 OkHttpClient
    static OkHttpClient create(boolean debug) {
        HttpLoggingInterceptor interceptor = new HttpLoggingInterceptor();
        interceptor.setLevel(debug? HttpLoggingInterceptor.Level.BODY: HttpLoggingInterceptor.Level.NONE);
        return new OkHttpClient.Builder()
                .addInterceptor(interceptor)
                .build();

    }

    static String sign(String bodyStr, String httpSign, long random) {
        try {
            return com.midea.smart.open.common.auth.MD5.encrypt(httpSign + bodyStr + random);
        } catch (AuthException e) {
            e.printStackTrace();
        }
        return "";
    }
}

public class ApiService implements IApiService {
    OkHttpClient mOkhttpClient;

    public ApiService() {
        mOkhttpClient = HttpClient.create(Portal.getBaseConfig().isDebug());
    }

    Request create(String path, String requestData) {
        RequestBody requestBody = RequestBody.create(MediaType.parse("application/json; charset=UTF-8"), requestData.toString());
        long random = System.currentTimeMillis();
        String signData = HttpClient.sign(requestData.toString(), Portal.getBaseConfig().getHttpSign(), random);
        Request.Builder builder = new Request.Builder();
        builder.url(Portal.getBaseConfig().getHost()+ '/' + path)
                .post(requestBody)
                .addHeader("accessToken", Portal.getBaseConfig().getToken())
                .addHeader("sign", signData)
                .addHeader("random", String.valueOf(random))
                .addHeader("deviceId", Portal.getBaseConfig().getDeviceId());
        return builder.build();
    }

    <T> T returnResult(TypeToken<T> token, Response response) throws IOException {
        if(response.isSuccessful()) {
            HttpResult<T> result = GsonUtils.tryParse(TypeToken.getParameterized(
                        new TypeToken<HttpResult<T>>(){}.getType(),
                        token.getType()
                    ).getType(), response.body().string());
            if(result != null  && result.isSuc()) {
                return result.getData();
            }
        }
        return null;
    }

    @Override
    public ApplianceBean bindDevice(String uid, String homeGroupId, String roomId, String applianceType,
                           String deviceSN, String name, String reqId, String stamp)
    {
        JsonObject request = new JsonObject();
        request.addProperty("uid", uid);
        request.addProperty("homegroupId", homeGroupId);
        request.addProperty("roomId", roomId);
        request.addProperty("sn", deviceSN);
        request.addProperty("applianceType", applianceType);
        request.addProperty("applianceName", name);
        request.addProperty("reqId", reqId);
        request.addProperty("stamp", stamp);

        try {
           Response response = mOkhttpClient.newCall(
                   create("/mas/v5/app/proxy?alias=/v1/appliance/home/bind", request.toString())).execute();
           return returnResult(new TypeToken<ApplianceBean>(){}, response);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    // 发送指令到网关
    @Override
    public boolean transmitCommandToGateway(String uid, String applianceCode, String order,
                                                      String homeGroupId, String stamp, String reqId) {

        JsonObject request = new JsonObject();
        request.addProperty("uid", uid);
        request.addProperty("stamp", stamp);
        request.addProperty("reqId", reqId);
        request.addProperty("applianceCode", applianceCode);
        request.addProperty("order", order);
        request.addProperty("homegroupId", homeGroupId);
        try {
            Response response = mOkhttpClient.newCall(create("mas/v5/app/proxy?alias=/v1/gateway/transport/send", request.toString())).execute();
            Object data = returnResult(new TypeToken<Object>(){}, response);
            return data != null;
        } catch (IOException e) {
            e.printStackTrace();
        }

        return false;
    }
    // 检查网关是有发现设备
    @Override
    public List<SearchZigbeeDeviceResult.ZigbeeDevice> checkGatewayWhetherHasFindDevice(String uid, String reqId, String stamp, String homeGroupId, String applianceCode) {
        JsonObject request = new JsonObject();
        request.addProperty("uid", uid);
        request.addProperty("reqId", reqId);
        request.addProperty("stamp", stamp);
        request.addProperty("homegroupId", homeGroupId);
        request.addProperty("applianceCode", applianceCode);

        try {
            Response response = mOkhttpClient.newCall(create("/mas/v5/app/proxy?alias=/v1/gateway/subdevice/search", request.toString())).execute();
            SearchZigbeeDeviceResult result = returnResult(new TypeToken<SearchZigbeeDeviceResult>(){}, response);
            return result.getList();
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    @Override
    public ApplianceBean modifyRoom(String homeGroupId, String roomId, String applianceCode) {
        JsonObject request = new JsonObject();
        request.addProperty("applianceCode", applianceCode);
        request.addProperty("roomId", roomId);
        request.addProperty("homegroupId", homeGroupId);
        request.addProperty("stamp", TimeUtil.getTimestamp());
        request.addProperty("reqId", UUID.randomUUID().toString());

        try {
            Response response = mOkhttpClient.newCall(create("mas/v5/app/proxy?alias=/v1/appliance/home/modify", request.toString())).execute();
            return returnResult(new TypeToken<ApplianceBean>(){}, response);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

}
