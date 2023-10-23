package com.midea.homlux.ai.observer;

import com.aispeech.dui.dds.DDS;
import com.aispeech.dui.dds.agent.MessageObserver;
import com.google.gson.Gson;
import com.midea.homlux.ai.bean.DianTaiBean;
import com.midea.homlux.ai.bean.GuShiBean;
import com.midea.homlux.ai.bean.MessageBean;
import com.midea.homlux.ai.bean.WeatherBean;
import com.midea.homlux.ai.bean.XiQuBean;
import com.midea.homlux.ai.bean.XiaoHuaBean;
import com.midea.homlux.ai.bean.XiaoShuoBean;
import com.midea.homlux.ai.music.MusicInfo;
import com.midea.homlux.ai.music.MusicManager;
import com.midea.homlux.ai.utils.LogUtil;
import com.midea.light.common.utils.GsonUtils;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.LinkedList;

/**
 * 客户端MessageObserver, 用于处理客户端动作的消息响应.
 */
public class DuiMessageObserver implements MessageObserver {
    private final String Tag = "DuiMessageObserver";

    public DuiMessageObserver() {
        mGson = new Gson();
    }

    public interface MessageCallback {
        void onMessage(MessageBean mMessageBean);

        void onState(String state);
    }

    private MessageCallback mMessageCallback;
    private LinkedList<MessageBean> mMessageList;
    private boolean mIsFirstVar = true;
    private boolean mHasvar = false;
    private Gson mGson;
    private String[] mSubscribeKeys = new String[]{
            "sys.dialog.state",
            "context.output.text",
            "context.input.text",
            "context.widget.content",
            "context.widget.list",
            "context.widget.web",
            "context.widget.media",
            "context.widget.custom",
            "sys.wakeup.result"
    };

    // 注册当前更新消息
    public void regist(MessageCallback messageCallback, LinkedList<MessageBean> msgList) {
        mMessageCallback = messageCallback;
        mMessageList = msgList;
        DDS.getInstance().getAgent().subscribe(mSubscribeKeys, this);
    }

    // 注销当前更新消息
    public void unregist() {
        DDS.getInstance().getAgent().unSubscribe(this);
    }

    private void clearVar() {
        if (mHasvar) {
            mMessageList.pollLast();
        }
    }

