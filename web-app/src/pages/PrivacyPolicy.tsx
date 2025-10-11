import React, { useEffect } from "react";

/**
 * SOUL Privacy Policy
 *
 * Note:
 * - This page is a SOUL-branded legal placeholder intended for production use after legal review.
 * - Content here does not constitute legal advice. Have counsel review and finalize before launch.
 */

const sectionStyle: React.CSSProperties = {
  marginBottom: "1.5rem",
};

const listStyle: React.CSSProperties = {
  paddingLeft: "1.25rem",
};

const containerStyle: React.CSSProperties = {
  maxWidth: 860,
  margin: "0 auto",
  padding: "2rem 1rem 4rem",
  lineHeight: 1.6,
};

const smallText: React.CSSProperties = {
  color: "var(--muted-foreground, #6b7280)",
  fontSize: "0.9rem",
};

const h1Style: React.CSSProperties = {
  fontSize: "2rem",
  fontWeight: 700,
  marginBottom: "0.75rem",
};

const h2Style: React.CSSProperties = {
  fontSize: "1.25rem",
  fontWeight: 700,
  marginTop: "1.75rem",
  marginBottom: "0.5rem",
};

const mutedBox: React.CSSProperties = {
  background: "var(--panel, rgba(148,163,184,0.08))",
  border: "1px solid var(--panel-border, rgba(148,163,184,0.18))",
  borderRadius: 12,
  padding: "1rem",
  marginTop: "1rem",
};

const linkStyle: React.CSSProperties = {
  color: "var(--accent, #4f46e5)",
  textDecoration: "underline",
};

const tocLinkStyle: React.CSSProperties = {
  ...linkStyle,
  textDecoration: "none",
};

const dividerStyle: React.CSSProperties = {
  borderTop: "1px solid var(--panel-border, rgba(148,163,184,0.18))",
  margin: "1.25rem 0",
};

