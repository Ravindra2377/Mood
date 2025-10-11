package com.mhaiapp.activities;

import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.text.TextUtils;
import android.view.View;
import android.view.inputmethod.EditorInfo;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.mhaiapp.BuildConfig;
import com.mhaiapp.R;
import com.mhaiapp.models.AuthResponse;
import com.mhaiapp.network.ApiClient;
import com.mhaiapp.network.ApiService;
import com.mhaiapp.utils.SharedPrefsManager;

import java.util.HashMap;
import java.util.Map;
import java.util.regex.Pattern;

import retrofit2.Call;
import retrofit2.Callback;
import retrofit2.Response;

/**
 * OtpActivity — Handles phone-based OTP request and verification.
 *
 * Flow:
 * 1) Enter E.164 phone (e.g., +14155550123), tap "Request OTP" → calls /api/auth/otp/request
 *    - In staging (DEV_MODE=true), response may include {"preview_code":"123456"} which we show
 * 2) Enter received code, tap "Verify" → calls /api/auth/verify-otp
 *    - On success, stores access_token and refresh_token, then finishes the activity
 *
 * Notes:
 * - Uses BuildConfig.BASE_URL configured via productFlavors (staging/prod)
 * - Basic 30-second resend cooldown (uses server Retry-After if provided on 429)
 */
public class OtpActivity extends AppCompatActivity {

    private static final Pattern E164 = Pattern.compile("^\\+\\d{8,15}$");
    private static final int DEFAULT_RESEND_COOLDOWN_SEC = 30;

    private EditText phoneInput;
    private EditText otpInput;
    private Button requestBtn;
    private Button verifyBtn;
    private TextView statusText;
    private ProgressBar progress;

    private ApiService api;
    private SharedPrefsManager prefs;

