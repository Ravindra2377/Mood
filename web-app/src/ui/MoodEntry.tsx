import React, { useState } from 'react'
import { enqueueMood } from '../sw/queue'
import { useToast } from './Toast'
import BottomNav from './BottomNav'

export default function MoodEntry() {
  const [rating, setRating] = useState(3)
  const [note, setNote] = useState('')
  const [status, setStatus] = useState('')
  const btnRefs = React.useRef([] as Array<HTMLButtonElement | null>)
  const toast = (() => { try { return useToast() } catch (_) { return null } })()

  async function save() {
    try {
      await enqueueMood({ rating, note, timestamp: new Date().toISOString() })
      setStatus('Saved locally')
      try { toast?.show('Saved') } catch (e) {}
    } catch (e) {
      setStatus('Save failed')
    }
  }

  React.useEffect(() => {
    function onKey(e: KeyboardEvent) {
      const active = document.activeElement as HTMLElement | null
      if (active) {
        const tag = active.tagName?.toLowerCase()
        if (tag === 'input' || tag === 'textarea' || active.isContentEditable) return
      }
      if (/^[1-5]$/.test(e.key)) {
        const val = Number(e.key)
        setRating(val)
        btnRefs.current[val - 1]?.focus()
      }
    }
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [])

  return (
    <div style={{ paddingBottom: 110 }}>
      <header className="app-header">
        <div>
          <div className="app-title">SOUL</div>
          <div className="app-subtitle">How are you feeling?</div>
        </div>
        <div aria-hidden>
          <div style={{ width: 40, height: 40, borderRadius: 20, background: '#fff', boxShadow: '0 4px 10px rgba(2,6,23,0.06)' }} />
        </div>
      </header>

      <main style={{ padding: 16 }}>
        <div style={{ marginBottom: 8 }}>Rating:</div>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <div role="radiogroup" aria-label="Daily SOUL rating" style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
            {[1, 2, 3, 4, 5].map((i) => {
              const isSelected = rating === i
              return (
                <div key={i} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
                  <button
                    ref={(el: HTMLButtonElement | null) => (btnRefs.current[i - 1] = el)}
                    role="radio"
                    aria-checked={isSelected}
                    tabIndex={isSelected ? 0 : -1}
                    onClick={() => setRating(i)}
                    aria-label={`Rate ${i}`}
                    style={{
                      width: 48,
                      height: 48,
                      borderRadius: 24,
                      border: isSelected ? '2px solid var(--soul-accent)' : '1px solid #e2e8f0',
                      background: 'white',
                      cursor: 'pointer',
                      display: 'inline-flex',
                      alignItems: 'center',
                      justifyContent: 'center'
                    }}
                  >{i}</button>
                  <div style={{ fontSize: 11, color: '#6b7280', marginTop: 6 }}>{i}</div>
                </div>
              )
            })}
          </div>
          <div style={{ marginLeft: 8, color: '#6b7280', fontSize: 13 }} title="Keyboard shortcuts">
            <span style={{ display: 'inline-flex', alignItems: 'center', gap: 8 }}>
              <kbd style={{ background: '#f3f4f6', padding: '2px 6px', borderRadius: 4, border: '1px solid #e5e7eb' }}>1</kbd>
              <span style={{ opacity: 0.8 }}>..</span>
              <kbd style={{ background: '#f3f4f6', padding: '2px 6px', borderRadius: 4, border: '1px solid #e5e7eb' }}>5</kbd>
              <span style={{ marginLeft: 6 }}>press 1–5 to set</span>
            </span>
          </div>
        </div>

        <div style={{ marginTop: 12 }}>
          <textarea value={note} onChange={(e) => setNote((e.target as HTMLTextAreaElement).value)} style={{ width: '100%', minHeight: 120, padding: 12, borderRadius: 12, border: '1px solid #e6eef8' }} />
        </div>

        <div style={{ display: 'flex', gap: 8, marginTop: 12 }}>
          <button onClick={save} style={{ background: 'var(--soul-accent)', color: 'white', padding: '10px 16px', borderRadius: 10, border: 'none', cursor: 'pointer' }}>Save</button>
          <button onClick={() => { setNote(''); setRating(3) }} style={{ background: '#fff', border: '1px solid #e6eef8', padding: '10px 12px', borderRadius: 10 }}>Reset</button>
        </div>

        <div role="status" aria-live="polite" style={{ marginTop: 8, minHeight: 18 }}>{status}</div>
      </main>

      <BottomNav />
    </div>
  )
}
