export async function login(phone: string, password: string) {
  const res = await fetch('/api/auth/login', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ phone, password }),
  });
  if (!res.ok) {
    const error = await res.json();
    throw new Error(error.detail || 'Login failed');
  }
  return res.json();
}

export async function signup(userData: {
  username: string;
  phone: string;
  age: number;
  password: string;
}) {
  const res = await fetch('/api/auth/signup', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(userData),
  });
  if (!res.ok) {
    const error = await res.json();
    throw new Error(error.detail || 'Signup failed');
  }
  return res.json();
}

export async function verifyOtp(phone: string, otp: string) {
  const res = await fetch('/api/auth/verify-otp', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ phone, otp }),
  });
  if (!res.ok) {
    const error = await res.json();
    throw new Error(error.detail || 'OTP verification failed');
  }
  return res.json();
}

export async function getCurrentUser(token: string) {
  const res = await fetch('/api/auth/me', {
    headers: { Authorization: `Bearer ${token}` },
  });
  if (!res.ok) {
    throw new Error('Not authenticated');
  }
  return res.json();
}

export function signOut() {
  localStorage.removeItem('auth_token');
  sessionStorage.clear();
}
