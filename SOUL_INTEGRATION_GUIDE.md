# SOUL App Integration Guide

Welcome to the SOUL Mental Health Companion! This guide will help you set up, run, and understand the integration between the **frontend** (React/TypeScript) and **backend** (FastAPI) for a seamless, modern mental health app experience.

---

## Table of Contents

1. [Project Structure](#project-structure)
2. [Frontend Setup (React)](#frontend-setup-react)
3. [Backend Setup (FastAPI)](#backend-setup-fastapi)
4. [Connecting Frontend & Backend](#connecting-frontend--backend)
5. [Authentication Flow](#authentication-flow)
6. [Feature Overview](#feature-overview)
7. [Development Tips](#development-tips)
8. [Troubleshooting](#troubleshooting)
9. [Customization](#customization)
10. [FAQ](#faq)

---

## Project Structure

```
Mood/
├── backend/           # FastAPI backend (Python)
│   └── app/           # Main backend app code
├── web-app/           # React frontend (TypeScript)
│   └── src/           # Source code for SOUL frontend
│   └── styles/        # SOUL theme CSS
│   └── screens/       # Main screen components
│   └── api/           # API service modules
│   └── components/    # Shared UI components
│   └── main.tsx       # React entry point
│   └── App.tsx        # Main app logic
├── SOUL_INTEGRATION_GUIDE.md  # This guide
```

---

## Frontend Setup (React)

1. **Install dependencies:**
   ```sh
   cd Mood/web-app
   npm install
   ```

2. **Run the development server:**
   ```sh
   npm run dev
   ```
   - The app will be available at [http://localhost:5173](http://localhost:5173) (default Vite port).

3. **Build for production:**
   ```sh
   npm run build
   ```

4. **Key files:**
   - `src/App.tsx` — Main app logic, routing, authentication
   - `src/screens/` — All major screens (Home, Login, Signup, Journal, etc.)
   - `src/styles/soul.css` — SOUL theme and UI styles
   - `src/api/` — API service modules for backend communication

---

## Backend Setup (FastAPI)

1. **Install Python dependencies:**
   ```sh
   cd Mood/backend
   pip install -r requirements.txt
   ```

2. **Run the backend server:**
   ```sh
   uvicorn app.main:app --reload
   ```
   - The backend will be available at [http://localhost:8000](http://localhost:8000)

3. **Key endpoints:**
   - `/api/auth/*` — Authentication (login, signup, OTP, profile)
   - `/api/moods/*` — Mood tracking
   - `/api/journals/*` — Journal entries
   - `/api/analytics/*` — Insights and stats

---

## Connecting Frontend & Backend

- **Proxy Setup:**  
  The frontend (Vite) is configured to proxy `/api` requests to the backend.
  - See `web-app/vite.config.ts`:
    ```js
    server: {
      proxy: {
        "/api": {
          target: "http://localhost:8000",
          changeOrigin: true,
          secure: false,
        },
      },
    }
    ```
- **Authentication:**  
  - JWT tokens are stored in `localStorage` after login/signup.
  - All API requests include the token in the `Authorization` header.

- **API Services:**  
  - Located in `src/api/` (e.g., `auth.ts`, `moods.ts`, `journals.ts`)
  - Use these modules for all backend communication.

---

## Authentication Flow

1. **Signup:**  
   - User enters username, phone, age, password.
   - Backend sends OTP to phone (mock/demo for now).
   - User enters OTP to verify.
   - On success, JWT token is stored and user is logged in.

2. **Login:**  
   - User enters phone and password.
   - On success, JWT token is stored and user is logged in.

3. **Session:**  
   - Token is validated on app load.
   - If invalid/expired, user is redirected to login.

4. **Sign Out:**  
   - Token is removed from storage.
   - User is redirected to login.

---

## Feature Overview

- **Splash Screen:**  
  Animated SOUL branding on app load.

- **Login/Signup/OTP:**  
  Modern authentication flow with phone verification.

- **Home Screen:**  
  - Mood tracking (emoji selection)
  - Activities (Meditation, Journal)
  - Quote of the day
  - Content recommendations

- **Breathing Meditation:**  
  - Animated timer and breath cycle
  - Play/pause controls

- **Journal:**  
  - Text entry with character counter
  - "Get Insight" button (static supportive messages)
  - Voice journaling button (demo)

- **Insights/Stats:**  
  - Physical state chart (sleep, etc.)
  - Mood trends (last 7 days)
  - Calendar week view

- **Profile:**  
  - User info
  - Settings (notifications, dark mode)
  - Sign out

- **Dark Mode:**  
  - Toggle in profile settings
  - All screens/theme adapt automatically

---

## Development Tips

- **Component Structure:**  
  - Each screen is a React component in `src/screens/`
  - Shared UI in `src/components/`
  - Styles in `src/styles/soul.css`

- **API Integration:**  
  - Use the service modules in `src/api/` for all backend calls.
  - Handle errors gracefully and show user feedback.

- **Routing:**  
  - Navigation is managed by state in `App.tsx`
  - Bottom navigation updates current screen.

- **Charts:**  
  - Chart.js is used for analytics (see `main.tsx` for setup).

- **Customization:**  
  - Update theme colors in `soul.css`
  - Add new screens/components as needed.

---

## Troubleshooting

- **CORS Issues:**  
  - Make sure backend allows CORS (`allow_origins=["*"]` in FastAPI).
- **API Proxy:**  
  - If API calls fail, check Vite proxy config and backend port.
- **Authentication Errors:**  
  - Ensure backend is running and JWT tokens are valid.
- **Chart.js Errors:**  
  - Make sure `chart.js` is installed and imported in `main.tsx`.

---

## Customization

- **Add New Features:**  
  - Create new screens in `src/screens/`
  - Add new API endpoints in backend `/app/controllers/`
- **Change Branding:**  
  - Update logo, colors, and text in `soul.css` and screen components.
- **Integrate Real OTP:**  
  - Connect to SMS provider in backend for production OTP.

---

## FAQ

**Q: Can I use this app on mobile?**  
A: Yes! The SOUL app is fully responsive and works great on mobile browsers.

**Q: How do I add new activities or content?**  
A: Update the relevant screen component (e.g., `HomeScreen.tsx`) and backend endpoints.

**Q: How do I deploy this app?**  
A: Build the frontend (`npm run build`) and serve the static files. Run the backend with a production server (e.g., Gunicorn/Uvicorn).

**Q: How do I enable real authentication?**  
A: Integrate with a real SMS provider and update backend `/api/auth/*` endpoints.

---

## Need Help?

If you have any questions or need help with integration, reach out to your engineering lead or open an issue in the project repository.

---

**Enjoy building with SOUL!**