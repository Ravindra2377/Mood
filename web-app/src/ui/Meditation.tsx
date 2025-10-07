import React, { useEffect, useRef, useState } from 'react'
import BottomNav from './BottomNav'
import '../styles/meditation.css'

const formatTime = (s: number): string => {
  const mm = Math.floor(s / 60).toString().padStart(2, '0')
  const ss = Math.floor(s % 60).toString().padStart(2, '0')
  return `${mm}:${ss}`
}

export default function Meditation(): JSX.Element {
  const [seconds, setSeconds] = useState(300)
  const [running, setRunning] = useState(false)
  const intervalRef = useRef(null as number | null)

  useEffect(() => {
    if (running && intervalRef.current === null) {
      intervalRef.current = window.setInterval(() => {
        setSeconds((prev: number) => {
          if (prev <= 1) {
            setRunning(false)
            if (intervalRef.current) {
              clearInterval(intervalRef.current)
              intervalRef.current = null
            }
            return 0
          }
          return prev - 1
        })
      }, 1000)
    }
    if (!running && intervalRef.current !== null) {
      clearInterval(intervalRef.current)
      intervalRef.current = null
    }
    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current)
        intervalRef.current = null
      }
    }
  }, [running])

  const onToggle = (): void => setRunning((r: boolean) => !r)
  const onReset = (): void => {
    setRunning(false)
    setSeconds(300)
  }
  const onShort = (mins: number): void => {
    setSeconds(mins * 60)
    setRunning(true)
  }

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
              <button className="med-action secondary" onClick={() => setSeconds((s: number) => Math.max(30, s - 30))} aria-label="Skip back 30 seconds">-30s</button>
            </div>

            <p className="med-note">Follow the breath: inhale 4s, hold 4s, exhale 6s.</p>
          </div>
        </section>
      </main>

      <BottomNav />
    </div>
  )
}
