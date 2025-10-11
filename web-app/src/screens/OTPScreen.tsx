import React, { useState } from "react";

interface OTPScreenProps {
  onVerify: (otp: string) => Promise<void>;
  navigateTo: (screen: string) => void;
  isDarkMode?: boolean;
  user?: any;
}

const OTPScreen: React.FC<OTPScreenProps> = ({
  onVerify,
  navigateTo,
  isDarkMode,
}) => {
  const [otp, setOtp] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setLoading(true);
    try {
      await onVerify(otp);
    } catch (err: any) {
      setError(err.message || "OTP verification failed");
      setLoading(false);
    }
  };

  return (
    <div className="screen active calm-gradient">
      <div className="form-container flex flex-col justify-center h-full">
        <h1 className="form-title">Verify Phone</h1>
        <p className="form-subtitle">
          Enter the OTP sent to your phone.
        </p>
        <form className="form-group" onSubmit={handleSubmit}>
          <input
            id="otp-input"
            type="text"
            className="form-input text-center tracking-widest text-2xl"
            placeholder="6-digit code"
            value={otp}
            onChange={e => setOtp(e.target.value.replace(/\D/g, ""))}
            maxLength={6}
            required
            disabled={loading}
            autoFocus
          />
          {error && (
            <div className="text-red-500 text-sm mt-2">{error}</div>
          )}
          <button
            type="submit"
            className="form-button mt-4"
            disabled={loading || otp.length !== 6}
          >
            {loading ? <div className="loader mx-auto" /> : "Verify"}
          </button>
        </form>
        <a
          href="#"
          className="form-link block text-center mt-4"
          onClick={e => {
            e.preventDefault();
            alert("Resend OTP feature coming soon!");
          }}
        >
          Resend OTP
        </a>
      </div>
    </div>
  );
};

export default OTPScreen;
