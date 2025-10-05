import React from 'react'
import { registerServiceWorker } from './sw/register'
import MoodEntry from './ui/MoodEntry'

export default function App() {
  React.useEffect(() => {
    registerServiceWorker()
  }, [])

  return (
    <div style={{ padding: 24 }}>
      <h1>Mood Web (PWA)</h1>
      <MoodEntry />
    </div>
  )
}
