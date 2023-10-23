package com.midea.light.device.explore.controller.control485.widget;

import android.app.Activity;
import android.app.Dialog;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.Switch;
import android.widget.TextView;

import com.midea.light.RxBus;
import com.midea.light.device.R;
import com.midea.light.device.explore.controller.control485.agreement.AirConditionAgr;
import com.midea.light.device.explore.controller.control485.controller.AirConditionController;
import com.midea.light.device.explore.controller.control485.deviceModel.AirConditionModel;
import com.midea.light.device.explore.controller.control485.event.AirConditionChangeEvent;

import java.util.ArrayList;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import io.reactivex.rxjava3.disposables.Disposable;

public class AirConditionDialog extends Dialog {

    private Activity context;
    private AirConditionModel device;
    private TextView currentModel, currentTemp, currentWindSpeed;
    private MyWheelView tempWhell, modelWhell, speedWhell;
    private Switch onOff;
    private Button back;
    private ArrayList<String>temp=new ArrayList<>();
    private ArrayList<String>model=new ArrayList<>();
    private ArrayList<String>speed=new ArrayList<>();
    private Disposable mDisposable;

    public AirConditionDialog(@NonNull Activity context, AirConditionModel device) {
        super(context);
        this.context = context;
        this.device = device;
    }

    public AirConditionDialog(@NonNull Context context, int themeResId) {
        super(context, themeResId);
    }

