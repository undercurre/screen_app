package com.midea.light.setting.wifi.impl;

import android.annotation.SuppressLint;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.net.ConnectivityManager;
import android.net.NetworkInfo;
import android.net.wifi.ScanResult;
import android.net.wifi.WifiConfiguration;
import android.net.wifi.WifiManager;
import android.os.Handler;
import android.os.Looper;
import android.os.Message;
import android.provider.Settings;
import android.text.TextUtils;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.StringRes;

import com.midea.light.BaseApplication;
import com.midea.light.ld.setting.R;
import com.midea.light.log.LogUtil;
import com.midea.light.setting.wifi.impl.entity.WiFiAccountPasswordBean;
import com.midea.light.setting.wifi.impl.repositories.WiFiRecordRepositories;
import com.midea.light.setting.wifi.util.WifiUtil;

import java.util.List;

import static android.net.wifi.WifiManager.WIFI_STATE_ENABLED;
import static android.net.wifi.WifiManager.WIFI_STATE_UNKNOWN;

public class WifiConnector {
    private final static int CONNECTED_WIFI_SUC = 1;
    private final static int CONNECTED_WIFI_FAIL = 2;

    private final Context mContext;
    private final String mScanResultSecurity;
    private final ScanResult mScanResult;
    private final int mNumOpenNetworksKept;
    private boolean mIsOpenNetwork = false;
    boolean register = false;

    private WifiManager mWifiManager;
    private VerifyConnectedState connectedState;
    private IConnectedCallback mConnectedCallback;
    private String pwd;

    Handler mHandler = new Handler(Looper.getMainLooper()) {

        @Override
        public void handleMessage(@NonNull Message msg) {
            super.handleMessage(msg);
            switch (msg.what) {
                case CONNECTED_WIFI_FAIL:
                    if (mConnectedCallback != null)
                        mConnectedCallback.invalidConnect(pwd, mScanResult);
                    break;
                case CONNECTED_WIFI_SUC:
                    if (mConnectedCallback != null)
                        mConnectedCallback.validConnected(mScanResult);
                    break;
            }
        }
    };


    private class VerifyConnectedState extends BroadcastReceiver {
        private static final int TYPE_CONNECT_OLD_WIFI = 0X01;
        private static final int TYPE_CONNECT_NEW_WIFI = 0X02;
        private static final int TYPE_CONNECT_MODIFY_PASSWORD_WIFI = 0X03;

        ScanResult target;
        boolean start = false;
        //Boolean vailded = null;
        int mConnectType;
        int lockCount;

        public void setStart(boolean start) {
            this.start = start;
        }

        public void setConnectType(int type) {
            this.mConnectType = type;
            if (TYPE_CONNECT_MODIFY_PASSWORD_WIFI == type) {
                lockCount = 2;
            } else if (TYPE_CONNECT_NEW_WIFI == type) {
                lockCount = 1;
            } else if (TYPE_CONNECT_OLD_WIFI == type) {
                lockCount = 1;
            }
        }

        public VerifyConnectedState(ScanResult scanResult) {
            this.target = scanResult;
        }


        @Override
        public void onReceive(Context context, Intent intent) {
            if (!start || lockCount == 0)
                return;

            if (intent.getAction().equals(WifiManager.WIFI_STATE_CHANGED_ACTION)) {

                if (mConnectType == TYPE_CONNECT_OLD_WIFI) {
                    return;
                }

                switch (intent.getIntExtra(WifiManager.EXTRA_WIFI_STATE, WIFI_STATE_UNKNOWN)) {
                    case WIFI_STATE_ENABLED: {
                        NetworkInfo info;
                        if ((info = isWifiConnected()) != null) {
                            LogUtil.i("WIFI_CONNECT_SUC_1");
                            String extraSSID = TextUtils.isEmpty(info.getExtraInfo()) ? "<unknown ssid>" : info.getExtraInfo().replace("\"", "");
                            if (target.SSID.equals(extraSSID)) {
                                mHandler.removeMessages(CONNECTED_WIFI_SUC);
                                mHandler.sendEmptyMessage(CONNECTED_WIFI_SUC);
                                lockCount = 0;
                            } else {
                                LogUtil.i("ERROR_AUTHENTICATING_2");
                                mHandler.removeMessages(CONNECTED_WIFI_FAIL);
                                mHandler.sendEmptyMessage(CONNECTED_WIFI_FAIL);
                                lockCount = 0;
                            }
                        }
                    }
                }
            } else if (intent.getAction().equals(WifiManager.SUPPLICANT_STATE_CHANGED_ACTION)) {
                //处理错误连接状态
                int linkWifiResult = intent.getIntExtra(WifiManager.EXTRA_SUPPLICANT_ERROR, -1);
                if (linkWifiResult == WifiManager.ERROR_AUTHENTICATING) {
                    if (lockCount <= 1) {
                        LogUtil.i("ERROR_AUTHENTICATING_1");
                        mHandler.removeMessages(CONNECTED_WIFI_FAIL);
                        mHandler.sendEmptyMessage(CONNECTED_WIFI_FAIL);
                    }
                    lockCount--;
                }
            } else if (intent.getAction().equals(WifiManager.NETWORK_STATE_CHANGED_ACTION)) {
                NetworkInfo info = intent.getParcelableExtra(WifiManager.EXTRA_NETWORK_INFO);
                String extraSSID = (info == null || TextUtils.isEmpty(info.getExtraInfo())) ? "<unknown ssid>" : info.getExtraInfo().replace("\"", "");
                NetworkInfo.State state = info.getState();
                if (info.getState().equals(NetworkInfo.State.CONNECTED)) {
                    LogUtil.i("WIFI_CONNECT_SUC_2");
                    //更新操作时间
                    if (target.SSID.equals(extraSSID) && NetworkInfo.State.CONNECTED.equals(state)) {
                        mHandler.removeMessages(CONNECTED_WIFI_SUC);
                        mHandler.sendEmptyMessage(CONNECTED_WIFI_SUC);
                        lockCount = 0;
                    }
                }
            }
        }

    }

