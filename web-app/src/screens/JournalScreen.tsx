import React, { useState } from "react";

interface JournalScreenProps {
  user?: { username?: string };
  navigateTo: (screen: string) => void;
  isDarkMode?: boolean;
}

const STATIC_INSIGHTS = [
  "It's completely natural to feel overwhelmed sometimes. Remember that difficult moments are temporary, and you have the strength to navigate through them.",
  "Your feelings are valid and important. Taking time to acknowledge them through writing is a powerful step toward understanding yourself better.",
  "Every challenge you face is an opportunity to grow stronger. You've overcome difficulties before, and you can do it again.",
  "Being gentle with yourself during tough times is not a weakness—it's wisdom. You deserve the same compassion you'd give a good friend.",
  "Your journey is unique, and it's okay to take things one day at a time. Progress doesn't always have to be big leaps forward.",
];

const MAX_LENGTH = 240;

const JournalScreen: React.FC<JournalScreenProps> = ({ user, navigateTo }) => {
  const [entry, setEntry] = useState("");
  const [insight, setInsight] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  // Simulate API call for insight
  const getInsight = async () => {
    if (entry.trim().length < 10) {
      setInsight(
        "Please write a bit more for an insightful reflection."
      );
      return;
    }
    setLoading(true);
    setInsight(null);
    // Simulate delay
    setTimeout(() => {
      const random =
        STATIC_INSIGHTS[
          Math.floor(Math.random() * STATIC_INSIGHTS.length)
        ];
      setInsight(random);
      setLoading(false);
    }, 800);
  };

  // Simulate save to backend
  const saveEntry = async () => {
    // TODO: Replace with real API call
    alert("Journal entry saved!");
    setEntry("");
    setInsight(null);
  };

  return (
    <div className="screen active calm-gradient journal-container">
      <header className="flex justify-between items-center pt-8">
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
        <div className="w-10"></div>
      </header>
      <div className="journal-content">
        <h2 className="journal-title">Your expression</h2>
        <p className="journal-subtitle">
          Feel free to jot down whatever comes to mind.
        </p>
        <div className="journal-textarea-container">
          <textarea
            className="journal-textarea"
            placeholder="Sometimes it feels like..."
            value={entry}
            onChange={e => {
              setEntry(e.target.value.slice(0, MAX_LENGTH));
              setInsight(null);
            }}
            maxLength={MAX_LENGTH}
            rows={8}
          />
          <span className="char-counter">
            {entry.length}/{MAX_LENGTH}
          </span>
        </div>
        <div className="insight-container">
          {loading && (
            <div className="loader mx-auto" />
          )}
          {insight && (
            <div className="insight-card visible">
              <div className="insight-title mb-1">A Gentle Reflection:</div>
              <div>{insight}</div>
            </div>
          )}
        </div>
        <button
          className="insight-button"
          onClick={getInsight}
          disabled={loading || entry.trim().length < 10}
        >
          Get Insight ✨
        </button>
        <button
          className="voice-button"
          onClick={() => alert("Voice journaling coming soon!")}
        >
          Use voice instead 🎙️
        </button>
        <button
          className="form-button mt-4"
          style={{ marginTop: 16 }}
          onClick={saveEntry}
          disabled={loading || entry.trim().length < 10}
        >
          Save Entry
        </button>
      </div>
      <div style={{ height: "64px" }} />
    </div>
  );
};

export default JournalScreen;
