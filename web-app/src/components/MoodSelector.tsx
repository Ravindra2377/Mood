import React from 'react';

interface MoodSelectorProps {
  selectedMood: number;
  onMoodSelect: (mood: number) => void;
}

export const MoodSelector: React.FC<MoodSelectorProps> = ({ selectedMood, onMoodSelect }) => {
  const moods = [
    { value: 1, emoji: '😢', color: '#FF8FA3' },
    { value: 2, emoji: '😕', color: '#8FB4FF' },
    { value: 3, emoji: '😐', color: '#A8A8A8' },
    { value: 4, emoji: '🙂', color: '#FFE66D' },
    { value: 5, emoji: '😊', color: '#A8E6CF' }
  ];

  return (
    <div className="mood-selector">
      {moods.map((mood) => (
        <button
          key={mood.value}
          className={`mood-button ${selectedMood === mood.value ? 'selected' : ''}`}
          onClick={() => onMoodSelect(mood.value)}
          style={{ backgroundColor: selectedMood === mood.value ? mood.color : 'transparent' }}
        >
          <span className="mood-emoji">{mood.emoji}</span>
        </button>
      ))}
    </div>
  );
};
