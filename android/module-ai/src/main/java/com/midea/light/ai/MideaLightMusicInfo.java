package com.midea.light.ai;

import android.annotation.SuppressLint;
import android.os.Parcel;
import android.os.Parcelable;

import androidx.annotation.NonNull;

import com.google.gson.annotations.SerializedName;

@SuppressLint("ParcelCreator")
public class MideaLightMusicInfo implements Parcelable {

    public MideaLightMusicInfo() {}

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

    protected MideaLightMusicInfo(Parcel in) {
        duration = in.readInt();
        song = in.readString();
        singer = in.readString();
        album = in.readString();
        musicUrl = in.readString();
        imageUrl = in.readString();
    }

    public static final Creator<MideaLightMusicInfo> CREATOR = new Creator<MideaLightMusicInfo>() {
        @Override
        public MideaLightMusicInfo createFromParcel(Parcel in) {
            return new MideaLightMusicInfo(in);
        }

        @Override
        public MideaLightMusicInfo[] newArray(int size) {
            return new MideaLightMusicInfo[size];
        }
    };

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(@NonNull Parcel dest, int flags) {
        dest.writeInt(duration);
        dest.writeString(song);
        dest.writeString(singer);
        dest.writeString(album);
        dest.writeString(musicUrl);
        dest.writeString(imageUrl);
    }

}

