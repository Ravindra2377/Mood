package com.mhaiapp;

import static org.junit.Assert.assertTrue;

import android.content.Context;

import androidx.room.Room;
import androidx.room.migration.Migration;
import androidx.room.testing.MigrationTestHelper;
import androidx.sqlite.db.SupportSQLiteDatabase;
import androidx.test.core.app.ApplicationProvider;
import androidx.test.ext.junit.runners.AndroidJUnit4;

import com.mhaiapp.models.AppDatabase;

import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;

import java.io.IOException;

@RunWith(AndroidJUnit4.class)
public class MigrationTest {
    private static final String TEST_DB = "migration-test";

    @Rule
    public MigrationTestHelper helper = new MigrationTestHelper(
        androidx.test.platform.app.InstrumentationRegistry.getInstrumentation(),
        AppDatabase.class.getCanonicalName());

    @Test
    public void migrate1To2() throws IOException {
        Context context = ApplicationProvider.getApplicationContext();
        // Create DB with version 1 schema
        SupportSQLiteDatabase db = helper.createDatabase(TEST_DB, 1);
        // Insert a row using raw SQL into mood_entries to simulate existing data
        db.execSQL("CREATE TABLE IF NOT EXISTS mood_entries (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, score INTEGER NOT NULL, note TEXT, timestamp INTEGER NOT NULL)");
        db.execSQL("INSERT INTO mood_entries (score, note, timestamp) VALUES (3, 'old note', 1234567890)");
        db.close();

        // Run migration
        helper.runMigrationsAndValidate(TEST_DB, 2, true, AppDatabase.MIGRATION_1_2);

        // If no exception thrown, migration succeeded
        assertTrue(true);
    }
}
