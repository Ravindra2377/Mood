package com.mhaiapp.viewmodels;

import android.app.Application;

import androidx.annotation.NonNull;
import androidx.lifecycle.AndroidViewModel;
import androidx.lifecycle.LiveData;
import androidx.lifecycle.MediatorLiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.Transformations;

import com.mhaiapp.network.ApiClient;
import com.mhaiapp.network.ApiService;
import com.mhaiapp.repositories.MoodRepository;
import com.mhaiapp.utils.SharedPrefsManager;
import com.mhaiapp.models.MoodEntryEntity;

import java.util.List;

public class MoodViewModel extends AndroidViewModel {
    private final MoodRepository repository;
    public final LiveData<List<MoodEntryEntity>> allEntries;
    private final MediatorLiveData<Boolean> saveStatus = new MediatorLiveData<>();
    public final LiveData<Integer> unsyncedCount;

    public MoodViewModel(@NonNull Application app) {
        super(app);
        ApiService api = ApiClient.getService();
        SharedPrefsManager prefs = SharedPrefsManager.getInstance(app);
        repository = new MoodRepository(app, api, prefs);
        allEntries = repository.getAllEntries();
        unsyncedCount = repository.getUnsyncedCountLive();
    }

    public LiveData<Boolean> saveMood(int score, String note) {
        LiveData<Boolean> status = repository.saveMood(score, note);
        saveStatus.addSource(status, saveStatus::setValue);
        return saveStatus;
    }
}
