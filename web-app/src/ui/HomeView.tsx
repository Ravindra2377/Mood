import React, { useEffect, useState } from 'react'
import '../styles/theme.css'
import JournalEditor from './JournalEditor'

function AnimatedDonut({ percent = 78, duration = 900 }: { percent?: number, duration?: number }) {
  const radius = 60
  const stroke = 12
  const r = radius
  const circumference = 2 * Math.PI * r
  const [offset, setOffset] = React.useState(circumference)
  const [display, setDisplay] = React.useState(0)

  React.useEffect(() => {
    // animate stroke-dashoffset from full to target
    const target = circumference * (1 - Math.min(Math.max(percent, 0), 100) / 100)
    const start = circumference
    const startTime = performance.now()
    function frame(now: number) {
      const t = Math.min(1, (now - startTime) / duration)
      const eased = 1 - Math.pow(1 - t, 3)
      setOffset(start + (target - start) * eased)
      setDisplay(Math.round(eased * percent))
      if (t < 1) requestAnimationFrame(frame)
      else setDisplay(percent)
    }
    requestAnimationFrame(frame)
  }, [percent, circumference, duration])

  return (
    <svg width={(r + stroke) * 2} height={(r + stroke) * 2} viewBox={`0 0 ${(r + stroke) * 2} ${(r + stroke) * 2}`}>
      <g transform={`translate(${r + stroke},${r + stroke})`}>
        <circle r={r} fill="none" stroke="#eef2ff" strokeWidth={stroke} />
        <circle r={r} fill="none" stroke="#60a5fa" strokeWidth={stroke} strokeDasharray={`${circumference}`} strokeDashoffset={offset} transform="rotate(-90)" style={{ transition: 'stroke-dashoffset 280ms linear' }} />
        <circle r={r - 6} fill="white" />
        <text x="0" y="6" textAnchor="middle" fontSize={22} fontWeight={700} fill="#0f172a">{display}%</text>
      </g>
    </svg>
  )
}

export default function HomeView() {
  const [latest, setLatest] = useState(null)
  const [editing, setEditing] = useState(null)

  useEffect(() => {
    async function loadLatest() {
      try {
        const res = await fetch('/api/journals?limit=1', { credentials: 'include' })
        if (res.ok) {
          const data = await res.json()
          setLatest(data && data.length ? data[0] : null)
        }
      } catch (e) {
        console.error(e)
      }
    }
    loadLatest()
  }, [])

  return (
    <div className="home-root">
      {/* left skinny nav */}
      <div className="nav-slab">
        <div style={{ height: 48, width: 48, borderRadius: 12, background: '#111827', marginBottom: 12 }} />
        <div style={{ height: 48, width: 48, borderRadius: 12, background: '#fff', border: '1px solid #e6eef8', marginBottom: 8 }} />
        <div style={{ height: 48, width: 48, borderRadius: 12, background: '#fff', border: '1px solid #e6eef8' }} />
      </div>

      {/* main content area */}
  <div className="main">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
          <div>
            <div style={{ fontSize: 20, color: '#0f172a', fontWeight: 700 }}>Hi, Olivia</div>
            <div style={{ color: '#475569' }}>How are you doing today?</div>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <input placeholder="Search" style={{ padding: '8px 12px', borderRadius: 22, border: '1px solid #e6eef8', width: 300 }} />
            <div style={{ width: 40, height: 40, borderRadius: 20, background: '#fff', border: '1px solid #e6eef8' }} />
          </div>
        </div>

        <div style={{ display: 'flex', gap: 18 }}>
          <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 18 }}>
            {/* Activities */}
            <div>
              <div style={{ fontWeight: 700, color: '#0f172a', marginBottom: 12 }}>Activities</div>
              <div className="activities-row">
                {['Yoga', 'Journal', 'Practices', 'Journal'].map((t, i) => (
                  <div key={t} className={`activity-card ${i === 0 ? 'activity-primary' : 'activity-secondary'} fade-up`}>
                    <div style={{ fontWeight: 700 }}>{t}</div>
                  </div>
                ))}
              </div>
            </div>

            {/* Self Help Quote */}
            <div>
              <div style={{ fontWeight: 700, marginBottom: 8 }}>Self Help</div>
              <div style={{ background: 'linear-gradient(90deg,#fbcff4,#f2f8ff)', padding: 22, borderRadius: 12, color: '#111827', boxShadow: '0 6px 18px rgba(2,6,23,0.04)' }}>
                <div style={{ fontStyle: 'italic', textAlign: 'center', fontWeight: 600 }}>“Success is not final, failure is not fatal: it is the courage to continue that counts.”</div>
              </div>

              <div style={{ display: 'flex', gap: 12, marginTop: 12 }}>
                <button className="card">Journal</button>
                <button className="card">Practices</button>
              </div>

              <div style={{ marginTop: 12 }} className="content-list">
                <div className="card">How to find balance in life despite... <span style={{ float: 'right', color: 'var(--muted)' }}>Article • 4 min</span></div>
                <div className="card">It's okay to ask for help, you're not alone <span style={{ float: 'right', color: 'var(--muted)' }}>Video • 8 min</span></div>
              </div>
            </div>
          </div>

          {/* Right column: physical state + journal box */}
          <div style={{ width: 420, display: 'flex', flexDirection: 'column', gap: 18 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div style={{ fontWeight: 700 }}>Physical state</div>
              <div style={{ display: 'flex', gap: 8 }}>
                <div style={{ padding: '8px 10px', borderRadius: 10, background: 'white', border: '1px solid #e6eef8' }}>Sleep Goal<br/><strong>8h Target</strong></div>
                <div style={{ padding: '8px 10px', borderRadius: 10, background: 'white', border: '1px solid #e6eef8' }}>Last night<br/><strong>7.5h Achieved</strong></div>
              </div>
            </div>

            <div className="donut-row">
              <div className="fade-up">
                <AnimatedDonut percent={78} />
              </div>
              <div style={{ flex: 1 }}>
                <div className="card">{latest ? latest.content : 'Sometimes it feels like no matter what we do, things only get worse.'}</div>
                <div style={{ textAlign: 'right', color: 'var(--muted)', fontSize: 12, marginTop: 6 }}>{latest ? `${(latest.content || '').length}/240` : '68/240'}</div>
                {latest && <div style={{ marginTop: 8 }}><button className="card" onClick={() => setEditing(latest)}>Quick Edit</button></div>}
              </div>
            </div>
          </div>
        </div>
      </div>

      {editing && (
        <>
          <div className="overlay" onClick={() => setEditing(null)} />
          <div className="modal fade-up">
            <JournalEditor
              date={(editing.entry_date || '').slice(0, 10)}
              initial={editing}
              onSaved={(entry?: any) => {
                // entry === null means deleted
                if (entry === null) {
                  setLatest(null)
                } else if (entry) {
                  setLatest(entry)
                }
                setEditing(null)
              }}
            />
          </div>
        </>
      )}

    </div>
  )
}
