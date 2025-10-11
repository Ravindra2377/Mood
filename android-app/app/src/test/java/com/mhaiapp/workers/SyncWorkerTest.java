package com.mhaiapp.workers;

import static org.junit.Assert.assertEquals;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import android.content.Context;

import androidx.work.WorkerParameters;

import com.mhaiapp.models.MoodEntryEntity;
import com.mhaiapp.models.MoodDao;
import com.mhaiapp.network.ApiService;
import com.mhaiapp.utils.SharedPrefsManager;

import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

import retrofit2.Call;
import retrofit2.Response;

public class SyncWorkerTest {

    @Mock MoodDao mockDao;
    @Mock ApiService mockApi;
    @Mock SharedPrefsManager mockPrefs;

    @Before
    public void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    private SyncWorker createWorker() {
        Context ctx = mock(Context.class);
        WorkerParameters params = mock(WorkerParameters.class);
        return new SyncWorker(ctx, params, mockDao, mockApi, mockPrefs);
    }

    @Test
    public void testSuccessfulSync() throws Exception {
        MoodEntryEntity entry = new MoodEntryEntity(3, "note", System.currentTimeMillis());
        entry.synced = false;
        List<MoodEntryEntity> list = Arrays.asList(entry);

        when(mockDao.getUnsyncedEntries()).thenReturn(list);
        when(mockPrefs.getAccessToken()).thenReturn("token");

        Call<MoodEntryEntity> callMock = mock(Call.class);
        when(mockApi.createMood(anyString(), any())).thenReturn(callMock);
        when(callMock.execute()).thenReturn(Response.success(entry));

        SyncWorker w = createWorker();
        androidx.work.ListenableWorker.Result result = w.doWork();

        verify(mockDao).update(any());
        assertEquals(androidx.work.ListenableWorker.Result.success(), result);
    }

    @Test
    public void testRetryOnIOException() throws Exception {
        MoodEntryEntity entry = new MoodEntryEntity(3, "note", System.currentTimeMillis());
        entry.synced = false;
        List<MoodEntryEntity> list = Arrays.asList(entry);

        when(mockDao.getUnsyncedEntries()).thenReturn(list);
        when(mockPrefs.getAccessToken()).thenReturn("token");

        Call<MoodEntryEntity> callMock = mock(Call.class);
        when(mockApi.createMood(anyString(), any())).thenReturn(callMock);
        when(callMock.execute()).thenThrow(new IOException());

        SyncWorker w = createWorker();
        androidx.work.ListenableWorker.Result result = w.doWork();

        assertEquals(androidx.work.ListenableWorker.Result.retry(), result);
    }

    @Test
    public void testDropEntryOn4xx() throws Exception {
        MoodEntryEntity entry = new MoodEntryEntity(3, "note", System.currentTimeMillis());
        entry.synced = false;
        List<MoodEntryEntity> list = Arrays.asList(entry);

        when(mockDao.getUnsyncedEntries()).thenReturn(list);
        when(mockPrefs.getAccessToken()).thenReturn("token");

        Call<MoodEntryEntity> callMock = mock(Call.class);
        when(mockApi.createMood(anyString(), any())).thenReturn(callMock);

        okhttp3.ResponseBody errorBody = okhttp3.ResponseBody.create(null, "{}");
        retrofit2.Response<MoodEntryEntity> errorResponse = retrofit2.Response.error(400, errorBody);

        when(callMock.execute()).thenReturn(errorResponse);

        SyncWorker w = createWorker();
        androidx.work.ListenableWorker.Result result = w.doWork();

        verify(mockDao).update(any());
        assertEquals(androidx.work.ListenableWorker.Result.success(), result);
    }
}
