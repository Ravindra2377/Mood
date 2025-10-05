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
