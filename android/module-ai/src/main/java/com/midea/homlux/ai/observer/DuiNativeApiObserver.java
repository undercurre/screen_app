package com.midea.homlux.ai.observer;

import android.content.Context;
import android.util.Log;

import com.aispeech.dui.dds.DDS;
import com.aispeech.dui.dsk.duiwidget.NativeApiObserver;
import com.aispeech.dui.dsk.duiwidget.TextWidget;
import com.midea.light.BaseApplication;
import com.midea.light.setting.SystemUtil;

/*
 * 注册NativeApiObserver, 用于客户端响应DUI平台技能配置里的资源调用指令, 同一个NativeApiObserver可以处理多个native api.
 * 目前demo中实现了打电话的功能逻辑
 */
public class DuiNativeApiObserver implements NativeApiObserver {
    private String TAG = "sky";
    private static final String NATIVE_API_GET_INFOR = "DUI.System.GetInfo";
    private static final String NATIVE_API_SET_ALERT = "DUI.Alerts.SetAlert";
    private static final String NATIVE_API_QUERY_ALERT = "DUI.Alerts.QueryAlert";
    private static final String NATIVE_API_DELETE_ALERT = "DUI.Alerts.DeleteAlert";


    private Context mContext;

    public DuiNativeApiObserver() {
        mContext = BaseApplication.getContext();
    }

    // 注册当前更新消息
    public void regist() {
        DDS.getInstance().getAgent().subscribe(new String[]{NATIVE_API_GET_INFOR, NATIVE_API_SET_ALERT, NATIVE_API_QUERY_ALERT, NATIVE_API_DELETE_ALERT}, this);
    }

    // 注销当前更新消息
    public void unregist() {
        DDS.getInstance().getAgent().unSubscribe(this);
    }

    /*
     * onQuery方法执行时，需要调用feedbackNativeApiResult来向DUI平台返回执行结果，表示一个native api执行结束。
     * native api的执行超时时间为10s
     */
    @Override
    public void onQuery(String nativeApi, String data) {
        Log.e(TAG, "nativeApi: " + nativeApi + "  data: " + data);
        if (nativeApi.equals("DUI.System.GetInfo")) {
            if (data.contains("亮度")) {
                int light = SystemUtil.lightGet();
                int bili = (int) (((float) light / (float) 255) * 100);
                TextWidget textWidget = new TextWidget();
                textWidget.addExtra("errId", "0");//nativeApi回传的参数
                textWidget.addExtra("__tgt__", "当前亮度");//nativeApi回传的参数
                textWidget.addExtra("brightness", bili + "");//nativeApi回传的参数
                DDS.getInstance().getAgent().feedbackNativeApiResult("DUI.System.GetInfo", textWidget);
            } else if (data.contains("音量") || data.contains("声音")) {
                int sound = SystemUtil.getSystemAudio();
                int bili = (int) (((float) sound / (float) 15) * 100);
                TextWidget textWidget = new TextWidget();
                textWidget.addExtra("errId", "0");//nativeApi回传的参数
                textWidget.addExtra("__tgt__", "当前音量");//nativeApi回传的参数
                textWidget.addExtra("volume", bili + "");//nativeApi回传的参数
                DDS.getInstance().getAgent().feedbackNativeApiResult("DUI.System.GetInfo", textWidget);
            }
        } else if (nativeApi.equals("DUI.Alerts.SetAlert")) {


        } else if (nativeApi.equals("DUI.Alerts.QueryAlert")) {


        } else if (nativeApi.equals("DUI.Alerts.DeleteAlert")) {


        }
    }


}
