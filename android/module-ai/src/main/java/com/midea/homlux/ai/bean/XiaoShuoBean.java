package com.midea.homlux.ai.bean;

import java.util.List;

public class XiaoShuoBean {
    private String type;
    private Integer count;
    private List<ContentBean> content;
    private BrandBean brand;
    private ExtraBean extra;
    private String dataSource;
    private Integer itemsPerPage;
    private Integer totalPages;
    private String widgetName;
    private Integer match;
    private Integer errorcode;
    private String duiWidget;
    private List<SegmentBean> segment;
    private Integer currentPage;
    private String name;
    private Integer lastCurrentPage;
    private Integer actualTotalPages;
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

    public Integer getCount() {
        return count;
    }

    public void setCount(Integer count) {
        this.count = count;
    }

    public List<ContentBean> getContent() {
        return content;
    }

    public void setContent(List<ContentBean> content) {
        this.content = content;
    }

    public BrandBean getBrand() {
        return brand;
    }

    public void setBrand(BrandBean brand) {
        this.brand = brand;
    }

    public ExtraBean getExtra() {
        return extra;
    }

    public void setExtra(ExtraBean extra) {
        this.extra = extra;
    }

    public String getDataSource() {
        return dataSource;
    }

    public void setDataSource(String dataSource) {
        this.dataSource = dataSource;
    }

    public Integer getItemsPerPage() {
        return itemsPerPage;
    }

    public void setItemsPerPage(Integer itemsPerPage) {
        this.itemsPerPage = itemsPerPage;
    }

    public Integer getTotalPages() {
        return totalPages;
    }

    public void setTotalPages(Integer totalPages) {
        this.totalPages = totalPages;
    }

    public String getWidgetName() {
        return widgetName;
    }

    public void setWidgetName(String widgetName) {
        this.widgetName = widgetName;
    }

    public Integer getMatch() {
        return match;
    }

    public void setMatch(Integer match) {
        this.match = match;
    }

    public Integer getErrorcode() {
        return errorcode;
    }

    public void setErrorcode(Integer errorcode) {
        this.errorcode = errorcode;
    }

    public String getDuiWidget() {
        return duiWidget;
    }

    public void setDuiWidget(String duiWidget) {
        this.duiWidget = duiWidget;
    }

    public List<SegmentBean> getSegment() {
        return segment;
    }

    public void setSegment(List<SegmentBean> segment) {
        this.segment = segment;
    }

    public Integer getCurrentPage() {
        return currentPage;
    }

    public void setCurrentPage(Integer currentPage) {
        this.currentPage = currentPage;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getLastCurrentPage() {
        return lastCurrentPage;
    }

    public void setLastCurrentPage(Integer lastCurrentPage) {
        this.lastCurrentPage = lastCurrentPage;
    }

    public Integer getActualTotalPages() {
        return actualTotalPages;
    }

    public void setActualTotalPages(Integer actualTotalPages) {
        this.actualTotalPages = actualTotalPages;
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
        private String isexport;
        private String showName;
        private String name;
        private String logoLarge;
        private String logoMiddle;
        private String logoSmall;

        public String getIsexport() {
            return isexport;
        }

        public void setIsexport(String isexport) {
            this.isexport = isexport;
        }

        public String getShowName() {
            return showName;
        }

        public void setShowName(String showName) {
            this.showName = showName;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getLogoLarge() {
            return logoLarge;
        }

        public void setLogoLarge(String logoLarge) {
            this.logoLarge = logoLarge;
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
    }

    public static class ExtraBean {
        private Integer sourceId;

        public Integer getSourceId() {
            return sourceId;
        }

        public void setSourceId(Integer sourceId) {
            this.sourceId = sourceId;
        }
    }

    public static class ContentBean {
        private String section;
        private String audiobook;
        private String type;
        private ExtraBean extra;
        private String subTitle;
        private String state;
        private String updatetime;
        private String chatdesc;
        private String imageUrl;
        private String aacUrl;
        private String desc;
        private String sectionAmount;
        private String author;
        private String linkUrl;
        private String source;
        private String title;
        private Integer albumId;

        public String getSection() {
            return section;
        }

        public void setSection(String section) {
            this.section = section;
        }

        public String getAudiobook() {
            return audiobook;
        }

        public void setAudiobook(String audiobook) {
            this.audiobook = audiobook;
        }

        public String getType() {
            return type;
        }

        public void setType(String type) {
            this.type = type;
        }

        public ExtraBean getExtra() {
            return extra;
        }

        public void setExtra(ExtraBean extra) {
            this.extra = extra;
        }

        public String getSubTitle() {
            return subTitle;
        }

        public void setSubTitle(String subTitle) {
            this.subTitle = subTitle;
        }

        public String getState() {
            return state;
        }

        public void setState(String state) {
            this.state = state;
        }

        public String getUpdatetime() {
            return updatetime;
        }

        public void setUpdatetime(String updatetime) {
            this.updatetime = updatetime;
        }

        public String getChatdesc() {
            return chatdesc;
        }

        public void setChatdesc(String chatdesc) {
            this.chatdesc = chatdesc;
        }

        public String getImageUrl() {
            return imageUrl;
        }

        public void setImageUrl(String imageUrl) {
            this.imageUrl = imageUrl;
        }

        public String getAacUrl() {
            return aacUrl;
        }

        public void setAacUrl(String aacUrl) {
            this.aacUrl = aacUrl;
        }

        public String getDesc() {
            return desc;
        }

        public void setDesc(String desc) {
            this.desc = desc;
        }

        public String getSectionAmount() {
            return sectionAmount;
        }

        public void setSectionAmount(String sectionAmount) {
            this.sectionAmount = sectionAmount;
        }

        public String getAuthor() {
            return author;
        }

        public void setAuthor(String author) {
            this.author = author;
        }

        public String getLinkUrl() {
            return linkUrl;
        }

        public void setLinkUrl(String linkUrl) {
            this.linkUrl = linkUrl;
        }

        public String getSource() {
            return source;
        }

        public void setSource(String source) {
            this.source = source;
        }

        public String getTitle() {
            return title;
        }

        public void setTitle(String title) {
            this.title = title;
        }

        public Integer getAlbumId() {
            return albumId;
        }

        public void setAlbumId(Integer albumId) {
            this.albumId = albumId;
        }

        public static class ExtraBean {
            private String source;
            private String resType;

            public String getSource() {
                return source;
            }

            public void setSource(String source) {
                this.source = source;
            }

            public String getResType() {
                return resType;
            }

            public void setResType(String resType) {
                this.resType = resType;
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
}
