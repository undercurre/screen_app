package com.midea.light.setting.relay;

import com.midea.light.repositories.setting.AbstractMMKVSetting;
import com.midea.light.common.config.AppCommonConfig;
/**
 * @ClassName RelayRepository
 * @Description
 * @Author weinp1
 * @Date 2023/2/15 10:21
 * @Version 1.0
 */
public class RelayRepository extends AbstractMMKVSetting {
    private static final String FILE_NAME = "RelayRepository";
    private static final String GP0_STATE = "GP_0_state";
    private static final String GP1_STATE = "GP_1_state";
    private static final String GP0_MODEL = "GP_0_model";
    private static final String GP1_MODEL = "GP_1_model";

    /**
     * 本实例
     */
    private static RelayRepository instance;

    /**
     * 私有的构造方法
     */
    private RelayRepository() {
    }

    /**
     * 单例的实例
     *
     * @return this
     */
    public static RelayRepository getInstance() {
        if (instance == null) {
            synchronized (RelayRepository.class) {
                if (instance == null) {
                    instance = new RelayRepository();
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
        return AppCommonConfig.SYSTEM_SETTING_DIR;
    }

    public boolean getGP0State() {
        Boolean result= get(GP0_STATE, Boolean.class);
        if(result!=null){
            return result;
        }else{
            return false;
        }
    }

    public void setGP0State(boolean state) {
        save(GP0_STATE, state);
    }

    public boolean getGP1State() {
        Boolean result= get(GP1_STATE, Boolean.class);
        if(result!=null){
            return result;
        }else{
            return false;
        }
    }

    public void setGP1State(boolean state) {
        save(GP1_STATE, state);
    }

    public void setGP0Model(int state) {
        save(GP0_MODEL, state);
    }

    public void setGP1Model(int state) {
        save(GP1_MODEL, state);
    }

    public int getGP0Model() {
        Integer result= get(GP0_MODEL, Integer.class);
        if(result!=null){
            return result;
        }else{
            return 0;
        }
    }

    public int getGP1Model() {
        Integer result= get(GP1_MODEL, Integer.class);
        if(result!=null){
            return result;
        }else{
            return 0;
        }
    }

}