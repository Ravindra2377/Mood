package com.mhaiapp.models;

import androidx.lifecycle.LiveData;
import androidx.room.Dao;
import androidx.room.Insert;
import androidx.room.OnConflictStrategy;
import androidx.room.Query;

import java.util.List;

@Dao
public interface MoodDao {
    @Query("SELECT * FROM mood_entries ORDER BY timestamp DESC")
    LiveData<List<MoodEntryEntity>> getAllEntries();

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    void insert(MoodEntryEntity entry);

    @Query("DELETE FROM mood_entries WHERE id = :id")
    void deleteById(int id);

    @Query("SELECT * FROM mood_entries WHERE synced = 0 ORDER BY timestamp DESC")
    java.util.List<MoodEntryEntity> getUnsyncedEntries();

    @Query("SELECT COUNT(*) FROM mood_entries WHERE synced = 0")
    androidx.lifecycle.LiveData<Integer> getUnsyncedCount();

    @androidx.room.Update
    void update(MoodEntryEntity entry);
}
