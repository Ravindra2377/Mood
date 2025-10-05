package com.mhaiapp.network;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

import java.io.IOException;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicInteger;

import okhttp3.Interceptor;
import okhttp3.Protocol;
import okhttp3.Request;
import okhttp3.Response;
import org.junit.Before;
import org.junit.Test;
import retrofit2.Call;
import retrofit2.Response as RetrofitResponse;

import com.mhaiapp.utils.SharedPrefsManager;
import com.mhaiapp.models.AuthResponse;

public class AuthInterceptorTest {
    private ApiService mockApiService;
    private SharedPrefsManager mockPrefs;
    private AuthInterceptor interceptor;

    @Before
    public void setup() {
        mockApiService = mock(ApiService.class);
        mockPrefs = mock(SharedPrefsManager.class);
        interceptor = new AuthInterceptor(mockPrefs, "http://localhost/");
        // replace internal apiService with mock via reflection
        try {
            java.lang.reflect.Field f = AuthInterceptor.class.getDeclaredField("apiService");
            f.setAccessible(true);
            f.set(interceptor, mockApiService);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private Response make401Response(Request req) {
        return new Response.Builder()
            .request(req)
            .protocol(Protocol.HTTP_1_1)
            .code(401)
            .message("Unauthorized")
            .body(okio.ResponseBody.create(null, new byte[0]))
            .build();
    }

    @Test
    public void testConcurrentRefreshRequests() throws InterruptedException, IOException {
        when(mockPrefs.getAccessToken()).thenReturn("oldAccess");
        when(mockPrefs.getRefreshToken()).thenReturn("refreshToken");

        Call<AuthResponse> mockCall = mock(Call.class);
        AuthResponse authResponse = new AuthResponse();
        authResponse.access_token = "newAccess";
        // mock Retrofit Response
        try {
            when(mockCall.execute()).thenReturn(RetrofitResponse.success(authResponse));
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
        when(mockApiService.refresh(any())).thenReturn(mockCall);

        Interceptor.Chain mockChain = mock(Interceptor.Chain.class);
        Request dummyRequest = new Request.Builder().url("https://api.test/").build();
        when(mockChain.request()).thenReturn(dummyRequest);
        when(mockChain.proceed(any())).thenReturn(make401Response(dummyRequest));

        Response okResponse = new Response.Builder()
            .request(dummyRequest)
            .protocol(Protocol.HTTP_1_1)
            .code(200)
            .message("OK")
            .body(okio.ResponseBody.create(null, new byte[0]))
            .build();
        try {
            when(mockChain.proceed(argThat(r -> r.header("Authorization") != null && r.header("Authorization").equals("Bearer newAccess")))).thenReturn(okResponse);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }

        int threadCount = 5;
        CountDownLatch startLatch = new CountDownLatch(1);
        CountDownLatch doneLatch = new CountDownLatch(threadCount);
        AtomicInteger successCount = new AtomicInteger();

        for (int i = 0; i < threadCount; i++) {
            new Thread(() -> {
                try {
                    startLatch.await();
                    Response resp = interceptor.intercept(mockChain);
                    if (resp.code() == 200) successCount.incrementAndGet();
                } catch (Exception e) {
                } finally {
                    doneLatch.countDown();
                }
            }).start();
        }

        startLatch.countDown();
        doneLatch.await();

        verify(mockApiService, times(1)).refresh(any());
        assert(successCount.get() == threadCount);
    }

    @Test
    public void testRefreshFailureHandling() throws Exception {
        when(mockPrefs.getAccessToken()).thenReturn("oldAccess");
        when(mockPrefs.getRefreshToken()).thenReturn("badRefresh");

        Call<AuthResponse> mockFailCall = mock(Call.class);
        when(mockFailCall.execute()).thenReturn(RetrofitResponse.error(400, okhttp3.ResponseBody.create(null, "Bad Request")));
        when(mockApiService.refresh(any())).thenReturn(mockFailCall);

        Interceptor.Chain mockChain = mock(Interceptor.Chain.class);
        Request req = new Request.Builder().url("https://api.test/").build();
        when(mockChain.request()).thenReturn(req);
        when(mockChain.proceed(any()))
            .thenReturn(make401Response(req))
            .thenReturn(new Response.Builder()
                .request(req)
                .protocol(Protocol.HTTP_1_1)
                .code(200)
                .message("OK")
                .body(okio.ResponseBody.create(null, new byte[0]))
                .build());

        // spy interceptor to verify redirectToLogin invocation
        AuthInterceptor spy = spy(interceptor);
        doNothing().when(spy).redirectToLogin();

        Response response = spy.intercept(mockChain);

        verify(mockPrefs).clear();
        verify(spy).redirectToLogin();
        assert(response.code() == 200);
    }
}
