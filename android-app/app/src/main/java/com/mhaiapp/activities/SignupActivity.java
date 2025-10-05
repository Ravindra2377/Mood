package com.mhaiapp.activities;

import android.os.Bundle;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;
import androidx.appcompat.app.AppCompatActivity;

import com.mhaiapp.models.AuthResponse;
import com.mhaiapp.repositories.AuthRepository;
import com.mhaiapp.R;

public class SignupActivity extends AppCompatActivity {
    private AuthRepository authRepo;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_signup);

        String baseUrl = "http://10.0.2.2:8000/";
        authRepo = new AuthRepository(this, baseUrl);

        EditText email = findViewById(R.id.email);
        EditText password = findViewById(R.id.password);
        Button signup = findViewById(R.id.btn_signup);

        signup.setOnClickListener(v -> {
            authRepo.signup(email.getText().toString(), password.getText().toString(), new AuthRepository.AuthCallback() {
                @Override
                public void onSuccess(AuthResponse resp) {
                    runOnUiThread(() -> Toast.makeText(SignupActivity.this, "Signup successful", Toast.LENGTH_SHORT).show());
                }

                @Override
                public void onError(String err) {
                    runOnUiThread(() -> Toast.makeText(SignupActivity.this, "Signup error: " + err, Toast.LENGTH_LONG).show());
                }
            });
        });
    }
}
