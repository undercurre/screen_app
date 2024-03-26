package com.midea.test;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.widget.Button;
import android.widget.GridView;

import com.google.gson.Gson;
import com.midea.light.RxBus;
import com.midea.light.device.explore.controller.control485.ControlManager;
import com.midea.light.device.explore.controller.control485.controller.AirConditionController;
import com.midea.light.device.explore.controller.control485.controller.FloorHotController;
import com.midea.light.device.explore.controller.control485.controller.FreshAirController;
import com.midea.light.device.explore.controller.control485.controller.GetWayController;
import com.midea.light.device.explore.controller.control485.event.AirConditionChangeEvent;
import com.midea.light.device.explore.controller.control485.event.FloorHotChangeEvent;
import com.midea.light.device.explore.controller.control485.event.FreshAirChangeEvent;
import com.midea.test.adapter.DeviceAdapter;
import com.midea.test.widget.AirConditionDialog;
import com.midea.test.widget.FloorHotDialog;
import com.midea.test.widget.FreshAirDialog;

import java.util.ArrayList;

import io.reactivex.rxjava3.schedulers.Schedulers;

public class StartServiceActivity extends Activity {

    private Button send, fresh, sendFreshAir, freshFreshAir, sendFloor, freshFloor;
    private GridView GridDevice, GridDeviceFreshAir, GridDeviceFloor;


