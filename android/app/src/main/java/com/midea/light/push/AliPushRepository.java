package com.midea.light.push;

import com.midea.light.common.config.AppCommonConfig;
import com.midea.light.repositories.setting.AbstractMMKVSetting;
import com.midea.light.setting.relay.RelayRepository;

/**
 * @author Admin
 * @version $
 * @des
 * @updateAuthor $
 * @updateDes
 */
public class AliPushRepository extends AbstractMMKVSetting {
    private String FILE_NAME = "AliPushRepository";
    private static AliPushRepository instance;

    public static AliPushRepository getInstance() {
        if (instance == null) {
            synchronized (AliPushRepository.class) {
                if (instance == null) {
                    instance = new AliPushRepository();
                }
            }
        }
        return instance;
    }

    @Override
    protected String getFileName() {
        return FILE_NAME;
    }

    @Override
    protected String getFileDir() {
        return AppCommonConfig.ALI_PUSH_DIR;
    }

    public void setAliPushDeviceId(String deviceId) {
        save("deviceId", deviceId);
    }

    public String getAliPushDeviceId() {
        return get("deviceId", String.class);
    }
}
