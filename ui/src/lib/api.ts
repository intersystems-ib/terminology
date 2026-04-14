import { getBasicAuthHeaderValue, normalizeServerUrl, type AuthSession } from "./auth";

export type RequestRecord = {
  method: "GET";
  url: string;
  status: number;
  requestHeaders: Record<string, string>;
  responseBody: unknown;
};

export async function authenticatedJsonRequest(
  session: AuthSession,
  path: string,
  accept: string
): Promise<RequestRecord> {
  const url = `${normalizeServerUrl(session.serverUrl)}${path}`;
  const requestHeaders = {
    Accept: accept,
    Authorization: getBasicAuthHeaderValue(session)
  };

  const response = await fetch(url, {
    method: "GET",
    headers: requestHeaders
  });

  const responseText = await response.text();
  let responseBody: unknown = responseText;

  if (responseText !== "") {
    try {
      responseBody = JSON.parse(responseText) as unknown;
    } catch {
      responseBody = responseText;
    }
  }

  if (!response.ok) {
    const message =
      typeof responseBody === "object" && responseBody !== null && "message" in responseBody
        ? String(responseBody.message)
        : `Request failed with status ${response.status}.`;

    throw Object.assign(new Error(message), {
      requestRecord: {
        method: "GET" as const,
        url,
        status: response.status,
        requestHeaders,
        responseBody
      } satisfies RequestRecord
    });
  }

  return {
    method: "GET",
    url,
    status: response.status,
    requestHeaders,
    responseBody
  };
}
