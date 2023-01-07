package com.midea.light.device.explore.api.entity.adapter;

import com.google.gson.TypeAdapter;
import com.google.gson.stream.JsonToken;
import com.google.gson.stream.JsonWriter;
import com.midea.iot.sdk.common.security.SecurityUtils;
import com.midea.light.device.explore.Portal;
import com.midea.light.device.explore.api.entity.ApplianceBean;

import java.io.IOException;

/**
 * @ClassName ApplianceBeanAdapter
 * @Description ApplianceBean的序列化和反序列器
 * @Author weinp1
 * @Date 2021/11/30 18:17
 * @Version 1.0
 */
public class ApplianceBeanAdapter extends TypeAdapter<ApplianceBean> {

    @Override
    public void write(JsonWriter out, ApplianceBean value) throws IOException {
        out.beginObject();
        out.name("applianceCode").value(value.getApplianceCode());
        out.name("onlineStatus").value(value.getOnlineStatus());
        out.name("type").value(value.getType());
        out.name("modelNumber").value(value.getModelNumber());
        out.name("name").value(value.getName());
        out.name("des").value(value.getDes());
        out.name("activeStatus").value(value.getActiveStatus());
        out.name("homegroupId").value(value.getHomegroupId());
        out.name("roomId").value(value.getRoomId());
        out.name("rawSn").value(value.getRawSn());
        out.endObject();
    }

    @Override
    public ApplianceBean read(com.google.gson.stream.JsonReader reader) throws IOException {
        JsonReader in = new JsonReader(reader);
        ApplianceBean applianceBean = new ApplianceBean();
        in.beginObject();
        while (in.hasNext()) {
            switch (in.nextName()) {
                case "applianceCode":
                    applianceBean.setApplianceCode(in.nextString());
                    break;
                case "sn":
                    applianceBean.setRawSn(SecurityUtils.decodeAES128(in.nextString(), Portal.getBaseConfig().getSeed()));
                    break;
                case "onlineStatus":
                    applianceBean.setOnlineStatus(in.nextString());
                    break;
                case "type":
                    applianceBean.setType(in.nextString());
                    break;
                case "modelNumber":
                    applianceBean.setModelNumber(in.nextString());
                    break;
                case "name":
                    applianceBean.setName(in.nextString());
                    break;
                case "des":
                    applianceBean.setDes(in.nextString());
                    break;
                case "activeStatus":
                    applianceBean.setActiveStatus(in.nextString());
                    break;
                case "homegroupId":
                    applianceBean.setHomegroupId(in.nextString());
                    break;
                case "roomId":
                    applianceBean.setRoomId(in.nextString());
                    break;
                case "rawSn":
                    applianceBean.setRawSn(in.nextString());
                    break;
                default:
                    in.skipValue();
                    break;
            }
        }
        in.endObject();
        return applianceBean;
    }

    class JsonReader {

        private final com.google.gson.stream.JsonReader reader;

        /**
         * Creates a new instance that reads a JSON-encoded stream from {@code in}.
         *
         * @param in
         */
        public JsonReader(com.google.gson.stream.JsonReader in) {
            this.reader = in;
        }

        public String nextString() throws IOException {
            if (reader.peek() == JsonToken.NULL) {
                reader.skipValue();
                return null;
            } else {
                return reader.nextString();
            }
        }

        public int nextInt() throws IOException {
            return reader.nextInt();
        }

        public void beginObject() throws IOException {
            reader.beginObject();
        }

        public void endObject() throws IOException {
            reader.endObject();
        }

        public boolean hasNext() throws IOException {
            return reader.hasNext();
        }

        public String nextName() throws IOException {
            return reader.nextName();
        }

        public void skipValue() throws IOException {
            reader.skipValue();
        }

    }
}
