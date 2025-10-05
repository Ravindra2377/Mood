import React, { useState, useEffect } from 'react'
type AnyEvent = any

import { createJournal, updateJournal, deleteJournal } from '../api/journals'

export default function JournalEditor({ date, onSaved, initial }: { date: string, onSaved: () => void, initial?: any }) {
  const [title, setTitle] = useState(initial?.title ?? '')
  const [content, setContent] = useState(initial?.content ?? '')
  const [progress, setProgress] = useState(initial?.progress ?? ('' as number | ''))
  const [status, setStatus] = useState('')
  const [editingId, setEditingId] = useState(initial?.id ?? null)

  useEffect(() => {
    if (initial) {
      setTitle(initial.title ?? '')
      setContent(initial.content ?? '')
      setProgress(initial.progress ?? '')
      setEditingId(initial.id ?? null)
    } else {
      setTitle('')
      setContent('')
      setProgress('')
      setEditingId(null)
    }
  }, [initial])

  async function save() {
    try {
      const body: any = { title, content }
      if (date) body.entry_date = date
      if (progress !== '') body.progress = Number(progress)
      if (editingId) {
        await updateJournal(editingId, body)
      } else {
        await createJournal(body)
      }
      setStatus('Saved')
      setTitle('')
      setContent('')
      setProgress('')
      setEditingId(null)
      onSaved()
    } catch (e) {
      console.error(e)
      setStatus('Save failed')
    }
  }

  async function doDelete() {
    if (!editingId) return
    try {
      await deleteJournal(editingId)
      setStatus('Deleted')
      setTitle('')
      setContent('')
      setProgress('')
      setEditingId(null)
      onSaved()
    } catch (e) {
      console.error(e)
      setStatus('Delete failed')
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
  <button onClick={save}>{editingId ? 'Update' : 'Save'}</button>
  {editingId && <button onClick={doDelete} style={{ marginLeft: 8 }}>Delete</button>}
      <div>{status}</div>
    </div>
  )
}
