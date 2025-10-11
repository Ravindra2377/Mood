import React, { useState } from "react";

interface SignupScreenProps {
  onSignup: (userData: {
    username: string;
    phone: string;
    age: number;
    password: string;
  }) => Promise<void>;
  navigateTo: (screen: string) => void;
  isDarkMode?: boolean;
  user?: any;
}

const SignupScreen: React.FC<SignupScreenProps> = ({
  onSignup,
  navigateTo,
  isDarkMode,
}) => {
  const [username, setUsername] = useState("");
  const [phone, setPhone] = useState("");
  const [age, setAge] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      await onSignup({
        username,
        phone,
        age: Number(age),
        password,
      });
    } catch (err: any) {
      setError(err.message || "Signup failed");
      setLoading(false);
    }
  };

  return (
    <div className="screen active calm-gradient">
      <div className="form-container flex flex-col justify-center h-full">
        <h1 className="form-title">Create Account</h1>
        <p className="form-subtitle">
          Start your journey with us today.
        </p>
        <form className="form-group" onSubmit={handleSubmit}>
          <input
            id="signup-username"
            type="text"
            className="form-input"
            placeholder="Username"
            value={username}
            onChange={e => setUsername(e.target.value)}
            autoComplete="username"
            required
            disabled={loading}
          />
          <input
            id="signup-phone"
            type="tel"
            className="form-input"
            placeholder="Phone Number (e.g., +16505551234)"
            value={phone}
            onChange={e => setPhone(e.target.value)}
            autoComplete="tel"
            required
            disabled={loading}
          />
          <input
            id="signup-age"
            type="number"
            className="form-input"
            placeholder="Age"
            value={age}
            onChange={e => setAge(e.target.value)}
            min={1}
            max={120}
            required
            disabled={loading}
          />
          <input
            id="signup-password"
            type="password"
            className="form-input"
            placeholder="Password"
            value={password}
            onChange={e => setPassword(e.target.value)}
            autoComplete="new-password"
            required
            disabled={loading}
          />
          {error && (
            <div className="text-red-500 text-sm mt-2">{error}</div>
          )}
          <button
            type="submit"
            className="form-button mt-4"
            disabled={
              loading ||
              !username ||
              !phone ||
              !age ||
              !password
            }
          >
            {loading ? <div className="loader mx-auto" /> : "Sign Up"}
          </button>
        </form>
        <p className="text-center text-sm mt-6">
          Already have an account?{" "}
          <a
            href="#"
            className="form-link"
            onClick={e => {
              e.preventDefault();
              navigateTo("login");
            }}
          >
            Login
          </a>
        </p>
      </div>
    </div>
  );
};

export default SignupScreen;
