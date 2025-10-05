import React, { useState } from 'react'
import { enqueueMood } from '../sw/queue'

export default function MoodEntry() {
  const [rating, setRating] = useState(3)
  const [note, setNote] = useState('')
  const [status, setStatus] = useState('')

  async function save() {
    try {
      await enqueueMood({ rating, note, timestamp: new Date().toISOString() })
      setStatus('Saved locally')
    } catch (e) {
      setStatus('Save failed')
    }
  }

  return (
    <div>
      <label>
        Rating:
        <input
          type="range"
          min={1}
          max={5}
          value={rating}
          onChange={(e: Event) => setRating(Number((e.target as HTMLInputElement).value))}
        />
      </label>
      <div>
  <textarea value={note} onChange={(e: Event) => setNote((e.target as HTMLTextAreaElement).value)} />
      </div>
      <button onClick={save}>Save</button>
      <div>{status}</div>
    </div>
  )
}
