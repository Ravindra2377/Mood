import React from "react";

interface ProfileScreenProps {
  user?: {
    username?: string;
    phone?: string;
    age?: number;
    language?: string;
  };
  isDarkMode?: boolean;
  navigateTo: (screen: string) => void;
  onSignOut: () => void;
  onToggleDarkMode: () => void;
  onUpdateUser?: (userData: Partial<any>) => void;
}

const ProfileScreen: React.FC<ProfileScreenProps> = ({
  user,
  isDarkMode,
  navigateTo,
  onSignOut,
  onToggleDarkMode,
  onUpdateUser,
}) => {
  return (
    <div className="screen active calm-gradient profile-container overflow-y-auto">
      <header className="profile-header">
        <h2 className="text-2xl font-bold">Profile</h2>
      </header>
      <div className="profile-avatar-section">
        <div className="profile-avatar">
          <img
            src="https://i.pravatar.cc/100?u=olivia"
            alt="User Avatar"
            className="w-full h-full object-cover"
          />
        </div>
        <h3 className="profile-name">{user?.username || "Olivia"}</h3>
        <p className="profile-joined">Joined November 2023</p>
      </div>
      <div className="settings-section">
        <h4 className="settings-title">Settings</h4>
        <div className="settings-list">
          <div className="setting-item card flex justify-between items-center">
            <span>Daily Check-in Reminder</span>
            <label className="switch">
              <input type="checkbox" defaultChecked />
              <span className="slider"></span>
            </label>
          </div>
          <div className="setting-item card flex justify-between items-center">
            <span>Evening Journaling Nudge</span>
            <label className="switch">
              <input type="checkbox" />
              <span className="slider"></span>
            </label>
          </div>
          <div className="setting-item card flex justify-between items-center">
            <span>Dark Mode</span>
            <label className="switch">
              <input
                type="checkbox"
                checked={isDarkMode}
                onChange={onToggleDarkMode}
                id="dark-mode-toggle"
              />
              <span className="slider"></span>
            </label>
          </div>
        </div>
      </div>
      <button
        className="sign-out-button"
        onClick={onSignOut}
        style={{ marginTop: 32 }}
      >
        Sign Out
      </button>
      <div style={{ height: "96px" }} />
    </div>
  );
};

export default ProfileScreen;
