package com.midea.light.ai.music;

import com.google.gson.annotations.SerializedName;
public  class MusicInfo {
    private Integer duration;
    @SerializedName(value = "song", alternate = {"title", "text"})
    private String song="";
    private String singer="";
    private String album="";

    @SerializedName(value = "musicUrl", alternate = {"url", "audioUrl"})
    private String musicUrl="";
    private String imageUrl="";

    public Integer getDuration() {
        return duration;
    }

    public void setDuration(Integer duration) {
        this.duration = duration;
    }

    public String getSong() {
        return song;
    }

    public void setSong(String song) {
        this.song = song;
    }

    public String getSinger() {
        return singer;
    }

    public void setSinger(String singer) {
        this.singer = singer;
    }

    public String getAlbum() {
        return album;
    }

    public void setAlbum(String album) {
        this.album = album;
    }

    public String getMusicUrl() {
        return musicUrl;
    }

    public void setMusicUrl(String musicUrl) {
        this.musicUrl = musicUrl;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }
}