    private final Handler handler = new Handler(Looper.getMainLooper());
    private int cooldownRemaining = 0;
    private final Runnable cooldownTick = new Runnable() {
        @Override
        public void run() {
            if (cooldownRemaining > 0) {
                statusText.setText(String.format("You can request another code in %ds", cooldownRemaining));
                cooldownRemaining--;
                handler.postDelayed(this, 1000);
            } else {
                requestBtn.setEnabled(true);
                statusText.setText("");
            }
        }
    };

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_otp);

        phoneInput = findViewById(R.id.phone);
        otpInput = findViewById(R.id.otp_code);
        requestBtn = findViewById(R.id.btn_request_otp);
        verifyBtn = findViewById(R.id.btn_verify_otp);
        statusText = findViewById(R.id.otp_status);
        progress = findViewById(R.id.otp_progress);

        api = ApiClient.getClient(BuildConfig.BASE_URL).create(ApiService.class);
        prefs = SharedPrefsManager.getInstance(getApplicationContext());

        requestBtn.setOnClickListener(v -> requestOtp());
        verifyBtn.setOnClickListener(v -> verifyOtp());

        otpInput.setOnEditorActionListener((v, actionId, event) -> {
            if (actionId == EditorInfo.IME_ACTION_DONE || actionId == EditorInfo.IME_ACTION_GO) {
                verifyOtp();
                return true;
            }
            return false;
        });
    }

    private void requestOtp() {
        final String phone = phoneInput.getText() != null ? phoneInput.getText().toString().trim() : "";
        if (!isValidE164(phone)) {
            toast("Enter a valid phone in E.164 format (e.g., +14155550123)");
            return;
        }

        setBusy(true);
        requestBtn.setEnabled(false);

        Map<String, String> payload = new HashMap<>();
        payload.put("phone", phone);

        api.requestOtp(payload).enqueue(new Callback<Map<String, Object>>() {
            @Override
            public void onResponse(Call<Map<String, Object>> call, Response<Map<String, Object>> response) {
                setBusy(false);

                if (response.isSuccessful() && response.body() != null) {
                    Map<String, Object> body = response.body();
                    Object status = body.get("status");
                    Object preview = body.get("preview_code");

                    if (preview != null) {
                        statusText.setText("Preview OTP (staging): " + preview.toString());
                    } else if (status != null) {
                        statusText.setText("OTP status: " + status.toString());
                    } else {
                        statusText.setText("OTP requested.");
                    }

                    startCooldown(DEFAULT_RESEND_COOLDOWN_SEC);
                } else {
                    // Handle 429 rate limit with Retry-After if present
                    if (response.code() == 429) {
                        String retryAfter = response.headers().get("Retry-After");
                        int seconds = parseIntOrDefault(retryAfter, DEFAULT_RESEND_COOLDOWN_SEC);
                        statusText.setText("Too many requests. Try again later.");
                        startCooldown(seconds);
                    } else {
                        statusText.setText("Failed to request OTP (HTTP " + response.code() + ")");
                        requestBtn.setEnabled(true);
                    }
                }
            }

            @Override
            public void onFailure(Call<Map<String, Object>> call, Throwable t) {
                setBusy(false);
                statusText.setText("Network error while requesting OTP");
                requestBtn.setEnabled(true);
            }
        });
    }

    private void verifyOtp() {
        final String phone = phoneInput.getText() != null ? phoneInput.getText().toString().trim() : "";
        final String code = otpInput.getText() != null ? otpInput.getText().toString().trim() : "";

        if (!isValidE164(phone)) {
            toast("Enter a valid phone in E.164 format (e.g., +14155550123)");
            return;
        }
        if (TextUtils.isEmpty(code)) {
            toast("Enter the verification code");
            return;
        }

        setBusy(true);

        Map<String, String> payload = new HashMap<>();
        payload.put("phone", phone);
        payload.put("otp", code);

        api.verifyOtp(payload).enqueue(new Callback<AuthResponse>() {
            @Override
            public void onResponse(Call<AuthResponse> call, Response<AuthResponse> response) {
                setBusy(false);
                if (response.isSuccessful() && response.body() != null) {
                    AuthResponse ar = response.body();
                    if (!TextUtils.isEmpty(ar.access_token)) {
                        prefs.saveAccessToken(ar.access_token);
                    }
                    if (ar.refresh_token != null) {
                        prefs.saveRefreshToken(ar.refresh_token);
                    }
                    statusText.setText("Phone verified. You are now signed in.");
                    toast("Verified");
                    setResult(RESULT_OK);
                    finish();
                } else {
                    if (response.code() == 400) {
                        statusText.setText("Invalid code or phone. Please check and try again.");
                    } else if (response.code() == 429) {
                        String retryAfter = response.headers().get("Retry-After");
                        int seconds = parseIntOrDefault(retryAfter, DEFAULT_RESEND_COOLDOWN_SEC);
                        statusText.setText("Too many attempts. Try again later.");
                        startCooldown(seconds);
                    } else {
                        statusText.setText("Verification failed (HTTP " + response.code() + ")");
                    }
                }
            }

            @Override
            public void onFailure(Call<AuthResponse> call, Throwable t) {
                setBusy(false);
                statusText.setText("Network error while verifying code");
            }
        });
    }

    private void setBusy(boolean busy) {
        progress.setVisibility(busy ? View.VISIBLE : View.GONE);
        requestBtn.setEnabled(!busy && cooldownRemaining == 0);
        verifyBtn.setEnabled(!busy);
        phoneInput.setEnabled(!busy);
        otpInput.setEnabled(!busy);
    }

    private void startCooldown(int seconds) {
        cooldownRemaining = Math.max(0, seconds);
        handler.removeCallbacks(cooldownTick);
        if (cooldownRemaining > 0) {
            handler.post(cooldownTick);
        } else {
            requestBtn.setEnabled(true);
            statusText.setText("");
        }
    }

    private boolean isValidE164(String phone) {
        return !TextUtils.isEmpty(phone) && E164.matcher(phone).matches();
    }

    private int parseIntOrDefault(String s, int def) {
        if (s == null) return def;
        try {
            return Integer.parseInt(s.trim());
        } catch (Exception ignored) {
            return def;
        }
    }

    private void toast(String msg) {
        Toast.makeText(this, msg, Toast.LENGTH_SHORT).show();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        handler.removeCallbacks(cooldownTick);
    }
}
