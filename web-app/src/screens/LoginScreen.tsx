import React, { useState } from "react";

interface LoginScreenProps {
  onLogin: (credentials: { phone: string; password: string }) => Promise<void>;
  navigateTo: (screen: string) => void;
  isDarkMode?: boolean;
  user?: any;
}

const LoginScreen: React.FC<LoginScreenProps> = ({
  onLogin,
  navigateTo,
  isDarkMode,
}) => {
  const [phone, setPhone] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      await onLogin({ phone, password });
    } catch (err: any) {
      setError(err.message || "Login failed");
      setLoading(false);
    }
  };

  return (
    <div className="screen active calm-gradient">
      <div className="form-container flex flex-col justify-center h-full">
        <h1 className="form-title">Welcome Back</h1>
        <p className="form-subtitle">
          Login to continue your journey.
        </p>
        <form className="form-group" onSubmit={handleSubmit}>
          <input
            type="tel"
            className="form-input"
            placeholder="Phone Number"
            value={phone}
            onChange={e => setPhone(e.target.value)}
            autoComplete="tel"
            required
            disabled={loading}
          />
          <input
            type="password"
            className="form-input"
            placeholder="Password"
            value={password}
            onChange={e => setPassword(e.target.value)}
            autoComplete="current-password"
            required
            disabled={loading}
          />
          {error && (
            <div className="text-red-500 text-sm mt-2">{error}</div>
          )}
          <button
            type="submit"
            className="form-button mt-4"
            disabled={loading || !phone || !password}
          >
            {loading ? <div className="loader mx-auto" /> : "Login"}
          </button>
        </form>
        <div className="flex justify-between items-center mt-2">
          <a
            href="#"
            className="form-link"
            style={{ fontSize: "0.95em" }}
            onClick={e => {
              e.preventDefault();
              alert("Forgot password feature coming soon!");
            }}
          >
            Forgot Password?
          </a>
        </div>
        <p className="text-center text-sm mt-6">
          Don't have an account?{" "}
          <a
            href="#"
            className="form-link"
            onClick={e => {
              e.preventDefault();
              navigateTo("signup");
            }}
          >
            Sign Up
          </a>
        </p>
      </div>
    </div>
  );
};

export default LoginScreen;
