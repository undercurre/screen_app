package com.midea.light.setting.relay;

import com.google.gson.JsonObject;
import com.midea.light.config.IRelayControl;
import com.midea.light.gateway.GateWayUtils;
import com.midea.light.setting.SystemUtil;

import io.reactivex.rxjava3.schedulers.Schedulers;

/**
 * @ClassName RelayControl
 * @Description 四寸继电器控制
 * @Author weinp1
 * @Date 2022/4/15 10:41
 * @Version 1.0
 */
public class RelayControl implements IRelayControl {
    // #全部上报（同时上报开关1，开关2）
    private final int REPORT_ALL = 1;
    // #只上报开关 1
    private final int REPORT_1 = 2;
    // #只上报开关 2
    private final int REPORT_2 = 3;

    @Override
    public void controlRelay1Open(boolean open) {
        //只有继电器模式为0时才去控制继电器
        if( RelayRepository.getInstance().getGP0Model()==0){
            SystemUtil.CommandGP(0, open);
        }
        RelayRepository.getInstance().setGP0State(open);
        reportRelayStateChange(REPORT_1);
    }

    @Override
    public void controlRelay2Open(boolean open) {
        //只有继电器模式为0时才去控制继电器
        if(RelayRepository.getInstance().getGP1Model()==0){
            SystemUtil.CommandGP(1, open);
        }
        RelayRepository.getInstance().setGP1State(open);
        reportRelayStateChange(REPORT_2);
    }

    @Override
    public boolean isRelay1Open() {
        if(RelayRepository.getInstance().getGP0Model()==0){
            return SystemUtil.readGP(0);
        }else{
            return RelayRepository.getInstance().getGP0State();
        }
    }

    @Override
    public boolean isRelay2Open() {
        if(RelayRepository.getInstance().getGP1Model()==0){
            return SystemUtil.readGP(1);
        }else{
            return RelayRepository.getInstance().getGP1State();
        }
    }

    public void reportRelayStateChange(int state) {
        Schedulers.io().scheduleDirect(() -> {
            // {"switch":{"ep1":1,"ep2":1}}
            JsonObject jsonObject = new JsonObject();
            JsonObject _switch = new JsonObject();
            jsonObject.add("switch", _switch);
            if(REPORT_1 == state) {
                _switch.addProperty("ep1", isRelay1Open() ? 1 : 0);
            } else if(REPORT_2 == state) {
                _switch.addProperty("ep2", isRelay2Open() ? 1 : 0);
            } else {
                _switch.addProperty("ep1", isRelay1Open() ? 1 : 0);
                _switch.addProperty("ep2", isRelay2Open() ? 1 : 0);
            }
            GateWayUtils.send(jsonObject.toString());
        });
    }

    @Override
    public void reportRelayStateChange() {
        reportRelayStateChange(REPORT_ALL);
    }

}