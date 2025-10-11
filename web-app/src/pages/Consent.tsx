import React, { useEffect, useMemo, useState } from "react";

/**
 * Consent Page
 *
 * Surfaces:
 * - Current consent status (from profile if available)
 * - Actions:
 *    • Grant / withdraw consent to data processing
 *    • Export my data (JSON/CSV)
 *    • Request deletion of my personal data
 *
 * Notes:
 * - This page uses the existing backend endpoints:
 *    • GET /api/profile/me (fallback: GET /api/profile) to read consent where available
 *    • POST /api/privacy/delete to request deletion (202 Accepted)
 *    • GET /api/privacy/export?format=json|csv to download data export
 * - Consent update endpoint may vary by backend. This page attempts:
 *    • PUT /api/profile/consent { consent_privacy: boolean }
 *      (fallback) PUT /api/profile { consent_privacy: boolean }
 *   and will show a friendly message if not implemented server-side.
 */

type ConsentStatus = "unknown" | "granted" | "not_granted";

const container: React.CSSProperties = {
  maxWidth: 860,
  margin: "0 auto",
  padding: "2rem 1rem 4rem",
  lineHeight: 1.6,
};

const h1: React.CSSProperties = {
  fontSize: "2rem",
  fontWeight: 700,
  marginBottom: "0.75rem",
};

const section: React.CSSProperties = { marginTop: "1.5rem" };

const row: React.CSSProperties = {
  display: "flex",
  gap: "0.75rem",
  flexWrap: "wrap",
  alignItems: "center",
};

const muted: React.CSSProperties = {
  color: "var(--muted-foreground, #6b7280)",
};

const panel: React.CSSProperties = {
  background: "var(--panel, rgba(148,163,184,0.08))",
  border: "1px solid var(--panel-border, rgba(148,163,184,0.18))",
  borderRadius: 12,
  padding: "1rem",
};

const button: React.CSSProperties = {
  appearance: "none",
  border: "1px solid var(--panel-border, rgba(148,163,184,0.18))",
  background: "transparent",
  borderRadius: 10,
  padding: "0.55rem 0.8rem",
  cursor: "pointer",
  color: "inherit",
};

const primaryButton: React.CSSProperties = {
  ...button,
  background: "var(--accent, #4f46e5)",
  borderColor: "var(--accent, #4f46e5)",
  color: "#fff",
};

const dangerButton: React.CSSProperties = {
  ...button,
  borderColor: "rgba(220, 38, 38, 0.6)",
  color: "rgb(220, 38, 38)",
};

const selectStyle: React.CSSProperties = {
  appearance: "none",
  border: "1px solid var(--panel-border, rgba(148,163,184,0.18))",
  background: "transparent",
  borderRadius: 10,
  padding: "0.55rem 0.8rem",
  color: "inherit",
};

const badge: React.CSSProperties = {
  display: "inline-block",
  padding: "0.25rem 0.5rem",
  borderRadius: 999,
  fontSize: "0.85rem",
  border: "1px solid var(--panel-border, rgba(148,163,184,0.18))",
};

const link: React.CSSProperties = {
  color: "var(--accent, #4f46e5)",
  textDecoration: "underline",
};

const Alert: React.FC<{ type?: "info" | "success" | "error"; children: React.ReactNode }> = ({
  type = "info",
  children,
}) => {
  const color =
    type === "success"
      ? "rgba(16, 185, 129, .2)"
      : type === "error"
      ? "rgba(239, 68, 68, .2)"
      : "rgba(148,163,184,0.12)";
  const border =
    type === "success"
      ? "rgba(16, 185, 129, .35)"
      : type === "error"
      ? "rgba(239, 68, 68, .35)"
      : "rgba(148,163,184,0.25)";
  return (
    <div
      style={{
        ...panel,
        background: color,
        borderColor: border,
      }}
      role="alert"
    >
      {children}
    </div>
  );
};

