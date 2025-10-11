import React, { useEffect, useRef, useState } from 'react'
import BottomNav from './BottomNav'
import '../styles/meditation.css'

const sounds = ['Ocean breeze', 'Forest sounds', 'Rain drops', 'White noise']

const formatTime = (s: number): string => {
  const mm = Math.floor(s / 60).toString().padStart(2, '0')
  const ss = Math.floor(s % 60).toString().padStart(2, '0')
  return `${mm}:${ss}`
}

export default function Meditation(): JSX.Element {
  const [seconds, setSeconds] = useState(5 * 60)
  const [running, setRunning] = useState(false)
  const [selectedSound, setSelectedSound] = useState<string>(sounds[0])
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

  const mins = Math.floor(seconds / 60)
  const secs = seconds % 60

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
          <div className="med-header" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <div style={{ fontSize: 14, color: 'var(--text-muted)' }}>{Math.floor((5 * 60) / 60)} minutes</div>
            <div className="sound-selector" style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
              <select value={selectedSound} onChange={(e) => setSelectedSound(e.target.value)}>
                {sounds.map(s => <option key={s} value={s}>{s}</option>)}
              </select>
            </div>
          </div>

          <div className="med-stage" style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 12 }}>
            <div className="med-character card" aria-hidden>
              {/* Decorative character area - can be replaced with animated SVG */}
              <div style={{ width: 200, height: 200, borderRadius: 100, background: 'rgba(240,236,255,0.7)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <div style={{ fontSize: 48 }}>🧘</div>
              </div>
            </div>

            <div className="med-time-large" aria-live="polite" style={{ fontSize: 36, fontWeight: 700 }}>{`${mins.toString().padStart(2,'0')}:${secs.toString().padStart(2,'0')}`}</div>

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
