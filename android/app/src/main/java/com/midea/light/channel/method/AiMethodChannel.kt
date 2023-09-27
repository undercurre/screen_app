package com.midea.light.channel.method

import android.content.Context
import android.util.Log
import com.midea.iot.sdk.common.security.SecurityUtils
import com.midea.light.MainApplication
import com.midea.light.RxBus
import com.midea.light.ai.music.MusicManager
import com.midea.light.ai.music.MusicPlayEvent
import com.midea.light.bean.GatewayPlatform
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


    lateinit var cMethodChannel: MethodChannel

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
        cMethodChannel = mMethodChannel
        RxBus.getInstance().toObservableInSingle(MusicPlayEvent::class.java)
            .subscribe { MusicPlayEvent: MusicPlayEvent? -> flashMusicInfor() }
    }


    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        LogUtil.tag(TAG).msg("flutter -> method: ${call.method}")
        when (call.method) {
            "InitialAi" -> {
                val plarform = call.argument<Int?>("platform")
                if (MainApplication.gatewayPlatform.rawPlatform() != plarform) {
                    Log.e("sky", "初始化AI语音失败，flutter运行平台与原生平台不一致")
                } else {
                    Log.e("sky", "初始化ai参数:" + call.arguments.toString())
                    if (MainApplication.gatewayPlatform == GatewayPlatform.MEIJU) {
                        MainApplication.mMainActivity.initialMeiJuAi(
                            call.argument<String?>("deviceSn").toString(),
                            call.argument<String?>("deviceId").toString(),
                            call.argument<String?>("macAddress").toString().replace
                                (":", ""),
                            call.argument<Boolean?>("aiEnable") == true
                        )
                    } else if (MainApplication.gatewayPlatform == GatewayPlatform.HOMLUX) {
                        MainApplication.mMainActivity.initialHomluxAI(
                            call.argument<String?>("uid").toString(),
                            call.argument<String?>("token").toString(),
                            call.argument<Boolean?>("aiEnable") == true,
                            call.argument<String?>("houseId").toString(),
                            call.argument<String?>("aiClientId").toString()
                        )
                    }
                }
            }
            "StopAi" -> {
                Log.e("sky", "停止运行ai")
                if (MainApplication.gatewayPlatform == GatewayPlatform.HOMLUX) {
                    Log.e("sky", "停止美居ai")
                    com.midea.light.ai.AiManager.getInstance().stopAi()
                    com.midea.homlux.ai.AiManager.getInstance().stopAi()
                } else if (MainApplication.gatewayPlatform == GatewayPlatform.MEIJU) {
                    Log.e("sky", "停止HomluxAi")
                    com.midea.homlux.ai.AiManager.getInstance().stopAi()
                    com.midea.light.ai.AiManager.getInstance().stopAi()

                }
            }
            "WakeUpAi" -> {
                if (MainApplication.gatewayPlatform == GatewayPlatform.MEIJU) {
                    com.midea.light.ai.AiManager.getInstance().wakeupAi()
                } else if (MainApplication.gatewayPlatform == GatewayPlatform.HOMLUX) {
                    com.midea.homlux.ai.AiManager.getInstance().wakeupAi()
                }
            }
            "EnableAi" -> {
                if (MainApplication.gatewayPlatform == GatewayPlatform.MEIJU) {
                    com.midea.light.ai.AiManager.getInstance()
                        .setAiEnable(call.arguments as Boolean)
                } else if (MainApplication.gatewayPlatform == GatewayPlatform.HOMLUX) {
                    com.midea.homlux.ai.AiManager.getInstance()
                        .setAiEnable(call.arguments as Boolean)
                }
            }
            "GetAiEnable" -> {

            }
            "AiMusicStart" -> {
                if (MainApplication.gatewayPlatform == GatewayPlatform.MEIJU) {
                    if (CollectionUtil.isEmpty(MusicManager.getInstance().getPlayList())) {
                        com.midea.light.ai.AiManager.getInstance().getMusicList()
                        //需要延迟一段时间后返回播放信息
                    } else {
                        MusicManager.getInstance().startMusic()
                    }
                }
            }
            "AiMusicPause" -> {
                if (MainApplication.gatewayPlatform == GatewayPlatform.MEIJU) {
                    MusicManager.getInstance().pauseMusic()
                }
            }
            "AiMusicPrevious" -> {
                if (MainApplication.gatewayPlatform == GatewayPlatform.MEIJU) {
                    MusicManager.getInstance().prevMusic()
                }
            }
            "AiMusicNext" -> {
                if (MainApplication.gatewayPlatform == GatewayPlatform.MEIJU) {
                    MusicManager.getInstance().nextMusic()
                }
            }
            "AiMusicIsPlaying" -> {
                if (MainApplication.gatewayPlatform == GatewayPlatform.MEIJU) {
                    result.success(MusicManager.getInstance().isPaying())
                }
            }
            "AiMusicInforGet" -> {
                if (MainApplication.gatewayPlatform == GatewayPlatform.MEIJU) {
                    flashMusicInfor()
                }
            }
            "Aes128Encode" -> {
                val data=call.argument<String?>("data").toString()
                val key=call.argument<String?>("seed").toString()
                val re = SecurityUtils.encodeAES128(data,key)
                result.safeSuccess(re)
            }

            else -> {
                // 对应的方法没有报错
                onCallNotImplement(result)
            }
        }
    }

    private fun flashMusicInfor() {
        val mMusicInfor = MusicManager.getInstance().playMusicInfor
        val json = JSONObject()
        if (mMusicInfor != null) {
            json.put("playState", if (MusicManager.getInstance().isPaying) 1 else 0)
            json.put("songName", mMusicInfor.song)
            json.put("singerName", mMusicInfor.singer)
            json.put("imgUrl", mMusicInfor.imageUrl)
        } else {
            json.put("playState", 0)
            json.put("songName", "暂无歌曲")
            json.put("singerName", "暂无歌手")
            json.put("imgUrl", "")
        }
        mMethodChannel.invokeMethod("musicResult", json)
    }


}