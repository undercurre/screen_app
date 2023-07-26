package com.midea.test.widget;

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
import android.widget.Switch;
import android.widget.TextView;

import com.midea.light.device.explore.controller.control485.agreement.FreshAirAgr;
import com.midea.light.device.explore.controller.control485.controller.FreshAirController;
import com.midea.light.device.explore.controller.control485.deviceModel.FreshAirModel;
import com.midea.test.R;

import java.util.ArrayList;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

public class FreshAirDialog extends Dialog {

    private Context context;
    private FreshAirModel device;
    private TextView currentModel, currentTemp, currentWindSpeed;
    private MyWheelView tempWhell, modelWhell, speedWhell;
    private Switch onOff;
    private Button back;
    private ArrayList<String>model=new ArrayList<>();
    private ArrayList<String>speed=new ArrayList<>();

    public FreshAirDialog(@NonNull Context context, FreshAirModel device) {
        super(context);
        this.context = context;
        this.device = device;
    }

    public FreshAirDialog(@NonNull Context context, int themeResId) {
        super(context, themeResId);
    }

    protected FreshAirDialog(@NonNull Context context, boolean cancelable, @Nullable OnCancelListener cancelListener) {
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
        tempWhell.setVisibility(View.GONE);
        currentTemp.setVisibility(View.GONE);
        model.add(FreshAirAgr.FRESH_AIR_ZI_DONG_MODEL.signal());
        model.add(FreshAirAgr.FRESH_AIR_HUAN_QI_MODEL.signal());
        model.add(FreshAirAgr.FRESH_AIR_PAI_FENG_MODEL.signal());
        model.add(FreshAirAgr.FRESH_AIR_ZHI_NENG_MODEL.signal());
        model.add(FreshAirAgr.FRESH_AIR_QIANG_JING_MODEL.signal());
        model.add(FreshAirAgr.FRESH_AIR_SHENG_DIAN_MODEL.signal());
        model.add(FreshAirAgr.FRESH_AIR_SONG_FENG_MODEL.signal());
        model.add(FreshAirAgr.FRESH_AIR_PANG_TONG_MODEL.signal());
        model.add(FreshAirAgr.FRESH_AIR_SU_JING_MODEL.signal());
        model.add(FreshAirAgr.FRESH_AIR_SHU_SHI_MODEL.signal());
        model.add(FreshAirAgr.FRESH_AIR_LIANG_FENG_MODEL.signal());
        model.add(FreshAirAgr.FRESH_AIR_SHOU_DONG_MODEL.signal());
        model.add(FreshAirAgr.FRESH_AIR_JING_YIN_MODEL.signal());
        model.add(FreshAirAgr.FRESH_AIR_XIN_FENG_MODEL.signal());
        model.add(FreshAirAgr.FRESH_AIR_ZHI_LENG_MODEL.signal());
        model.add(FreshAirAgr.FRESH_AIR_ZHI_RE_MODEL.signal());
        model.add(FreshAirAgr.FRESH_AIR_RE_JIAO_HUAN_MODEL.signal());
        model.add(FreshAirAgr.FRESH_AIR_NEI_XUN_HUAN_MODEL.signal());
        model.add(FreshAirAgr.FRESH_AIR_WAI_XUN_HUAN_MODEL.signal());
        model.add(FreshAirAgr.FRESH_AIR_HUN_FENG_MODEL.signal());
        model.add(FreshAirAgr.FRESH_AIR_GUAN_BI_MODEL.signal());
        model.add(FreshAirAgr.FRESH_AIR_XIN_FENG_CHU_SHI_MODEL.signal());
        model.add(FreshAirAgr.FRESH_AIR_DING_SHI_MODEL.signal());
        model.add(FreshAirAgr.FRESH_AIR_STRONG_HOT_MODEL.signal());
        model.add(FreshAirAgr.FRESH_AIR_CHU_SHUANG_MODEL.signal());
        model.add(FreshAirAgr.FRESH_AIR_NEI_CHU_SHI_MODEL.signal());


        modelWhell.setItems(model);
        modelWhell.setOnWheelViewListener(new MyWheelView.OnWheelViewListener() {
            public void onSelected(int selectedIndex, String item) {
                for (int i = 0; i <model.size() ; i++) {
                    if(item.equals(model.get(i))){
                        if(item.equals(FreshAirAgr.FRESH_AIR_ZI_DONG_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_ZI_DONG_MODEL.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_HUAN_QI_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_HUAN_QI_MODEL.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_PAI_FENG_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_PAI_FENG_MODEL.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_ZHI_NENG_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_ZHI_NENG_MODEL.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_QIANG_JING_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_QIANG_JING_MODEL.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_SHENG_DIAN_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_SHENG_DIAN_MODEL.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_SONG_FENG_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_SONG_FENG_MODEL.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_PANG_TONG_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_PANG_TONG_MODEL.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_SU_JING_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_SU_JING_MODEL.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_SHU_SHI_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_SHU_SHI_MODEL.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_LIANG_FENG_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_LIANG_FENG_MODEL.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_SHOU_DONG_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_SHOU_DONG_MODEL.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_JING_YIN_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_JING_YIN_MODEL.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_XIN_FENG_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_XIN_FENG_MODEL.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_ZHI_LENG_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_ZHI_LENG_MODEL.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_ZHI_RE_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_ZHI_RE_MODEL.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_RE_JIAO_HUAN_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_RE_JIAO_HUAN_MODEL.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_NEI_XUN_HUAN_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_NEI_XUN_HUAN_MODEL.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_WAI_XUN_HUAN_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_WAI_XUN_HUAN_MODEL.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_HUN_FENG_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_HUN_FENG_MODEL.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_GUAN_BI_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_GUAN_BI_MODEL.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_XIN_FENG_CHU_SHI_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_XIN_FENG_CHU_SHI_MODEL.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_DING_SHI_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_DING_SHI_MODEL.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_STRONG_HOT_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_STRONG_HOT_MODEL.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_CHU_SHUANG_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_CHU_SHUANG_MODEL.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_NEI_CHU_SHI_MODEL.signal())){
                            FreshAirController.getInstance().setModel(device,FreshAirAgr.FRESH_AIR_NEI_CHU_SHI_MODEL.data);
                        }
                    }
                }

            }
        });


        speed.add(FreshAirAgr.FRESH_AIR_WIND_AUTO.signal());
        speed.add(FreshAirAgr.FRESH_AIR_WIND_HIGHT.signal());
        speed.add(FreshAirAgr.FRESH_AIR_WIND_MIDDLE.signal());
        speed.add(FreshAirAgr.FRESH_AIR_WIND_MIDDLE_HIGHT.signal());
        speed.add(FreshAirAgr.FRESH_AIR_WIND_LOW.signal());
        speed.add(FreshAirAgr.FRESH_AIR_WIND_MIDDLE_LOW.signal());
        speed.add(FreshAirAgr.FRESH_AIR_WIND_SMALL.signal());

        speedWhell.setItems(speed);
        speedWhell.setOnWheelViewListener(new MyWheelView.OnWheelViewListener() {
            public void onSelected(int selectedIndex, String item) {
                for (int i = 0; i <speed.size() ; i++) {
                    if(item.equals(speed.get(i))){
                        if(item.equals(FreshAirAgr.FRESH_AIR_WIND_AUTO.signal())){
                            FreshAirController.getInstance().setWindSpeedLevl(device,FreshAirAgr.FRESH_AIR_WIND_AUTO.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_WIND_HIGHT.signal())){
                            FreshAirController.getInstance().setWindSpeedLevl(device,FreshAirAgr.FRESH_AIR_WIND_HIGHT.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_WIND_MIDDLE.signal())){
                            FreshAirController.getInstance().setWindSpeedLevl(device,FreshAirAgr.FRESH_AIR_WIND_MIDDLE.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_WIND_MIDDLE_HIGHT.signal())){
                            FreshAirController.getInstance().setWindSpeedLevl(device,FreshAirAgr.FRESH_AIR_WIND_MIDDLE_HIGHT.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_WIND_LOW.signal())){
                            FreshAirController.getInstance().setWindSpeedLevl(device,FreshAirAgr.FRESH_AIR_WIND_LOW.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_WIND_MIDDLE_LOW.signal())){
                            FreshAirController.getInstance().setWindSpeedLevl(device,FreshAirAgr.FRESH_AIR_WIND_MIDDLE_LOW.data);
                        }else if(item.equals(FreshAirAgr.FRESH_AIR_WIND_SMALL.signal())){
                            FreshAirController.getInstance().setWindSpeedLevl(device,FreshAirAgr.FRESH_AIR_WIND_SMALL.data);
                        }
                    }
                }
            }
        });
        if(device.getOnOff().equals(FreshAirAgr.FRESH_AIR_OPEN.data)){
            onOff.setChecked(true);
        }else{
            onOff.setChecked(false);
        }
        onOff.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if(isChecked){
                FreshAirController.getInstance().open(device);
            }else{
                FreshAirController.getInstance().close(device);
            }
        });
        back.setOnClickListener(v -> dismiss());

        FreshAirAgr type=FreshAirAgr.parseWorkModel(device.getWorkModel());
        currentModel.setText("工作模式:"+type.signal());

        FreshAirAgr speed=FreshAirAgr.parseWindSpeed(device.getWindSpeed());
        currentWindSpeed.setText("风速:"+speed.signal());

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


}
