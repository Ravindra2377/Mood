package com.mhaiapp.activities;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

import androidx.appcompat.app.AppCompatActivity;

import com.mhaiapp.BuildConfig;
import com.mhaiapp.R;
import com.mhaiapp.models.AuthResponse;
import com.mhaiapp.repositories.AuthRepository;

/**
 * LoginActivity — clean implementation.
 * - Uses BuildConfig.BASE_URL (set by productFlavors) to construct the API client.
 * - Provides email/password login wired to AuthRepository.
 * - Exposes openOtp(View) to launch the phone OTP flow (OtpActivity).
 */
public class LoginActivity extends AppCompatActivity {

    private AuthRepository authRepo;
    private EditText emailInput;
    private EditText passwordInput;
    private Button loginBtn;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_login);

        // Base URL provided by product flavor (staging/prod)
        String baseUrl = BuildConfig.BASE_URL;
        authRepo = new AuthRepository(this, baseUrl);

        emailInput = findViewById(R.id.email);
        passwordInput = findViewById(R.id.password);
        loginBtn = findViewById(R.id.btn_login);

        loginBtn.setOnClickListener(v -> doEmailPasswordLogin());
    }

    private void doEmailPasswordLogin() {
        final String email = emailInput.getText() != null ? emailInput.getText().toString().trim() : "";
        final String password = passwordInput.getText() != null ? passwordInput.getText().toString().trim() : "";

        if (email.isEmpty() || password.isEmpty()) {
            Toast.makeText(this, "Enter email and password", Toast.LENGTH_SHORT).show();
            return;
        }

        authRepo.login(email, password, new AuthRepository.AuthCallback() {
            @Override
            public void onSuccess(AuthResponse resp) {
                runOnUiThread(() -> {
                    Toast.makeText(LoginActivity.this, "Login successful", Toast.LENGTH_SHORT).show();
                    // Navigate to main screen after a successful login
                    startActivity(new Intent(LoginActivity.this, MainActivity.class));
                    finish();
                });
            }

            @Override
            public void onError(String err) {
                runOnUiThread(() ->
                        Toast.makeText(LoginActivity.this, "Login error: " + err, Toast.LENGTH_LONG).show()
                );
            }
        });
    }

    /**
     * Launch the OTP flow (wired via android:onClick="openOtp" in activity_login.xml).
     */
    public void openOtp(View view) {
        startActivity(new Intent(this, OtpActivity.class));
    }
}
