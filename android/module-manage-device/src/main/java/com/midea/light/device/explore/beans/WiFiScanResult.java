package com.midea.light.device.explore.beans;

import android.os.Parcel;

import java.util.Objects;

/**
 * @ClassName ScanResult
 * @Description
 * @Author weinp1
 * @Date 2021/7/20 11:34
 * @Version 1.0
 */
public class WiFiScanResult extends BaseScanResult {
    public android.net.wifi.ScanResult scanResult;

    public WiFiScanResult() {
        super(TYPE.wifi.ordinal(),null,null);
    }

    public android.net.wifi.ScanResult getScanResult() {
        return scanResult;
    }

    public WiFiScanResult(android.net.wifi.ScanResult scanResult, String icon, String name) {
        super(TYPE.wifi.ordinal(), icon, name);
        this.scanResult = scanResult;
    }

    protected WiFiScanResult(Parcel in) {
        super(in);
        scanResult = in.readParcelable(android.net.wifi.ScanResult.class.getClassLoader());
    }

    public void setScanResult(android.net.wifi.ScanResult scanResult) {
        this.scanResult = scanResult;
    }

    public String SSID() {
        return scanResult.SSID;
    }

    public String BSSID() {
        return scanResult.BSSID;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        WiFiScanResult that = (WiFiScanResult) o;
        return Objects.equals(SSID(), that.SSID()) &&
                Objects.equals(BSSID(), that.BSSID());
    }

    @Override
    public String toString() {
        return "ScanResult{" +
                "scanResult=" + scanResult +
                ", icon='" + icon + '\'' +
                ", name='" + name + '\'' +
                '}';
    }

    @Override
    public int hashCode() {
        return Objects.hash(scanResult, icon, name);
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        super.writeToParcel(dest,flags);
        dest.writeParcelable(scanResult, 0);
    }

    public static final Creator<WiFiScanResult> CREATOR =
            new Creator<WiFiScanResult>() {
                public WiFiScanResult createFromParcel(Parcel in) {
                    WiFiScanResult result = new WiFiScanResult(in);
                    return result;
                }

                public WiFiScanResult[] newArray(int size) {
                    return new WiFiScanResult[size];
                }
            };

}
