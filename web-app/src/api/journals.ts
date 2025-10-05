export async function fetchJournalsByDate(date: string) {
  const res = await fetch(`/api/journals?date=${date}`, { credentials: 'include' })
  if (!res.ok) throw new Error('fetch failed')
  return res.json()
}

export async function createJournal(payload: any) {
  const res = await fetch('/api/journals', { method: 'POST', headers: { 'Content-Type': 'application/json' }, credentials: 'include', body: JSON.stringify(payload) })
  if (!res.ok) throw new Error('create failed')
  return res.json()
}

export async function updateJournal(id: number, payload: any) {
  const res = await fetch(`/api/journals/${id}`, { method: 'PUT', headers: { 'Content-Type': 'application/json' }, credentials: 'include', body: JSON.stringify(payload) })
  if (!res.ok) throw new Error('update failed')
  return res.json()
}

export async function deleteJournal(id: number) {
  const res = await fetch(`/api/journals/${id}`, { method: 'DELETE', credentials: 'include' })
  if (!res.ok) throw new Error('delete failed')
  return res.json()
}
