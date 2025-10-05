package com.mhaiapp.repositories;

import android.content.Context;

import com.mhaiapp.models.AuthRequest;
import com.mhaiapp.models.AuthResponse;
import com.mhaiapp.network.ApiClient;
import com.mhaiapp.network.ApiService;
import com.mhaiapp.utils.SharedPrefsManager;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

public class AuthRepository {
    private ApiService apiService;
    private SharedPrefsManager prefs;

    public AuthRepository(Context ctx, String baseUrl) {
        apiService = ApiClient.getClient(baseUrl).create(ApiService.class);
        prefs = new SharedPrefsManager(ctx);
    }

    public void login(String email, String password, final AuthCallback cb) {
        AuthRequest req = new AuthRequest(email, password);
        apiService.login(req).enqueue(new Callback<AuthResponse>() {
            @Override
            public void onResponse(Call<AuthResponse> call, Response<AuthResponse> response) {
                if (response.isSuccessful() && response.body() != null) {
                    String token = response.body().access_token;
                    String refresh = null;
                    if (response.body().user != null) {
                        // backend returns refresh token in top-level field in some flows
                        try {
                            java.lang.reflect.Field f = response.body().getClass().getField("refresh_token");
                            Object rv = f.get(response.body());
                            if (rv != null) refresh = rv.toString();
                        } catch (Exception e) { /* ignore */ }
                    }
                    prefs.saveAccessToken(token);
                    if (refresh != null) prefs.saveRefreshToken(refresh);
                    cb.onSuccess(response.body());
                } else {
                    cb.onError("Login failed: " + response.code());
                }
            }

            @Override
            public void onFailure(Call<AuthResponse> call, Throwable t) {
                cb.onError(t.getMessage());
            }
        });
    }

    public void signup(String email, String password, final AuthCallback cb) {
        AuthRequest req = new AuthRequest(email, password);
        apiService.signup(req).enqueue(new Callback<AuthResponse>() {
            @Override
            public void onResponse(Call<AuthResponse> call, Response<AuthResponse> response) {
                if (response.isSuccessful() && response.body() != null) {
                    String token = response.body().access_token;
                    String refresh = null;
                    try {
                        java.lang.reflect.Field f = response.body().getClass().getField("refresh_token");
                        Object rv = f.get(response.body());
                        if (rv != null) refresh = rv.toString();
                    } catch (Exception e) { /* ignore */ }
                    prefs.saveAccessToken(token);
                    if (refresh != null) prefs.saveRefreshToken(refresh);
                    cb.onSuccess(response.body());
                } else {
                    cb.onError("Signup failed: " + response.code());
                }
            }

            @Override
            public void onFailure(Call<AuthResponse> call, Throwable t) {
                cb.onError(t.getMessage());
            }
        });
    }

    public interface AuthCallback {
        void onSuccess(AuthResponse resp);
        void onError(String err);
    }

    public void logout() {
        prefs.clear();
    }
}
