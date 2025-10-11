package com.mhaiapp.activities;

import android.content.Intent;
import android.os.Bundle;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import com.google.android.material.badge.BadgeDrawable;
import com.google.android.material.bottomnavigation.BottomNavigationView;
import androidx.lifecycle.ViewModelProvider;
import com.mhaiapp.viewmodels.MoodViewModel;
import com.mhaiapp.R;
import com.mhaiapp.activities.MoodTrackingActivity;

public class MainActivity extends AppCompatActivity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        BottomNavigationView bottomNav = findViewById(R.id.bottomNav);
        if (bottomNav != null) {
            bottomNav.setOnItemSelectedListener(item -> {
                int id = item.getItemId();
                if (id == R.id.nav_mood) {
                    Intent i = new Intent(this, MoodTrackingActivity.class);
                    startActivity(i);
                    overridePendingTransition(android.R.anim.fade_in, android.R.anim.slide_in_left);
                    return true;
                }
                return false;
            });

            // Observe unsynced count and show badge
            MoodViewModel vm = new ViewModelProvider(this).get(MoodViewModel.class);
            BadgeDrawable badge = bottomNav.getOrCreateBadge(R.id.nav_mood);
            vm.unsyncedCount.observe(this, count -> {
                if (count != null && count > 0) {
                    badge.setVisible(true);
                    badge.setNumber(count);
                } else {
                    badge.setVisible(false);
                }
            });
        }
    }
}
