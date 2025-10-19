package com.mhaiapp.activities;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;

import com.mhaiapp.BuildConfig;
import com.mhaiapp.models.AuthResponse;
import com.mhaiapp.repositories.AuthRepository;
import com.mhaiapp.R;

public class SignupActivity extends AppCompatActivity {
    private AuthRepository authRepo;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_signup);

        // Use the same base URL strategy as LoginActivity
        String baseUrl = BuildConfig.BASE_URL;
        authRepo = new AuthRepository(this, baseUrl);

        EditText email = findViewById(R.id.email);
        EditText password = findViewById(R.id.password);
        Button signup = findViewById(R.id.btn_signup);

        signup.setOnClickListener(v -> {
            String e = email.getText() != null ? email.getText().toString().trim() : "";
            String p = password.getText() != null ? password.getText().toString().trim() : "";
            if (e.isEmpty() || p.isEmpty()) {
                Toast.makeText(SignupActivity.this, "Enter email and password", Toast.LENGTH_SHORT).show();
                return;
            }
            authRepo.signup(e, p, new AuthRepository.AuthCallback() {
                @Override
                public void onSuccess(AuthResponse resp) {
                    runOnUiThread(() -> {
                        Toast.makeText(SignupActivity.this, "Signup successful", Toast.LENGTH_SHORT).show();
                        startActivity(new Intent(SignupActivity.this, MainActivity.class));
                        finish();
                    });
                }

                @Override
                public void onError(String err) {
                    runOnUiThread(() -> Toast.makeText(SignupActivity.this, "Signup error: " + err, Toast.LENGTH_LONG).show());
                }
            });
        });
    }
}