    public NetworkInfo isWifiConnected() {
        ConnectivityManager connectivity = (ConnectivityManager) mContext.getSystemService(Context.CONNECTIVITY_SERVICE);
        if (connectivity == null) {
        } else {
            NetworkInfo[] info = connectivity.getAllNetworkInfo();
            if (info != null) {
                for (int i = 0; i < info.length; i++) {
                    if (info[i].getState() == NetworkInfo.State.CONNECTED) {
                        return info[i];
                    }
                }
            }
        }
        return null;
    }

    void register(ScanResult scanResult) {
        if (!register) {
            register = true;
            IntentFilter filter = new IntentFilter();
            filter.addAction(WifiManager.NETWORK_STATE_CHANGED_ACTION);

            filter.addAction(WifiManager.WIFI_STATE_CHANGED_ACTION);
            filter.addAction(WifiManager.SUPPLICANT_STATE_CHANGED_ACTION);
            filter.addAction(ConnectivityManager.CONNECTIVITY_ACTION);
            try {
                BaseApplication.getContext().registerReceiver(connectedState = new VerifyConnectedState(scanResult), filter);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    void unRegister() {
        if (register) {
            register = false;
            connectedState.start = false;
            try {
                BaseApplication.getContext().unregisterReceiver(connectedState);
            } catch (Exception e) {
                e.printStackTrace();
            }
            mHandler.removeCallbacksAndMessages(null);
        }
    }


    public WifiConnector(Context context, ScanResult scanResult) {
        this.mContext = context;
        this.mScanResult = scanResult;
        mWifiManager = (WifiManager) context.getSystemService(Context.WIFI_SERVICE);
        mScanResultSecurity = Wifi.ConfigSec.getScanResultSecurity(scanResult);
        mIsOpenNetwork = Wifi.ConfigSec.isOpenNetwork(mScanResultSecurity);
        mNumOpenNetworksKept = Settings.Secure.getInt(context.getContentResolver(),
                Settings.Secure.WIFI_NUM_OPEN_NETWORKS_KEPT, 10);
        register(scanResult);
    }

    /**
     * 连接新wifi
     */
    public boolean connectNewWifi(String pwd, IConnectedCallback connectedCallback) {
        //连接新wifi时，将已连接的wifi对优先级设置降级
        mWifiManager.disconnect();
        connectedState.setConnectType(VerifyConnectedState.TYPE_CONNECT_NEW_WIFI);
        WifiConnector.this.mConnectedCallback = connectedCallback;
        WifiConnector.this.pwd = pwd;
        WifiConfiguration wifiConfigs = createWifiConfigs(mScanResult.SSID,mScanResult.BSSID, pwd, getCapabilities(mScanResult.capabilities));
        if (wifiConfigs != null) {
            int netWorkId = mWifiManager.addNetwork(wifiConfigs);//真正添加WIFI连接的方法
            if (netWorkId == -1 || !mWifiManager.enableNetwork(netWorkId, true) || !mWifiManager.reconnect()) {
                mConnectedCallback.invalidConnect(pwd, mScanResult);
                return false;
            }
        } else {
            mConnectedCallback.invalidConnect(pwd, mScanResult);
            return false;
        }
        saveOrReplaceLocalWiFi(pwd);
        connectedState.setStart(true);
        return true;
    }

    /**
     * 连接已经连接过的wifi（仅限app创建的wifi连接）
     */
    public void connect(IConnectedCallback connectedCallback) {
        mWifiManager.disconnect();
        connectedState.setConnectType(VerifyConnectedState.TYPE_CONNECT_OLD_WIFI);
        WifiConnector.this.mConnectedCallback = connectedCallback;
        final WifiConfiguration config = Wifi.getWifiConfiguration(mWifiManager, mScanResult, mScanResultSecurity);
        if (config != null) {
            Wifi.connectToConfiguredNetwork(mContext, mWifiManager, config, false);
        } else {
            connectedCallback.invalidConnect(getPwd(), mScanResult);
            return;
        }
        connectedState.setStart(true);
    }

    /**
     * 移除wifi
     */
    private boolean forget() {
        final WifiConfiguration config = Wifi.getWifiConfiguration(mWifiManager, mScanResult, mScanResultSecurity);
        boolean result = false;
        if (config != null) {
            result = mWifiManager.removeNetwork(config.networkId)
                    && mWifiManager.saveConfiguration();
        }


        if (!result) {
            toast(R.string.option_failed);
        }

        return result;
    }


    /**
     * 更新wifi密码（仅限app创建的wifi连接）
     *
     * @param newPwd
     */
    public void changePwd(String newPwd, IConnectedCallback callback) {
        connectedState.setConnectType(VerifyConnectedState.TYPE_CONNECT_MODIFY_PASSWORD_WIFI);
        WifiConnector.this.mConnectedCallback = callback;
        final WifiConfiguration config = Wifi.getWifiConfiguration(mWifiManager, mScanResult, mScanResultSecurity);
        if (config != null) {
            Wifi.changePasswordAndConnect(mContext, mWifiManager, config, newPwd, mNumOpenNetworksKept);
        } else {
            //本地配置为空的话，重新创建配置并连接wifi
            connectNewWifi(newPwd, callback);
        }
        saveOrReplaceLocalWiFi(newPwd);
        connectedState.setStart(true);
    }

    void saveOrReplaceLocalWiFi(String pwd) {
        WiFiAccountPasswordBean bean = new WiFiAccountPasswordBean(mScanResult.SSID, mScanResult.BSSID, pwd, WifiUtil.getEncrypt(mScanResult));
        WiFiRecordRepositories.getInstance().saveWiFi(bean);
    }

    void toast(@StringRes int strId) {
        Toast.makeText(BaseApplication.getContext(), strId, Toast.LENGTH_LONG).show();
    }

    public void clear() {
        unRegister();
        mConnectedCallback = null;
    }

    public String getPwd() {
        return pwd;
    }

    public int isConfiguration(String SSID) {
        @SuppressLint("MissingPermission") List<WifiConfiguration> wifiConfigList = mWifiManager.getConfiguredNetworks();
        for (int i = 0; i < wifiConfigList.size(); i++) {
            String wifiConfigString = wifiConfigList.get(i).SSID;
            wifiConfigString = wifiConfigString.substring(1, wifiConfigString.length() - 1);
            if (wifiConfigString.equals(SSID)) {
                return wifiConfigList.get(i).networkId;
            }
        }
        return -1;
    }

    private int getCapabilities(String capabilities) {
        if (capabilities.contains("WPA") || capabilities.contains("wpa")) {
            return 2;
        } else if (capabilities.contains("WEP") || capabilities.contains("wep")) {
            return 1;
        }
        return 0;
    }

    public WifiConfiguration createWifiConfigs(String ssid,String bssid ,String password, int type) {
        WifiConfiguration config = new WifiConfiguration();
        config.allowedAuthAlgorithms.clear();
        config.allowedGroupCiphers.clear();
        config.allowedKeyManagement.clear();
        config.allowedPairwiseCiphers.clear();
        config.allowedProtocols.clear();
        config.SSID = "\"" + ssid + "\"";
        config.BSSID=bssid;

        WifiConfiguration tempConfig = isExist(ssid);
        if (tempConfig != null) {
            mWifiManager.removeNetwork(tempConfig.networkId);
        }

        if (type == 0) {
            config.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE);
        } else if (type == 1) {//wep
            config.hiddenSSID = true;
            config.wepKeys[0] = "\"" + password + "\"";
            config.allowedAuthAlgorithms.set(WifiConfiguration.AuthAlgorithm.OPEN);
            config.allowedAuthAlgorithms.set(WifiConfiguration.AuthAlgorithm.SHARED);
            config.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE);
            config.wepTxKeyIndex = 0;
        } else if (type == 2) {//WPA
            config.preSharedKey = "\"" + password + "\"";
            config.hiddenSSID = true;
            config.allowedAuthAlgorithms.set(WifiConfiguration.AuthAlgorithm.OPEN);
            config.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.TKIP);
            config.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.WPA_PSK);
            config.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.TKIP);
            config.allowedGroupCiphers.set(WifiConfiguration.GroupCipher.CCMP);
            config.allowedPairwiseCiphers.set(WifiConfiguration.PairwiseCipher.CCMP);
            config.status = WifiConfiguration.Status.ENABLED;
        }

        return config;
    }

    private WifiConfiguration isExist(String ssid) {
        @SuppressLint("MissingPermission") List<WifiConfiguration> configs = mWifiManager.getConfiguredNetworks();

        for (WifiConfiguration config : configs) {
            if (config.SSID.equals("\"" + ssid + "\"")) {
                return config;
            }
        }
        return null;
    }
}

