import React from 'react'

export default function MetricsDocs() {
  return (
    <div style={{ padding: 28, fontFamily: 'Inter, system-ui, Roboto, Arial' }}>
      <h1 id="sleep-percent">Sleep percent metric</h1>
      <p style={{ color: '#475569' }}>This page documents how the Sleep Percent is computed for the SOUL dashboard.</p>

      <h2>Definition</h2>
      <p style={{ color: '#475569' }}>The sleep percent is calculated as:</p>
      <pre style={{ background: '#f3f4f6', padding: 12, borderRadius: 8 }}>percent = min(100, round((hours / 8.0) * 100))</pre>
      <p style={{ color: '#475569' }}>Where <code>hours</code> is the duration of a night's sleep in hours. For the "7-day avg" window the app computes the average nightly duration across the last 7 days and applies the same formula to the mean.</p>

      <h2>Notes</h2>
      <ul style={{ color: '#475569' }}>
        <li>Only sleep entries with an explicit end time are considered.</li>
        <li>For the 7-day window, nights without a recorded end time are ignored (count is shown in the UI).</li>
        <li>The percent is capped at 100% — durations longer than the 8-hour target will show 100%.</li>
      </ul>

      <p style={{ color: '#475569' }}>Questions or suggested improvements? Open an issue in the repository or contact the dev team.</p>
      <p><a href="/">← Back to app</a></p>
    </div>
  )
}
