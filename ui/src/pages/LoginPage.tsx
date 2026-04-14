import { useState, type FormEvent } from "react";
import { useNavigate } from "react-router-dom";
import { DEFAULT_SERVER_URL } from "../config/demoConfig";
import { normalizeServerUrl, verifyCredentials } from "../lib/auth";
import { useAuth } from "../state/AuthContext";

export function LoginPage() {
  const navigate = useNavigate();
  const { setSession } = useAuth();
  const [serverUrl, setServerUrl] = useState(DEFAULT_SERVER_URL);
  const [username, setUsername] = useState("superuser");
  const [password, setPassword] = useState("SYS");
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [successMessage, setSuccessMessage] = useState<string | null>(null);

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setIsSubmitting(true);
    setErrorMessage(null);
    setSuccessMessage(null);

    const nextSession = {
      serverUrl: normalizeServerUrl(serverUrl),
      username: username.trim(),
      password
    };

    try {
      await verifyCredentials(nextSession);
      setSession(nextSession);
      setSuccessMessage("Connection verified. Opening the terminology workspace...");
      navigate("/", { replace: true });
    } catch (error) {
      const message =
        error instanceof Error
          ? error.message
          : "Unable to connect to the IRIS terminology server.";
      setErrorMessage(message);
    } finally {
      setIsSubmitting(false);
    }
  }

  return (
    <div className="app-shell">
      <div className="page grid login-grid">
        <section className="hero-panel">
          <div className="hero-heading">
            <div>
              <p className="eyebrow">IRIS Terminology Server</p>
              <h1 className="hero-title">A multi-terminology server on IRIS for Health.</h1>
            </div>
            <p className="pill">Demo UI</p>
          </div>
          <p className="hero-copy">
            This UI presents a practical example of how InterSystems IRIS for Health can support SNOMED CT, LOINC, and
            ICD in one integrated terminology server, with terminology-specific runtime models underneath and both
            native and FHIR APIs on top.
          </p>

          <div className="status-list">
            <article className="status-card">
              <h3>Unified demo story</h3>
              <p>Show search, lookup, hierarchy, validation and ValueSet flows across multiple terminologies.</p>
            </article>
            <article className="status-card">
              <h3>Native plus FHIR</h3>
              <p>Keep one UI surface while comparing native endpoints and the shared FHIR R4 terminology layer.</p>
            </article>
            <article className="status-card">
              <h3>Built for partner conversations</h3>
              <p>Stay close to the repo docs and the existing HTTP examples instead of inventing a separate product.</p>
            </article>
          </div>
        </section>

        <section className="form-panel">
          <h2 className="form-title">Connect To IRIS</h2>
          <p className="form-copy">
            The MVP uses Basic authentication and reuses the same credentials for all later API requests.
          </p>

          <form className="form" onSubmit={handleSubmit}>
            <div className="field">
              <label htmlFor="serverUrl">Server URL</label>
              <input
                id="serverUrl"
                name="serverUrl"
                placeholder="http://localhost:52774"
                value={serverUrl}
                onChange={(event) => setServerUrl(event.target.value)}
              />
            </div>

            <div className="field">
              <label htmlFor="username">Username</label>
              <input
                id="username"
                name="username"
                autoComplete="username"
                value={username}
                onChange={(event) => setUsername(event.target.value)}
              />
            </div>

            <div className="field">
              <label htmlFor="password">Password</label>
              <input
                id="password"
                name="password"
                type="password"
                autoComplete="current-password"
                value={password}
                onChange={(event) => setPassword(event.target.value)}
              />
            </div>

            {errorMessage ? <p className="error-text">{errorMessage}</p> : null}
            {successMessage ? <p className="success-text">{successMessage}</p> : null}

            <div className="button-row">
              <button className="button button-primary" type="submit" disabled={isSubmitting}>
                {isSubmitting ? "Connecting..." : "Connect"}
              </button>
            </div>
          </form>
        </section>
      </div>
    </div>
  );
}
