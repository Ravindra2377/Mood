import React, { useState, useEffect } from "react";
import { registerServiceWorker } from "./sw/register";
import "./styles/soul.css";

// Import screens
import SplashScreen from "./screens/SplashScreen";
import LoginScreen from "./screens/LoginScreen";
import SignupScreen from "./screens/SignupScreen";
import OTPScreen from "./screens/OTPScreen";
import HomeScreen from "./screens/HomeScreen";
import BreathingScreen from "./screens/BreathingScreen";
import JournalScreen from "./screens/JournalScreen";
import InsightsScreen from "./screens/InsightsScreen";
import ProfileScreen from "./screens/ProfileScreen";
import BottomNavigation from "./components/BottomNavigation";
import ToastProvider from "./ui/Toast";

// Import legal/consent pages
import PrivacyPolicy from "./pages/PrivacyPolicy";
import TermsOfService from "./pages/TermsOfService";
import ConsentPage from "./pages/Consent";

// Types
interface User {
  id: number;
  username: string;
  phone: string;
  age: number;
  language?: string;
}

interface AppState {
  currentScreen: string;
  isAuthenticated: boolean;
  user: User | null;
  isDarkMode: boolean;
  isLoading: boolean;
}

export default function App() {
  const [state, setState] = useState<AppState>({
    currentScreen: "splash",
    isAuthenticated: false,
    user: null,
    isDarkMode: false,
    isLoading: true,
  });

  useEffect(() => {
    registerServiceWorker();

    // If user is navigating directly to legal/consent routes, show those immediately
    const path = window.location.pathname;
    const legalRoutes = ["/privacy-policy", "/terms-of-service", "/consent"];
    if (legalRoutes.includes(path)) {
      setState((prev) => ({
        ...prev,
        currentScreen: path.slice(1), // remove leading '/'
        isLoading: false,
      }));
      return;
    }

    // Check for existing auth token
    const token = localStorage.getItem("auth_token");
    if (token) {
      validateToken(token);
    } else {
      // Show splash for 2.5 seconds then go to login
      setTimeout(() => {
        setState((prev) => ({
          ...prev,
          currentScreen: "login",
          isLoading: false,
        }));
      }, 2500);
    }

    // Load dark mode preference
    const darkMode = localStorage.getItem("dark_mode") === "true";
    if (darkMode) {
      document.documentElement.classList.add("dark");
      setState((prev) => ({ ...prev, isDarkMode: true }));
    }
  }, []);

  const validateToken = async (token: string) => {
    try {
      const response = await fetch("/api/auth/me", {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      });

      if (response.ok) {
        const userData = await response.json();
        setState((prev) => ({
          ...prev,
          isAuthenticated: true,
          user: userData,
          currentScreen: "home",
          isLoading: false,
        }));
      } else {
        localStorage.removeItem("auth_token");
        setState((prev) => ({
          ...prev,
          currentScreen: "login",
          isLoading: false,
        }));
      }
    } catch (error) {
      console.error("Token validation failed:", error);
      localStorage.removeItem("auth_token");
      setState((prev) => ({
        ...prev,
        currentScreen: "login",
        isLoading: false,
      }));
    }
  };

  const navigateTo = (screen: string) => {
    setState((prev) => ({ ...prev, currentScreen: screen }));

    // Update browser history for main screens and legal pages
    if (
      [
        "home",
        "journal",
        "insights",
        "profile",
        "privacy-policy",
        "terms-of-service",
        "consent",
      ].includes(screen)
    ) {
      const path = screen === "home" ? "/" : `/${screen}`;
      if (window.location.pathname !== path) {
        window.history.pushState({}, "", path);
      }
    }
  };

  const handleLogin = async (credentials: {
    phone: string;
    password: string;
  }) => {
    try {
      const response = await fetch("/api/auth/login", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(credentials),
      });

      if (response.ok) {
        const data = await response.json();
        localStorage.setItem("auth_token", data.access_token);

        setState((prev) => ({
          ...prev,
          isAuthenticated: true,
          user: data.user,
          currentScreen: "home",
        }));
      } else {
        const error = await response.json();
        throw new Error(error.detail || "Login failed");
      }
    } catch (error) {
      console.error("Login error:", error);
      throw error;
    }
  };

  const handleSignup = async (userData: {
    username: string;
    phone: string;
    age: number;
    password: string;
  }) => {
    try {
      const response = await fetch("/api/auth/signup", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify(userData),
      });

      if (response.ok) {
        // Store temp data for OTP verification
        sessionStorage.setItem("signup_data", JSON.stringify(userData));
        navigateTo("otp");
      } else {
        const error = await response.json();
        throw new Error(error.detail || "Signup failed");
      }
    } catch (error) {
      console.error("Signup error:", error);
      throw error;
    }
  };

  const handleOTPVerify = async (otp: string) => {
    try {
      const signupData = JSON.parse(
        sessionStorage.getItem("signup_data") || "{}",
      );

      const response = await fetch("/api/auth/verify-otp", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          phone: signupData.phone,
          otp: otp,
        }),
      });

      if (response.ok) {
        const data = await response.json();
        localStorage.setItem("auth_token", data.access_token);
        sessionStorage.removeItem("signup_data");

        setState((prev) => ({
          ...prev,
          isAuthenticated: true,
          user: data.user,
          currentScreen: "home",
        }));
      } else {
        const error = await response.json();
        throw new Error(error.detail || "OTP verification failed");
      }
    } catch (error) {
      console.error("OTP verification error:", error);
      throw error;
    }
  };

  const handleSignOut = () => {
    localStorage.removeItem("auth_token");
    sessionStorage.clear();

    setState((prev) => ({
      ...prev,
      isAuthenticated: false,
      user: null,
      currentScreen: "login",
    }));
  };

  const toggleDarkMode = () => {
    const newDarkMode = !state.isDarkMode;
    setState((prev) => ({ ...prev, isDarkMode: newDarkMode }));

    if (newDarkMode) {
      document.documentElement.classList.add("dark");
      localStorage.setItem("dark_mode", "true");
    } else {
      document.documentElement.classList.remove("dark");
      localStorage.setItem("dark_mode", "false");
    }
  };

  const updateUser = (userData: Partial<User>) => {
    setState((prev) => ({
      ...prev,
      user: prev.user ? { ...prev.user, ...userData } : null,
    }));
  };

  // Listen to browser back/forward
  useEffect(() => {
    const handlePopState = () => {
      const path = window.location.pathname;
      if (path === "/") {
        navigateTo("home");
      } else if (path.startsWith("/")) {
        const screen = path.slice(1);
        if (
          [
            "journal",
            "insights",
            "profile",
            "privacy-policy",
            "terms-of-service",
            "consent",
          ].includes(screen)
        ) {
          navigateTo(screen);
        }
      }
    };

    window.addEventListener("popstate", handlePopState);
    return () => window.removeEventListener("popstate", handlePopState);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const renderScreen = () => {
    const commonProps = {
      navigateTo,
      user: state.user,
      isDarkMode: state.isDarkMode,
    };

    switch (state.currentScreen) {
      case "splash":
        return <SplashScreen />;

      case "login":
        return <LoginScreen {...commonProps} onLogin={handleLogin} />;

      case "signup":
        return <SignupScreen {...commonProps} onSignup={handleSignup} />;

      case "otp":
        return <OTPScreen {...commonProps} onVerify={handleOTPVerify} />;

      case "home":
        return <HomeScreen {...commonProps} />;

      case "breathing":
        return <BreathingScreen {...commonProps} />;

      case "journal":
        return <JournalScreen {...commonProps} />;

      case "insights":
        return <InsightsScreen {...commonProps} />;

      case "profile":
        return (
          <ProfileScreen
            {...commonProps}
            onSignOut={handleSignOut}
            onToggleDarkMode={toggleDarkMode}
            onUpdateUser={updateUser}
          />
        );

      case "privacy-policy":
        return <PrivacyPolicy />;

      case "terms-of-service":
        return <TermsOfService />;

      case "consent":
        return <ConsentPage />;

      default:
        return <HomeScreen {...commonProps} />;
    }
  };

  if (state.isLoading) {
    return (
      <div className="app-container">
        <SplashScreen />
      </div>
    );
  }

  return (
    <ToastProvider>
      <div className="app-container">
        {renderScreen()}

        {state.isAuthenticated && (
          <BottomNavigation
            currentScreen={state.currentScreen}
            onNavigate={navigateTo}
          />
        )}
      </div>
    </ToastProvider>
  );
}
