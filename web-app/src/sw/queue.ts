import Dexie from 'dexie'

export interface QueuedMood {
  id?: number
  rating: number
  note?: string
  timestamp: string
  attempts?: number
  synced?: boolean
}

const db = new Dexie('MoodDB')
db.version(1).stores({ moods: '++id,timestamp,synced,attempts' })

export const enqueueMood = async (m: Omit<QueuedMood, 'id' | 'attempts' | 'synced'>) => {
  return await db.table('moods').add({ ...m, attempts: 0, synced: false })
}

export const getPending = async () => {
  return await db.table('moods').where('synced').equals(false).toArray()
}

export const markSynced = async (id: number) => {
  return await db.table('moods').update(id, { synced: true })
}

export const incrementAttempts = async (id: number) => {
  const rec: any = await db.table('moods').get(id)
  const attempts = (rec?.attempts || 0) + 1
  return await db.table('moods').update(id, { attempts })
}

export default db
