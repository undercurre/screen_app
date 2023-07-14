package com.midea.homlux.ai.bean;

import java.util.List;

public class GuShiBean {
    private ExtraBean extra;
    private String type;
    private Integer count;
    private Integer resume;
    private Integer currentPage;
    private Integer match;
    private Integer totalPages;
    private String dataSource;
    private String name;
    private Integer actualTotalPages;
    private String errorcode;
    private String widgetName;
    private List<SegmentBean> segment;
    private String duiWidget;
    private Integer lastCurrentPage;
    private List<ContentBean> content;
    private Integer itemsPerPage;
    private String intentName;
    private String skillId;
    private String skillName;
    private String taskName;

    public ExtraBean getExtra() {
        return extra;
    }

    public void setExtra(ExtraBean extra) {
        this.extra = extra;
    }

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

    public Integer getResume() {
        return resume;
    }

    public void setResume(Integer resume) {
        this.resume = resume;
    }

    public Integer getCurrentPage() {
        return currentPage;
    }

    public void setCurrentPage(Integer currentPage) {
        this.currentPage = currentPage;
    }

    public Integer getMatch() {
        return match;
    }

    public void setMatch(Integer match) {
        this.match = match;
    }

    public Integer getTotalPages() {
        return totalPages;
    }

    public void setTotalPages(Integer totalPages) {
        this.totalPages = totalPages;
    }

    public String getDataSource() {
        return dataSource;
    }

    public void setDataSource(String dataSource) {
        this.dataSource = dataSource;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Integer getActualTotalPages() {
        return actualTotalPages;
    }

    public void setActualTotalPages(Integer actualTotalPages) {
        this.actualTotalPages = actualTotalPages;
    }

    public String getErrorcode() {
        return errorcode;
    }

    public void setErrorcode(String errorcode) {
        this.errorcode = errorcode;
    }

    public String getWidgetName() {
        return widgetName;
    }

    public void setWidgetName(String widgetName) {
        this.widgetName = widgetName;
    }

    public List<SegmentBean> getSegment() {
        return segment;
    }

    public void setSegment(List<SegmentBean> segment) {
        this.segment = segment;
    }

    public String getDuiWidget() {
        return duiWidget;
    }

    public void setDuiWidget(String duiWidget) {
        this.duiWidget = duiWidget;
    }

    public Integer getLastCurrentPage() {
        return lastCurrentPage;
    }

    public void setLastCurrentPage(Integer lastCurrentPage) {
        this.lastCurrentPage = lastCurrentPage;
    }

    public List<ContentBean> getContent() {
        return content;
    }

    public void setContent(List<ContentBean> content) {
        this.content = content;
    }

    public Integer getItemsPerPage() {
        return itemsPerPage;
    }

    public void setItemsPerPage(Integer itemsPerPage) {
        this.itemsPerPage = itemsPerPage;
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
        private String imageUrl;
        private ExtraBean extra;
        private String sourcename;
        private String albumId;
        private String title;
        private String linkUrl;
        private String trackId;
        private String subTitle;
        private String album;
        private String tags;
        private String imageUrlLarge;

        public String getImageUrl() {
            return imageUrl;
        }

        public void setImageUrl(String imageUrl) {
            this.imageUrl = imageUrl;
        }

        public ExtraBean getExtra() {
            return extra;
        }

        public void setExtra(ExtraBean extra) {
            this.extra = extra;
        }

        public String getSourcename() {
            return sourcename;
        }

        public void setSourcename(String sourcename) {
            this.sourcename = sourcename;
        }

        public String getAlbumId() {
            return albumId;
        }

        public void setAlbumId(String albumId) {
            this.albumId = albumId;
        }

        public String getTitle() {
            return title;
        }

        public void setTitle(String title) {
            this.title = title;
        }

        public String getLinkUrl() {
            return linkUrl;
        }

        public void setLinkUrl(String linkUrl) {
            this.linkUrl = linkUrl;
        }

        public String getTrackId() {
            return trackId;
        }

        public void setTrackId(String trackId) {
            this.trackId = trackId;
        }

        public String getSubTitle() {
            return subTitle;
        }

        public void setSubTitle(String subTitle) {
            this.subTitle = subTitle;
        }

        public String getAlbum() {
            return album;
        }

        public void setAlbum(String album) {
            this.album = album;
        }

        public String getTags() {
            return tags;
        }

        public void setTags(String tags) {
            this.tags = tags;
        }

        public String getImageUrlLarge() {
            return imageUrlLarge;
        }

        public void setImageUrlLarge(String imageUrlLarge) {
            this.imageUrlLarge = imageUrlLarge;
        }

        public static class ExtraBean {
            private String source;
            private String resType;
            private String mediaCategory;

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

            public String getMediaCategory() {
                return mediaCategory;
            }

            public void setMediaCategory(String mediaCategory) {
                this.mediaCategory = mediaCategory;
            }
        }
    }
}
