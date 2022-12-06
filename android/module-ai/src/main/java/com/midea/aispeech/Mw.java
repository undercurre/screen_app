package com.midea.aispeech;

import android.util.Log;

import org.json.JSONException;

public class Mw
{
    private static final String TAG = "MideaSpeechAI";
    private static Mw mw;


    static {


        try {
            Log.e(TAG,  "CRC load library libmspeech.so ");

            System.loadLibrary("mspeech");

            Log.e(TAG,  "CRC load library libmspeech.so successfully");
        } catch (UnsatisfiedLinkError ule) {
            Log.e(TAG,"WARNING: Could not load library libmspeech.so!" + ule);
        }

    }

    public static synchronized Mw getInstance()
    {
        if (mw == null) {
            mw = new Mw();
        }
        return mw;
    }

    public interface Callback {
        public void function(int type, String eventName, String data) throws JSONException, InterruptedException;
    }

    public static int registerEvent(int index, String[] type, Callback func)
    {
        if ((type == null) || (type.length == 0))
        {
            return -1;
        }
        if (func == null)
        {
            return -1;
        }

        return registerEventDo(index, type, func);
    }

    public synchronized static int init(String jsonDeviceInfo)
    {
        initDo(jsonDeviceInfo);

        return 0;
    }

    public synchronized static int deInit()
    {
        return 0;
    }

    public synchronized static int commandResponse(String jsonDevResp)
    {
        //Log.d(TAG, "commandAndResponse" + jsonDevResp);

        return 0;
    }

    /*
      speechCtrl: "start/stop",
    */
    public synchronized static int speechCtrl(String speechCtrl)
    {
        // Log.d(TAG, "speechCtrl: " + speechCtrl);

        //TODO: start or stop aispeech

        return  0;
    }

    public int getInitStatus()
    {
        return 1;
    }

    public static native int setEventCallback(Callback callback);
    public static native int registerEventDo(int index, String[] type, Callback func);
    public static native int unregisterEvent(int index, String[] type, Callback func);

    public static native int initDo(String deviceInfo);
    public static native int unInitDo();
    public static native int deviceStatusToCloudResp(String jsonDevResp);
    public static native int playStatusToSpeech(String jsonDevResp);

    public static native int audioDataToSpeech(byte[] buffer, int size);
    public static native int beginningTTS(String ttsStr);
    public static native int beginningOnlineTTS(String ttsStr);
    public static native int getNLPwithText(String ttsStr);
    public static native int settingAccent(String accent);
    public static native String gettingAccent();
    public static native int settingDeviceInfo(String deviceInfo);

    //media AI CLOUD
    public static native int endOfSpeech();
    public static native int createSession();
    public static native int registerLicense(String deviceInfo);
    public static native int getLicense();

}