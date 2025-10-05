package com.mhaiapp.models;

import android.content.Context;

import androidx.room.Database;
import androidx.room.Room;
import androidx.room.RoomDatabase;
import androidx.annotation.NonNull;

@Database(entities = {MoodEntryEntity.class}, version = 2)
public abstract class AppDatabase extends RoomDatabase {
    public abstract MoodDao moodDao();

    private static volatile AppDatabase INSTANCE;
    public static AppDatabase getInstance(Context context) {
        if (INSTANCE == null) {
            synchronized (AppDatabase.class) {
                if (INSTANCE == null) {
                    INSTANCE = Room.databaseBuilder(
                        context.getApplicationContext(),
                        AppDatabase.class, "mood_app_db"
                    ).addMigrations(MIGRATION_1_2).build();
                }
            }
        }
        return INSTANCE;
    }

    public static final androidx.room.migration.Migration MIGRATION_1_2 =
        new androidx.room.migration.Migration(1, 2) {
            @Override
            public void migrate(@NonNull androidx.sqlite.db.SupportSQLiteDatabase database) {
                database.execSQL("ALTER TABLE mood_entries ADD COLUMN synced INTEGER NOT NULL DEFAULT 0");
            }
        };
}
