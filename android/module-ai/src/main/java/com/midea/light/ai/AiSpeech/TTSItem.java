package com.midea.light.ai.AiSpeech;

public class TTSItem {
    private String urlType = "";
    private String skillType = "";
    private boolean autoResume;
    private String text;
    private String url;
    private int seq;

    public TTSItem(String url) {
        this.url = url;
    }

    public void setSeq(int seq) {
        this.seq = seq;
    }

    public String getLinkUrl() {
        return url;
    }

    public void setLinkUrl(String linkUrl) {
        this.url = linkUrl;
    }

    public String getLabel() {
        return text;
    }

    public void setLabel(String label) {
        this.text = label;
    }

    public String getUrlType() {
        return urlType;
    }

    public String getSkillType() {
        return skillType;
    }

    public void setSkillType(String skillType) {
        this.skillType = skillType;
    }

    public int getSeq() {
        return seq;
    }

    public void setUrlType(String urlType) {
        this.urlType = urlType;
    }

    public boolean isAutoResume() {
        return autoResume;
    }

    public void setAutoResume(boolean autoResume) {
        this.autoResume = autoResume;
    }

}

