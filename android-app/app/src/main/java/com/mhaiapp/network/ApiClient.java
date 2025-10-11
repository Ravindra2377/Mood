package com.mhaiapp.network;


import retrofit2.Retrofit;

import retrofit2.converter.gson.GsonConverterFactory;

import okhttp3.OkHttpClient;

import okhttp3.logging.HttpLoggingInterceptor;
import android.content.Context;
import com.mhaiapp.network.AuthInterceptor;
import com.mhaiapp.utils.SharedPrefsManager;


public class ApiClient {
    private static Retrofit retrofit = null;

    public static Retrofit getClient(String baseUrl) {
        if (retrofit == null) {
            HttpLoggingInterceptor logging = new HttpLoggingInterceptor();
            logging.setLevel(HttpLoggingInterceptor.Level.BODY);


            Context appCtx = null;
            try {
                Class<?> at = Class.forName("android.app.ActivityThread");
                Object thread = at.getMethod("currentActivityThread").invoke(null);
                Object app = at.getMethod("getApplication").invoke(thread);
                appCtx = (Context) app;
            } catch (Exception ignored) {}

            OkHttpClient.Builder builder = new OkHttpClient.Builder()

                    .addInterceptor(logging);


            if (appCtx != null) {
                builder.addInterceptor(new AuthInterceptor(SharedPrefsManager.getInstance(appCtx), baseUrl));
            }

            OkHttpClient client = builder.build();


            retrofit = new Retrofit.Builder()
                    .baseUrl(baseUrl)
                    .addConverterFactory(GsonConverterFactory.create())
                    .client(client)
                    .build();
        }
        return retrofit;
    }
}
