package com.mhaiapp.viewmodels;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import com.mhaiapp.models.AuthRequest;
import com.mhaiapp.models.AuthResponse;
import com.mhaiapp.repositories.AuthRepository;

public class AuthViewModel extends ViewModel {
    private AuthRepository repo;
    private MutableLiveData<AuthResponse> authLive = new MutableLiveData<>();
    private MutableLiveData<String> errorLive = new MutableLiveData<>();

    public void init(AuthRepository r) {
        this.repo = r;
    }

    public LiveData<AuthResponse> getAuth() { return authLive; }
    public LiveData<String> getError() { return errorLive; }

    public void login(String email, String password) {
        repo.login(email, password, new AuthRepository.AuthCallback() {
            @Override
            public void onSuccess(AuthResponse resp) {
                authLive.postValue(resp);
            }

            @Override
            public void onError(String err) {
                errorLive.postValue(err);
            }
        });
    }

    public void signup(String email, String password) {
        repo.signup(email, password, new AuthRepository.AuthCallback() {
            @Override
            public void onSuccess(AuthResponse resp) {
                authLive.postValue(resp);
            }

            @Override
            public void onError(String err) {
                errorLive.postValue(err);
            }
        });
    }
}
