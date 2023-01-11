package com.midea.light.channel.method

import android.content.Context
import android.util.Log
import com.midea.light.MainApplication
import com.midea.light.RxBus
import com.midea.light.ai.AiManager
import com.midea.light.ai.music.MusicManager
import com.midea.light.ai.music.MusicPlayEvent
import com.midea.light.channel.AbsMZMethodChannel
import com.midea.light.log.LogUtil
import com.midea.light.utils.CollectionUtil
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject


private const val TAG = "Ai"


/**
 * @ClassName AiMethodChanel
 * @Description 语音 -- 方法通道
 * @Author yangyl19
 * @Date 2022/12/10 13:37
 * @Version 1.0
 */
class AiMethodChannel constructor(override val context: Context) : AbsMZMethodChannel(context) {


    companion object {
        fun create(
            channel: String,
            binaryMessenger: BinaryMessenger,
            context: Context
        ): AiMethodChannel {
            val methodChannel = AiMethodChannel(context)
            methodChannel.setup(binaryMessenger, channel)
            return methodChannel
        }
    }

    override fun setup(binaryMessenger: BinaryMessenger, channel: String) {
        super.setup(binaryMessenger, channel)
        LogUtil.tag(TAG).msg("语音设置通道启动")
        RxBus.getInstance().toObservableInSingle( MusicPlayEvent::class.java)
            .subscribe { MusicPlayEvent: MusicPlayEvent? -> flashMusicInfor() }
    }


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        LogUtil.tag(TAG).msg("flutter -> method: ${call.method}")
        when (call.method) {
            "InitialAi" -> {
                Log.e("sky","初始化ai参数:"+call.arguments.toString())
                MainApplication.mMainActivity.initialAi(call.argument<String?>("deviceSn").toString(),call.argument<String?>("deviceId").toString(),call.argument<String?>("macAddress").toString().replace
                    (":",""))
            }
            "WakeUpAi" -> {
                AiManager.getInstance().wakeupAi()
            }
            "EnableAi" -> {
                AiManager.getInstance().setAiEnable(call.arguments as Boolean)
            }
            "GetAiEnable" -> {

            }
            "AiMusicStart" -> {
                if (CollectionUtil.isEmpty(MusicManager.getInstance().getPlayList())) {
                    AiManager.getInstance().getMusicList()
                    //需要延迟一段时间后返回播放信息
                } else {
                    MusicManager.getInstance().startMusic()
                }
            }
            "AiMusicPause" -> {
                MusicManager.getInstance().pauseMusic()
            }
            "AiMusicPrevious" -> {
                MusicManager.getInstance().prevMusic()
            }
            "AiMusicNext" -> {
                MusicManager.getInstance().nextMusic()
            }
            "AiMusicIsPlaying" -> {
                result.success(MusicManager.getInstance().isPaying())
            }
            "AiMusicInforGet" -> {
                flashMusicInfor()
            }

            else -> {
                // 对应的方法没有报错
                onCallNotImplement(result)
            }
        }
    }

    private fun flashMusicInfor(){
        val mMusicInfor = MusicManager.getInstance().playMusicInfor
        val json = JSONObject()
        if(mMusicInfor!=null){
            json.put("playState",if(MusicManager.getInstance().isPaying) 1 else 0)
            json.put("songName",mMusicInfor.song)
            json.put("singerName",mMusicInfor.singer)
            json.put("imgUrl",mMusicInfor.imageUrl)
        }else{
            json.put("playState", 0)
            json.put("songName","暂无歌曲")
            json.put("singerName","暂无歌手")
            json.put("imgUrl","")
        }
        mMethodChannel.invokeMethod("musicResult", json)
    }


}