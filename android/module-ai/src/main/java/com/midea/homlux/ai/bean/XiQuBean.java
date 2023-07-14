package com.midea.homlux.ai.bean;

import java.util.List;

public class XiQuBean {
    private String duiWidget;
    private Integer itemsPerPage;
    private List<SegmentBean> segment;
    private Integer totalPages;
    private ExtraBean extra;
    private List<ContentBean> content;
    private Integer match;
    private Integer currentPage;
    private String type;
    private String name;
    private String widgetName;
    private BrandBean brand;
    private Integer actualTotalPages;
    private Integer lastCurrentPage;
    private String dataSource;
    private String errorcode;
    private Integer count;
    private String intentName;
    private String skillId;
    private String skillName;
    private String taskName;

    public String getDuiWidget() {
        return duiWidget;
    }

    public void setDuiWidget(String duiWidget) {
        this.duiWidget = duiWidget;
    }

    public Integer getItemsPerPage() {
        return itemsPerPage;
    }

    public void setItemsPerPage(Integer itemsPerPage) {
        this.itemsPerPage = itemsPerPage;
    }

    public List<SegmentBean> getSegment() {
        return segment;
    }

    public void setSegment(List<SegmentBean> segment) {
        this.segment = segment;
    }

    public Integer getTotalPages() {
        return totalPages;
    }

    public void setTotalPages(Integer totalPages) {
        this.totalPages = totalPages;
    }

    public ExtraBean getExtra() {
        return extra;
    }

    public void setExtra(ExtraBean extra) {
        this.extra = extra;
    }

    public List<ContentBean> getContent() {
        return content;
    }

    public void setContent(List<ContentBean> content) {
        this.content = content;
    }

    public Integer getMatch() {
        return match;
    }

    public void setMatch(Integer match) {
        this.match = match;
    }

    public Integer getCurrentPage() {
        return currentPage;
    }

    public void setCurrentPage(Integer currentPage) {
        this.currentPage = currentPage;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getWidgetName() {
        return widgetName;
    }

    public void setWidgetName(String widgetName) {
        this.widgetName = widgetName;
    }

    public BrandBean getBrand() {
        return brand;
    }

    public void setBrand(BrandBean brand) {
        this.brand = brand;
    }

    public Integer getActualTotalPages() {
        return actualTotalPages;
    }

    public void setActualTotalPages(Integer actualTotalPages) {
        this.actualTotalPages = actualTotalPages;
    }

    public Integer getLastCurrentPage() {
        return lastCurrentPage;
    }

    public void setLastCurrentPage(Integer lastCurrentPage) {
        this.lastCurrentPage = lastCurrentPage;
    }

    public String getDataSource() {
        return dataSource;
    }

    public void setDataSource(String dataSource) {
        this.dataSource = dataSource;
    }

    public String getErrorcode() {
        return errorcode;
    }

    public void setErrorcode(String errorcode) {
        this.errorcode = errorcode;
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

    public static class ExtraBean {
        private Integer sourceId;

        public Integer getSourceId() {
            return sourceId;
        }

        public void setSourceId(Integer sourceId) {
            this.sourceId = sourceId;
        }
    }

    public static class BrandBean {
        private String logoMiddle;
        private String logoSmall;
        private String name;
        private String showName;
        private String logoLarge;
        private String isexport;

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

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
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

        public String getIsexport() {
            return isexport;
        }

        public void setIsexport(String isexport) {
            this.isexport = isexport;
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
        private Integer albumId;
        private String title;
        private String artist;
        private String imageUrl;
        private String linkUrl;
        private ExtraBean extra;
        private String tag;
        private String drama_type;
        private String resType;
        private Integer episode;
        private String subTitle;

        public Integer getAlbumId() {
            return albumId;
        }

        public void setAlbumId(Integer albumId) {
            this.albumId = albumId;
        }

        public String getTitle() {
            return title;
        }

        public void setTitle(String title) {
            this.title = title;
        }

        public String getArtist() {
            return artist;
        }

        public void setArtist(String artist) {
            this.artist = artist;
        }

        public String getImageUrl() {
            return imageUrl;
        }

        public void setImageUrl(String imageUrl) {
            this.imageUrl = imageUrl;
        }

        public String getLinkUrl() {
            return linkUrl;
        }

        public void setLinkUrl(String linkUrl) {
            this.linkUrl = linkUrl;
        }

        public ExtraBean getExtra() {
            return extra;
        }

        public void setExtra(ExtraBean extra) {
            this.extra = extra;
        }

        public String getTag() {
            return tag;
        }

        public void setTag(String tag) {
            this.tag = tag;
        }

        public String getDrama_type() {
            return drama_type;
        }

        public void setDrama_type(String drama_type) {
            this.drama_type = drama_type;
        }

        public String getResType() {
            return resType;
        }

        public void setResType(String resType) {
            this.resType = resType;
        }

        public Integer getEpisode() {
            return episode;
        }

        public void setEpisode(Integer episode) {
            this.episode = episode;
        }

        public String getSubTitle() {
            return subTitle;
        }

        public void setSubTitle(String subTitle) {
            this.subTitle = subTitle;
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
