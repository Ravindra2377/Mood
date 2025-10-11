package com.mhaiapp.models;


    public String access_token;

    public String refresh_token;
    public String token_type;

    public User user;


    public static class User {
        public int id;
        public String email;
        public String name;
    }
}
