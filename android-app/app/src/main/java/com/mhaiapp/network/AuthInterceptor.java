package com.mhaiapp.network;

import java.io.IOException;

import com.mhaiapp.utils.SharedPrefsManager;

import okhttp3.Interceptor;
import okhttp3.Request;
import okhttp3.Response;

public class AuthInterceptor implements Interceptor {
    private final SharedPrefsManager prefs;
    private final ApiService apiService;
    private final Object refreshLock = new Object();
    private volatile boolean isRefreshing = false;

    public AuthInterceptor(SharedPrefsManager prefs, String baseUrl) {
        this.prefs = prefs;
        this.apiService = ApiClient.getClient(baseUrl).create(ApiService.class);
    }

    @Override
    public Response intercept(Chain chain) throws IOException {
        Request original = chain.request();

        // Don't add auth header for auth endpoints
        String url = original.url().toString();
        String access = prefs.getAccessToken();
        Request request = original;
        if (access != null && !url.contains("/api/auth/")) {
            request = original.newBuilder().header("Authorization", "Bearer " + access).build();
        }

        Response response = chain.proceed(request);
        if (response.code() != 401) {
            return response;
        }

        // Close the 401 response before retrying
        response.close();

        // synchronized refresh logic
        synchronized (refreshLock) {
            if (!isRefreshing) {
                isRefreshing = true;
                try {
                    String refreshToken = prefs.getRefreshToken();
                    if (refreshToken == null) {
                        // nothing to do - clear and return original 401
                        prefs.clear();
                        return chain.proceed(original);
                    }

                    try {
                        java.util.Map<String, String> payload = new java.util.HashMap<>();
                        payload.put("old_refresh_token", refreshToken);
                        retrofit2.Response<com.mhaiapp.models.AuthResponse> rf = apiService.refresh(payload).execute();
                        if (rf.isSuccessful() && rf.body() != null) {
                            String newAccess = rf.body().access_token;
                            // attempt to read refresh_token field if provided
                            try {
                                java.lang.reflect.Field f = rf.body().getClass().getField("refresh_token");
                                Object rv = f.get(rf.body());
                                if (rv != null) prefs.saveRefreshToken(rv.toString());
                            } catch (Exception ignored) {}
                            prefs.saveAccessToken(newAccess);
                        } else {
                            // refresh failed - clear stored tokens
                            prefs.clear();
                            return chain.proceed(original);
                        }
                    } catch (Exception e) {
                        prefs.clear();
                        return chain.proceed(original);
                    }
                } finally {
                    isRefreshing = false;
                    refreshLock.notifyAll();
                }
            } else {
                // Wait for ongoing refresh to complete
                try {
                    while (isRefreshing) {
                        refreshLock.wait();
                    }
                } catch (InterruptedException ignored) {
                }
            }
        }

        // Retry original request with updated token
        String updated = prefs.getAccessToken();
        Request newReq = original;
        if (updated != null && !original.url().toString().contains("/api/auth/")) {
            newReq = original.newBuilder().header("Authorization", "Bearer " + updated).build();
        }
        return chain.proceed(newReq);
    }
}
