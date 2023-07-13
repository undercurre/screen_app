package com.midea.homlux.ai.music;

import java.util.ArrayList;

public class MusicBean {
   private String skillId;
   private String responseType;
   private DataBean data;

   public String getSkillId() {
      return skillId;
   }

   public void setSkillId(String skillId) {
      this.skillId = skillId;
   }

   public String getResponseType() {
      return responseType;
   }

   public void setResponseType(String responseType) {
      this.responseType = responseType;
   }

   public DataBean getData() {
      return data;
   }

   public void setData(DataBean data) {
      this.data = data;
   }

   public static class DataBean {
      private GeneralSkillBean generalSkill;

      public GeneralSkillBean getGeneralSkill() {
         return generalSkill;
      }

      public void setGeneralSkill(GeneralSkillBean generalSkill) {
         this.generalSkill = generalSkill;
      }

      public static class GeneralSkillBean {
         private ArrayList<MusicInfo> listItems=new ArrayList<>();

         public ArrayList<MusicInfo> getListItems() {
            return listItems;
         }

         public void setListItems(ArrayList<MusicInfo> listItems) {
            this.listItems = listItems;
         }

      }
   }
}
