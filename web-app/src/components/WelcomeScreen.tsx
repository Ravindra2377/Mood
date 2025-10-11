import React from 'react';
import { BrainCharacter } from './Characters';
import '../styles/WelcomeScreen.css';

interface WelcomeScreenProps {
  onComplete: (name: string) => void;
}

const WelcomeScreen: React.FC<WelcomeScreenProps> = ({ onComplete }) => {
  const handleStartJourney = () => {
    onComplete('Olivia');
  };

  return (
    <div className="welcome-container">
      <div className="welcome-content">
        <div className="brand-header">
          <h1 className="brand-name">SOUL</h1>
          <div className="brand-dot" />
        </div>

        <div className="character-container floating-element">
          <BrainCharacter />
        </div>

        <div className="welcome-text">
          <h2>Your mental health matters</h2>
          <p>Start your journey with us</p>
        </div>

        <button className="cta-button" onClick={handleStartJourney}>
          Let's start now
        </button>
      </div>
    </div>
  );
};

export default WelcomeScreen;
