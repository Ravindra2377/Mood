import React, { useEffect, useRef, useState } from 'react'
import BottomNav from './BottomNav'
import '../styles/meditation.css'

const formatTime = (s: number) => {
  const mm = Math.floor(s / 60).toString().padStart(2, '0')
  const ss = Math.floor(s % 60).toString().padStart(2, '0')
  return `${mm}:${ss}`
}

export default function Meditation() {
  const [seconds, setSeconds] = useState(300)
  const [running, setRunning] = useState(false)
  const intervalRef = useRef<number | null>(null)

  useEffect(() => {
    if (running && intervalRef.current === null) {
      intervalRef.current = window.setInterval(() => {
        setSeconds(prev => {
          if (prev <= 1) {
            setRunning(false)
            if (intervalRef.current) { clearInterval(intervalRef.current); intervalRef.current = null }
            return 0
          }
          return prev - 1
        })
      }, 1000)
    }
    if (!running && intervalRef.current !== null) {
      clearInterval(intervalRef.current); intervalRef.current = null
    }
    return () => { if (intervalRef.current) { clearInterval(intervalRef.current); intervalRef.current = null } }
  }, [running])

  const onToggle = () => setRunning(r => !r)
  const onReset = () => { setRunning(false); setSeconds(300) }
  const onShort = (mins: number) => { setSeconds(mins * 60); setRunning(true) }

  return (
    <div className="soul-app-root">
      <header className="app-header">
        <div />
        <div style={{ textAlign: 'center' }}>
          <div className="app-title">SOUL</div>
          <div className="app-subtitle">Breathing meditation</div>
        </div>
        <div />
      </header>

      <main className="meditation-main">
        <section className="med-card" role="region" aria-label="Meditation session">
          <div className="med-visual" aria-hidden>
            <svg width="220" height="220" viewBox="0 0 220 220" className="med-svg" focusable="false">
              <defs>
                <radialGradient id="g1" cx="50%" cy="40%">
                  <stop offset="0%" stopColor="#fef7ff" />
                  <stop offset="100%" stopColor="#f3eafe" />
                </radialGradient>
              </defs>
              <circle cx="110" cy="90" r="80" fill="url(#g1)" />
              <circle cx="110" cy="90" r="44" fill="#fff" />
            </svg>
          </div>

          <div className="med-info">
            <div className="med-time" aria-live="polite">{formatTime(seconds)}</div>

            <div className="med-controls" role="toolbar" aria-label="Preset durations">
              <button className="control-btn" onClick={() => onShort(1)} aria-label="1 minute session">1m</button>
              <button className="control-btn" onClick={() => onShort(5)} aria-label="5 minute session">5m</button>
              <button className="control-btn" onClick={() => onShort(10)} aria-label="10 minute session">10m</button>
            </div>

            <div className="med-action-row">
              <button className="med-action secondary" onClick={onReset} aria-label="Reset timer">Reset</button>
              <button className={`med-action center ${running ? 'pause' : 'play'}`} onClick={onToggle} aria-pressed={running} aria-label={running ? 'Pause meditation' : 'Start meditation'}>{running ? '❚❚' : '▶'}</button>
              <button className="med-action secondary" onClick={() => setSeconds(s => Math.max(30, s - 30))} aria-label="Skip back 30 seconds">-30s</button>
            </div>

            <p className="med-note">Follow the breath: inhale 4s, hold 4s, exhale 6s.</p>
          </div>
        </section>
      </main>

      <BottomNav />
    </div>
  )
}
import React from 'react'
import BottomNav from './BottomNav'

export default function Meditation() {
  const [running, setRunning] = React.useState(false)
  const [seconds, setSeconds] = React.useState(90)

  React.useEffect(() => {
    let id: number | undefined
    if (running) {
      id = window.setInterval(() => setSeconds(s => Math.max(0, s - 1)), 1000)
    }
    return () => { if (id) window.clearInterval(id) }
  }, [running])

  function toggle() {
    setRunning(r => !r)
  }

  function reset() {
    setRunning(false)
    setSeconds(90)
  }

  const mins = Math.floor(seconds / 60)
  const secs = seconds % 60

  return (
    <div style={{ paddingBottom: 110 }}>
      <header className="app-header">
        <div>
          <div className="app-title">SOUL</div>
          <div className="app-subtitle">Breathing meditation</div>
        </div>
        <div aria-hidden style={{ width: 40, height: 40 }} />
      </header>

      <main style={{ padding: 16, display: 'flex', flexDirection: 'column', gap: 16, alignItems: 'center' }}>
        <div style={{ width: '100%', maxWidth: 420, background: 'linear-gradient(180deg,#fbf8ff,#f2f8ff)', borderRadius: 16, padding: 20, textAlign: 'center', boxShadow: '0 8px 28px rgba(2,6,23,0.06)' }}>
          <div style={{ fontSize: 14, color: 'var(--muted)', marginBottom: 12 }}>5 minutes</div>
          <div style={{ fontSize: 22, fontWeight: 700, marginBottom: 8 }}>Breathing meditation</div>
          <div style={{ width: 180, height: 180, borderRadius: 90, background: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '12px auto', boxShadow: '0 8px 24px rgba(2,6,23,0.08)' }}>
            <div style={{ fontSize: 28, fontWeight: 700 }}>{`${mins}:${secs.toString().padStart(2, '0')}`}</div>
          </div>
          <div style={{ display: 'flex', gap: 12, justifyContent: 'center' }}>
            <button onClick={toggle} style={{ padding: '10px 18px', borderRadius: 12, border: 'none', background: running ? '#f3f4f6' : 'var(--soul-accent)', color: running ? '#111' : '#fff', cursor: 'pointer' }}>{running ? 'Pause' : 'Start'}</button>
            <button onClick={reset} style={{ padding: '10px 18px', borderRadius: 12, border: '1px solid #e6eef8', background: '#fff' }}>Reset</button>
          </div>
        </div>
      </main>

      <BottomNav />
    </div>
  )
}
