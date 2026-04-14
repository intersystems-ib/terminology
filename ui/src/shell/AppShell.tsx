import { Outlet, useNavigate } from "react-router-dom";
import { useAuth } from "../state/AuthContext";

export function AppShell() {
  const navigate = useNavigate();
  const { session, logout } = useAuth();

  return (
    <div className="app-shell">
      <div className="page">
        <header className="shell-header">
          <div className="shell-brand">
            <p className="eyebrow">InterSystems IRIS</p>
            <h1>Terminology Explorer</h1>
            <p>Demo UI for native and FHIR terminology APIs.</p>
          </div>
          <div className="shell-actions">
            <p className="shell-meta">
              {session?.username} on {session?.serverUrl}
            </p>
            <button
              className="button button-secondary"
              type="button"
              onClick={() => {
                logout();
                navigate("/login", { replace: true });
              }}
            >
              Log Out
            </button>
          </div>
        </header>
        <Outlet />
      </div>
    </div>
  );
}
