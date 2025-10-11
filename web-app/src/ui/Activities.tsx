import React from 'react'
import '../styles/activities.css'

export default function Activities(): JSX.Element {
  return (
    <main style={{ padding: 16 }}>
      <div className="card" style={{ padding: 18 }}>
        <h2>Your Activities</h2>
        <div style={{ display: 'flex', gap: 12, marginTop: 12 }}>
          <div className="activity-card">Sleeping Time<br/><strong>8h 34m</strong></div>
          <div className="activity-card">Mood Level<br/><strong>8/10</strong></div>
          <div className="activity-card">Activity<br/><strong>2h</strong></div>
        </div>
      </div>
    </main>
  )
}
