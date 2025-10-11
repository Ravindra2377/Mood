import React from 'react';

export const BrainCharacter: React.FC = () => (
  <div className="brain-character">
    <div className="brain-body">
      <div className="brain-texture">
        <div className="brain-fold" />
        <div className="brain-fold" />
        <div className="brain-fold" />
      </div>
      <div className="brain-face">
        <div className="brain-eyes">
          <div className="eye left-eye" />
          <div className="eye right-eye" />
        </div>
        <div className="brain-mouth" />
      </div>
    </div>
    <div className="brain-arms">
      <div className="arm left-arm" />
      <div className="arm right-arm" />
    </div>
    <div className="brain-legs">
      <div className="leg left-leg" />
      <div className="leg right-leg" />
    </div>
  </div>
);

interface MeditationCharacterProps {
  isAnimating: boolean;
}

export const MeditationCharacter: React.FC<MeditationCharacterProps> = ({ isAnimating }) => (
  <div className={`meditation-character ${isAnimating ? 'breathing' : ''}`}>
    <div className="character-body">
      <div className="character-head">
        <div className="character-hair" />
        <div className="character-face">
          <div className="character-eyes closed" />
          <div className="character-nose" />
          <div className="character-mouth peaceful" />
        </div>
      </div>
      <div className="character-torso">
        <div className="meditation-pose">
          <div className="lotus-position" />
        </div>
      </div>
    </div>
  </div>
);
