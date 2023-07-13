package com.midea.homlux.ai.music;

public class MusicPlayStateEvent {

    public int getState() {
        return state;
    }

    public void setState(int state) {
        this.state = state;
    }

    int state;

    public MusicPlayStateEvent(int state) {
        this.state=state;
    }
}