    protected AirConditionDialog(@NonNull Context context, boolean cancelable, @Nullable OnCancelListener cancelListener) {
        super(context, cancelable, cancelListener);
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        View contentView = LayoutInflater.from(context).inflate(R.layout.dialog_485_air_control, null, false);
        setContentView(contentView);
        //按空白处不能取消动画
        setCanceledOnTouchOutside(true);
        //设置window背景，默认的背景会有Padding值，不能全屏。当然不一定要是透明，你可以设置其他背景，替换默认的背景即可。
        getWindow().setBackgroundDrawable(new ColorDrawable(Color.TRANSPARENT));
        //一定要在setContentView之后调用，否则无效
        getWindow().setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);
        initView(contentView);
        initDate();
    }

    private void initDate() {
        for (int i = 16; i <30 ; i++) {
            temp.add(i+"");
        }
        tempWhell.setItems(temp);
        tempWhell.setOnWheelViewListener(new MyWheelView.OnWheelViewListener() {
            public void onSelected(int selectedIndex, String item) {
                AirConditionController.getInstance().setTemp(device,String.format("%02x", Integer.parseInt(item)));
            }
        });

        model.add(AirConditionAgr.COLD_MODEL.signal());
        model.add(AirConditionAgr.WET_MODEL.signal());
        model.add(AirConditionAgr.REFRESHING_MODEL.signal());
        model.add(AirConditionAgr.WIND_MODEL.signal());
        model.add(AirConditionAgr.AUTO_WET_MODEL.signal());
        model.add(AirConditionAgr.SLEEP_MODEL.signal());
        model.add(AirConditionAgr.HOT_MODEL.signal());
        model.add(AirConditionAgr.FLOOR_HOT_MODEL.signal());
        model.add(AirConditionAgr.STRONG_HOT_MODEL.signal());

        modelWhell.setItems(model);
        modelWhell.setOnWheelViewListener(new MyWheelView.OnWheelViewListener() {
            public void onSelected(int selectedIndex, String item) {
                for (int i = 0; i <model.size() ; i++) {
                    if(item.equals(model.get(i))){
                        if(item.equals(AirConditionAgr.COLD_MODEL.signal())){
                            AirConditionController.getInstance().setModel(device,AirConditionAgr.COLD_MODEL.data);
                        }else if(item.equals(AirConditionAgr.WET_MODEL.signal())){
                            AirConditionController.getInstance().setModel(device,AirConditionAgr.WET_MODEL.data);
                        }else if(item.equals(AirConditionAgr.REFRESHING_MODEL.signal())){
                            AirConditionController.getInstance().setModel(device,AirConditionAgr.REFRESHING_MODEL.data);
                        }else if(item.equals(AirConditionAgr.AUTO_WET_MODEL.signal())){
                            AirConditionController.getInstance().setModel(device,AirConditionAgr.AUTO_WET_MODEL.data);
                        }else if(item.equals(AirConditionAgr.SLEEP_MODEL.signal())){
                            AirConditionController.getInstance().setModel(device,AirConditionAgr.SLEEP_MODEL.data);
                        }else if(item.equals(AirConditionAgr.HOT_MODEL.signal())){
                            AirConditionController.getInstance().setModel(device,AirConditionAgr.HOT_MODEL.data);
                        }else if(item.equals(AirConditionAgr.FLOOR_HOT_MODEL.signal())){
                            AirConditionController.getInstance().setModel(device,AirConditionAgr.FLOOR_HOT_MODEL.data);
                        }else if(item.equals(AirConditionAgr.STRONG_HOT_MODEL.signal())){
                            AirConditionController.getInstance().setModel(device,AirConditionAgr.STRONG_HOT_MODEL.data);
                        }else if(item.equals(AirConditionAgr.WIND_MODEL.signal())){
                            AirConditionController.getInstance().setModel(device,AirConditionAgr.WIND_MODEL.data);
                        }
                    }
                }

            }
        });

        speed.add(AirConditionAgr.WIND_AUTO.signal());
        speed.add(AirConditionAgr.WIND_HIGHT.signal());
        speed.add(AirConditionAgr.WIND_MIDDLE.signal());
        speed.add(AirConditionAgr.WIND_MIDDLE_HIGHT.signal());
        speed.add(AirConditionAgr.WIND_LOW.signal());
        speed.add(AirConditionAgr.WIND_MIDDLE_LOW.signal());
        speed.add(AirConditionAgr.WIND_SMALL.signal());

        speedWhell.setItems(speed);
        speedWhell.setOnWheelViewListener(new MyWheelView.OnWheelViewListener() {
            public void onSelected(int selectedIndex, String item) {
                for (int i = 0; i <speed.size() ; i++) {
                    if(item.equals(speed.get(i))){
                        if(item.equals(AirConditionAgr.WIND_AUTO.signal())){
                            AirConditionController.getInstance().setWindSpeedLevl(device,AirConditionAgr.WIND_AUTO.data);
                        }else if(item.equals(AirConditionAgr.WIND_HIGHT.signal())){
                            AirConditionController.getInstance().setWindSpeedLevl(device,AirConditionAgr.WIND_HIGHT.data);
                        }else if(item.equals(AirConditionAgr.WIND_MIDDLE.signal())){
                            AirConditionController.getInstance().setWindSpeedLevl(device,AirConditionAgr.WIND_MIDDLE.data);
                        }else if(item.equals(AirConditionAgr.WIND_MIDDLE_HIGHT.signal())){
                            AirConditionController.getInstance().setWindSpeedLevl(device,AirConditionAgr.WIND_MIDDLE_HIGHT.data);
                        }else if(item.equals(AirConditionAgr.WIND_LOW.signal())){
                            AirConditionController.getInstance().setWindSpeedLevl(device,AirConditionAgr.WIND_LOW.data);
                        }else if(item.equals(AirConditionAgr.WIND_MIDDLE_LOW.signal())){
                            AirConditionController.getInstance().setWindSpeedLevl(device,AirConditionAgr.WIND_MIDDLE_LOW.data);
                        }else if(item.equals(AirConditionAgr.WIND_SMALL.signal())){
                            AirConditionController.getInstance().setWindSpeedLevl(device,AirConditionAgr.WIND_SMALL.data);
                        }
                    }
                }
            }
        });
        if(device.getOnOff().equals(AirConditionAgr.OPEN.data)){
            onOff.setChecked(true);
        }else{
            onOff.setChecked(false);
        }
        onOff.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if(isChecked){
                AirConditionController.getInstance().open(device);
            }else{
                AirConditionController.getInstance().close(device);
            }
        });
        back.setOnClickListener(v -> dismiss());

        AirConditionAgr type=AirConditionAgr.parseWorkModel(device.getWorkModel());
        currentModel.setText("工作模式:"+type.signal());

        AirConditionAgr speed=AirConditionAgr.parseWindSpeed(device.getWindSpeed());
        currentWindSpeed.setText("风速:"+speed.signal());

        currentTemp.setText("当前温度:"+Integer.parseInt(device.getCurrTemperature(),16)+"℃");

        mDisposable= RxBus.getInstance().toObservableInSingle(AirConditionChangeEvent.class)
                .subscribe(AirConditionChangeEvent -> {
                    String address= AirConditionChangeEvent.getAirConditionModel().getOutSideAddress()+AirConditionChangeEvent.getAirConditionModel().getInSideAddress();
                    String adddevice=device.getOutSideAddress()+device.getInSideAddress();
                    if(address.equals(adddevice)){
                        AirConditionAgr modeltype=AirConditionAgr.parseWorkModel(AirConditionChangeEvent.getAirConditionModel().getWorkModel());
                        AirConditionAgr windspeed=AirConditionAgr.parseWindSpeed(AirConditionChangeEvent.getAirConditionModel().getWindSpeed());
                        context.runOnUiThread(() -> {
                            currentModel.setText("工作模式:"+modeltype.signal());
                            currentWindSpeed.setText("风速:"+windspeed.signal());
                            currentTemp.setText("当前温度:"+Integer.parseInt(AirConditionChangeEvent.getAirConditionModel().getCurrTemperature(),16)+"℃");
                        });
                    }
                },throwable -> Log.e("sky","rxbus错误" ,throwable));
    }

    private void initView(View contentView) {
        currentModel = contentView.findViewById(R.id.currentModel);
        currentTemp = contentView.findViewById(R.id.currentTemp);
        currentWindSpeed = contentView.findViewById(R.id.currentWindSpeed);
        tempWhell = contentView.findViewById(R.id.tempWhell);
        modelWhell = contentView.findViewById(R.id.modelWhell);
        speedWhell = contentView.findViewById(R.id.speedWhell);
        back= contentView.findViewById(R.id.back);
        onOff=contentView.findViewById(R.id.onOff);
    }

    @Override
    public void dismiss() {
        super.dismiss();
        if(mDisposable!=null&&mDisposable.isDisposed()){
            mDisposable.dispose();
        }
    }
}
