/**
 * Auth API client for SOUL web app
 * - Corrected signup payload to send { email, password }
 * - Added requestOtp(phone) export for requesting OTP codes
 */

export interface AuthResponse {
  access_token: string;
  token_type?: string;
  refresh_token?: string;
  user?: {
    id: number;
    email: string;
    name?: string | null;
  };
}

export interface UserRead {
  id: number;
  email: string;
  is_active: boolean;
  is_verified: boolean;
  role: string;
  created_at: string; // ISO datetime
}

async function handleResponse<T>(
  res: Response,
  fallbackMessage: string,
): Promise<T> {
  if (!res.ok) {
    let detail = fallbackMessage;
    try {
      const err = await res.json();
      if (typeof err?.detail === "string") detail = err.detail;
    } catch {
      // ignore parse error
    }
    throw new Error(detail);
  }
  return res.json() as Promise<T>;
}

/**
 * JSON login using phone + password
 * Backend will infer an email from phone for dev/demo auth.
 */
export async function login(
  phone: string,
  password: string,
): Promise<AuthResponse> {
  const res = await fetch("/api/auth/login", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ phone, password }),
  });
  return handleResponse<AuthResponse>(res, "Login failed");
}

/**
 * Signup with email + password
 * Sends the correct payload { email, password } to the backend.
 */
export async function signup(
  email: string,
  password: string,
): Promise<UserRead> {
  const res = await fetch("/api/auth/signup", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ email, password }),
  });
  return handleResponse<UserRead>(res, "Signup failed");
}

/**
 * Request an OTP code for the given phone number.
 * In dev mode, backend may return a preview_code (e.g., "123456").
 */
export async function requestOtp(
  phone: string,
): Promise<{ status: string; preview_code?: string }> {
  const res = await fetch("/api/auth/otp/request", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ phone }),
  });
  return handleResponse(res, "OTP request failed");
}

/**
 * Verify the OTP and receive tokens.
 */
export async function verifyOtp(
  phone: string,
  otp: string,
): Promise<AuthResponse> {
  const res = await fetch("/api/auth/verify-otp", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ phone, otp }),
  });
  return handleResponse<AuthResponse>(res, "OTP verification failed");
}

/**
 * Get the current user using an access token.
 */
export async function getCurrentUser(token: string): Promise<UserRead> {
  const res = await fetch("/api/auth/me", {
    headers: { Authorization: `Bearer ${token}` },
  });
  return handleResponse<UserRead>(res, "Not authenticated");
}

/**
 * Clear local auth state.
 */
export function signOut(): void {
  localStorage.removeItem("auth_token");
  sessionStorage.clear();
}
