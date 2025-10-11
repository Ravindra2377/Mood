import React from "react";

const SplashScreen: React.FC = () => {
  return (
    <div className="screen active calm-gradient">
      <div className="flex flex-col items-center justify-center h-full p-8 text-center">
        <div className="flex flex-col items-center animate-pulse">
          <span className="text-5xl font-bold mb-2">SOUL</span>
          <p className="text-gray-600 dark:text-gray-400">
            Your mental health companion
          </p>
        </div>
      </div>
    </div>
  );
};

export default SplashScreen;
