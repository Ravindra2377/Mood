package com.mhaiapp.workers;

import android.content.Context;

import androidx.annotation.NonNull;
import androidx.work.Worker;
import androidx.work.WorkerParameters;

import com.mhaiapp.models.AppDatabase;
import com.mhaiapp.models.MoodEntryEntity;
import com.mhaiapp.network.ApiClient;
import com.mhaiapp.network.ApiService;
import com.mhaiapp.models.MoodRequest;
import com.mhaiapp.utils.SharedPrefsManager;

import java.io.IOException;
import java.util.List;

import retrofit2.Call;

public class SyncWorker extends Worker {
    private final AppDatabase db;
    private final ApiService api;
    private final SharedPrefsManager prefs;
    private final com.mhaiapp.models.MoodDao daoOverride;

    public SyncWorker(@NonNull Context context, @NonNull WorkerParameters params) {
        super(context, params);
        db = AppDatabase.getInstance(context);
        api = ApiClient.getService();
        prefs = SharedPrefsManager.getInstance(context);
        daoOverride = null;
    }

    // Testing constructor to inject mocks
    public SyncWorker(@NonNull Context context, @NonNull WorkerParameters params,
                      com.mhaiapp.models.MoodDao dao, ApiService apiService, SharedPrefsManager sharedPrefs) {
        super(context, params);
        db = null;
        api = apiService;
        prefs = sharedPrefs;
        daoOverride = dao;
    }

    @NonNull
    @Override
    public Result doWork() {
        try {
            com.mhaiapp.models.MoodDao dao = daoOverride != null ? daoOverride : db.moodDao();
            List<MoodEntryEntity> pending = dao.getUnsyncedEntries();
            for (MoodEntryEntity e : pending) {
                try {
                    Call<?> call = api.createMood("Bearer " + prefs.getAccessToken(), new MoodRequest(e.score, e.note));
                    retrofit2.Response<?> resp = call.execute();
                    int code = resp.code();
                    if (resp.isSuccessful()) {
                        e.synced = true;
                        dao.update(e);
                    } else if (code >= 400 && code < 500) {
                        // Client error: treat as bad data and drop it (mark synced to avoid retry storms)
                        e.synced = true;
                        dao.update(e);
                    } else {
                        // Server error: retry later
                        return Result.retry();
                    }
                } catch (IOException ex) {
                    // Network I/O issue—retry later
                    return Result.retry();
                }
            }
            return Result.success();
        } catch (Exception ex) {
            return Result.retry();
        }
    }
}
