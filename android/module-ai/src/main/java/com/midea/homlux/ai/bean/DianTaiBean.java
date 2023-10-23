package com.midea.homlux.ai.bean;

import java.util.List;

public class DianTaiBean {
    private String type;
    private String duiWidget;
    private Integer totalPages;
    private BrandBean brand;
    private Integer itemsPerPage;
    private String dataSource;
    private Integer actualTotalPages;
    private String name;
    private Integer errorcode;
    private List<SegmentBean> segment;
    private List<ContentBean> content;
    private Integer currentPage;
    private ExtraBean extra;
    private Integer lastCurrentPage;
    private String widgetName;
    private Integer count;
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

    public String getDuiWidget() {
        return duiWidget;
    }

    public void setDuiWidget(String duiWidget) {
        this.duiWidget = duiWidget;
    }

    public Integer getTotalPages() {
        return totalPages;
    }

    public void setTotalPages(Integer totalPages) {
        this.totalPages = totalPages;
    }

    public BrandBean getBrand() {
        return brand;
    }

    public void setBrand(BrandBean brand) {
        this.brand = brand;
    }

    public Integer getItemsPerPage() {
        return itemsPerPage;
    }

    public void setItemsPerPage(Integer itemsPerPage) {
        this.itemsPerPage = itemsPerPage;
    }

    public String getDataSource() {
        return dataSource;
    }

    public void setDataSource(String dataSource) {
        this.dataSource = dataSource;
    }

    public Integer getActualTotalPages() {
        return actualTotalPages;
    }

    public void setActualTotalPages(Integer actualTotalPages) {
        this.actualTotalPages = actualTotalPages;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getErrorcode() {
        return errorcode;
    }

    public void setErrorcode(Integer errorcode) {
        this.errorcode = errorcode;
    }

    public List<SegmentBean> getSegment() {
        return segment;
    }

    public void setSegment(List<SegmentBean> segment) {
        this.segment = segment;
    }

    public List<ContentBean> getContent() {
        return content;
    }

    public void setContent(List<ContentBean> content) {
        this.content = content;
    }

    public Integer getCurrentPage() {
        return currentPage;
    }

    public void setCurrentPage(Integer currentPage) {
        this.currentPage = currentPage;
    }

    public ExtraBean getExtra() {
        return extra;
    }

    public void setExtra(ExtraBean extra) {
        this.extra = extra;
    }

    public Integer getLastCurrentPage() {
        return lastCurrentPage;
    }

    public void setLastCurrentPage(Integer lastCurrentPage) {
        this.lastCurrentPage = lastCurrentPage;
    }

    public String getWidgetName() {
        return widgetName;
    }

    public void setWidgetName(String widgetName) {
        this.widgetName = widgetName;
    }

    public Integer getCount() {
        return count;
    }

    public void setCount(Integer count) {
        this.count = count;
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

    public static class BrandBean {
        private String logoSmall;
        private String logoLarge;
        private String showName;
        private String logoMiddle;
        private String name;
        private String isexport;

        public String getLogoSmall() {
            return logoSmall;
        }

        public void setLogoSmall(String logoSmall) {
            this.logoSmall = logoSmall;
        }

        public String getLogoLarge() {
            return logoLarge;
        }

        public void setLogoLarge(String logoLarge) {
            this.logoLarge = logoLarge;
        }

        public String getShowName() {
            return showName;
        }

        public void setShowName(String showName) {
            this.showName = showName;
        }

        public String getLogoMiddle() {
            return logoMiddle;
        }

        public void setLogoMiddle(String logoMiddle) {
            this.logoMiddle = logoMiddle;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getIsexport() {
            return isexport;
        }

        public void setIsexport(String isexport) {
            this.isexport = isexport;
        }
    }

    public static class ExtraBean {
        private SourceBean source;
        private Integer sourceId;

        public SourceBean getSource() {
            return source;
        }

        public void setSource(SourceBean source) {
            this.source = source;
        }

        public Integer getSourceId() {
            return sourceId;
        }

        public void setSourceId(Integer sourceId) {
            this.sourceId = sourceId;
        }

        public static class SourceBean {
            private String logo;
            private String name;

            public String getLogo() {
                return logo;
            }

            public void setLogo(String logo) {
                this.logo = logo;
            }

            public String getName() {
                return name;
            }

            public void setName(String name) {
                this.name = name;
            }
        }
    }

    public static class SegmentBean {
        private String pinyin;
        private String name;

        public String getPinyin() {
            return pinyin;
        }

        public void setPinyin(String pinyin) {
            this.pinyin = pinyin;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }
    }

    public static class ContentBean {
        private String subTitle;
        private String mp3PlayUrl64;
        private String host;
        private String mp3PlayUrl32;
        private String mp3PlayUrl128;
        private String imageUrl;
        private String title;
        private ExtraBean extra;
        private String linkUrl;

        public String getSubTitle() {
            return subTitle;
        }

        public void setSubTitle(String subTitle) {
            this.subTitle = subTitle;
        }

        public String getMp3PlayUrl64() {
            return mp3PlayUrl64;
        }

        public void setMp3PlayUrl64(String mp3PlayUrl64) {
            this.mp3PlayUrl64 = mp3PlayUrl64;
        }

        public String getHost() {
            return host;
        }

        public void setHost(String host) {
            this.host = host;
        }

        public String getMp3PlayUrl32() {
            return mp3PlayUrl32;
        }

        public void setMp3PlayUrl32(String mp3PlayUrl32) {
            this.mp3PlayUrl32 = mp3PlayUrl32;
        }

        public String getMp3PlayUrl128() {
            return mp3PlayUrl128;
        }

        public void setMp3PlayUrl128(String mp3PlayUrl128) {
            this.mp3PlayUrl128 = mp3PlayUrl128;
        }

        public String getImageUrl() {
            return imageUrl;
        }

        public void setImageUrl(String imageUrl) {
            this.imageUrl = imageUrl;
        }

        public String getTitle() {
            return title;
        }

        public void setTitle(String title) {
            this.title = title;
        }

        public ExtraBean getExtra() {
            return extra;
        }

        public void setExtra(ExtraBean extra) {
            this.extra = extra;
        }

        public String getLinkUrl() {
            return linkUrl;
        }

        public void setLinkUrl(String linkUrl) {
            this.linkUrl = linkUrl;
        }

        public static class ExtraBean {
            private String mediaCategory;

            public String getMediaCategory() {
                return mediaCategory;
            }

            public void setMediaCategory(String mediaCategory) {
                this.mediaCategory = mediaCategory;
            }
        }
    }
}
