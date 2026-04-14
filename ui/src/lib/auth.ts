export type AuthSession = {
  serverUrl: string;
  username: string;
  password: string;
};

const STORAGE_KEY = "iris-terminology-auth";

export function normalizeServerUrl(serverUrl: string): string {
  return serverUrl.trim().replace(/\/+$/, "");
}

export function getBasicAuthHeaderValue(session: AuthSession): string {
  return `Basic ${btoa(`${session.username}:${session.password}`)}`;
}

export function saveSession(session: AuthSession): void {
  sessionStorage.setItem(STORAGE_KEY, JSON.stringify(session));
}

export function loadSession(): AuthSession | null {
  const raw = sessionStorage.getItem(STORAGE_KEY);

  if (!raw) {
    return null;
  }

  try {
    return JSON.parse(raw) as AuthSession;
  } catch {
    sessionStorage.removeItem(STORAGE_KEY);
    return null;
  }
}

export function clearSession(): void {
  sessionStorage.removeItem(STORAGE_KEY);
}

export async function verifyCredentials(session: AuthSession): Promise<void> {
  const response = await fetch(`${normalizeServerUrl(session.serverUrl)}/terminology/auth/login`, {
    method: "GET",
    headers: {
      Accept: "application/json",
      Authorization: getBasicAuthHeaderValue(session)
    }
  });

  if (!response.ok) {
    throw new Error(`Login failed with status ${response.status}.`);
  }
}
