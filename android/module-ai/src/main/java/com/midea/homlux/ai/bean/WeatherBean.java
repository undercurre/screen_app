package com.midea.homlux.ai.bean;

import com.google.gson.annotations.SerializedName;

import java.util.List;

/**
 * Created by nemo on 2019-05-30.
 */
public class WeatherBean {


    private String type;
    private String dm_intent;
    private String duiWidget;
    private String widgetName;
    private WebhookRespBean webhookResp;
    private List<String> recommendations;
    private ExtraBean extra;
    private String cityName;
    private String name;
    private String intentName;
    private String skillId;
    private String skillName;
    private String taskName;

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getDm_intent() {
        return dm_intent;
    }

    public void setDm_intent(String dm_intent) {
        this.dm_intent = dm_intent;
    }

    public String getDuiWidget() {
        return duiWidget;
    }

    public void setDuiWidget(String duiWidget) {
        this.duiWidget = duiWidget;
    }

    public String getWidgetName() {
        return widgetName;
    }

    public void setWidgetName(String widgetName) {
        this.widgetName = widgetName;
    }

    public WebhookRespBean getWebhookResp() {
        return webhookResp;
    }

    public void setWebhookResp(WebhookRespBean webhookResp) {
        this.webhookResp = webhookResp;
    }

    public List<String> getRecommendations() {
        return recommendations;
    }

    public void setRecommendations(List<String> recommendations) {
        this.recommendations = recommendations;
    }

    public ExtraBean getExtra() {
        return extra;
    }

    public void setExtra(ExtraBean extra) {
        this.extra = extra;
    }

    public String getCityName() {
        return cityName;
    }

