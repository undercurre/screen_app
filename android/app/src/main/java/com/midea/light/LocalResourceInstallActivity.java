package com.midea.light;

import android.app.Activity;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.util.Log;

import androidx.annotation.Nullable;

import com.midea.light.setting.ota.OTAUpgradeHelper;

import io.reactivex.rxjava3.schedulers.Schedulers;

public class LocalResourceInstallActivity extends Activity {

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_local_resource_install);
        if (!OTAUpgradeHelper.checkInstallResourceExistLocally()) {
            finish();
            return;
        }
        CountDownTimer timer1 = new CountDownTimer(30 * 1000, 1000) {
            @Override
            public void onTick(long millisUntilFinished) {
                Log.i("upgrade", "local install tick " + millisUntilFinished);
            }

            @Override
            public void onFinish() {
                Log.i("upgrade", "强制升级");
                if (OTAUpgradeHelper.checkInstallResourceExistLocally()) {
                    OTAUpgradeHelper.installResourceExitLocally();
                }
            }
        };
        timer1.start();

        CountDownTimer timer2 = new CountDownTimer(5 * 60 * 1000, 1000) {
            @Override
            public void onTick(long millisUntilFinished) {

            }

            @Override
            public void onFinish() {
                Log.i("upgrade", "倒计时超时");
                Schedulers.computation().scheduleDirect(() -> {
                    try {
                        if (OTAUpgradeHelper.checkInstallResourceExistLocally()) {
                            OTAUpgradeHelper.deleteInstallResource();
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                });
            }
        };
        timer2.start();


    }
}
