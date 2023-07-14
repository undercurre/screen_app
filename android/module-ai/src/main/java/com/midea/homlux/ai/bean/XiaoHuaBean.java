package com.midea.homlux.ai.bean;

import java.util.List;

public class XiaoHuaBean {
    private Integer totalPages;
    private String type;
    private String name;
    private Integer actualTotalPages;
    private Integer count;
    private String widgetName;
    private String duiWidget;
    private String dataSource;
    private Integer itemsPerPage;
    private List<ContentBean> content;
    private List<SegmentBean> segment;
    private Integer currentPage;
    private Integer lastCurrentPage;
    private String intentName;
    private String skillId;
    private String skillName;
    private String taskName;

    public Integer getTotalPages() {
        return totalPages;
    }

    public void setTotalPages(Integer totalPages) {
        this.totalPages = totalPages;
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

    public Integer getActualTotalPages() {
        return actualTotalPages;
    }

    public void setActualTotalPages(Integer actualTotalPages) {
        this.actualTotalPages = actualTotalPages;
    }

    public Integer getCount() {
        return count;
    }

    public void setCount(Integer count) {
        this.count = count;
    }

    public String getWidgetName() {
        return widgetName;
    }

    public void setWidgetName(String widgetName) {
        this.widgetName = widgetName;
    }

    public String getDuiWidget() {
        return duiWidget;
    }

    public void setDuiWidget(String duiWidget) {
        this.duiWidget = duiWidget;
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

    public List<ContentBean> getContent() {
        return content;
    }

    public void setContent(List<ContentBean> content) {
        this.content = content;
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

    public Integer getLastCurrentPage() {
        return lastCurrentPage;
    }

    public void setLastCurrentPage(Integer lastCurrentPage) {
        this.lastCurrentPage = lastCurrentPage;
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

    public static class ContentBean {
        private ParametersBean parameters;
        private String imageUrl;
        private String title;
        private String linkUrl;

        public ParametersBean getParameters() {
            return parameters;
        }

        public void setParameters(ParametersBean parameters) {
            this.parameters = parameters;
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

        public String getLinkUrl() {
            return linkUrl;
        }

        public void setLinkUrl(String linkUrl) {
            this.linkUrl = linkUrl;
        }

        public static class ParametersBean {
            private String resType;

            public String getResType() {
                return resType;
            }

            public void setResType(String resType) {
                this.resType = resType;
            }
        }
    }

    public static class SegmentBean {
        private String name;
        private String pinyin;

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getPinyin() {
            return pinyin;
        }

        public void setPinyin(String pinyin) {
            this.pinyin = pinyin;
        }
    }
}
