import React, { useState, useRef, useEffect } from "react";

interface BreathingScreenProps {
  navigateTo: (screen: string) => void;
  isDarkMode?: boolean;
}

const BREATH_CYCLE = ["Inhale...", "Hold...", "Exhale...", "Hold..."];
const BREATH_INTERVAL = 4000; // ms
const INITIAL_SECONDS = 94; // 1:34

const BreathingScreen: React.FC<BreathingScreenProps> = ({
  navigateTo,
  isDarkMode,
}) => {
  const [timer, setTimer] = useState(INITIAL_SECONDS);
  const [isPlaying, setIsPlaying] = useState(true);
  const [breathIndex, setBreathIndex] = useState(0);
  const [breathText, setBreathText] = useState(BREATH_CYCLE[0]);
  const breathIntervalRef = useRef<NodeJS.Timeout | null>(null);
  const timerIntervalRef = useRef<NodeJS.Timeout | null>(null);

  // Start breathing cycle
  useEffect(() => {
    if (isPlaying) {
      breathIntervalRef.current = setInterval(() => {
        setBreathIndex((prev) => (prev + 1) % BREATH_CYCLE.length);
      }, BREATH_INTERVAL);
      timerIntervalRef.current = setInterval(() => {
        setTimer((prev) => (prev > 0 ? prev - 1 : 0));
      }, 1000);
    }
    return () => {
      if (breathIntervalRef.current) clearInterval(breathIntervalRef.current);
      if (timerIntervalRef.current) clearInterval(timerIntervalRef.current);
    };
  }, [isPlaying]);

  // Update breath text
  useEffect(() => {
    setBreathText(BREATH_CYCLE[breathIndex]);
  }, [breathIndex]);

  // Stop breathing when timer ends
  useEffect(() => {
    if (timer === 0) {
      setIsPlaying(false);
      if (breathIntervalRef.current) clearInterval(breathIntervalRef.current);
      if (timerIntervalRef.current) clearInterval(timerIntervalRef.current);
    }
  }, [timer]);

  // Play/Pause handler
  const handlePlayPause = () => {
    setIsPlaying((prev) => !prev);
  };

  // Reset when entering screen
  useEffect(() => {
    setTimer(INITIAL_SECONDS);
    setIsPlaying(true);
    setBreathIndex(0);
    setBreathText(BREATH_CYCLE[0]);
  }, []);

  // Format timer
  const formatTime = (seconds: number) => {
    const m = String(Math.floor(seconds / 60)).padStart(2, "0");
    const s = String(seconds % 60).padStart(2, "0");
    return `${m}:${s}`;
  };

  return (
    <div className="screen active calm-gradient breathing-container">
      <header className="breathing-header">
        <button
          className="back-button"
          onClick={() => navigateTo("home")}
          aria-label="Back to Home"
        >
          <svg
            className="w-6 h-6"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M15 19l-7-7 7-7"
            />
          </svg>
        </button>
        <select
          className="bg-white/50 dark:bg-gray-800/50 rounded-full px-4 py-1 text-sm font-semibold focus:outline-none"
          defaultValue="Ocean Breeze"
          style={{ minWidth: 120 }}
        >
          <option>Ocean Breeze</option>
          <option>Rainfall</option>
          <option>Forest</option>
        </select>
        <div style={{ width: 40 }} />
      </header>
      <div className="breathing-content">
        <p className="text-sm font-semibold text-gray-500 dark:text-gray-400">
          5 minutes
        </p>
        <p className="text-xl font-bold">Breathing meditation</p>
        <div className="breathing-circle mt-8">
          <svg viewBox="0 0 100 100" className="breathing-character">
            <g transform="translate(5,5) scale(0.9)">
              <path
                d="M45,20 a5,5 0 1,1 10,0 a5,5 0 1,1 -10,0"
                fill="#4A5568"
              />
              <path d="M30 40 C 30 30, 70 30, 70 40" fill="#FEEBC8" />
              <path
                d="M35 40 Q 50 50, 65 40"
                fill="none"
                stroke="#4A5568"
                strokeWidth={2}
                strokeLinecap="round"
              />
              <path d="M42 45 a2 2 0 1 1 0.1 0" fill="#4A5568" />
              <path d="M58 45 a2 2 0 1 1 0.1 0" fill="#4A5568" />
              <path
                d="M40 60 H 60"
                fill="none"
                stroke="#4A5568"
                strokeWidth={2}
                strokeLinecap="round"
              />
              <path
                d="M20 70 Q 50 50, 80 70 L 70 90 H 30 Z"
                fill="#FBBF24"
              />
              <path
                d="M30 70 L 10 75"
                fill="none"
                stroke="#4A5568"
                strokeWidth={3}
                strokeLinecap="round"
              />
              <path
                d="M70 70 L 90 75"
                fill="none"
                stroke="#4A5568"
                strokeWidth={3}
                strokeLinecap="round"
              />
            </g>
          </svg>
        </div>
        <p className="breathing-text">{breathText}</p>
      </div>
      <div className="breathing-controls">
        <p className="timer-display">{formatTime(timer)}</p>
        <button
          className="play-pause-button"
          onClick={handlePlayPause}
          aria-label={isPlaying ? "Pause" : "Play"}
        >
          {isPlaying ? (
            <svg
              className="w-8 h-8"
              fill="currentColor"
              viewBox="0 0 20 20"
            >
              <path
                fillRule="evenodd"
                d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zM7 8a1 1 0 012 0v4a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v4a1 1 0 102 0V8a1 1 0 00-1-1z"
                clipRule="evenodd"
              />
            </svg>
          ) : (
            <svg
              className="w-8 h-8"
              fill="currentColor"
              viewBox="0 0 20 20"
            >
              <path
                fillRule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z"
                clipRule="evenodd"
              />
            </svg>
          )}
        </button>
      </div>
    </div>
  );
};

export default BreathingScreen;
