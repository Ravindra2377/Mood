package com.mhaiapp.repositories;

import android.content.Context;

import androidx.lifecycle.LiveData;

import com.mhaiapp.models.AppDatabase;
import com.mhaiapp.models.MoodDao;
import com.mhaiapp.models.MoodEntryEntity;
import com.mhaiapp.network.ApiService;
import com.mhaiapp.utils.SharedPrefsManager;
import com.mhaiapp.models.MoodRequest;
import com.mhaiapp.models.MoodEntry;

import java.util.List;
import java.util.concurrent.Executor;
import java.util.concurrent.Executors;

import retrofit2.Call;

public class MoodRepository {
    private final MoodDao moodDao;
    private final ApiService apiService;
    private final SharedPrefsManager prefs;
    private final Executor executor = Executors.newSingleThreadExecutor();
    private final android.content.Context context;

    public MoodRepository(Context context, ApiService apiService, SharedPrefsManager prefs) {
        this.context = context.getApplicationContext();
        this.apiService = apiService;
        this.prefs = prefs;
        AppDatabase db = AppDatabase.getInstance(context);
        this.moodDao = db.moodDao();
    }

    public LiveData<List<MoodEntryEntity>> getAllEntries() {
        return moodDao.getAllEntries();
    }
    public LiveData<Boolean> saveMood(int score, String note) {
        MutableLiveData<Boolean> result = new MutableLiveData<>();
        executor.execute(() -> {
            long ts = System.currentTimeMillis();
            MoodEntryEntity entry = new MoodEntryEntity(score, note, ts);
            entry.synced = false;
            moodDao.insert(entry);

            // Schedule an immediate one-time sync worker
            try {
                androidx.work.OneTimeWorkRequest work = new androidx.work.OneTimeWorkRequest.Builder(
                    com.mhaiapp.workers.SyncWorker.class).build();
                androidx.work.WorkManager.getInstance(context).enqueue(work);
                result.postValue(true);
            } catch (Exception e) {
                result.postValue(false);
            }
        });
        return result;
    }

    public LiveData<Integer> getUnsyncedCountLive() {
        return moodDao.getUnsyncedCount();
    }
}
