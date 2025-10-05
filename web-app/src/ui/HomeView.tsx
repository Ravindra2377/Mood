import React, { useEffect, useState } from 'react'
import '../styles/theme.css'
import JournalEditor from './JournalEditor'

function Donut({ percent = 78 }: { percent?: number }) {
  const radius = 60
  const stroke = 12
  const cx = radius + stroke
  const cy = radius + stroke
  const r = radius
  const c = 2 * Math.PI * r
  const filled = (percent / 100) * c
  const gap = c - filled
  return (
    <svg width={(r + stroke) * 2} height={(r + stroke) * 2} viewBox={`0 0 ${(r + stroke) * 2} ${(r + stroke) * 2}`}>
      <g transform={`translate(${cx},${cy})`}>
        <circle r={r} fill="none" stroke="#eef2ff" strokeWidth={stroke} />
        {/* three colored arcs using stroke-dasharray hack by overlaying segments */}
        <circle r={r} fill="none" stroke="#fbcfe8" strokeWidth={stroke} strokeDasharray={`${c * 0.25} ${c}`} strokeDashoffset={-c * 0.0} transform="rotate(-90)" />
        <circle r={r} fill="none" stroke="#fef08a" strokeWidth={stroke} strokeDasharray={`${c * 0.28} ${c}`} strokeDashoffset={-c * 0.25} transform="rotate(-90)" />
        <circle r={r} fill="none" stroke="#bfdbfe" strokeWidth={stroke} strokeDasharray={`${c * 0.47} ${c}`} strokeDashoffset={-c * 0.53} transform="rotate(-90)" />
        <circle r={r - 6} fill="white" />
        <text x="0" y="6" textAnchor="middle" fontSize={22} fontWeight={700} fill="#0f172a">{percent}%</text>
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
                <Donut percent={78} />
              </div>
              <div style={{ flex: 1 }}>
                <div className="card">Sometimes it feels like no matter what we do, things only get worse.</div>
                <div style={{ textAlign: 'right', color: 'var(--muted)', fontSize: 12, marginTop: 6 }}>68/240</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {editing && (
        <>
          <div className="overlay" onClick={() => setEditing(null)} />
          <div className="modal fade-up">
            <JournalEditor date={(editing.entry_date || '').slice(0, 10)} onSaved={() => { setEditing(null); window.location.reload() }} initial={editing} />
          </div>
        </>
      )}

    </div>
  )
}
