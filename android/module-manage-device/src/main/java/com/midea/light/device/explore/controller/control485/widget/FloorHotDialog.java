package com.midea.light.device.explore.controller.control485.widget;

import android.app.Dialog;
import android.content.Context;
import android.graphics.Color;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.Switch;
import android.widget.TextView;

import com.midea.light.device.R;
import com.midea.light.device.explore.controller.control485.agreement.FloorHotAgr;
import com.midea.light.device.explore.controller.control485.controller.FloorHotController;
import com.midea.light.device.explore.controller.control485.deviceModel.FloorHotModel;

import java.util.ArrayList;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class FloorHotDialog extends Dialog {

    private Context context;
    private FloorHotModel device;
    private TextView currentModel, currentTemp, currentWindSpeed;
    private MyWheelView tempWhell, modelWhell, speedWhell;
    private LinearLayout llProtect;
    private Switch onOff,protectOnOff;
    private Button back;
    private ArrayList<String>temp=new ArrayList<>();

    public FloorHotDialog(@NonNull Context context, FloorHotModel device) {
        super(context);
        this.context = context;
        this.device = device;
    }

    public FloorHotDialog(@NonNull Context context, int themeResId) {
        super(context, themeResId);
    }

    protected FloorHotDialog(@NonNull Context context, boolean cancelable, @Nullable OnCancelListener cancelListener) {
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
        modelWhell.setVisibility(View.GONE);
        speedWhell.setVisibility(View.GONE);
        currentModel.setVisibility(View.GONE);
        currentWindSpeed.setVisibility(View.GONE);
        llProtect.setVisibility(View.VISIBLE);
        for (int i = 5; i <90 ; i++) {
            temp.add(i+"");
        }
        tempWhell.setItems(temp);
        tempWhell.setOnWheelViewListener(new MyWheelView.OnWheelViewListener() {
            public void onSelected(int selectedIndex, String item) {
                FloorHotController.getInstance().setTemp(device,String.format("%02x", Integer.parseInt(item)));
            }
        });


        if(device.getOnOff().equals(FloorHotAgr.FLOOR_HOT_OPEN.data)){
            onOff.setChecked(true);
        }else{
            onOff.setChecked(false);
        }
        if(device.getFrostProtection().equals(FloorHotAgr.FLOOR_HOT_FANG_DONG_OPEN.data)){
            protectOnOff.setChecked(true);
        }else{
            protectOnOff.setChecked(false);
        }
        onOff.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if(isChecked){
                FloorHotController.getInstance().open(device);
            }else{
                FloorHotController.getInstance().close(device);
            }
        });
        protectOnOff.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if(isChecked){
                FloorHotController.getInstance().setFrostProtectionOn(device);
            }else{
                FloorHotController.getInstance().setFrostProtectionOff(device);
            }
        });
        back.setOnClickListener(v -> dismiss());

        currentTemp.setText("当前温度:"+Integer.parseInt(device.getCurrTemperature(),16)+"℃");
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
        llProtect=contentView.findViewById(R.id.llProtect);
        protectOnOff=contentView.findViewById(R.id.protectOnOff);

    }


}