    @SuppressLint("CheckResult")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.start_service_layout);
        ControlManager.getInstance().registeOber();
        ControlManager.getInstance().startFresh();

        ArrayList mData = new ArrayList<>();
        ArrayList mDataFreshAir = new ArrayList<>();
        ArrayList mDataFloor = new ArrayList<>();

        send = findViewById(R.id.send);
        fresh = findViewById(R.id.fresh);
        sendFreshAir = findViewById(R.id.sendFreshAir);
        freshFreshAir = findViewById(R.id.freshFreshAir);
        sendFloor = findViewById(R.id.sendFloor);
        freshFloor = findViewById(R.id.freshFloor);
        GridDevice = findViewById(R.id.GridDevice);
        GridDeviceFreshAir = findViewById(R.id.GridDeviceFreshAir);
        GridDeviceFloor = findViewById(R.id.GridDeviceFloor);

        DeviceAdapter mAdapter = new DeviceAdapter(this, mData);
        DeviceAdapter mAdapterFreshAir = new DeviceAdapter(this, mDataFreshAir);
        DeviceAdapter mAdapterFloor = new DeviceAdapter(this, mDataFloor);

        send.setOnClickListener(v ->{
//            GetWayController.getInstance().findAllAirConditionOnlineState();
            Intent serviceIntent = new Intent("android.rockchip.update.service");
            serviceIntent.setPackage("android.rockchip.update.service");
            serviceIntent.putExtra("command", 1);
            serviceIntent.putExtra("delay", 0);
            startService(serviceIntent);
        });
        sendFreshAir.setOnClickListener(v -> GetWayController.getInstance().findAllFreshAirOnlineState());
        sendFloor.setOnClickListener(v -> GetWayController.getInstance().findAllFloorHotOnlineState());

        fresh.setOnClickListener(v -> {
            Log.e("sky","手动开启查找刷新");
//            ControlManager.getInstance().stopFresh();
//            new Thread(() -> {
//                Log.e("sky", "设备列表详情:" + new Gson().toJson(AirConditionController.getInstance().AirConditionList));
//                mData.clear();
//                for (int i = 0; i < AirConditionController.getInstance().AirConditionList.size(); i++) {
//                    mData.add("空调" + AirConditionController.getInstance().AirConditionList.get(i).getInSideAddress());
//                    runOnUiThread(() -> mAdapter.notifyDataSetChanged());
//                }
//                ControlManager.getInstance().startFresh();
//            }).start();
            ControlManager.getInstance().startFresh();
        });


        freshFreshAir.setOnClickListener(v -> {
            GetWayController.getInstance().getAllFreshAirParamete();

            Schedulers.computation().scheduleDirect(() -> {
                try {
                    Thread.sleep(2000);
                    Log.e("sky", "新风设备列表详情:" + new Gson().toJson(FreshAirController.getInstance().FreshAirList));
                    mDataFreshAir.clear();
                    for (int i = 0; i < FreshAirController.getInstance().FreshAirList.size(); i++) {
                        mDataFreshAir.add("新风" + FreshAirController.getInstance().FreshAirList.get(i).getInSideAddress());
                        runOnUiThread(() -> mAdapterFreshAir.notifyDataSetChanged());
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            });
        });

        freshFloor.setOnClickListener(v -> {
            GetWayController.getInstance().getAllFloorHotParamete();
            Schedulers.computation().scheduleDirect(() -> {
                try {
                    Thread.sleep(2000);
                    Log.e("sky", "地暖设备列表详情:" + new Gson().toJson(FloorHotController.getInstance().FloorHotList));
                    mDataFloor.clear();
                    for (int i = 0; i < FloorHotController.getInstance().FloorHotList.size(); i++) {
                        mDataFloor.add("地暖" + FloorHotController.getInstance().FloorHotList.get(i).getInSideAddress());
                        runOnUiThread(() -> mAdapterFloor.notifyDataSetChanged());
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            });
        });

        GridDevice.setNumColumns(3);
        GridDevice.setAdapter(mAdapter);
        GridDeviceFreshAir.setNumColumns(3);
        GridDeviceFreshAir.setAdapter(mAdapterFreshAir);
        GridDeviceFloor.setNumColumns(3);
        GridDeviceFloor.setAdapter(mAdapterFloor);
        GridDevice.setOnItemClickListener((parent, view, position, id) -> {
            AirConditionDialog dialog = new AirConditionDialog(StartServiceActivity.this, AirConditionController.getInstance().AirConditionList.get(position));
            dialog.create();
            dialog.show();
        });
        GridDeviceFreshAir.setOnItemClickListener((parent, view, position, id) -> {
            FreshAirDialog dialog = new FreshAirDialog(StartServiceActivity.this, FreshAirController.getInstance().FreshAirList.get(position));
            dialog.create();
            dialog.show();
        });
        GridDeviceFloor.setOnItemClickListener((parent, view, position, id) -> {
            FloorHotDialog dialog = new FloorHotDialog(StartServiceActivity.this, FloorHotController.getInstance().FloorHotList.get(position));
            dialog.create();
            dialog.show();
        });

        RxBus.getInstance().toObservableInSingle(AirConditionChangeEvent.class)
                .subscribe(AirConditionChangeEvent -> {
                    Log.e("sky", "空调设备列表详情:" + new Gson().toJson(AirConditionController.getInstance().AirConditionList));
                    mData.clear();
                    for (int i = 0; i < AirConditionController.getInstance().AirConditionList.size(); i++) {
                        mData.add("空调" + AirConditionController.getInstance().AirConditionList.get(i).getInSideAddress());
                        runOnUiThread(() -> mAdapter.notifyDataSetChanged());
                    }
                },throwable -> Log.e("sky","rxbus错误" ,throwable));

        RxBus.getInstance().toObservableInSingle(FreshAirChangeEvent.class)
                .subscribe(FreshAirChangeEvent -> {
                    Log.e("sky", "新风设备列表详情:" + new Gson().toJson(FreshAirController.getInstance().FreshAirList));
                    mDataFreshAir.clear();
                    for (int i = 0; i < FreshAirController.getInstance().FreshAirList.size(); i++) {
                        mDataFreshAir.add("新风" + FreshAirController.getInstance().FreshAirList.get(i).getInSideAddress());
                    }
                    runOnUiThread(() -> mAdapterFreshAir.notifyDataSetChanged());
                },throwable -> Log.e("sky","rxbus错误" ,throwable));

        RxBus.getInstance().toObservableInSingle(FloorHotChangeEvent.class)
                .subscribe(FloorHotChangeEvent -> {
                    Log.e("sky", "地暖设备列表详情:" + new Gson().toJson(FloorHotController.getInstance().FloorHotList));
                    mDataFloor.clear();
                    for (int i = 0; i < FloorHotController.getInstance().FloorHotList.size(); i++) {
                        mDataFloor.add("地暖" + FloorHotController.getInstance().FloorHotList.get(i).getInSideAddress());
                    }
                    runOnUiThread(() -> mAdapterFloor.notifyDataSetChanged());
                },throwable -> Log.e("sky","rxbus错误" ,throwable));

    }




}
