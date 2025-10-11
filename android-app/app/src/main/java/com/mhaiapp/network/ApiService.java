package com.mhaiapp.network;

import com.mhaiapp.models.AuthResponse;
import com.mhaiapp.models.AuthRequest;
import com.mhaiapp.models.MoodEntry;
import com.mhaiapp.models.MoodRequest;


import java.util.List;
import java.util.Map;


import retrofit2.Call;
import retrofit2.http.Body;
import retrofit2.http.GET;
import retrofit2.http.Header;
import retrofit2.http.POST;

public interface ApiService {
    @POST("api/auth/signup")
    Call<AuthResponse> signup(@Body AuthRequest request);

    @POST("api/auth/login")
    Call<AuthResponse> login(@Body AuthRequest request);

    @POST("api/auth/refresh")
    Call<AuthResponse> refresh(@Body java.util.Map<String, String> payload);

    @GET("api/moods")
    Call<List<MoodEntry>> getMoods(@Header("Authorization") String token);


    @POST("api/moods")

    Call<MoodEntry> createMood(@Header("Authorization") String token, @Body MoodRequest request);


    @POST("api/auth/otp/request")
    Call<Map<String, Object>> requestOtp(@Body Map<String, String> payload);

    @POST("api/auth/verify-otp")
    Call<AuthResponse> verifyOtp(@Body Map<String, String> payload);
}
