package com.midea.light.common.utils;


import android.text.TextUtils;
import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.JsonSyntaxException;
import com.google.gson.reflect.TypeToken;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


/**
 * gson 解析工具
 * @author Elan 15.3.31 
 */
public class GsonUtils {


	public static Gson gson = new Gson();

	public static <T> T deSerializedFromJson(String json, Class<T> clazz) throws JsonSyntaxException {
		return gson.fromJson(json, clazz);
	}

	public static <T> T deSerializedFromJson(String json, Type type)throws JsonSyntaxException {
		return gson.fromJson(json, type);
	}

	public static String serializedToJson(Object object) {
		if(object!=null){
			return gson.toJson(object);
		}else{
			return "";
		}
	}


	/**
	 * 获取JsonObject
	 * @return JsonObject
	 */
	public static JsonObject parseJson(String json){
		JsonObject jsonObj = null;
		try {
			JsonParser parser = new JsonParser();
			jsonObj = parser.parse(json).getAsJsonObject();
		} catch (JsonSyntaxException e) {
			Log.e("frank","parseJson Exception==="+e.toString());
		}
		return jsonObj;
	}

	/**
	 * json字符串转成Bean对象
	 * @param str
	 * @param type
	 * @return
	 */
	public static <T> T jsonToBean(String str, Class<T> type) {
		Gson gson = new Gson();
		try {
			T t = gson.fromJson(str, type);
			return t;
		} catch (JsonSyntaxException e) {
			Log.e("frank","jsonToBean Exception==="+e.toString());

		}
		return null;
	}

	public static JSONObject fromString(String json){
		JSONObject jsonObject =null;
		try {
			jsonObject = new JSONObject(json);
		} catch (JSONException e) {
			e.printStackTrace();
			Log.e("frank","fromString Exception==="+e.toString());
		}
		return jsonObject;

	}

	public static String getStringFromJSON(String json, String key1, String key2){
		String data = "";
		try {
			JSONObject jsonObject = new JSONObject(json).getJSONObject(key1);
			data = jsonObject.getString(key2);

		} catch (JSONException e) {
			e.printStackTrace();
			Log.e("frank","getStringFromJSON Exception==="+e.toString());
		}
		return data;
	}



	public static long getLongFormJSON(String json, String key1, String key2){
		long data = 0;
		try {
			JSONObject jsonObject = new JSONObject(json).getJSONObject(key1);
			data = jsonObject.getLong(key2);

		} catch (JSONException e) {
			Log.e("frank","getLongFormJSON Exception==="+e.toString());
		}
		return data;
	}

	/**
	 * @param json
	 * @param key1
	 * @return
	 */
	// 现有逻辑有问题 ：更新包判断
	public static boolean getBooleanFormJSON(String json, String key1){
		boolean data = true;
		try {
			JSONObject jsonObject = new JSONObject(json);
			data = jsonObject.getBoolean(key1);
		} catch (JSONException e) {
			Log.e("frank","getBooleanFormJSON Exception==="+e.toString());
		}
		return data;
	}


	/**
	 * 从JSON字符串提取出对应 Key的 字符串
	 * @param json
	 * @param key
	 * @return
	 */
	public static String getStringFromJSON(String json, String key){
		String data = null;
		try {
			JSONObject jsonObject = new JSONObject(json);
			data = jsonObject.getString(key);
		} catch (JSONException e) {
			Log.e("frank","getStringFromJSON Exception==="+e.toString());
		}
		return data;
	}




	/**
	 * 获得网络请求状态  1 成功  0 不成功
	 * @param json
	 * @return
	 */
	public static int getStatusFromJSON(String json){
		int status = 0;
		try {
			JSONObject jsonObject = new JSONObject(json);
			status = jsonObject.getInt("status");
		} catch (JSONException e) {

		}
		return status;
	}


	/**
	 * 获得网络请求状态  1 注册过  0 未注册
	 * @param json
	 * @return
	 */
	public static int getIsRegisterJSON(String json){
		int status = 0;
		try {
			JSONObject jsonObject = new JSONObject(json);
			status = jsonObject.getInt("is_register");
		} catch (JSONException e) {

		}
		return status;
	}

	/**
	 * 获得网络请求message
	 * @param json
	 * @return
	 */
	public static String getMessageFromJSON(String json){
		String message=null;
		try {
			JSONObject jsonObject = new JSONObject(json);
			message = jsonObject.getString("message");
		} catch (JSONException e) {

		}
		return message;
	}



