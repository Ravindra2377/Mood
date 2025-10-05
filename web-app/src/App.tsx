import React from 'react'
import { registerServiceWorker } from './sw/register'
import MoodEntry from './ui/MoodEntry'
import DiaryView from './ui/DiaryView'
import ToastProvider from './ui/Toast'

export default function App() {
  React.useEffect(() => {
    registerServiceWorker()
  }, [])

  return (
    <ToastProvider>
      <div style={{ padding: 24 }}>
        <h1>SOUL</h1>
        <p>Welcome to SOUL — your mental health companion.</p>
        <MoodEntry />
        <hr />
        <DiaryView />
      </div>
    </ToastProvider>
  )
}
