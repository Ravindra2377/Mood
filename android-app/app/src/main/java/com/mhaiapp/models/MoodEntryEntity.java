package com.mhaiapp.models;

import androidx.room.Entity;
import androidx.room.PrimaryKey;

@Entity(tableName = "mood_entries")
public class MoodEntryEntity {
    @PrimaryKey(autoGenerate = true)
    public int id;

    public int score;
    public String note;
    public long timestamp;
    public boolean synced = false;

    public MoodEntryEntity(int score, String note, long timestamp) {
        this.score = score;
        this.note = note;
        this.timestamp = timestamp;
    }
}
