import React, { useState } from 'react'
import '../styles/journal.css'

export default function Journal(): JSX.Element {
  const [text, setText] = useState('')
  const [voice, setVoice] = useState(false)

  return (
    <main style={{ padding: 16 }}>
      <div className="card" style={{ padding: 18 }}>
        <h2>Your expression</h2>
        <p>Feel free to jot down whatever comes to mind.</p>
        <textarea className="journal-textarea" rows={8} value={text} onChange={(e) => setText(e.target.value)} placeholder="Write your thoughts here..." />
        <div style={{ display: 'flex', gap: 12, marginTop: 12 }}>
          <button onClick={() => setVoice(v => !v)} className={voice ? 'voice-button active' : 'voice-button'}>{voice ? 'Stop voice' : 'Use voice'}</button>
          <button className="continue-button">Continue</button>
        </div>
      </div>
    </main>
  )
}
