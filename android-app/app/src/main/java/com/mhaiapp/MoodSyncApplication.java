package com.mhaiapp;

import android.app.Application;

import androidx.work.ExistingPeriodicWorkPolicy;
import androidx.work.PeriodicWorkRequest;
import androidx.work.WorkManager;

import com.mhaiapp.workers.SyncWorker;

import java.util.concurrent.TimeUnit;

public class MoodSyncApplication extends Application {
    @Override
    public void onCreate() {
        super.onCreate();
        // Schedule periodic work to sync moods every 15 minutes (minimum allowed interval)
        PeriodicWorkRequest req = new PeriodicWorkRequest.Builder(SyncWorker.class, 15, TimeUnit.MINUTES)
            .setBackoffCriteria(
                androidx.work.BackoffPolicy.EXPONENTIAL,
                30, java.util.concurrent.TimeUnit.SECONDS
            )
            .build();
        WorkManager.getInstance(this).enqueueUniquePeriodicWork(
            "mood_sync", ExistingPeriodicWorkPolicy.KEEP, req
        );
    }
}
