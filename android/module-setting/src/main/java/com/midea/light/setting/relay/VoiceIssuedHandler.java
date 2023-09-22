package com.midea.light.setting.relay;

import android.content.res.AssetFileDescriptor;
import android.media.AudioManager;
import android.media.MediaPlayer;

import com.midea.light.BaseApplication;
import com.midea.light.issued.IIssuedHandler;
import com.midea.light.issued.IssuedWriteCallback;

import org.json.JSONObject;

import java.util.concurrent.locks.ReentrantLock;

import io.reactivex.rxjava3.schedulers.Schedulers;

/**
 * @author Janner
 * @ProjectName: SmartScreen
 * @Package: com.midea.light.gatewaylib.issued.voice
 * @ClassName: VoiceIssuedHandler
 * @CreateDate: 2022/7/14 10:49
 */
public class VoiceIssuedHandler implements IIssuedHandler, MediaPlayer.OnPreparedListener, MediaPlayer.OnCompletionListener {
   private static ReentrantLock mLock = new ReentrantLock();

   @Override
   public void onHandler(String data, IssuedWriteCallback callback) {
      try {
         JSONObject root = new JSONObject(data);
         if(!root.has("audioBroadcast"))
            return;
         String broadcast = root.getString("audioBroadcast");
         if(broadcast.equals("permit")) {

            Schedulers.io().scheduleDirect(new Runnable() {
               @Override
               public void run() {
                  try {
                     if (mLock.tryLock()) {
                        MediaPlayer mediaPlayer = new MediaPlayer();
                        AssetFileDescriptor descriptor = BaseApplication.getContext().getAssets().openFd("music/allow_link.mp3");
                        mediaPlayer.setDataSource(descriptor.getFileDescriptor(),
                                descriptor.getStartOffset(), descriptor.getLength());
                        descriptor.close();
                        mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
                        mediaPlayer.setOnPreparedListener(VoiceIssuedHandler.this);
                        mediaPlayer.prepareAsync();
                        mediaPlayer.setOnCompletionListener(VoiceIssuedHandler.this);
                        Thread.sleep(1000);
                        waitUntil(new Predicate() {
                           @Override
                           public boolean waitCondition() throws Throwable {
                              return !mediaPlayer.isPlaying();
                           }
                        }, 10);
                        mLock.unlock();
                     }
                  } catch(Exception e){
                     e.printStackTrace();
                     mLock.unlock();
                  }
               }
            });
         }else if(broadcast.equals("newDevice")){
            Schedulers.io().scheduleDirect(new Runnable() {
               @Override
               public void run() {
                  try {
                     if (mLock.tryLock()) {
                        MediaPlayer mediaPlayer = new MediaPlayer();
                        AssetFileDescriptor descriptor = BaseApplication.getContext().getAssets().openFd("music/device_add_already.mp3");
                        mediaPlayer.setDataSource(descriptor.getFileDescriptor(),
                                descriptor.getStartOffset(), descriptor.getLength());
                        descriptor.close();
                        mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
                        mediaPlayer.setOnPreparedListener(VoiceIssuedHandler.this);
                        mediaPlayer.prepareAsync();
                        mediaPlayer.setOnCompletionListener(VoiceIssuedHandler.this);
                        Thread.sleep(1000);
                        waitUntil(new Predicate() {
                           @Override
                           public boolean waitCondition() throws Throwable {
                              return !mediaPlayer.isPlaying();
                           }
                        }, 10);
                        mLock.unlock();
                     }
                  }catch (Exception e) {
                     e.printStackTrace();
                     mLock.unlock();
                  }
               }
            });
         }else if(broadcast.equals("delDevice")) {
            Schedulers.io().scheduleDirect(new Runnable() {
               @Override
               public void run() {
                  try {
                     if (mLock.tryLock()) {
                        MediaPlayer mediaPlayer = new MediaPlayer();
                        AssetFileDescriptor descriptor = BaseApplication.getContext().getAssets().openFd("music/device_delete_already.mp3");
                        mediaPlayer.setDataSource(descriptor.getFileDescriptor(),
                                descriptor.getStartOffset(), descriptor.getLength());
                        descriptor.close();
                        mediaPlayer.setAudioStreamType(AudioManager.STREAM_MUSIC);
                        mediaPlayer.setOnPreparedListener(VoiceIssuedHandler.this);
                        mediaPlayer.prepareAsync();
                        mediaPlayer.setOnCompletionListener(VoiceIssuedHandler.this);
                        Thread.sleep(1000);
                        waitUntil(new Predicate() {
                           @Override
                           public boolean waitCondition() throws Throwable {
                              return !mediaPlayer.isPlaying();
                           }
                        }, 10);
                        mLock.unlock();
                     }
                  }catch (Exception e) {
                     e.printStackTrace();
                     mLock.unlock();
                  }
               }
            });
         }
      } catch (Exception e) {
         e.printStackTrace();
      }
   }

   @Override
   public void onPrepared(MediaPlayer mediaPlayer) {
      mediaPlayer.start();
   }

   @Override
   public void onCompletion(MediaPlayer mediaPlayer) {
      mediaPlayer.release();
   }

   public interface Predicate {
      boolean waitCondition() throws Throwable;
   }

   public static boolean waitUntil(Predicate predicate, int timeout) {
      timeout *= 10;
      try {
         while (!predicate.waitCondition() && timeout >= 0) {
            Thread.sleep(100);
            timeout -= 1;
         }
         if (predicate.waitCondition()) {
            return true;
         }
      } catch (Throwable e) {
         throw new RuntimeException(e);
      }
      return false;
   }
}
