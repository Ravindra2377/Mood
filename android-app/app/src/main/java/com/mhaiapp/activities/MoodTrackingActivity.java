package com.mhaiapp.activities;

import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.lifecycle.ViewModelProvider;

import com.google.android.material.floatingactionbutton.FloatingActionButton;
import com.google.android.material.snackbar.Snackbar;
import com.google.android.material.slider.Slider;
import com.google.android.material.textfield.TextInputEditText;
import com.mhaiapp.R;
import com.mhaiapp.viewmodels.MoodViewModel;
import com.mhaiapp.models.AppDatabase;
import android.view.Menu;
import android.view.MenuItem;
import androidx.annotation.NonNull;
import androidx.work.OneTimeWorkRequest;
import androidx.work.WorkManager;
import com.mhaiapp.workers.SyncWorker;

import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

public class MoodTrackingActivity extends AppCompatActivity {
    private MoodViewModel viewModel;
    private Slider sliderMood;
    private TextView tvEmoji;
    private TextInputEditText etNote;
    private TextView tvSyncStatus;
    private final Executor executor = Executors.newSingleThreadExecutor();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_mood_tracking);
        sliderMood = findViewById(R.id.sliderMood);
        tvEmoji = findViewById(R.id.tvEmoji);
    etNote = findViewById(R.id.etNote);
    tvSyncStatus = findViewById(R.id.tvSyncStatus);
        FloatingActionButton fabSave = findViewById(R.id.fabSave);

        viewModel = new ViewModelProvider(this).get(MoodViewModel.class);

        // Observe unsynced count to update sync status label
        viewModel.unsyncedCount.observe(this, count -> {
            if (count != null && count > 0) {
                tvSyncStatus.setText(count + " pending sync");
                tvSyncStatus.setVisibility(View.VISIBLE);
            } else {
                tvSyncStatus.setVisibility(View.GONE);
            }
        });

        sliderMood.addOnChangeListener((slider, value, fromUser) -> {
            int val = Math.round(value);
            String emoji = new String[]{"😢","😕","😌","🙂","😀"}[val-1];
            tvEmoji.setText(emoji);
        });

        fabSave.setOnClickListener(v -> {
            int score = Math.round(sliderMood.getValue());
            String note = etNote.getText() != null ? etNote.getText().toString() : "";
            tvSyncStatus.setVisibility(View.VISIBLE);
            viewModel.saveMood(score, note).observe(this, success -> {
                tvSyncStatus.setVisibility(View.GONE);
                if (success != null && success) {
                    Snackbar.make(v, "Saved ✅", Snackbar.LENGTH_SHORT).show();
                    checkPending();
                } else {
                    Snackbar.make(v, "Save failed (queued)", Snackbar.LENGTH_SHORT).show();
                    checkPending();
                }
            });
        });
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        getMenuInflater().inflate(R.menu.menu_mood, menu);
        return true;
    }

    @Override
    public boolean onOptionsItemSelected(@NonNull MenuItem item) {
        if (item.getItemId() == R.id.action_sync) {
            OneTimeWorkRequest req = new OneTimeWorkRequest.Builder(SyncWorker.class).build();
            WorkManager.getInstance(this).enqueue(req);
            Snackbar.make(findViewById(android.R.id.content), "Sync started", Snackbar.LENGTH_SHORT).show();
            return true;
        }
        return super.onOptionsItemSelected(item);
    }

    @Override
    protected void onResume() {
        super.onResume();
        // LiveData observer will handle updates
    }

    private void checkPending() {
        // retained for compatibility but LiveData provides real-time updates
        executor.execute(() -> {
            int pending = AppDatabase.getInstance(this).moodDao().getUnsyncedEntries().size();
            runOnUiThread(() -> {
                if (pending > 0) {
                    tvSyncStatus.setText(pending + " pending sync");
                    tvSyncStatus.setVisibility(View.VISIBLE);
                } else {
                    tvSyncStatus.setVisibility(View.GONE);
                }
            });
        });
    }
}
