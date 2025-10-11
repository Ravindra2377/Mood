export async function submitMood(mood: string, token?: string) {
  const res = await fetch('/api/moods', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    body: JSON.stringify({ mood }),
    credentials: 'include',
  });
  if (!res.ok) {
    const error = await res.json();
    throw new Error(error.detail || 'Failed to submit mood');
  }
  return res.json();
}

export async function getDailyMood(token?: string) {
  const res = await fetch('/api/moods/daily', {
    headers: {
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    credentials: 'include',
  });
  if (!res.ok) {
    throw new Error('Failed to fetch daily mood');
  }
  return res.json();
}

export async function getMoodHistory(token?: string) {
  const res = await fetch('/api/moods/history', {
    headers: {
      ...(token ? { Authorization: `Bearer ${token}` } : {}),
    },
    credentials: 'include',
  });
  if (!res.ok) {
    throw new Error('Failed to fetch mood history');
  }
  return res.json();
}