const PrivacyPolicy: React.FC = () => {
  useEffect(() => {
    // Ensure we start at the top when navigating to this page
    window.scrollTo(0, 0);
  }, []);

  return (
    <main style={containerStyle}>
      <header>
        <h1 style={h1Style}>SOUL Privacy Policy</h1>
        <p style={smallText}>Last updated: 2025-10-11</p>
        <div style={mutedBox}>
          <strong>Summary</strong>
          <p style={{ margin: "0.5rem 0 0" }}>
            This Privacy Policy explains how SOUL (“SOUL”, “we”, “us” or
            “our”) collects, uses, and protects information when you use our
            applications and services, including our mobile apps (iOS/Android)
            and web app (the “Services”). By using the Services, you agree to
            the practices described below.
          </p>
        </div>
      </header>

      <section aria-label="quick-actions" style={{ marginTop: "1rem" }}>
        <button
          onClick={() => window.history.back()}
          style={{
            appearance: "none",
            border: "1px solid var(--panel-border, rgba(148,163,184,0.18))",
            background: "transparent",
            borderRadius: 10,
            padding: "0.5rem 0.75rem",
            cursor: "pointer",
            color: "inherit",
          }}
          aria-label="Back to app"
        >
          ← Back
        </button>
      </section>

      <section aria-label="toc" style={sectionStyle}>
        <h2 style={h2Style}>Contents</h2>
        <nav>
          <ol style={listStyle}>
            <li>
              <a style={tocLinkStyle} href="#principles">
                1. Our privacy principles
              </a>
            </li>
            <li>
              <a style={tocLinkStyle} href="#data-we-collect">
                2. Information we collect
              </a>
            </li>
            <li>
              <a style={tocLinkStyle} href="#how-we-use">
                3. How we use information
              </a>
            </li>
            <li>
              <a style={tocLinkStyle} href="#sharing">
                4. How we share information
              </a>
            </li>
            <li>
              <a style={tocLinkStyle} href="#security">
                5. Security and data protection
              </a>
            </li>
            <li>
              <a style={tocLinkStyle} href="#retention">
                6. Data retention and deletion
              </a>
            </li>
            <li>
              <a style={tocLinkStyle} href="#rights">
                7. Your rights and choices
              </a>
            </li>
            <li>
              <a style={tocLinkStyle} href="#children">
                8. Children’s privacy
              </a>
            </li>
            <li>
              <a style={tocLinkStyle} href="#intl">
                9. International transfers
              </a>
            </li>
            <li>
              <a style={tocLinkStyle} href="#changes">
                10. Changes to this Policy
              </a>
            </li>
            <li>
              <a style={tocLinkStyle} href="#contact">
                11. Contact us
              </a>
            </li>
          </ol>
        </nav>
      </section>

      <div style={dividerStyle} />

      <section id="principles" style={sectionStyle}>
        <h2 style={h2Style}>1. Our privacy principles</h2>
        <ul style={listStyle}>
          <li>Only collect what we need to operate and improve SOUL.</li>
          <li>Encrypt data in transit and protect sensitive data at rest.</li>
          <li>No selling of personal data.</li>
          <li>Transparent controls for export, deletion, and consent.</li>
          <li>Security and safety first for a mental-health–focused app.</li>
        </ul>
      </section>

      <section id="data-we-collect" style={sectionStyle}>
        <h2 style={h2Style}>2. Information we collect</h2>
        <p>
          The specific data we collect depends on how you use SOUL, and your
          settings and permissions. This may include:
        </p>
        <ul style={listStyle}>
          <li>
            <strong>Account information</strong>: email or phone number, password
            (hashed), basic profile (e.g., display name, language).
          </li>
          <li>
            <strong>Health-related content you provide</strong>: mood entries,
            journal entries, symptoms, sleep data, insights, and activity.
          </li>
          <li>
            <strong>Device and usage data</strong>: app version, device type,
            general diagnostics, and crash logs.
          </li>
          <li>
            <strong>Verification</strong>: phone number for SMS-based OTP (via
            third-party provider like Twilio).
          </li>
          <li>
            <strong>Communications</strong>: messages or emails you send to our
            support channels.
          </li>
        </ul>
        <div style={mutedBox}>
          <strong>HIPAA & sensitive data</strong>
          <p style={{ margin: "0.5rem 0 0" }}>
            SOUL is designed for sensitive wellness information and uses
            industry-standard practices to protect it. If you require
            HIPAA-compliant services, ensure you deploy SOUL with HIPAA-eligible
            infrastructure and enter into appropriate BAAs with vendors (e.g.,
            SMS, hosting).
          </p>
        </div>
      </section>

      <section id="how-we-use" style={sectionStyle}>
        <h2 style={h2Style}>3. How we use information</h2>
        <ul style={listStyle}>
          <li>Provide and maintain the Services (core functionality).</li>
          <li>
            Authenticate users (e.g., SMS OTP), maintain sessions, and secure
            accounts.
          </li>
          <li>
            Personalize recommendations and insights to support your mental
            health journey.
          </li>
          <li>Improve performance, reliability, and user experience.</li>
          <li>Detect, prevent, and respond to abuse or safety concerns.</li>
          <li>
            Conduct analytics on anonymized or aggregated data to improve SOUL.
          </li>
        </ul>
      </section>

      <section id="sharing" style={sectionStyle}>
        <h2 style={h2Style}>4. How we share information</h2>
        <p>We do not sell personal information. We may share:</p>
        <ul style={listStyle}>
          <li>
            <strong>Service providers (processors)</strong> that help us operate
            SOUL (e.g., hosting, databases, SMS verification). These providers
            are required to safeguard your data and act only under our
            instructions.
          </li>
          <li>
            <strong>Legal and safety</strong> when required by law or to protect
            your vital interests or those of others.
          </li>
          <li>
            <strong>Aggregated/anonymized insights</strong> that cannot
            reasonably identify you (e.g., product analytics).
          </li>
        </ul>
        <div style={mutedBox}>
          <p style={{ margin: 0 }}>
            Example providers may include: hosting and deployment platforms,
            managed Postgres, Redis, and SMS vendors for OTP (e.g., Twilio).
            Vendor selection depends on your deployment configuration.
          </p>
        </div>
      </section>

      <section id="security" style={sectionStyle}>
        <h2 style={h2Style}>5. Security and data protection</h2>
        <ul style={listStyle}>
          <li>Encryption in transit (TLS) across services.</li>
          <li>
            Sensitive content (e.g., journals) can be encrypted at rest using
            application-level encryption strategies (e.g., envelope encryption)
            when enabled by your deployment.
          </li>
          <li>
            Access controls, audit primitives, and rate limiting to reduce abuse
            and unauthorized access risk.
          </li>
        </ul>
        <p>
          No system can be guaranteed 100% secure. We continuously improve our
          safeguards and recommend strong device security, updated OS versions,
          and careful sharing practices.
        </p>
      </section>

      <section id="retention" style={sectionStyle}>
        <h2 style={h2Style}>6. Data retention and deletion</h2>
        <p>
          We retain information for as long as necessary to provide the
          Services, comply with our legal obligations, resolve disputes, and
          enforce agreements. You can request:
        </p>
        <ul style={listStyle}>
          <li>
            <strong>Export</strong> of your data (e.g., moods and journals).
          </li>
          <li>
            <strong>Deletion</strong> of your account data (subject to legal or
            safety limitations).
          </li>
        </ul>
        <p>
          In-app, visit your Profile or Settings to initiate an export or
          deletion request. If you need help, contact{" "}
          <a style={linkStyle} href="mailto:privacy@soulapp.app">
            privacy@soulapp.app
          </a>
          .
        </p>
      </section>

      <section id="rights" style={sectionStyle}>
        <h2 style={h2Style}>7. Your rights and choices</h2>
        <p>
          Depending on your location, you may have rights to access, correct,
          export, delete, or restrict processing of your personal information,
          as well as withdraw consent where applicable.
        </p>
        <p>
          To exercise these rights, use in-app controls or email{" "}
          <a style={linkStyle} href="mailto:privacy@soulapp.app">
            privacy@soulapp.app
          </a>
          . We may require verification (e.g., via your account email/phone).
        </p>
      </section>

      <section id="children" style={sectionStyle}>
        <h2 style={h2Style}>8. Children’s privacy</h2>
        <p>
          SOUL is not directed to children under the age of 13 (or the minimum
          age required in your jurisdiction). If we learn we have collected
          information from a child in violation of applicable law, we will take
          steps to delete it.
        </p>
      </section>

      <section id="intl" style={sectionStyle}>
        <h2 style={h2Style}>9. International transfers</h2>
        <p>
          We may process and store information in countries other than your own.
          Where required, we implement appropriate safeguards for cross-border
          transfers.
        </p>
      </section>

      <section id="changes" style={sectionStyle}>
        <h2 style={h2Style}>10. Changes to this Policy</h2>
        <p>
          We may update this Privacy Policy from time to time. The “Last
          updated” date reflects the most recent changes. We encourage you to
          review this Policy periodically.
        </p>
      </section>

      <section id="contact" style={sectionStyle}>
        <h2 style={h2Style}>11. Contact us</h2>
        <p>
          For questions about this Privacy Policy or our data practices, contact
          us at{" "}
          <a style={linkStyle} href="mailto:privacy@soulapp.app">
            privacy@soulapp.app
          </a>
          .
        </p>
        <div style={mutedBox}>
          <strong>Disclaimer</strong>
          <p style={{ margin: "0.5rem 0 0" }}>
            This document is provided for informational purposes only and does
            not constitute legal advice. Please consult your legal counsel to
            tailor and finalize the policy for your production deployment and
            applicable laws.
          </p>
        </div>
      </section>
    </main>
  );
};

export default PrivacyPolicy;