    public void setCityName(String cityName) {
        this.cityName = cityName;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getIntentName() {
        return intentName;
    }

    public void setIntentName(String intentName) {
        this.intentName = intentName;
    }

    public String getSkillId() {
        return skillId;
    }

    public void setSkillId(String skillId) {
        this.skillId = skillId;
    }

    public String getSkillName() {
        return skillName;
    }

    public void setSkillName(String skillName) {
        this.skillName = skillName;
    }

    public String getTaskName() {
        return taskName;
    }

    public void setTaskName(String taskName) {
        this.taskName = taskName;
    }

    public static class WebhookRespBean {
        private Integer errorcode;
        private ExtraBean extra;
        private BrandBean brand;
        private String cityName;

        public Integer getErrorcode() {
            return errorcode;
        }

        public void setErrorcode(Integer errorcode) {
            this.errorcode = errorcode;
        }

        public ExtraBean getExtra() {
            return extra;
        }

        public void setExtra(ExtraBean extra) {
            this.extra = extra;
        }

        public BrandBean getBrand() {
            return brand;
        }

        public void setBrand(BrandBean brand) {
            this.brand = brand;
        }

        public String getCityName() {
            return cityName;
        }

        public void setCityName(String cityName) {
            this.cityName = cityName;
        }

        public static class ExtraBean {
            private ConditionBean condition;
            private List<HourForecast24Bean> hourForecast24;
            private Integer sourceId;
            private List<ForecastBean> forecast;
            @SerializedName("Index")
            private IndexBean index;
            private List<FutureBean> future;

            public ConditionBean getCondition() {
                return condition;
            }

            public void setCondition(ConditionBean condition) {
                this.condition = condition;
            }

            public List<HourForecast24Bean> getHourForecast24() {
                return hourForecast24;
            }

            public void setHourForecast24(List<HourForecast24Bean> hourForecast24) {
                this.hourForecast24 = hourForecast24;
            }

            public Integer getSourceId() {
                return sourceId;
            }

            public void setSourceId(Integer sourceId) {
                this.sourceId = sourceId;
            }

            public List<ForecastBean> getForecast() {
                return forecast;
            }

            public void setForecast(List<ForecastBean> forecast) {
                this.forecast = forecast;
            }

            public IndexBean getIndex() {
                return index;
            }

            public void setIndex(IndexBean index) {
                this.index = index;
            }

            public List<FutureBean> getFuture() {
                return future;
            }

            public void setFuture(List<FutureBean> future) {
                this.future = future;
            }

            public static class ConditionBean {
                private String weather;
                private String temperature;
                private String windLevel;
                private String wind;

                public String getWeather() {
                    return weather;
                }

                public void setWeather(String weather) {
                    this.weather = weather;
                }

                public String getTemperature() {
                    return temperature;
                }

                public void setTemperature(String temperature) {
                    this.temperature = temperature;
                }

                public String getWindLevel() {
                    return windLevel;
                }

                public void setWindLevel(String windLevel) {
                    this.windLevel = windLevel;
                }

                public String getWind() {
                    return wind;
                }

                public void setWind(String wind) {
                    this.wind = wind;
                }
            }

            public static class IndexBean {
                private AqiBean aqi;
                private List<LiveIndexBean> liveIndex;
                private String humidity;

                public AqiBean getAqi() {
                    return aqi;
                }

                public void setAqi(AqiBean aqi) {
                    this.aqi = aqi;
                }

                public List<LiveIndexBean> getLiveIndex() {
                    return liveIndex;
                }

                public void setLiveIndex(List<LiveIndexBean> liveIndex) {
                    this.liveIndex = liveIndex;
                }

                public String getHumidity() {
                    return humidity;
                }

                public void setHumidity(String humidity) {
                    this.humidity = humidity;
                }

                public static class AqiBean {
                    @SerializedName("AQI")
                    private String aQI;
                    @SerializedName("AQL")
                    private String aQL;
                    private String pm25;
                    @SerializedName("AQIdesc")
                    private String aQIdesc;

                    public String getAQI() {
                        return aQI;
                    }

                    public void setAQI(String aQI) {
                        this.aQI = aQI;
                    }

                    public String getAQL() {
                        return aQL;
                    }

                    public void setAQL(String aQL) {
                        this.aQL = aQL;
                    }

                    public String getPm25() {
                        return pm25;
                    }

                    public void setPm25(String pm25) {
                        this.pm25 = pm25;
                    }

                    public String getAQIdesc() {
                        return aQIdesc;
                    }

                    public void setAQIdesc(String aQIdesc) {
                        this.aQIdesc = aQIdesc;
                    }
                }

                public static class LiveIndexBean {
                    private String desc;
                    private String status;
                    private String name;

                    public String getDesc() {
                        return desc;
                    }

                    public void setDesc(String desc) {
                        this.desc = desc;
                    }

                    public String getStatus() {
                        return status;
                    }

                    public void setStatus(String status) {
                        this.status = status;
                    }

                    public String getName() {
                        return name;
                    }

                    public void setName(String name) {
                        this.name = name;
                    }
                }
            }

            public static class HourForecast24Bean {
                private String weather;
                private Integer temperature;
                private String processTime;

                public String getWeather() {
                    return weather;
                }

                public void setWeather(String weather) {
                    this.weather = weather;
                }

                public Integer getTemperature() {
                    return temperature;
                }

                public void setTemperature(Integer temperature) {
                    this.temperature = temperature;
                }

                public String getProcessTime() {
                    return processTime;
                }

                public void setProcessTime(String processTime) {
                    this.processTime = processTime;
                }
            }

            public static class ForecastBean {
                private String weather;
                private String tempInteval;
                private String tempTip;
                private String sunrise;
                private String windLevel;
                private String highTemp;
                private String sunset;
                private String lowTemp;
                private String wind;
                private String date;
                private String temperature;
                private String week;
                private String tip;

                public String getWeather() {
                    return weather;
                }

                public void setWeather(String weather) {
                    this.weather = weather;
                }

                public String getTempInteval() {
                    return tempInteval;
                }

                public void setTempInteval(String tempInteval) {
                    this.tempInteval = tempInteval;
                }

                public String getTempTip() {
                    return tempTip;
                }

                public void setTempTip(String tempTip) {
                    this.tempTip = tempTip;
                }

                public String getSunrise() {
                    return sunrise;
                }

                public void setSunrise(String sunrise) {
                    this.sunrise = sunrise;
                }

                public String getWindLevel() {
                    return windLevel;
                }

                public void setWindLevel(String windLevel) {
                    this.windLevel = windLevel;
                }

                public String getHighTemp() {
                    return highTemp;
                }

                public void setHighTemp(String highTemp) {
                    this.highTemp = highTemp;
                }

                public String getSunset() {
                    return sunset;
                }

                public void setSunset(String sunset) {
                    this.sunset = sunset;
                }

                public String getLowTemp() {
                    return lowTemp;
                }

                public void setLowTemp(String lowTemp) {
                    this.lowTemp = lowTemp;
                }

                public String getWind() {
                    return wind;
                }

                public void setWind(String wind) {
                    this.wind = wind;
                }

                public String getDate() {
                    return date;
                }

                public void setDate(String date) {
                    this.date = date;
                }

                public String getTemperature() {
                    return temperature;
                }

                public void setTemperature(String temperature) {
                    this.temperature = temperature;
                }

                public String getWeek() {
                    return week;
                }

                public void setWeek(String week) {
                    this.week = week;
                }

                public String getTip() {
                    return tip;
                }

                public void setTip(String tip) {
                    this.tip = tip;
                }
            }

            public static class FutureBean {
                private String weather;
                private String wind;
                private String date;
                private String windLevel;
                private String temperature;
                private String week;

                public String getWeather() {
                    return weather;
                }

                public void setWeather(String weather) {
                    this.weather = weather;
                }

                public String getWind() {
                    return wind;
                }

                public void setWind(String wind) {
                    this.wind = wind;
                }

                public String getDate() {
                    return date;
                }

                public void setDate(String date) {
                    this.date = date;
                }

                public String getWindLevel() {
                    return windLevel;
                }

                public void setWindLevel(String windLevel) {
                    this.windLevel = windLevel;
                }

                public String getTemperature() {
                    return temperature;
                }

                public void setTemperature(String temperature) {
                    this.temperature = temperature;
                }

                public String getWeek() {
                    return week;
                }

                public void setWeek(String week) {
                    this.week = week;
                }
            }
        }

        public static class BrandBean {
            private String isexport;
            private String logoMiddle;
            private String logoSmall;
            private String showName;
            private String logoLarge;
            private String name;

            public String getIsexport() {
                return isexport;
            }

            public void setIsexport(String isexport) {
                this.isexport = isexport;
            }

            public String getLogoMiddle() {
                return logoMiddle;
            }

            public void setLogoMiddle(String logoMiddle) {
                this.logoMiddle = logoMiddle;
            }

            public String getLogoSmall() {
                return logoSmall;
            }

            public void setLogoSmall(String logoSmall) {
                this.logoSmall = logoSmall;
            }

            public String getShowName() {
                return showName;
            }

            public void setShowName(String showName) {
                this.showName = showName;
            }

            public String getLogoLarge() {
                return logoLarge;
            }

            public void setLogoLarge(String logoLarge) {
                this.logoLarge = logoLarge;
            }

            public String getName() {
                return name;
            }

            public void setName(String name) {
                this.name = name;
            }
        }
    }

    public static class ExtraBean {
        private String nlg_message;

        public String getNlg_message() {
            return nlg_message;
        }

        public void setNlg_message(String nlg_message) {
            this.nlg_message = nlg_message;
        }
    }
}
