package com.mhaiapp.network;

import java.io.IOException;

import com.mhaiapp.utils.SharedPrefsManager;

import okhttp3.Interceptor;
import okhttp3.Request;
import okhttp3.Response;

public class AuthInterceptor implements Interceptor {
    private SharedPrefsManager prefs;
    private ApiService apiService;
    private String baseUrl;

    public AuthInterceptor(SharedPrefsManager prefs, String baseUrl) {
        this.prefs = prefs;
        this.baseUrl = baseUrl;
        this.apiService = ApiClient.getClient(baseUrl).create(ApiService.class);
    }

    @Override
    public Response intercept(Chain chain) throws IOException {
        Request req = chain.request();
        String token = prefs.getToken();
        Request.Builder builder = req.newBuilder();
        if (token != null && !req.url().toString().contains("/api/auth/")) {
            builder.addHeader("Authorization", "Bearer " + token);
        }
        Request request = builder.build();
        Response response = chain.proceed(request);

        if (response.code() == 401) {
            // Attempt silent refresh (synchronous) - simplistic approach
            String refreshToken = prefs.getToken(); // placeholder: in real app store refresh separately
            if (refreshToken != null) {
                try {
                    java.util.Map<String, String> payload = new java.util.HashMap<>();
                    payload.put("old_refresh_token", refreshToken);
                    retrofit2.Response<com.mhaiapp.models.AuthResponse> rf = apiService.refresh(payload).execute();
                    if (rf.isSuccessful() && rf.body() != null) {
                        String newAccess = rf.body().access_token;
                        prefs.saveToken(newAccess);
                        Request newReq = req.newBuilder().header("Authorization", "Bearer " + newAccess).build();
                        response.close();
                        return chain.proceed(newReq);
                    }
                } catch (Exception e) {
                    // ignore and forward original response
                }
            }
        }

        return response;
    }
}
