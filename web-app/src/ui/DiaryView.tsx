import React, { useEffect, useState } from 'react'
type AnyEvent = any
import JournalEditor from './JournalEditor'

type JournalItem = { id: number; title?: string; content?: string; progress?: number }

export default function DiaryView() {
  const [date, setDate] = useState(new Date().toISOString().slice(0, 10))
  const [entries, setEntries] = useState([] as JournalItem[])
  const [editing, setEditing] = useState(null as JournalItem | null)

  useEffect(() => {
    fetchEntries()
  }, [date])

  async function fetchEntries() {
    try {
      const res = await fetch(`/api/journals?date=${date}`, { credentials: 'include' })
      if (res.ok) {
        const data = await res.json()
        setEntries(data)
      }
    } catch (e) {
      console.error(e)
    }
  }

  return (
    <div>
      <h2>Diary</h2>
      <label>
        Date:
  <input value={date} onChange={(e: AnyEvent) => setDate((e.target as HTMLInputElement).value)} type="date" />
      </label>
      <JournalEditor date={date} onSaved={() => { setEditing(null); fetchEntries() }} initial={editing ?? undefined} />
      <div>
        {entries.length === 0 && <p>No entries for this date</p>}
        {entries.map((e: JournalItem) => (
          <div key={e.id} style={{ border: '1px solid #ddd', padding: 8, marginTop: 8 }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                <h3 style={{ margin: 0 }}>{e.title}</h3>
                <div>{e.content}</div>
                <div>Progress: {e.progress ?? '—'}</div>
              </div>
              <div>
                <button onClick={() => setEditing(e)}>Edit</button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
