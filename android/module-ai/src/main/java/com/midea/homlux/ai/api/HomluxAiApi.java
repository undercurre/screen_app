package com.midea.homlux.ai.api;

import android.util.Log;

import com.midea.light.common.config.AppCommonConfig;
import com.midea.light.utils.GsonUtils;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import okhttp3.Call;
import okhttp3.Callback;
import okhttp3.Headers;
import okhttp3.MediaType;
import okhttp3.OkHttpClient;
import okhttp3.Request;
import okhttp3.RequestBody;
import okhttp3.Response;

public class HomluxAiApi {

    public static class HomluxDuiTokenEntity {
        public int refreshTokenExpireTime;
        public int accessTokenExpireTime;
        public String accessToken;
        public String refreshToken;
    }

    // AI Token Callback
    public interface IHomluxQueryDuiTokenCallback {
        // 空为请求失败
        void result(HomluxDuiTokenEntity entity);
    }

    public static void syncQueryDuiToken(String hourseId, String aiClientId, String token, IHomluxQueryDuiTokenCallback callback) {
        Map<String, String> headers = new HashMap<>();
        headers.put("Authorization", "Bearer " + token);

        Map<String, Object> data = new HashMap<>();
        data.put("houseId", hourseId);
        data.put("client_id", aiClientId);
        data.put("frontendType", "ANDROID");
        data.put("reqId", UUID.randomUUID().toString());
        data.put("systemSource", "FSMARTSCREEN");
        data.put("timestamp", System.currentTimeMillis());
        String jsonData = GsonUtils.stringify(data);
        OkHttpClient okHttpClient = new OkHttpClient();
        Request request = new Request.Builder()
                .url(AppCommonConfig.HOMLUX_HOST + "/mzaio/v1/thirdparty/dui/get/oauth2/access_token")
                .headers(Headers.of(headers))
                .method("POST", RequestBody.create(MediaType.parse("application/json; charset=UTF-8"), jsonData))
                .build();
        okHttpClient.newCall(request).enqueue(new Callback() {
            @Override
            public void onFailure(Call call, IOException e) {
                try {
                    callback.result(null);
                } finally {
                    // 关闭所有okHttpClient资源
                    okHttpClient.dispatcher().executorService().shutdown();
                    okHttpClient.connectionPool().evictAll();
                }
            }

            @Override
            public void onResponse(Call call, Response response) throws IOException {
                try {
                    if (response.body() != null) {
                        String resultContent = response.body().string();
                        Log.i("sky", "获取HomluxAiToken请求成功：$resultContent");
                        callback.result(GsonUtils.tryParse(HomluxDuiTokenEntity.class, resultContent));
                    } else {
                        Log.i("sky", "获取HomluxAiToken请求失败");
                        callback.result(null);
                    }
                } finally {
                    // 关闭所有okHttpClient资源
                    okHttpClient.dispatcher().executorService().shutdown();
                    okHttpClient.connectionPool().evictAll();
                }
            }
        });
    }

    public static HomluxDuiTokenEntity ayncQueryDuiToken(String hourseId, String aiClientId, String token) {
        Map<String, String> headers = new HashMap<>();
        headers.put("Authorization", "Bearer " + token);

        Map<String, Object> data = new HashMap<>();
        data.put("houseId", hourseId);
        data.put("client_id", aiClientId);
        data.put("frontendType", "ANDROID");
        data.put("reqId", UUID.randomUUID().toString());
        data.put("systemSource", "FSMARTSCREEN");
        data.put("timestamp", System.currentTimeMillis());
        String jsonData = GsonUtils.stringify(data);
        OkHttpClient okHttpClient = new OkHttpClient();
        Request request = new Request.Builder()
                .url(AppCommonConfig.HOMLUX_HOST + "/mzaio/v1/thirdparty/dui/get/oauth2/access_token")
                .headers(Headers.of(headers))
                .method("POST", RequestBody.create(MediaType.parse("application/json; charset=UTF-8"), jsonData))
                .build();
        try {
            Response response = okHttpClient.newCall(request).execute();
            if (response.body() != null) {
                String resultContent = response.body().string();
                Log.i("sky", "获取HomluxAiToken请求成功：$resultContent");
                return GsonUtils.tryParse(HomluxDuiTokenEntity.class, resultContent);
            } else {
                Log.i("sky", "获取HomluxAiToken请求失败");
                return null;
            }
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            // 关闭所有okHttpClient资源
            okHttpClient.dispatcher().executorService().shutdown();
            okHttpClient.connectionPool().evictAll();
        }
        return null;
    }

}