	public static int getErrorCodeFromJSON(String json){
		int status = 0;
		try {
			JSONObject jsonObject = new JSONObject(json);
			status = jsonObject.getInt("error_code");
		} catch (JSONException e) {
			Log.e("frank","getErrorCodeFromJSON Exception==="+e.toString());
		}
		return status;
	}

	public static int getCodeFromJSON(String json){
		int status = 0;
		try {
			JSONObject jsonObject = new JSONObject(json);
			status = jsonObject.getInt("code");
		} catch (JSONException e) {
			Log.e("frank","getCodeFromJSON Exception==="+e.toString());
		}
		return status;
	}

	public static String getErrorStringFromJSON(String json){
		String err_str="";
		try {
			JSONObject jsonObject = new JSONObject(json);
			err_str = jsonObject.getString("error");
		} catch (JSONException e) {
			Log.e("frank","getErrorStringFromJSON Exception==="+e.toString());
		}
		return err_str;
	}



	/**
	 * 从json, data 段 中返回long
	 * @return
	 */
	public static long getLongFromJsonData(String json, String key){
		long value = 0;
		try {
			JSONObject jsonObject = new JSONObject(json).getJSONObject("data");
			value = jsonObject.getLong(key);
		} catch (JSONException e) {
			Log.e("frank","getLongFromJsonData Exception==="+e.toString());
		}
		return value;
	}


	/**
	 * 从json, data 段 中返回int
	 * @return
	 */
	public static int getIntFromJsonData(String json, String key){
		int value = 0;
		try {
			JSONObject jsonObject = new JSONObject(json).getJSONObject("data");
			value = jsonObject.getInt(key);
		} catch (JSONException e) {
			Log.e("frank","getIntFromJsonData Exception==="+e.toString());
		}
		return value;
	}

	/**
	 * 从json, key 段 String
	 * @return
	 */
	public static String getStringFromJsonData(String json, String key){
		String value = "";
		try {
			JSONObject jsonObject = new JSONObject(json);
			value = jsonObject.getString(key);
		} catch (JSONException e) {
			Log.e("frank","getStringFromJsonData Exception=== key="+key+" == " +e.toString());
		}
		return value;
	}


	public static int getIntFromJSON(JSONObject obj, String key){
		int data = 0;
		try {
			if (obj==null) {
				return data;
			}
			data = obj.getInt(key);
		} catch (JSONException e) {
			Log.e("frank","getIntFromJSON Exception==="+e.toString());
		}
		return data;
	}


	public static int getIntFromJSON(String json, String key){
		int data = 0;
		try {
			JSONObject jsonObject = new JSONObject(json);
			data = jsonObject.getInt(key);
		} catch (JSONException e) {
			Log.e("frank","getIntFromJSON Exception==="+e.toString());
		}
		return data;
	}

	public static int getIntFromJSON(String json, String key1, String key2){
		int data = 0;
		try {
			JSONObject jsonObject = new JSONObject(json);
			String dataJson = jsonObject.getString(key1);
			data = getIntFromJSON(dataJson, key2);
		} catch (JSONException e) {
			Log.e("frank","getIntFromJSON Exception==="+e.toString());
		}
		return data;
	}

	public static long getLongFromJSON(String json, String key){
		long data = 0;
		try {
			JSONObject jsonObject = new JSONObject(json);
			data = jsonObject.getLong(key);
		} catch (JSONException e) {
			Log.e("frank","getLongFromJSON Exception==="+e.toString());
		}
		return data;
	}

	public static long getLongFromJSON(String json, String key1, String key2){
		long data = 0;
		try {
			JSONObject jsonObject = new JSONObject(json);
			String dataJson = jsonObject.getString(key1);
			data = getLongFromJSON(dataJson, key2);
		} catch (JSONException e) {
			Log.e("frank","getLongFromJSON Exception==="+e.toString());
		}
		return data;
	}


