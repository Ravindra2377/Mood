import React, { useState } from 'react'
type AnyEvent = any

export default function JournalEditor({ date, onSaved }: { date: string, onSaved: () => void }) {
  const [title, setTitle] = useState('')
  const [content, setContent] = useState('')
  const [progress, setProgress] = useState('' as number | '')
  const [status, setStatus] = useState('')

  async function save() {
    try {
      const body: any = { title, content }
      if (date) body.entry_date = date
      if (progress !== '') body.progress = Number(progress)
      const res = await fetch('/api/journals', { method: 'POST', headers: { 'Content-Type': 'application/json' }, credentials: 'include', body: JSON.stringify(body) })
      if (res.ok) {
        setStatus('Saved')
        setTitle('')
        setContent('')
        setProgress('')
        onSaved()
      } else {
        setStatus('Save failed')
      }
    } catch (e) {
      console.error(e)
      setStatus('Save failed')
    }
  }

  return (
    <div style={{ border: '1px solid #eee', padding: 12, marginTop: 12 }}>
      <h3>Write entry for {date}</h3>
      <input placeholder="Title" value={title} onChange={(e: AnyEvent) => setTitle((e.target as HTMLInputElement).value)} />
      <div>
        <textarea rows={6} style={{ width: '100%' }} value={content} onChange={(e: AnyEvent) => setContent((e.target as HTMLTextAreaElement).value)} />
      </div>
      <div>
        <label>
          Progress (0-100):
          <input type="number" min={0} max={100} value={progress === '' ? '' : progress} onChange={(e: AnyEvent) => setProgress((e.target as HTMLInputElement).value === '' ? '' : Number((e.target as HTMLInputElement).value))} />
        </label>
      </div>
      <button onClick={save}>Save</button>
      <div>{status}</div>
    </div>
  )
}
