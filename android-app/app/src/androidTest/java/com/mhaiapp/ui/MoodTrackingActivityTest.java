package com.mhaiapp.ui;

import static androidx.test.espresso.Espresso.onView;
import static androidx.test.espresso.action.ViewActions.click;
import static androidx.test.espresso.action.ViewActions.closeSoftKeyboard;
import static androidx.test.espresso.action.ViewActions.typeText;
import static androidx.test.espresso.assertion.ViewAssertions.matches;
import static androidx.test.espresso.matcher.ViewMatchers.isDisplayed;
import static androidx.test.espresso.matcher.ViewMatchers.withId;
import static androidx.test.espresso.matcher.ViewMatchers.withText;

import android.content.Context;

import androidx.test.core.app.ActivityScenario;
import androidx.test.core.app.ApplicationProvider;
import androidx.test.ext.junit.runners.AndroidJUnit4;

import com.google.android.material.slider.Slider;
import com.mhaiapp.R;
import com.mhaiapp.activities.MoodTrackingActivity;

import org.hamcrest.Matchers;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(AndroidJUnit4.class)
public class MoodTrackingActivityTest {

    @Before
    public void setup() {
        Context ctx = ApplicationProvider.getApplicationContext();
        // Launch activity
        ActivityScenario.launch(MoodTrackingActivity.class);
    }

    @Test
    public void testSaveMoodFlow_showsSavedSnackbar() {
        // Set slider value via direct view action is tricky; use click on Save without changing
        onView(withId(R.id.etNote)).perform(typeText("Feeling great"), closeSoftKeyboard());
        onView(withId(R.id.fabSave)).perform(click());
        onView(withText("Saved ✅")).check(matches(isDisplayed()));
    }

    @Test
    public void testManualSync_showsSyncStarted() {
        // Open overflow menu and click Sync Now
        // Some devices may require Espresso to open overflow differently; use direct click on menu using content description
        onView(withText("Sync Now")).perform(click());
        onView(withText("Sync started")).check(matches(isDisplayed()));
    }
}
