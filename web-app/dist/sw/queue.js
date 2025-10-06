import Dexie from 'dexie';
const db = new Dexie('MoodDB');
db.version(1).stores({ moods: '++id,timestamp,synced,attempts' });
export const enqueueMood = async (m) => {
    return await db.table('moods').add({ ...m, attempts: 0, synced: false });
};
export const getPending = async () => {
    return await db.table('moods').where('synced').equals(false).toArray();
};
export const markSynced = async (id) => {
    return await db.table('moods').update(id, { synced: true });
};
export const incrementAttempts = async (id) => {
    const rec = await db.table('moods').get(id);
    const attempts = (rec?.attempts || 0) + 1;
    return await db.table('moods').update(id, { attempts });
};
export default db;