const ConsentPage: React.FC = () => {
  const token = useMemo(() => localStorage.getItem("auth_token") || "", []);
  const [loading, setLoading] = useState<boolean>(true);
  const [busy, setBusy] = useState<boolean>(false);
  const [exportBusy, setExportBusy] = useState<boolean>(false);
  const [deleteBusy, setDeleteBusy] = useState<boolean>(false);

  const [message, setMessage] = useState<{ kind: "success" | "error" | "info"; text: string } | null>(
    null,
  );

  const [consent, setConsent] = useState<ConsentStatus>("unknown");
  const [exportFormat, setExportFormat] = useState<"json" | "csv">("json");

  useEffect(() => {
    let cancelled = false;
    async function loadProfile() {
      if (!token) {
        setLoading(false);
        setConsent("unknown");
        return;
      }
      setLoading(true);
      setMessage(null);

      const endpoints = ["/api/profile/me", "/api/profile"]; // try both; use whichever exists
      for (const ep of endpoints) {
        try {
          const res = await fetch(ep, {
            headers: { Authorization: `Bearer ${token}` },
          });
          if (!res.ok) continue;
          const data = await res.json();
          // consent_privacy may live under the profile object or at top-level depending on API
          const value =
            typeof data?.consent_privacy === "boolean"
              ? data.consent_privacy
              : typeof data?.profile?.consent_privacy === "boolean"
              ? data.profile.consent_privacy
              : null;
          if (!cancelled) {
            setConsent(value === true ? "granted" : value === false ? "not_granted" : "unknown");
            setLoading(false);
          }
          return;
        } catch {
          // try next
        }
      }
      if (!cancelled) {
        setConsent("unknown");
        setLoading(false);
      }
    }
    loadProfile();
    return () => {
      cancelled = true;
    };
  }, [token]);

  async function updateConsent(next: boolean) {
    if (!token) {
      setMessage({ kind: "error", text: "Please sign in to update consent." });
      return;
    }
    setBusy(true);
    setMessage(null);
    // Try primary endpoint; fallback to general profile update if not available
    const attempts: { url: string; method: string; body: any }[] = [
      { url: "/api/profile/consent", method: "PUT", body: { consent_privacy: next } },
      { url: "/api/profile", method: "PUT", body: { consent_privacy: next } },
    ];
    for (const a of attempts) {
      try {
        const res = await fetch(a.url, {
          method: a.method,
          headers: { "Content-Type": "application/json", Authorization: `Bearer ${token}` },
          body: JSON.stringify(a.body),
        });
        if (res.ok) {
          setConsent(next ? "granted" : "not_granted");
          setMessage({
            kind: "success",
            text: next ? "Consent granted successfully." : "Consent withdrawn.",
          });
          setBusy(false);
          return;
        }
        // if 404, try next endpoint
        if (res.status === 404) continue;
        // surfacing server error
        const err = await safeJson(res);
        setMessage({
          kind: "error",
          text: err?.detail || "Failed to update consent. Please try again.",
        });
        setBusy(false);
        return;
      } catch {
        // try next
      }
    }
    setMessage({
      kind: "error",
      text:
        "Consent update endpoint is not available. Please contact support or try again later.",
    });
    setBusy(false);
  }

  async function exportMyData() {
    if (!token) {
      setMessage({ kind: "error", text: "Please sign in to export your data." });
      return;
    }
    setExportBusy(true);
    setMessage(null);
    try {
      const res = await fetch(`/api/privacy/export?format=${encodeURIComponent(exportFormat)}`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (!res.ok) {
        const err = await safeJson(res);
        throw new Error(err?.detail || "Export failed");
      }
      const blob = await res.blob();
      const fileName =
        exportFormat === "csv" ? "soul_data_export.csv" : "soul_data_export.json";
      triggerDownload(blob, fileName);
      setMessage({ kind: "success", text: "Your data export has started downloading." });
    } catch (e: any) {
      setMessage({ kind: "error", text: e?.message || "Failed to export data." });
    } finally {
      setExportBusy(false);
    }
  }

  async function requestDeletion() {
    if (!token) {
      setMessage({ kind: "error", text: "Please sign in to request deletion." });
      return;
    }
    const confirm = window.confirm(
      "This will request deletion of your personal data (moods, journals, profile). This action cannot be undone. Continue?",
    );
    if (!confirm) return;

    setDeleteBusy(true);
    setMessage(null);
    try {
      const res = await fetch("/api/privacy/delete", {
        method: "POST",
        headers: { Authorization: `Bearer ${token}` },
      });
      if (res.status !== 202 && !res.ok) {
        const err = await safeJson(res);
        throw new Error(err?.detail || "Deletion request failed");
      }
      setMessage({
        kind: "success",
        text:
          "Your deletion request was accepted and will be processed. You will be signed out.",
      });
      // Sign out after a short delay
      setTimeout(() => {
        localStorage.removeItem("auth_token");
        sessionStorage.clear();
        window.location.href = "/"; // redirect to app root/login
      }, 2000);
    } catch (e: any) {
      setMessage({ kind: "error", text: e?.message || "Failed to request deletion." });
    } finally {
      setDeleteBusy(false);
    }
  }

  const consentBadgeColor =
    consent === "granted"
      ? "rgba(16, 185, 129, .25)"
      : consent === "not_granted"
      ? "rgba(239, 68, 68, .25)"
      : "rgba(148,163,184,0.15)";
  const consentBadge: React.CSSProperties = {
    ...badge,
    background: consentBadgeColor,
  };

  return (
    <main style={container} aria-labelledby="consent-title">
      <header>
        <h1 id="consent-title" style={h1}>
          Data Consent & Privacy Controls
        </h1>
        <p style={muted}>
          Manage your privacy preferences, export your data, or request deletion. For
          details, review our{" "}
          <a href="/privacy-policy" style={link}>
            Privacy Policy
          </a>{" "}
          and{" "}
          <a href="/terms-of-service" style={link}>
            Terms of Service
          </a>
          .
        </p>

        <div style={{ marginTop: "1rem" }}>
          <button
            onClick={() => window.history.back()}
            style={button}
            aria-label="Back to app"
          >
            ← Back
          </button>
        </div>
      </header>

      {message && (
        <section style={{ ...section }}>
          <Alert
            type={message.kind === "error" ? "error" : message.kind === "success" ? "success" : "info"}
          >
            {message.text}
          </Alert>
        </section>
      )}

      <section style={{ ...section }}>
        <div style={panel}>
          <div style={{ ...row, justifyContent: "space-between" }}>
            <div>
              <strong>Consent status:</strong>{" "}
              <span style={consentBadge} aria-live="polite">
                {loading ? "Loading…" : consent === "granted" ? "Granted" : consent === "not_granted" ? "Not granted" : "Unknown"}
              </span>
            </div>
            <div style={{ display: "flex", gap: "0.5rem", flexWrap: "wrap" }}>
              <button
                style={primaryButton}
                disabled={busy || loading || consent === "granted"}
                onClick={() => updateConsent(true)}
              >
                {busy ? "Saving…" : "Grant consent"}
              </button>
              <button
                style={button}
                disabled={busy || loading || consent === "not_granted"}
                onClick={() => updateConsent(false)}
              >
                {busy ? "Saving…" : "Withdraw consent"}
              </button>
            </div>
          </div>
          <p style={{ marginTop: "0.75rem", ...muted }}>
            Consent allows SOUL to process your data to provide and improve the Services. You
            can update this at any time.
          </p>
        </div>
      </section>

      <section style={{ ...section }}>
        <div style={panel}>
          <h2 style={{ fontSize: "1.15rem", fontWeight: 700, margin: 0 }}>
            Export my data
          </h2>
          <p style={{ ...muted, marginTop: "0.5rem" }}>
            Download your moods and journals in your preferred format.
          </p>
          <div style={{ ...row, marginTop: "0.75rem" }}>
            <label htmlFor="export-format" style={{ ...muted }}>
              Format
            </label>
            <select
              id="export-format"
              value={exportFormat}
              onChange={(e) => setExportFormat((e.target.value as "json" | "csv") || "json")}
              style={selectStyle}
              aria-label="Export format"
            >
              <option value="json">JSON (.json)</option>
              <option value="csv">CSV (.csv)</option>
            </select>
            <button
              style={button}
              onClick={exportMyData}
              disabled={exportBusy}
              aria-busy={exportBusy}
            >
              {exportBusy ? "Preparing…" : "Download"}
            </button>
          </div>
        </div>
      </section>

      <section style={{ ...section }}>
        <div style={panel}>
          <h2 style={{ fontSize: "1.15rem", fontWeight: 700, margin: 0, color: "rgb(220,38,38)" }}>
            Request deletion
          </h2>
          <p style={{ ...muted, marginTop: "0.5rem" }}>
            Permanently remove your personal data (moods, journals, profile). This is
            irreversible. We’ll sign you out once the request is accepted.
          </p>
          <div style={{ ...row, marginTop: "0.75rem" }}>
            <button
              style={dangerButton}
              onClick={requestDeletion}
              disabled={deleteBusy}
              aria-busy={deleteBusy}
            >
              {deleteBusy ? "Submitting…" : "Request deletion"}
            </button>
          </div>
        </div>
      </section>
    </main>
  );
};

async function safeJson(res: Response): Promise<any | null> {
  try {
    return await res.json();
  } catch {
    return null;
  }
}

function triggerDownload(blob: Blob, filename: string) {
  const url = URL.createObjectURL(blob);
  const a = document.createElement("a");
  a.href = url;
  a.download = filename;
  a.style.display = "none";
  document.body.appendChild(a);
  a.click();
  a.remove();
  URL.revokeObjectURL(url);
}

export default ConsentPage;