	/**
	 * 3.0
	 * 从key里解析出对象数组
	 *
	 * @param json
	 * @param key
	 * @return  list<T>  数据异常返回  list (size is 0)
	 */
	public static <T> List<T> jsonToBeanList(String json, String key, Class<T> type) {
		String data = getStringFromJSON(json, key);
		if (data == null|| TextUtils.isEmpty(data)){ // json data 字段为空
            return new ArrayList<>();
		}else { //json data 字段不为空
        	try {
				List<T> lst =  new ArrayList<>();
				JsonArray array = new JsonParser().parse(data).getAsJsonArray();
				for(final JsonElement elem : array){
					lst.add(gson.fromJson(elem, type));
				}
			if (lst!=null){
				return lst;
			}
			} catch (JsonSyntaxException e) {
				Log.e("frank","jsonToBeanList Exception==="+e.toString());
			}
		}
		return new ArrayList<>();
	}

	public static Map<String, String> jsonToBeanMapFromData(String json){
		Map<String, String> map;
		String data = getStringFromJSON(json, "data");
		if (data == null|| TextUtils.isEmpty(data)){ // json data 字段为空
			return new HashMap<String, String>();
		}else { //json data 字段不为空
			map = gson.fromJson(data,new TypeToken<Map<String, String>>() {}.getType());
			if (map!=null){
				return map;
			}
		}
		return new HashMap<String, String>();
	}
	public static Map<String, String> jsonToBeanMap(String json){
		Map<String, String> map;
		if (json == null|| TextUtils.isEmpty(json)){
			return new HashMap<String, String>();
		}else { //json data 字段不为空
			map = gson.fromJson(json,new TypeToken<Map<String, String>>() {}.getType());
			if (map!=null){
				return map;
			}
		}
		return new HashMap<String, String>();
	}

	public static Map<String, List<String>> jsonToBeanMap_2(String json){
		Map<String, List<String>> map;
		String data = getStringFromJSON(json, "data");
		if (data == null|| TextUtils.isEmpty(data)){ // json data 字段为空
			return new HashMap<String, List<String>>();
		}else { //json data 字段不为空
			map = gson.fromJson(data,new TypeToken<Map<String, List<String>>>() {}.getType());
			if (map!=null){
				return map;
			}
		}
		return new HashMap<String, List<String>>();
	}


	/**
	 * 3.0
	 * 从data里解析出对象数组  key1 一般为 : data  key2 ： your key
	 *
	 * @param json
	 * @param tClass
	 * @return  list<T>  数据异常返回  list (size is 0)
	 */
	public static <T> List<T> jsonToBeanList(String json, String key1, String key2, Type tClass) {
		List<T> list;
		String data = getStringFromJSON(json, key1, key2);
		if (data == null|| TextUtils.isEmpty(data)){ // json data 字段为空
			return new ArrayList<>();
		}else { //json data 字段不为空
			try {
				list = gson.fromJson(data, tClass);
				if (list!=null){
					return list;
				}
			} catch (JsonSyntaxException je) {
				Log.e("frank","jsonToBeanList Exception==="+je.toString());
			}
		}
		return new ArrayList<>();
	}

	public static <T> List<T> getBeanListFromJSONString(String jsonString,
                                                        String key1, String key2, Type tClass) {
		List<T> list;
		if (jsonString == null || TextUtils.isEmpty(jsonString)) {
			return new ArrayList<T>();
		} else {
			try {
				JSONArray jsonArray = new JSONObject(jsonString).getJSONObject(
						key1).getJSONArray(key2);
				list = gson.fromJson(jsonArray.toString(), tClass);
				if (list != null) {
					return list;
				}
			} catch (JSONException e) {
				Log.e("frank","getBeanListFromJSONString Exception==="+e.toString());
			}
		}
		return new ArrayList<T>();
	}

	/**
	 * 3.1
	 * 从data里解析出对象
	 *
	 * @param json
	 * @param modelClass
	 * @return  T  数据异常返回 空
	 */
	public static <T> T getModelFromJson(String json, Class modelClass){
		return getBeanFromJSONString(getStringFromJSON(json,"data"),modelClass);
	}




	public static <T> T getBeanFromJSONString(String json, Type tClass) {
		try {
			return gson.fromJson(json, tClass);
		} catch (Exception e) {
			e.printStackTrace();
			Log.e("frank","getBeanFromJSONString Exception==="+e.toString());
		}
		return null;
	}

	public static String getStringFromJSON(JSONObject json, String key) {
		String data=null;
		try {
			if (json==null) {
				return data;
			}
			data = json.getString(key);
		} catch (JSONException e) {
			Log.e("frank","getStringFromJSON Exception==="+e.toString());
			e.printStackTrace();
		}
		return data;
	}

}
