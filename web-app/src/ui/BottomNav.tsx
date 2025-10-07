import React from 'react'

export default function BottomNav() {
  return (
    <nav className="bottom-nav" role="navigation" aria-label="Primary Navigation">
      <button className="nav-button" aria-label="Home">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M3 11.5L12 4l9 7.5" stroke="#111827" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/></svg>
      </button>
      <button className="nav-button" aria-label="Journal">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><rect x="3" y="4" width="14" height="16" rx="2" stroke="#111827" strokeWidth="1.2"/><path d="M7 8h6" stroke="#111827" strokeWidth="1.2" strokeLinecap="round"/></svg>
      </button>

      <div className="nav-center" aria-hidden>
        <button className="nav-center-btn" aria-label="Main Action">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="#fff" xmlns="http://www.w3.org/2000/svg"><path d="M12 5v14M5 12h14" stroke="#111827" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/></svg>
        </button>
      </div>

      <button className="nav-button" aria-label="Stats">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M3 3v18h18" stroke="#111827" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/><path d="M7 13v6M12 7v12M17 10v9" stroke="#111827" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/></svg>
      </button>
      <button className="nav-button" aria-label="Profile">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2" stroke="#111827" strokeWidth="1.2" strokeLinecap="round" strokeLinejoin="round"/><circle cx="12" cy="7" r="3" stroke="#111827" strokeWidth="1.2"/></svg>
      </button>
    </nav>
  )
}