    @Override
    public void onMessage(String message, String data) {
        LogUtil.e("sky", "原始message : " + message + " data : " + data);
        MessageBean bean = null;
        switch (message) {
            case "context.output.text":
                clearVar();
                bean = new MessageBean();
                String txt = "";
                try {
                    JSONObject jo = new JSONObject(data);
                    txt = jo.optString("text", "");
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                bean.setText(txt);
                bean.setType(MessageBean.TYPE_OUTPUT);
                mMessageList.add(bean);
                if (mMessageCallback != null) {
                    mMessageCallback.onMessage(bean);
                }
                break;
            case "context.input.text":
                bean = new MessageBean();
                try {
                    JSONObject jo = new JSONObject(data);
                    if (jo.has("var")) {
                        String var = jo.optString("var", "");
                        if (mIsFirstVar) {
                            mIsFirstVar = false;
                            mHasvar = true;
                            bean.setText(var);
                            bean.setType(MessageBean.TYPE_INPUT);
                            mMessageList.add(bean);
                            if (mMessageCallback != null) {
                                mMessageCallback.onMessage(bean);
                            }
                        } else {
                            mMessageList.pollLast();
                            bean.setText(var);
                            bean.setType(MessageBean.TYPE_INPUT);
                            mMessageList.add(bean);
                            if (mMessageCallback != null) {
                                mMessageCallback.onMessage(bean);
                            }
                        }
                    }
                    if (jo.has("text")) {
                        if (mHasvar) {
                            mMessageList.pollLast();
                            mHasvar = false;
                            mIsFirstVar = true;
                        }
                        String text = jo.optString("text", "");
                        bean.setText(text);
                        bean.setType(MessageBean.TYPE_INPUT);
                        mMessageList.add(bean);
                        if (mMessageCallback != null) {
                            mMessageCallback.onMessage(bean);
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                break;
            case "context.widget.content":
                bean = new MessageBean();
                try {
                    JSONObject jo = new JSONObject(data);
                    String title = jo.optString("title", "");
                    String subTitle = jo.optString("subTitle", "");
                    String imgUrl = jo.optString("imageUrl", "");
                    bean.setTitle(title);
                    bean.setSubTitle(subTitle);
                    bean.setImgUrl(imgUrl);
                    bean.setType(MessageBean.TYPE_WIDGET_CONTENT);
                    mMessageList.add(bean);
                    if (mMessageCallback != null) {
                        mMessageCallback.onMessage(bean);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                break;
            case "context.widget.list":
                bean = new MessageBean();
                try {
                    JSONObject jo = new JSONObject(data);
                    JSONArray array = jo.optJSONArray("content");
                    if (array == null || array.length() == 0) {
                        return;
                    }
                    for (int i = 0; i < array.length(); i++) {
                        JSONObject object = array.optJSONObject(i);
                        String title = object.optString("title", "");
                        String subTitle = object.optString("subTitle", "");
                        MessageBean b = new MessageBean();
                        b.setTitle(title);
                        b.setSubTitle(subTitle);
                        bean.addMessageBean(b);
                    }
                    int currentPage = jo.optInt("currentPage");
                    bean.setCurrentPage(currentPage);
                    bean.setType(MessageBean.TYPE_WIDGET_LIST);

                    int itemsPerPage = jo.optInt("itemsPerPage");
                    bean.setItemsPerPage(itemsPerPage);

                    mMessageList.add(bean);

                    if (mMessageCallback != null) {
                        mMessageCallback.onMessage(bean);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                break;
            case "context.widget.web":
                bean = new MessageBean();
                try {
                    JSONObject jo = new JSONObject(data);
                    String url = jo.optString("url");
                    bean.setUrl(url);
                    bean.setType(MessageBean.TYPE_WIDGET_WEB);
                    mMessageList.add(bean);
                    if (mMessageCallback != null) {
                        mMessageCallback.onMessage(bean);
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                break;
            case "context.widget.custom":
                bean = new MessageBean();
                try {
                    JSONObject jo = new JSONObject(data);
                    String name = jo.optString("widgetName");
                    if (name.equals("weather")) {
                        bean.setWeatherBean(mGson.fromJson(data, WeatherBean.class));
                        bean.setType(MessageBean.TYPE_WIDGET_WEATHER);
                        mMessageList.add(bean);
                        if (mMessageCallback != null) {
                            mMessageCallback.onMessage(bean);
                        }
                    }
                } catch (JSONException e) {
                    e.printStackTrace();
                }
                break;
            case "context.widget.media":
                JSONObject jsonObject;
                try {
                    jsonObject = new JSONObject(data);
                    if (jsonObject.has("skillId")) {
                        String skillId = jsonObject.getString("skillId");
                        if (skillId.equals("2019032900000210")) {//戏曲
                            xiqu(data);
                        } else if (skillId.equals("2022092900000137")) {//笑话
                            xiaohua(data);
                        } else if (skillId.equals("2019031500001013")) {//故事
                            gushi(data);
                        } else if (skillId.equals("2019041200000195")) {//小说
                            xiaoshuo(data);
                        } else if (skillId.equals("2019031500001032")) {//电台
                            diantai(data);
                        }
                    }

                } catch (JSONException e) {
                    e.printStackTrace();
                }
                break;
            case "sys.dialog.state":
                if (mMessageCallback != null) {
                    mMessageCallback.onState(data);
                }
                break;
            case "sys.wakeup.result":
                if (mMessageCallback != null) {
                    mMessageCallback.onState(message);
                }
                break;
            default:
        }
    }

    private void xiqu(String data) {
        XiQuBean xiqu = GsonUtils.deSerializedFromJson(data, XiQuBean.class);
        if(xiqu!=null&&xiqu.getContent()!=null&&xiqu.getContent().size()>0){
            ArrayList<MusicInfo> musicInfoList=new ArrayList<>();
            for (XiQuBean.ContentBean content: xiqu.getContent()) {
                MusicInfo musicInfo=new MusicInfo();
                if(content.getLinkUrl().contains("&")){
                    musicInfo.setMusicUrl(content.getLinkUrl().substring(0,content.getLinkUrl().indexOf("&")));
                }else{
                    musicInfo.setMusicUrl(content.getLinkUrl());
                }
                musicInfo.setImageUrl(content.getImageUrl());
                musicInfo.setSong(content.getTitle());
                musicInfo.setSinger(content.getArtist());
                musicInfoList.add(musicInfo);
            }
            MusicManager.getInstance().setPlayList(musicInfoList);
        }
    }

    private void xiaohua(String data) {
        XiaoHuaBean xiaohua = GsonUtils.deSerializedFromJson(data, XiaoHuaBean.class);
        if(xiaohua!=null&&xiaohua.getContent()!=null&&xiaohua.getContent().size()>0){
            ArrayList<MusicInfo> musicInfoList=new ArrayList<>();
            for (XiaoHuaBean.ContentBean content: xiaohua.getContent()) {
                MusicInfo musicInfo=new MusicInfo();
                if(content.getLinkUrl().contains("&")){
                    musicInfo.setMusicUrl(content.getLinkUrl().substring(0,content.getLinkUrl().indexOf("&")));
                }else{
                    musicInfo.setMusicUrl(content.getLinkUrl());
                }
                musicInfo.setImageUrl(content.getImageUrl());
                musicInfo.setSong(content.getTitle());
                musicInfo.setSinger("");
                musicInfoList.add(musicInfo);
            }
            MusicManager.getInstance().setPlayList(musicInfoList);
        }
    }

    private void gushi(String data) {
        GuShiBean gushi = GsonUtils.deSerializedFromJson(data, GuShiBean.class);
        if(gushi!=null&&gushi.getContent()!=null&&gushi.getContent().size()>0){
            ArrayList<MusicInfo> musicInfoList=new ArrayList<>();
            for (GuShiBean.ContentBean content: gushi.getContent()) {
                MusicInfo musicInfo=new MusicInfo();
                if(content.getLinkUrl().contains("&")){
                    musicInfo.setMusicUrl(content.getLinkUrl().substring(0,content.getLinkUrl().indexOf("&")));
                }else{
                    musicInfo.setMusicUrl(content.getLinkUrl());
                }
                musicInfo.setImageUrl(content.getImageUrl());
                musicInfo.setSong(content.getTitle());
                musicInfo.setSinger(content.getSubTitle());
                musicInfoList.add(musicInfo);
            }
            MusicManager.getInstance().setPlayList(musicInfoList);
        }

    }

    private void xiaoshuo(String data) {
        XiaoShuoBean xiaoshuo = GsonUtils.deSerializedFromJson(data, XiaoShuoBean.class);
        if(xiaoshuo!=null&&xiaoshuo.getContent()!=null&&xiaoshuo.getContent().size()>0){
            ArrayList<MusicInfo> musicInfoList=new ArrayList<>();
            for (XiaoShuoBean.ContentBean content: xiaoshuo.getContent()) {
                MusicInfo musicInfo=new MusicInfo();
                if(content.getLinkUrl().contains("&")){
                    musicInfo.setMusicUrl(content.getLinkUrl().substring(0,content.getLinkUrl().indexOf("&")));
                }else{
                    musicInfo.setMusicUrl(content.getLinkUrl());
                }
                musicInfo.setImageUrl(xiaoshuo.getBrand().getLogoMiddle());
                musicInfo.setSong(content.getAudiobook()+content.getTitle());
                musicInfo.setSinger(content.getSubTitle());
                musicInfoList.add(musicInfo);
            }
            MusicManager.getInstance().setPlayList(musicInfoList);
        }

    }

    private void diantai(String data) {
        DianTaiBean diantai = GsonUtils.deSerializedFromJson(data, DianTaiBean.class);
        if(diantai!=null&&diantai.getContent()!=null&&diantai.getContent().size()>0){
            ArrayList<MusicInfo> musicInfoList=new ArrayList<>();
            for (DianTaiBean.ContentBean content: diantai.getContent()) {
                MusicInfo musicInfo=new MusicInfo();
                if(content.getLinkUrl().contains("&")){
                    musicInfo.setMusicUrl(content.getLinkUrl().substring(0,content.getLinkUrl().indexOf("&")));
                }else{
                    musicInfo.setMusicUrl(content.getLinkUrl());
                }
                musicInfo.setImageUrl(content.getImageUrl());
                musicInfo.setSong(content.getTitle());
                musicInfo.setSinger(content.getSubTitle());
                musicInfoList.add(musicInfo);
            }
            MusicManager.getInstance().setPlayList(musicInfoList);
        }

    }

}
