package com.midea.light.setting.relay;


import com.midea.light.RxBus;
import com.midea.light.issued.IIssuedMatch;

import org.json.JSONException;
import org.json.JSONObject;
/**
 * @author Janner
 * @ProjectName: SmartScreen
 * @Package: com.midea.light.gatewaylib.issued.voice
 * @ClassName: VoiceIssuedMatch
 * @CreateDate: 2022/7/14 10:49
 */
public class VoiceIssuedMatch implements IIssuedMatch<VoiceIssuedHandler> {

    public VoiceIssuedMatch() {
//        RxBus.getInstance().toObservableInSingle(ZigbeeScanEvent.class)
//            .subscribe(new Consumer<ZigbeeScanEvent>() {
//                @Override
//                public void accept(ZigbeeScanEvent zigbeeScanEvent) throws Throwable {
//                    VoiceIssuedHandler.allowCnt = 0;
//                    VoiceIssuedHandler.isStart = zigbeeScanEvent.isStart;
//                }
//            });
    }

    @Override
    public VoiceIssuedHandler onMather(String data) {
        JSONObject jsonObject = null;
        try {
            jsonObject = new JSONObject(data);
            if(jsonObject.has("audioBroadcast"))
                return new VoiceIssuedHandler();
        } catch (JSONException e) {
            e.printStackTrace();
        }
        return null;
    }
}
