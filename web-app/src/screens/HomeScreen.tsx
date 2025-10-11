import React, { useState, useEffect } from "react";

interface HomeScreenProps {
  user?: { username?: string };
  navigateTo: (screen: string) => void;
  isDarkMode?: boolean;
}

const QUOTES = [
  {
    text: "A wise woman wishes to be no one's enemy; a wise woman refuses to be anyone's victim.",
    author: "Maya Angelou",
  },
  {
    text: "The greatest wealth is a quiet mind.",
    author: "Anonymous",
  },
  {
    text: "You are not your thoughts. You are the awareness behind them.",
    author: "Eckhart Tolle",
  },
  {
    text: "Self-care is how you take your power back.",
    author: "Lalah Delia",
  },
  {
    text: "You can't stop the waves, but you can learn to surf.",
    author: "Jon Kabat-Zinn",
  },
];

const MOODS = [
  { emoji: "😡", label: "Angry" },
  { emoji: "😔", label: "Sad" },
  { emoji: "😐", label: "Neutral" },
  { emoji: "🙂", label: "Content" },
  { emoji: "😄", label: "Happy" },
];

const HomeScreen: React.FC<HomeScreenProps> = ({ user, navigateTo }) => {
  const [selectedMood, setSelectedMood] = useState<number | null>(null);
  const [quote, setQuote] = useState<{ text: string; author: string }>(QUOTES[0]);

  useEffect(() => {
    // Pick a random quote on mount
    setQuote(QUOTES[Math.floor(Math.random() * QUOTES.length)]);
  }, []);

  const handleMoodSelect = (idx: number) => {
    setSelectedMood(idx);
    // TODO: Send mood to backend if needed
  };

  return (
    <div className="screen active calm-gradient overflow-y-auto">
      <header className="page-header">
        <div>
          <h2 className="user-greeting">
            Hi, {user?.username ? user.username : "there"}
          </h2>
          <p className="user-subtitle">How are you doing today?</p>
        </div>
        <div className="avatar">
          <img
            src="https://i.pravatar.cc/100?u=olivia"
            alt="User Avatar"
          />
        </div>
      </header>

      <div className="mood-section">
        <h3 className="mood-title">Daily mood</h3>
        <div className="mood-emojis">
          {MOODS.map((mood, idx) => (
            <span
              key={mood.emoji}
              className={`mood-emoji${selectedMood === idx ? " selected" : ""}`}
              title={mood.label}
              onClick={() => handleMoodSelect(idx)}
              tabIndex={0}
              role="button"
              aria-label={mood.label}
            >
              {mood.emoji}
            </span>
          ))}
        </div>
      </div>

      <div className="activities-section">
        <h3 className="mood-title">Activities</h3>
        <div className="activities-grid">
          <div
            className="activity-card meditation"
            onClick={() => navigateTo("breathing")}
            tabIndex={0}
            role="button"
            aria-label="Meditation"
          >
            <span className="activity-emoji">🧘‍♀️</span>
            <span className="activity-name">Meditation</span>
          </div>
          <div
            className="activity-card journal"
            onClick={() => navigateTo("journal")}
            tabIndex={0}
            role="button"
            aria-label="Journal"
          >
            <span className="activity-emoji">📓</span>
            <span className="activity-name">Journal</span>
          </div>
        </div>
      </div>

      <div className="quote-card card">
        <div className="quote-header">✨ Quote of the Day</div>
        <div className="quote-text">{`"${quote.text}"`}</div>
        <div className="quote-author">{`- ${quote.author} -`}</div>
      </div>

      <div className="activities-section">
        <h3 className="mood-title">Content and Guidance</h3>
        <div className="space-y-3">
          <div className="card flex items-center space-x-4">
            <div className="w-16 h-16 rounded-xl bg-purple-200 flex items-center justify-center text-3xl">
              🎨
            </div>
            <div>
              <p className="font-semibold">How to find balance in life</p>
              <p className="text-sm text-gray-500 dark:text-gray-400">
                Article • 4 min
              </p>
            </div>
          </div>
          <div className="card flex items-center space-x-4">
            <div className="w-16 h-16 rounded-xl bg-green-200 flex items-center justify-center text-3xl">
              🎬
            </div>
            <div>
              <p className="font-semibold">It's okay to ask for help</p>
              <p className="text-sm text-gray-500 dark:text-gray-400">
                Video • 8 min
              </p>
            </div>
          </div>
        </div>
      </div>

      <div style={{ height: "96px" }} />
    </div>
  );
};

export default HomeScreen;
