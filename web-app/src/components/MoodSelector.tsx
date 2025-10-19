import React from 'react';

interface MoodSelectorProps {
  selectedMood: number;
  onMoodSelect: (mood: number) => void;
}

export const MoodSelector: React.FC<MoodSelectorProps> = ({ selectedMood, onMoodSelect }) => {
  const moods = [
    { value: 1, image: '/mood-1.png', color: '#FF8FA3' },
    { value: 2, image: '/mood-2.png', color: '#8FB4FF' },
    { value: 3, image: '/mood-3.png', color: '#A8A8A8' },
    { value: 4, image: '/mood-4.png', color: '#FFE66D' },
    { value: 5, image: '/mood-5.png', color: '#A8E6CF' }
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
          <img src={mood.image} alt={`Mood ${mood.value}`} className="mood-emoji" />
        </button>
      ))}
    </div>
  );
};
