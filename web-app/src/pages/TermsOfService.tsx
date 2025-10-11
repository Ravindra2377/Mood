import React, { useEffect } from "react";

/**
 * SOUL Terms of Service
 *
 * Note:
 * - This page is a SOUL-branded legal placeholder intended for production use after legal review.
 * - Content here does not constitute legal advice. Have counsel review and finalize before launch.
 */

const containerStyle: React.CSSProperties = {
  maxWidth: 860,
  margin: "0 auto",
  padding: "2rem 1rem 4rem",
  lineHeight: 1.6,
};

const sectionStyle: React.CSSProperties = {
  marginBottom: "1.5rem",
};

const listStyle: React.CSSProperties = {
  paddingLeft: "1.25rem",
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

const TermsOfService: React.FC = () => {
  useEffect(() => {
    window.scrollTo(0, 0);
  }, []);

  return (
    <main style={containerStyle}>
      <header>
        <h1 style={h1Style}>SOUL Terms of Service</h1>
        <p style={smallText}>Last updated: 2025-10-11</p>
        <div style={mutedBox}>
          <strong>Summary</strong>
          <p style={{ margin: "0.5rem 0 0" }}>
            These Terms of Service (“Terms”) govern your access to and use of
            the SOUL applications and websites (the “Services”). By creating an
            account, accessing, or using the Services, you agree to be bound by
            these Terms. If you do not agree, do not use the Services.
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
              <a style={tocLinkStyle} href="#acceptance">
                1. Acceptance of Terms
              </a>
            </li>
            <li>
              <a style={tocLinkStyle} href="#eligibility">
                2. Eligibility & Account Registration
              </a>
            </li>
            <li>
              <a style={tocLinkStyle} href="#use">
                3. Use of the Services
              </a>
            </li>
            <li>
              <a style={tocLinkStyle} href="#content">
                4. Your Content & License
              </a>
            </li>
            <li>
              <a style={tocLinkStyle} href="#health">
                5. Health & Safety Notice (Not Medical Advice)
              </a>
            </li>
            <li>
              <a style={tocLinkStyle} href="#privacy">
                6. Privacy & Data Protection
              </a>
            </li>
            <li>
              <a style={tocLinkStyle} href="#subscriptions">
                7. Subscriptions, Payments & Trials
              </a>
            </li>
            <li>
              <a style={tocLinkStyle} href="#prohibited">
                8. Prohibited Conduct
              </a>
            </li>
            <li>
              <a style={tocLinkStyle} href="#ip">
                9. Intellectual Property
              </a>
            </li>
            <li>
              <a style={tocLinkStyle} href="#termination">
                10. Termination
              </a>
            </li>
            <li>
              <a style={tocLinkStyle} href="#disclaimers">
                11. Disclaimers & Limitation of Liability
              </a>
            </li>
            <li>
              <a style={tocLinkStyle} href="#indemnity">
                12. Indemnification
              </a>
            </li>
            <li>
              <a style={tocLinkStyle} href="#law">
                13. Governing Law & Dispute Resolution
              </a>
            </li>
            <li>
              <a style={tocLinkStyle} href="#changes">
                14. Changes to the Services or Terms
              </a>
            </li>
            <li>
              <a style={tocLinkStyle} href="#contact">
                15. Contact
              </a>
            </li>
          </ol>
        </nav>
      </section>

      <div style={dividerStyle} />

      <section id="acceptance" style={sectionStyle}>
        <h2 style={h2Style}>1. Acceptance of Terms</h2>
        <p>
          By accessing or using the Services, you confirm that you can form a
          binding contract with SOUL and that you accept these Terms and agree
          to comply with them. If you are using the Services on behalf of an
          organization, you represent that you are authorized to bind that
          organization to these Terms.
        </p>
      </section>

      <section id="eligibility" style={sectionStyle}>
        <h2 style={h2Style}>2. Eligibility & Account Registration</h2>
        <ul style={listStyle}>
          <li>
            You must be at least the age of majority in your jurisdiction to use
            the Services. If you are under 18 (or the applicable minimum age
            where you live), you may only use the Services with consent of a
            parent or legal guardian.
          </li>
          <li>
            You agree to provide accurate, current, and complete registration
            information and to keep it up to date.
          </li>
          <li>
            You are responsible for safeguarding your account credentials and
            for all activity that occurs under your account.
          </li>
        </ul>
      </section>

      <section id="use" style={sectionStyle}>
        <h2 style={h2Style}>3. Use of the Services</h2>
        <p>
          Subject to your compliance with these Terms, SOUL grants you a
          personal, limited, non-exclusive, non-transferable, revocable license
          to access and use the Services for your personal, non-commercial
          wellness purposes.
        </p>
        <div style={mutedBox}>
          <strong>Service availability</strong>
          <p style={{ margin: "0.5rem 0 0" }}>
            The Services may evolve over time. We may suspend, modify, or
            discontinue features at any time, with or without notice, to improve
            performance, security, or user experience.
          </p>
        </div>
      </section>

      <section id="content" style={sectionStyle}>
        <h2 style={h2Style}>4. Your Content & License</h2>
        <p>
          You retain ownership of content you submit (e.g., mood entries,
          journals). By submitting content, you grant SOUL a worldwide,
          non-exclusive, royalty-free license to use, host, store, reproduce,
          modify, and create derivative works of such content solely to operate,
          maintain, and improve the Services.
        </p>
        <p>
          You are responsible for the content you submit. Do not upload content
          that infringes third-party rights or violates applicable law.
        </p>
      </section>

      <section id="health" style={sectionStyle}>
        <h2 style={h2Style}>5. Health & Safety Notice (Not Medical Advice)</h2>
        <p>
          SOUL provides wellness tools and educational content and does not
          provide medical advice, diagnosis, or treatment. The Services are not
          a substitute for professional medical advice, diagnosis, or treatment.
          Always seek the advice of a qualified healthcare professional with any
          questions you may have regarding a medical condition. If you are in
          crisis or think you may harm yourself or others, call your local
          emergency number immediately.
        </p>
      </section>

      <section id="privacy" style={sectionStyle}>
        <h2 style={h2Style}>6. Privacy & Data Protection</h2>
        <p>
          Your privacy is important to us. Please review our{" "}
          <a style={linkStyle} href="/privacy-policy">
            Privacy Policy
          </a>{" "}
          to understand how we collect, use, and protect your information.
        </p>
      </section>

      <section id="subscriptions" style={sectionStyle}>
        <h2 style={h2Style}>7. Subscriptions, Payments & Trials</h2>
        <p>
          Some features may require a subscription or one-time purchase. If
          applicable, pricing, billing cycles, and trial periods will be
          disclosed prior to purchase. Subscriptions will auto-renew unless
          canceled in accordance with platform rules or your account settings.
          Taxes may apply.
        </p>
      </section>

      <section id="prohibited" style={sectionStyle}>
        <h2 style={h2Style}>8. Prohibited Conduct</h2>
        <ul style={listStyle}>
          <li>Attempting to access another user’s account or data.</li>
          <li>
            Uploading content that is unlawful, defamatory, harassing, or
            infringes intellectual property rights.
          </li>
          <li>
            Reverse engineering, scraping, or circumventing technical
            protections.
          </li>
          <li>Interfering with or disrupting the Services or networks.</li>
        </ul>
      </section>

      <section id="ip" style={sectionStyle}>
        <h2 style={h2Style}>9. Intellectual Property</h2>
        <p>
          The Services, including software, UI, design, and trademarks, are
          owned by SOUL or its licensors and are protected by intellectual
          property laws. Except for the limited license granted to you in these
          Terms, no rights are granted to you.
        </p>
      </section>

      <section id="termination" style={sectionStyle}>
        <h2 style={h2Style}>10. Termination</h2>
        <p>
          We may suspend or terminate your access to the Services at any time if
          we reasonably believe you have violated these Terms, engaged in
          fraudulent or unlawful activity, or posed a risk to the safety or
          integrity of the Services. You may stop using the Services at any
          time.
        </p>
      </section>

      <section id="disclaimers" style={sectionStyle}>
        <h2 style={h2Style}>11. Disclaimers & Limitation of Liability</h2>
        <p>
          THE SERVICES ARE PROVIDED “AS IS” AND “AS AVAILABLE.” TO THE MAXIMUM
          EXTENT PERMITTED BY LAW, SOUL DISCLAIMS ALL WARRANTIES, EXPRESS OR
          IMPLIED, INCLUDING MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
          AND NON-INFRINGEMENT. TO THE MAXIMUM EXTENT PERMITTED BY LAW, SOUL
          WILL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL,
          CONSEQUENTIAL, OR PUNITIVE DAMAGES, OR ANY LOSS OF PROFITS OR REVENUE,
          WHETHER INCURRED DIRECTLY OR INDIRECTLY, OR ANY LOSS OF DATA, USE,
          GOODWILL, OR OTHER INTANGIBLE LOSSES, ARISING OUT OF OR RELATED TO
          YOUR USE OF THE SERVICES.
        </p>
      </section>

      <section id="indemnity" style={sectionStyle}>
        <h2 style={h2Style}>12. Indemnification</h2>
        <p>
          You agree to defend, indemnify, and hold harmless SOUL and its
          affiliates, officers, directors, employees, and agents from and
          against any claims, liabilities, damages, losses, and expenses
          (including reasonable legal fees) arising out of or related to your
          violation of these Terms or misuse of the Services.
        </p>
      </section>

      <section id="law" style={sectionStyle}>
        <h2 style={h2Style}>13. Governing Law & Dispute Resolution</h2>
        <p>
          These Terms are governed by the laws of the jurisdiction where SOUL is
          organized, without regard to conflict of laws principles. Any disputes
          will be resolved in the courts located in that jurisdiction, unless
          otherwise required by applicable consumer protection laws or agreed in
          writing.
        </p>
      </section>

      <section id="changes" style={sectionStyle}>
        <h2 style={h2Style}>14. Changes to the Services or Terms</h2>
        <p>
          We may update these Terms from time to time. If we make material
          changes, we will provide notice (e.g., in-app or via email). Your
          continued use of the Services after changes become effective
          constitutes acceptance of the updated Terms.
        </p>
      </section>

      <section id="contact" style={sectionStyle}>
        <h2 style={h2Style}>15. Contact</h2>
        <p>
          For questions about these Terms or the Services, contact us at{" "}
          <a style={linkStyle} href="mailto:legal@soulapp.app">
            legal@soulapp.app
          </a>
          . For privacy-related questions, contact{" "}
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
            tailor and finalize the Terms for your production deployment and
            applicable laws.
          </p>
        </div>
      </section>
    </main>
  );
};

export default TermsOfService;
