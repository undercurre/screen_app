package com.midea.light.ai.music;

import com.midea.light.ai.MideaLightMusicInfo;

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
         private ArrayList<MideaLightMusicInfo> listItems=new ArrayList<>();

         public ArrayList<MideaLightMusicInfo> getListItems() {
            return listItems;
         }

         public void setListItems(ArrayList<MideaLightMusicInfo> listItems) {
            this.listItems = listItems;
         }

      }
   }
}
